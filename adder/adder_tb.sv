module adder_tb;

    reg clk;
    reg rst;
    reg [31:0] input_a;
    reg input_a_stb;
    wire input_a_ack;
    reg [31:0] input_b;
    reg input_b_stb;
    wire input_b_ack;
    wire [31:0] output_z;
    wire output_z_stb;
    reg output_z_ack;
  
    // Instantiate the adder module
    adder uut (
      .clk(clk),
      .rst(rst),
      .input_a(input_a),
      .input_a_stb(input_a_stb),
      .input_a_ack(input_a_ack),
      .input_b(input_b),
      .input_b_stb(input_b_stb),
      .input_b_ack(input_b_ack),
      .output_z(output_z),
      .output_z_stb(output_z_stb),
      .output_z_ack(output_z_ack)
    );
  
    // Function to run test cases
    function run_test_cases;
        // Test Case 1: Basic addition
        input_a = 32'h40400000; // 3.0
        input_b = 32'h40800000; // 4.0
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result
        if (output_z !== 32'h40A00000) begin
            $display("Test case 1 failed: Expected output_z = 0x40A00000, Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 1 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 2: Addition of Positive Numbers
        input_a = $urandom_range(32'h00000001, 32'h7F7FFFFF); // Random positive number
        input_b = $urandom_range(32'h00000001, 32'h7F7FFFFF); // Random positive number
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Calculate the expected result
        real expected_result;
        expected_result = $bitstoreal(input_a) + $bitstoreal(input_b);
        int expected_result_bits = $realtobits(expected_result);
    
        // Check the result
        if (output_z !== expected_result_bits) begin
            $display("Test case 2 failed: Expected output_z = 0x%x, Actual output_z = 0x%x", expected_result_bits, output_z);
        end else begin
            $display("Test case 2 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 3: Addition of Negative Numbers
        input_a = $urandom_range(32'h80000001, 32'hFF7FFFFF); // Random negative number
        input_b = $urandom_range(32'h80000001, 32'hFF7FFFFF); // Random negative number
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Calculate the expected result
        real expected_result;
        expected_result = $bitstoreal(input_a) + $bitstoreal(input_b);
        int expected_result_bits = $realtobits(expected_result);
    
        // Check the result
        if (output_z !== expected_result_bits) begin
            $display("Test case 3 failed: Expected output_z = 0x%x, Actual output_z = 0x%x", expected_result_bits, output_z);
        end else begin
            $display("Test case 3 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 4: Addition of Zero
        input_a = 32'h00000000; // 0.0
        input_b = 32'h00000000; // 0.0
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result
        if (output_z !== 32'h00000000) begin
            $display("Test case 4 failed: Expected output_z = 0x00000000, Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 4 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 5: Addition of +0 and -0
        input_a = 32'h00000000; // +0.0
        input_b = 32'h80000000; // -0.0
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result
        if (output_z !== 32'h00000000) begin
            $display("Test case 5 failed: Expected output_z = 0x00000000, Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 5 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 6: Addition of Two Large Positive Numbers
        input_a = 32'h7F7FFFFF; // Largest positive finite number
        input_b = 32'h7F7FFFFF; // Largest positive finite number
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result (Overflow)
        if (output_z !== 32'h7F800000) begin
            $display("Test case 6 failed: Expected output_z = 0x7F800000 (+Infinity), Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 6 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 7: Addition of Two Large Negative Numbers
        input_a = 32'hFF7FFFFF; // Largest negative finite number
        input_b = 32'hFF7FFFFF; // Largest negative finite number
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result (Overflow)
        if (output_z !== 32'hFF800000) begin
            $display("Test case 7 failed: Expected output_z = 0xFF800000 (-Infinity), Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 7 passed");
        end
    
        // Clear input signals
        input_a_stb = 0;
        input_b_stb = 0;
        output_z_ack = 1;
        #5 output_z_ack = 0;
    
        // Test Case 8: Addition of Infinity and Finite Number
        input_a = 32'h7F800000; // +Infinity
        input_b = 32'h3F800000; // 1.0 (finite)
        input_a_stb = 1;
        input_b_stb = 1;
    
        // Wait for the output to be ready
        wait(output_z_stb);
    
        // Check the result (Infinity)
        if (output_z !== 32'h7F800000) begin
            $display("Test case 8 failed: Expected output_z = 0x7F800000 (+Infinity), Actual output_z = 0x%x", output_z);
        end else begin
            $display("Test case 8 passed");
        end
    endfunction
  
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        input_a = 32'h00000000;
        input_a_stb = 0;
        input_b = 32'h00000000;
        input_b_stb = 0;
        output_z_ack = 1;
    
        // Reset the DUT
        rst = 1;
        #10 rst = 0;
    
        // Apply test cases
        run_test_cases;
    
        // Finish the simulation
        $finish;
    end
  
    always begin
        #5 clk = ~clk;
    end
  
endmodule
  