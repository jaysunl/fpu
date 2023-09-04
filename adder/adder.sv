module adder (
  input logic clk,                // Clock signal
  input logic rst,                // Reset signal
  input logic [31:0] input_a,     // Input A (32-bit)
  input logic input_a_stb,        // Input A valid signal
  output logic input_a_ack,       // Input A acknowledgment signal
  input logic [31:0] input_b,     // Input B (32-bit)
  input logic input_b_stb,        // Input B valid signal
  output logic input_b_ack,       // Input B acknowledgment signal
  output logic [31:0] output_z,   // Output Z (32-bit)
  output logic output_z_stb,      // Output Z valid signal
  input logic output_z_ack        // Output Z acknowledgment signal
);
    // Internal registers
    reg [31:0] a, b, z;
    reg [26:0] a_m, b_m, z_m;
    reg [8:0] a_e, b_e, z_e;
    reg a_s, b_s, z_s;
    reg guard, round_bit, sticky;
    reg [27:0] sum;
    
    // State machine states
    localparam  GET_A = 4'd0,
                GET_B = 4'd1,
                UNPACK = 4'd2,
                ALIGN = 4'd3,
                ADD = 4'd4,
                NORMALIZE = 4'd5,
                ROUND = 4'd6,
                PACK = 4'd7,
                PUT_Z = 4'd8;
                
    reg [3:0] state;
    
    // Register for acknowledging input A
    reg s_input_a_ack;
    
    // Register for acknowledging input B
    reg s_input_b_ack;
    
    // Registers for the output value and acknowledgment
    reg s_output_z_stb;
    reg [31:0] s_output_z;

    // State machine logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the state machine and acknowledgments
            state <= GET_A;
            s_input_a_ack <= 0;
            s_input_b_ack <= 0;
            s_output_z_stb <= 0;
        end else begin
            // Update state machine based on the current state
            case (state)
                GET_A: begin
                    s_input_a_ack <= input_a_stb;
                    if (s_input_a_ack) begin
                        a <= input_a;
                        state <= GET_B;
                    end
                end
                GET_B: begin
                    s_input_b_ack <= input_b_stb;
                    if (s_input_b_ack) begin
                        b <= input_b;
                        state <= UNPACK;
                    end
                end
                UNPACK: begin
                    // Unpacking logic (exponent and mantissa extraction)
                    a_m = a[22:0];
                    b_m = b[22:0];
                    a_e = a[30:23] - 127;
                    b_e = b[30:23] - 127;
                    a_s = a[31];
                    b_s = b[31];
                    state <= ALIGN;
                end
                ALIGN: begin
                    // Aligning exponents and shifting mantissas
                    if (a_e > b_e) begin
                        b_e = a_e;
                        b_m = {1'b1, b_m};
                    end else if (a_e < b_e) begin
                        a_e = b_e;
                        a_m = {1'b1, a_m};
                    end
                    state <= ADD;
                end
                ADD: begin
                    // Addition of mantissas
                    if (a_s == b_s) begin
                        // Same sign, perform addition
                        {sum, guard, round_bit, sticky} = a_m + b_m;
                        z_s = a_s;
                    end else begin
                        // Different signs, perform subtraction
                        if (a_m >= b_m) begin
                            {sum, guard, round_bit, sticky} = a_m - b_m;
                            z_s = a_s;
                        end else begin
                            {sum, guard, round_bit, sticky} = b_m - a_m;
                            z_s = b_s;
                        end
                    end
                    state <= NORMALIZE;
                end
                NORMALIZE: begin
                    // Normalize the result
                    if (sum[27]) begin
                        z_m = sum[27:4];
                        guard = sum[3];
                        round_bit = sum[2];
                        sticky = sum[1] | sum[0];
                        z_e = a_e + 1; // Increase exponent due to carry
                    end else begin
                        z_m = sum[26:3];
                        guard = sum[2];
                        round_bit = sum[1];
                        sticky = sum[0];
                        z_e = a_e; // Exponent remains the same
                    end
                    state <= ROUND;
                end
                ROUND: begin
                    // Round the result
                    if (guard && (round_bit | sticky | z_m[0])) begin
                        z_m = z_m + 1;
                        if (z_m == 24'hffffff) begin
                            z_e = z_e + 1; // Overflow, adjust exponent
                        end
                    end
                    state <= PACK;
                end
                PACK: begin
                    // Packing the result
                    s_output_z_stb = 1;
                    s_output_z = {z_s, z_e + 127, z_m[22:0]};
                    if (z_e == -126 && z_m == 24'h000000) begin
                        // Special case: -a + a = +0
                        s_output_z[31] = 0;
                    end else if (z_e > 127) begin
                        // Overflow, return infinity
                        s_output_z = {z_s, 8'hFF, 23'h000000};
                    end
                    state <= PUT_Z;
                end
                PUT_Z: begin
                    if (output_z_ack) begin
                        s_output_z_stb = 0;
                        state <= GET_A; // Return to the initial state
                    end
                end
            endcase
        end
    end
  
    // Output assignments
    assign input_a_ack = s_input_a_ack;
    assign input_b_ack = s_input_b_ack;
    assign output_z_stb = s_output_z_stb;
    assign output_z = s_output_z;
endmodule