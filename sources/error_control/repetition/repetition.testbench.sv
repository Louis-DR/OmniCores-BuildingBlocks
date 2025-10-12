// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition.testbench.sv                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the repetition error control modules.          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module repetition__testbench ();

// Devices parameters
localparam int DATA_WIDTH = 8;
localparam int REPETITION = 3;

// Devices constants
localparam int DATA_WIDTH_POW2 = 2 ** DATA_WIDTH;
localparam int CODE_WIDTH      = (REPETITION-1) * DATA_WIDTH;
localparam int BLOCK_WIDTH     = CODE_WIDTH + DATA_WIDTH;

// Device ports
logic  [DATA_WIDTH-1:0] encoder_data;
logic  [CODE_WIDTH-1:0] encoder_code;
logic [BLOCK_WIDTH-1:0] encoder_block;

logic  [DATA_WIDTH-1:0] checker_data;
logic  [CODE_WIDTH-1:0] checker_code;
logic                   checker_error;

logic  [DATA_WIDTH-1:0] corrector_data;
logic  [CODE_WIDTH-1:0] corrector_code;
logic                   corrector_error;
logic  [DATA_WIDTH-1:0] corrector_corrected_data;

logic [BLOCK_WIDTH-1:0] block_checker_block;
logic                   block_checker_error;

logic [BLOCK_WIDTH-1:0] block_corrector_block;
logic                   block_corrector_error;
logic  [DATA_WIDTH-1:0] block_corrector_corrected_data;

// Test signals
logic  [CODE_WIDTH-1:0] expected_code;
logic [BLOCK_WIDTH-1:0] expected_block;
logic  [DATA_WIDTH-1:0] test_data;
logic  [CODE_WIDTH-1:0] test_code;
logic [BLOCK_WIDTH-1:0] test_block;

// Devices under test
repetition_encoder #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) repetition_encoder_dut (
  .data  ( encoder_data  ),
  .code  ( encoder_code  ),
  .block ( encoder_block )
);

repetition_checker #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) repetition_checker_dut (
  .data  ( checker_data  ),
  .code  ( checker_code  ),
  .error ( checker_error )
);

repetition_corrector #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) repetition_corrector_dut (
  .data           ( corrector_data           ),
  .code           ( corrector_code           ),
  .error          ( corrector_error          ),
  .corrected_data ( corrector_corrected_data )
);

repetition_block_checker #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) repetition_block_checker_dut (
  .block ( block_checker_block ),
  .error ( block_checker_error )
);

repetition_block_corrector #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) repetition_block_corrector_dut (
  .block          ( block_corrector_block          ),
  .error          ( block_corrector_error          ),
  .corrected_data ( block_corrector_corrected_data )
);

