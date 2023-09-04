module sqrt (
    input logic clk,                // Clock signal
    input logic rst,                // Reset signal
    input logic [31:0] input_a,     // Input A (32-bit)
    input logic input_a_stb,        // Input A valid signal
    output logic input_a_ack,       // Input A acknowledgment signal
    output logic [31:0] output_z,   // Output Z (32-bit)
    output logic output_z_stb,      // Output Z valid signal
    input logic output_z_ack        // Output Z acknowledgment signal
  );
  
    // Internal registers and signals
    reg [31:0] a, z;
    reg [23:0] a_m, z_m;
    reg [7:0] a_e, z_e;
    reg a_s, z_s;
    reg [2:0] state;
    reg [24:0] x_n, x_n_plus_1; // Variables for Newton-Raphson method
    reg [1:0] iteration; // Iteration counter
  
    // State machine states
    localparam  GET_A = 3'd0,
                UNPACK = 3'd1,
                APPROXIMATION = 3'd2,
                ROUND = 3'd3,
                PACK = 3'd4,
                PUT_Z = 3'd5;
  
    // State machine logic
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset the state machine and acknowledgments
            state <= GET_A;
            input_a_ack <= 0;
            output_z_stb <= 0;
            iteration <= 0;
        end else begin
            // Update state machine based on the current state
            case (state)
                GET_A: begin
                    input_a_ack <= input_a_stb;
                    if (input_a_ack) begin
                        a <= input_a;
                        state <= UNPACK;
                    end
                end
        
                UNPACK: begin
                    // Unpacking logic (exponent and mantissa extraction)
                    a_m = {1'b1, a[22:0]}; // Include the implicit leading '1'
                    a_e = a[30:23];
                    a_s = a[31];
                    state <= APPROXIMATION;
                end
        
                APPROXIMATION: begin
                    // Square root approximation using Newton-Raphson method
                    x_n = {a_e[0], a_m[23:0], 6'b000000}; // Initial guess
                    repeat (4) begin // Four iterations for good accuracy
                        x_n_plus_1 = x_n - ((x_n * x_n - a_m) / (2 * x_n)); // Newton-Raphson update
                        x_n = x_n_plus_1;
                    end
        
                    // Final result
                    z_m = x_n[23:0];
                    z_e = (a_e + 127) >> 1;
                    z_s = a_s;
                    state <= ROUND;
                end
        
                ROUND: begin
                    // Rounding logic (round-to-nearest-even)
                    logic [24:0] rounding_mask;
                    rounding_mask = 25'b0_1000_0000_0000_0000_0000_0000_0;
                    if ((z_m & rounding_mask) != 25'b0) begin
                        z_m = z_m + 1;
                    end
                    state <= PACK;
                end
        
                PACK: begin
                    // Packing the result
                    output_z_stb = 1;
                    output_z = {z_s, z_e, z_m};
                    state <= PUT_Z;
                end
        
                PUT_Z: begin
                    if (output_z_ack) begin
                        output_z_stb = 0;
                        state <= GET_A; // Return to the initial state
                    end
                end
            endcase
        end
    end
  
    assign input_a_ack = input_a_stb;
endmodule
  