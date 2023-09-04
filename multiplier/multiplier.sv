module multiplier (
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
    reg [23:0] a_m, b_m, z_m;
    reg [7:0] a_e, b_e, z_e;
    reg a_s, b_s, z_s;
    reg guard, round_bit, sticky;
    reg [47:0] product;
    
    // State machine states
    localparam  GET_A = 3'd0,
                GET_B = 3'd1,
                UNPACK = 3'd2,
                MULTIPLY = 3'd3,
                NORMALIZE = 3'd4,
                ROUND = 3'd5,
                PACK = 3'd6,
                PUT_Z = 3'd7;
              
    reg [2:0] state;
    
    // Register for acknowledging input A
    reg s_input_a_ack;
    
    // Register for acknowledging input B
    reg s_input_b_ack;
    
    // Registers for the output value and acknowledgment
    reg s_output_z_stb;
    reg [31:0] s_output_z;
    
    // State machine logic
    always_ff @(posedge clk) begin
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
                    a_m = {1'b1, a[22:0]};
                    b_m = {1'b1, b[22:0]};
                    a_e = a[30:23];
                    b_e = b[30:23];
                    a_s = a[31];
                    b_s = b[31];
                    state <= MULTIPLY;
                end
                MULTIPLY: begin
                    // Multiply mantissas and adjust exponents
                    {product, guard} = a_m * b_m;
                    z_e = a_e + b_e - 127;
                    z_s = a_s ^ b_s; // Result sign
                    state <= NORMALIZE;
                end
                NORMALIZE: begin
                    // Normalize the result
                    if (product[47]) begin
                        // Adjust exponent and shift mantissa
                        z_e = z_e + 1;
                        z_m = product[46:24];
                        guard = product[23];
                    end else begin
                        z_m = product[45:23];
                        guard = product[22];
                    end
                    state <= ROUND;
                end
                ROUND: begin
                    // Round the result
                    round_bit = product[21];
                    sticky = |product[20:0];
                    if (guard && (round_bit | sticky)) begin
                        // Rounding required
                        z_m = z_m + 1;
                        if (z_m[23]) begin
                            // Mantissa overflow, adjust exponent
                            z_e = z_e + 1;
                            z_m = z_m >> 1;
                        end
                    end
                    state <= PACK;
                end
                PACK: begin
                    // Packing the result
                    s_output_z_stb = 1;
                    s_output_z = {z_s, z_e, z_m[22:0]};
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
  