// Main block
initial begin
  // Log waves
  $dumpfile("repetition.testbench.vcd");
  $dumpvars(0, repetition__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  encoder_data = 0;
  checker_data = 0;
  checker_code = 0;
  corrector_data = 0;
  corrector_code = 0;
  block_checker_block = 0;
  block_corrector_block = 0;

  // Small delay after initialization
  #1;

  // Check 1: Repetition encoder exhaustive test
  $display("CHECK 1: Repetition encoder exhaustive test.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    encoder_data = data_configuration;

    // Calculate expected repetition code
    expected_code  = {CODE_WIDTH{encoder_data}};
    expected_block = {expected_code, encoder_data};

    // Wait for combinational logic propagation
    #1;

    // Check encoder outputs
    assert (encoder_code === expected_code)
      else $error("[%t] Incorrect encoder code for data %b. Expected %b, got %b.",
                  $time, data_configuration, expected_code, encoder_code);
    assert (encoder_block === expected_block)
      else $error("[%t] Incorrect encoder block for data %b. Expected %b, got %b.",
                  $time, data_configuration, expected_block, encoder_block);

    // Small delay before next configuration
    #1;
  end

  // Check 2: Repetition checker with correct repetition
  $display("CHECK 2: Repetition checker with correct repetition.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data = data_configuration;
    test_code = {CODE_WIDTH{test_data}};

    checker_data = test_data;
    checker_code = test_code;

    // Wait for combinational logic propagation
    #1;

    // Should not detect any error with correct repetition
    assert (!checker_error)
      else $error("[%t] False error detected for correct repetition. Data: %b, Code: %b",
                  $time, test_data, test_code);

    // Small delay before next configuration
    #1;
  end

  // Check 3: Repetition checker with incorrect repetition
  $display("CHECK 3: Repetition checker with incorrect repetition.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data = data_configuration;
    test_code = {CODE_WIDTH{~test_data}}; // Incorrect repetition

    checker_data = test_data;
    checker_code = test_code;

    // Wait for combinational logic propagation
    #1;

    // Should detect error with incorrect repetition
    assert (checker_error)
      else $error("[%t] Failed to detect error for incorrect repetition. Data: %b, Code: %b",
                  $time, test_data, test_code);

    // Small delay before next configuration
    #1;
  end

  // Check 4: Block checker with correct repetition blocks
  $display("CHECK 4: Block checker with correct repetition blocks.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data  = data_configuration;
    test_code  = {CODE_WIDTH{test_data}};
    test_block = {test_code, test_data};

    block_checker_block = test_block;

    // Wait for combinational logic propagation
    #1;

    // Should not detect any error with correct repetition block
    assert (!block_checker_error)
      else $error("[%t] False error detected for correct repetition block. Block: %b",
                  $time, test_block);

    // Small delay before next configuration
    #1;
  end

  // Check 5: Block checker with incorrect repetition blocks
  $display("CHECK 5: Block checker with incorrect repetition blocks.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data  = data_configuration;
    test_code  = {CODE_WIDTH{~test_data}}; // Incorrect repetition
    test_block = {test_code, test_data};

    block_checker_block = test_block;

    // Wait for combinational logic propagation
    #1;

    // Should detect error with incorrect repetition block
    assert (block_checker_error)
      else $error("[%t] Failed to detect error for incorrect repetition block. Block: %b",
                  $time, test_block);

    // Small delay before next configuration
    #1;
  end

  // Check 6: Complete encode-decode cycle
  $display("CHECK 6: Complete encode-decode cycle.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    // Step 1: Encode the data
    encoder_data = data_configuration;
    #1;

    // Step 2: Use the encoded block with the block checker
    block_checker_block = encoder_block;
    #1;

    // Should not detect any error in the complete cycle
    assert (!block_checker_error)
      else $error("[%t] Error detected in complete encode-decode cycle for data %b.",
                  $time, data_configuration);

    // Step 3: Use the individual code and data with the checker
    checker_data = encoder_data;
    checker_code = encoder_code;
    #1;

    // Should not detect any error in the complete cycle
    assert (!checker_error)
      else $error("[%t] Error detected in complete encode-check cycle for data %b.",
                  $time, data_configuration);

    // Small delay before next configuration
    #1;
  end

  // Check 7: Single bit error detection and correction
  $display("CHECK 7: Single bit error detection and correction.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    // Encode the original data
    encoder_data = data_configuration;
    #1;

    // Introduce single bit errors in each position of the block
    for (int error_position = 0; error_position < BLOCK_WIDTH; error_position++) begin
      // Create corrupted block with single bit error
      test_block = encoder_block ^ (1 << error_position);

      // Test with block checker
      block_checker_block = test_block;
      #1;

      // Should detect the single bit error
      assert (block_checker_error)
        else $error("[%t] Failed to detect single bit error at position %0d for data %b.",
                    $time, error_position, data_configuration);

      // Test with block corrector
      block_corrector_block = test_block;
      #1;

      // Should detect the error and correct the data
      assert (block_corrector_error)
        else $error("[%t] Failed to detect single bit error at position %0d for data %b.",
                    $time, error_position, data_configuration);
      assert (block_corrector_corrected_data === encoder_data)
        else $error("[%t] Failed to correct single bit error at position %0d for data %b. Expected %b, got %b.",
                    $time, error_position, data_configuration, encoder_data, block_corrector_corrected_data);

      // Small delay before next error position
      #1;
    end

    // Small delay before next data configuration
    #1;
  end

  // Check 8: Corrector with correct data
  $display("CHECK 8: Corrector with correct data.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    test_data = data_configuration;
    test_code = {CODE_WIDTH{test_data}};

    corrector_data = test_data;
    corrector_code = test_code;

    // Wait for combinational logic propagation
    #1;

    // Should not detect any error and output the original data
    assert (!corrector_error)
      else $error("[%t] False error detected for correct repetition. Data: %b, Code: %b",
                  $time, test_data, test_code);
    assert (corrector_corrected_data === test_data)
      else $error("[%t] Incorrect corrected data for correct repetition. Data: %b, Expected: %b, Got: %b",
                  $time, test_data, test_data, corrector_corrected_data);

    // Small delay before next configuration
    #1;
  end

  // Check 9: Corrector with single bit errors
  $display("CHECK 9: Corrector with single bit errors.");
  for (int data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
    // Encode the original data
    encoder_data = data_configuration;
    #1;

    // Test single bit errors in the data part only (correctable)
    for (int error_position = 0; error_position < DATA_WIDTH; error_position++) begin
      // Create corrupted data with single bit error
      corrector_data = encoder_data ^ (1 << error_position);
      corrector_code = encoder_code;
      #1;

      // Should detect error and correct the data
      assert (corrector_error)
        else $error("[%t] Failed to detect single bit data error at position %0d for data %b.",
                    $time, error_position, data_configuration);
      assert (corrector_corrected_data === encoder_data)
        else $error("[%t] Failed to correct single bit data error at position %0d for data %b. Expected %b, got %b.",
                    $time, error_position, data_configuration, encoder_data, corrector_corrected_data);

      // Small delay before next error position
      #1;
    end

    // Small delay before next data configuration
    #1;
  end

  // Check 10: Double bit error detection (uncorrectable)
  $display("CHECK 10: Double bit error detection (uncorrectable).");
  for (int data_configuration = 0; data_configuration < 16; data_configuration++) begin
    // Encode the original data
    encoder_data = data_configuration;
    #1;

    // Create double bit error in different repetitions
    test_block             = encoder_block;
    test_block[0]          = ~test_block[0];           // Error in first copy
    test_block[DATA_WIDTH] = ~test_block[DATA_WIDTH];  // Error in second copy

    // Test with block checker
    block_checker_block = test_block;
    #1;

    // Should detect the error
    assert (block_checker_error)
      else $error("[%t] Failed to detect double bit error for data %b.",
                  $time, data_configuration);

    // Test with block corrector - may not correct properly with double errors
    block_corrector_block = test_block;
    #1;

    // Should detect the error
    assert (block_corrector_error)
      else $error("[%t] Failed to detect double bit error for data %b.",
                  $time, data_configuration);

    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule