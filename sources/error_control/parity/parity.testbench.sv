// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        parity.testbench.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the parity error control modules.              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module parity__testbench ();

// Devices parameters
localparam DATA_WIDTH = 8;

// Devices constants
localparam DATA_WIDTH_POW2 = 2 ** DATA_WIDTH;

// Devices ports
logic [DATA_WIDTH-1:0] encoder_data;
logic                  encoder_code;
logic   [DATA_WIDTH:0] encoder_block;
logic [DATA_WIDTH-1:0] checker_data;
logic                  checker_code;
logic                  checker_error;
logic   [DATA_WIDTH:0] block_checker_block;
logic                  block_checker_error;

// Test signals
logic                  expected_code;
logic                  expected_error;
logic [DATA_WIDTH:0]   expected_block;
logic [DATA_WIDTH-1:0] test_data;
logic                  test_code;
logic [DATA_WIDTH:0]   test_block;

// Devices under test
parity_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) parity_encoder_dut (
  .data  ( encoder_data  ),
  .code  ( encoder_code  ),
  .block ( encoder_block )
);

parity_checker #(
  .DATA_WIDTH ( DATA_WIDTH )
) parity_checker_dut (
  .data  ( checker_data  ),
  .code  ( checker_code  ),
  .error ( checker_error )
);

parity_block_checker #(
  .DATA_WIDTH ( DATA_WIDTH )
) parity_block_checker_dut (
  .block ( block_checker_block ),
  .error ( block_checker_error )
);

// Main block
initial begin
  // Log waves
  $dumpfile("parity.testbench.vcd");
  $dumpvars(0, parity__testbench);

  // Initialization
  encoder_data        = 0;
  checker_data        = 0;
  checker_code        = 0;
  block_checker_block = 0;

  // Small delay after initialization
  #1;

  // Check 1: Parity encoder exhaustive test
  $display("CHECK 1: Parity encoder exhaustive test.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    encoder_data = data_configuration;

    // Calculate expected parity code
    expected_code  = ^encoder_data;
    expected_block = {expected_code, encoder_data};

    // Wait for combinatorial logic propagation
    #1;

    // Check encoder outputs
    assert (encoder_code === expected_code)
      else $error("[%0tns] Incorrect encoder code for data %b. Expected %b, got %b.", $time, data_configuration, expected_code, encoder_code);
    assert (encoder_block === expected_block)
      else $error("[%0tns] Incorrect encoder block for data %b. Expected %b, got %b.", $time, data_configuration, expected_block, encoder_block);

    // Small delay before next configuration
    #1;
  end

  // Check 2: Parity checker with correct parity
  $display("CHECK 2: Parity checker with correct parity.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data = data_configuration;
    test_code = ^test_data;

    checker_data = test_data;
    checker_code = test_code;

    // Wait for combinatorial logic propagation
    #1;

    // Should not detect any error with correct parity
    assert (checker_error === 1'b0)
      else $error("[%0tns] False error detected for correct parity. Data: %b, Code: %b", $time, test_data, test_code);

    // Small delay before next configuration
    #1;
  end

  // Check 3: Parity checker with incorrect parity
  $display("CHECK 3: Parity checker with incorrect parity.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data = data_configuration;
    test_code = ~(^test_data);

    checker_data = test_data;
    checker_code = test_code;

    // Wait for combinatorial logic propagation
    #1;

    // Should detect error with incorrect parity
    assert (checker_error === 1'b1)
      else $error("[%0tns] Failed to detect error for incorrect parity. Data: %b, Code: %b", $time, test_data, test_code);

    // Small delay before next configuration
    #1;
  end

  // Check 4: Block checker with correct parity blocks
  $display("CHECK 4: Block checker with correct parity blocks.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data  = data_configuration;
    test_code  = ^test_data;
    test_block = {test_code, test_data};

    block_checker_block = test_block;

    // Wait for combinatorial logic propagation
    #1;

    // Should not detect any error with correct parity block
    assert (block_checker_error === 1'b0)
      else $error("[%0tns] False error detected for correct parity block. Block: %b", $time, test_block);

    // Small delay before next configuration
    #1;
  end

  // Check 5: Block checker with incorrect parity blocks
  $display("CHECK 5: Block checker with incorrect parity blocks.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data  = data_configuration;
    test_code  = ~(^test_data);
    test_block = {test_code, test_data};

    block_checker_block = test_block;

    // Wait for combinatorial logic propagation
    #1;

    // Should detect error with incorrect parity block
    assert (block_checker_error === 1'b1)
      else $error("[%0tns] Failed to detect error for incorrect parity block. Block: %b", $time, test_block);

    // Small delay before next configuration
    #1;
  end

  // Check 6: Complete encode-decode cycle
  $display("CHECK 6: Complete encode-decode cycle.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    // Encode the data
    encoder_data = data_configuration;
    #1;

    // Feed the encoded block to the block checker
    block_checker_block = encoder_block;
    #1;

    // Should not detect any error in the complete cycle
    assert (block_checker_error === 1'b0)
      else $error("[%0tns] Error detected in complete encode-decode cycle for data %b.", $time, data_configuration);

    // Feed the code and data to the checker
    checker_data = encoder_data;
    checker_code = encoder_code;
    #1;

    // Should not detect any error in the complete cycle
    assert (checker_error === 1'b0)
      else $error("[%0tns] Error detected in complete encode-check cycle for data %b.", $time, data_configuration);

    // Small delay before next configuration
    #1;
  end

  // Check 7: Single bit error detection
  $display("CHECK 7: Single bit error detection.");
  for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    // Encode the original data
    encoder_data = data_configuration;
    #1;

    // Introduce single bit errors in each position of the block
    for (integer error_position = 0; error_position <= DATA_WIDTH; error_position++) begin
      // Create corrupted block with single bit error
      test_block = encoder_block ^ (1 << error_position);

      // Test with block checker
      block_checker_block = test_block;
      #1;

      // Should detect the single bit error
      assert (block_checker_error === 1'b1)
        else $error("[%0tns] Failed to detect single bit error at position %0d for data %b.", $time, error_position, data_configuration);

      // Test with normal checker
      if (error_position < DATA_WIDTH) begin
        checker_data = test_block[DATA_WIDTH-1:0];
        checker_code = test_block[DATA_WIDTH];
        #1;

        assert (checker_error === 1'b1)
          else $error("[%0tns] Failed to detect single bit data error at position %0d for data %b.", $time, error_position, data_configuration);
      end

      // Small delay before next error position
      #1;
    end

    // Small delay before next data configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule