module sqrt_tb;

    reg clk;
    reg rst;
    reg [31:0] input_a;
    reg input_a_stb;
    wire input_a_ack;
    wire [31:0] output_z;
    wire output_z_stb;
    reg output_z_ack;
  
    // Randomization constraints
    rand bit [31:0] test_a;
    constraint c1 { test_a >= -32'h7F800000 && test_a < 32'h7F800000; } // Allow finite values (both positive and negative)
    constraint c2 { test_a != 32'h7F800000; } // Exclude NaN values for test_a
  
    // Instantiate the sqrt module
    sqrt uut (
      .clk(clk),
      .rst(rst),
      .input_a(input_a),
      .input_a_stb(input_a_stb),
      .input_a_ack(input_a_ack),
      .output_z(output_z),
      .output_z_stb(output_z_stb),
      .output_z_ack(output_z_ack)
    );
  
    // Function to run constrained random test cases
    function void run_constrained_random_test(int num_tests);
        int i;
        for (i = 0; i < num_tests; i++) begin
            // Randomize input_a within constraints
            void'(randomize(test_a) with { c1; c2; });
    
            // Set input signals
            input_a = test_a;
            input_a_stb = 1;
    
            // Wait for the output to be ready
            wait(output_z_stb);
    
            // Calculate expected result
            bit [31:0] expected_result;
    
            // Regular square root calculation
            expected_result = $sqrt(test_a);
    
            // Special case: Square root of zero
            if (test_a == 32'h00000000) begin
                expected_result = 32'h00000000;
            end
    
            // Special case: NaN
            if (test_a == 32'h7F800000) begin
                expected_result = 32'h7F800000; // NaN
            end
    
            // Special case: Negative zero
            if (test_a == 32'h80000000) begin
                expected_result = 32'h80000000; // -0
            end
    
            // Check the result
            if (output_z !== expected_result) begin
                $display("Test case %0d failed: Expected output_z = 0x%h, Actual output_z = 0x%x", i, expected_result, output_z);
            end else begin
                $display("Test case %0d passed", i);
            end
    
            // Clear input signals
            input_a_stb = 0;
            output_z_ack = 1;
            #5 output_z_ack = 0;
        end
    endfunction
  
    // Initialize signals
    clk = 0;
    rst = 0;
    input_a = 32'h00000000;
    input_a_stb = 0;
    output_z_ack = 1;
  
    // Reset the DUT
    rst = 1;
    #10 rst = 0;
  
    // Run constrained random test cases
    run_constrained_random_test(20); // Run 20 random test cases
  
    // Finish the simulation
    $finish;
endmodule
  