// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming.testbench.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the extended Hamming error control modules.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "extended_hamming.svh"
`include "extended_hamming.testbench.svh"



module extended_hamming__testbench ();

// Device parameters
localparam DATA_WIDTH   = 8;
localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH(DATA_WIDTH);
localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH;

// Test parameters
localparam DATA_WIDTH_POW2         = 2**DATA_WIDTH;
localparam FULL_CHECK_MAX_DURATION = 512;  // Exhaustive up to 2^9
localparam RANDOM_CHECK_DURATION   = 1024;

// Device ports
logic   [DATA_WIDTH-1:0] encoder_data;
logic [PARITY_WIDTH-1:0] encoder_code;
logic  [BLOCK_WIDTH-1:0] encoder_block;

logic   [DATA_WIDTH-1:0] packer_data;
logic [PARITY_WIDTH-1:0] packer_code;
logic  [BLOCK_WIDTH-1:0] packer_block;

logic  [BLOCK_WIDTH-1:0] unpacker_block;
logic   [DATA_WIDTH-1:0] unpacker_data;
logic [PARITY_WIDTH-1:0] unpacker_code;

logic   [DATA_WIDTH-1:0] checker_data;
logic [PARITY_WIDTH-1:0] checker_code;
logic                    checker_error;

logic   [DATA_WIDTH-1:0] corrector_data;
logic [PARITY_WIDTH-1:0] corrector_code;
logic                    corrector_error;
logic   [DATA_WIDTH-1:0] corrector_corrected_data;

logic  [BLOCK_WIDTH-1:0] block_checker_block;
logic                    block_checker_error;

logic  [BLOCK_WIDTH-1:0] block_corrector_block;
logic                    block_corrector_error;
logic  [BLOCK_WIDTH-1:0] block_corrector_corrected_block;

// Test signals
logic   [DATA_WIDTH-1:0] test_data;
logic [PARITY_WIDTH-1:0] expected_code;
logic  [BLOCK_WIDTH-1:0] expected_block;
logic  [BLOCK_WIDTH-1:0] poisoned_block;
logic   [DATA_WIDTH-1:0] poisoned_data;
logic [PARITY_WIDTH-1:0] poisoned_code;

// Test variables
integer error_position;

// Devices under test
extended_hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) extended_hamming_encoder_dut (
  .data  ( encoder_data  ),
  .code  ( encoder_code  ),
  .block ( encoder_block )
);

extended_hamming_block_packer #(
  .DATA_WIDTH ( DATA_WIDTH )
) extended_hamming_block_packer_dut (
  .data  ( packer_data  ),
  .code  ( packer_code  ),
  .block ( packer_block )
);

extended_hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) extended_hamming_block_unpacker_dut (
  .block ( unpacker_block ),
  .data  ( unpacker_data  ),
  .code  ( unpacker_code  )
);

extended_hamming_checker #(
  .DATA_WIDTH ( DATA_WIDTH )
) extended_hamming_checker_dut (
  .data  ( checker_data  ),
  .code  ( checker_code  ),
  .error ( checker_error )
);

extended_hamming_block_checker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) extended_hamming_block_checker_dut (
  .block ( block_checker_block ),
  .error ( block_checker_error )
);

extended_hamming_corrector #(
  .DATA_WIDTH ( DATA_WIDTH )
) extended_hamming_corrector_dut (
  .data           ( corrector_data           ),
  .code           ( corrector_code           ),
  .error          ( corrector_error          ),
  .corrected_data ( corrector_corrected_data )
);

extended_hamming_block_corrector #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) extended_hamming_block_corrector_dut (
  .block           ( block_corrector_block           ),
  .error           ( block_corrector_error           ),
  .corrected_block ( block_corrector_corrected_block )
);

// Reference function for calculating Hamming code
function logic [PARITY_WIDTH-1:0] extended_hamming_code(input logic [DATA_WIDTH-1:0] data);
  case (PARITY_WIDTH)
    4: extended_hamming_code = extended_hamming_8_4(data);
    5: extended_hamming_code = extended_hamming_16_11(data);
    6: extended_hamming_code = extended_hamming_32_26(data);
    7: extended_hamming_code = extended_hamming_64_57(data);
    8: extended_hamming_code = extended_hamming_128_120(data);
    9: extended_hamming_code = extended_hamming_256_247(data);
    default: begin
      $fatal(1, "[%0tns] Unsupported parity width '%0d' for reference extended Hamming code function.", $time, PARITY_WIDTH);
      return 0;
    end
  endcase
endfunction

// Reference function for Hamming block packing
function logic [BLOCK_WIDTH-1:0] extended_hamming_block_pack(input logic [DATA_WIDTH-1:0] data, input logic [PARITY_WIDTH-1:0] code);
  logic [BLOCK_WIDTH-1:0] expected_block;
  expected_block[     0] = code[    0];
  expected_block[     1] = code[    1];
  expected_block[     2] = code[    2];
  expected_block[     3] = data[    0];
  if (PARITY_WIDTH < 4) return expected_block;
  expected_block[     4] = code[    2];
  expected_block[   7:5] = data[  3:1];
  if (PARITY_WIDTH < 5) return expected_block;
  expected_block[     8] = code[    3];
  expected_block[  15:9] = data[ 10:4];
  if (PARITY_WIDTH < 6) return expected_block;
  expected_block[    16] = code[    4];
  expected_block[ 31:17] = data[25:11];
  if (PARITY_WIDTH < 7) return expected_block;
  expected_block[    32] = code[    5];
  expected_block[ 63:33] = data[56:26];
  if (PARITY_WIDTH < 8) return expected_block;
  expected_block[    64] = code[    6];
  expected_block[127:65] = data[119:57];
  if (PARITY_WIDTH < 9) return expected_block;
  $fatal(1, "[%0tns] Unsupported parity width '%0d' for reference extended Hamming block packing function.", $time, PARITY_WIDTH);
  return 0;
endfunction

// Function to inject a single bit error in a block
function automatic logic [BLOCK_WIDTH-1:0] inject_single_bit_error(input integer error_position, input logic [BLOCK_WIDTH-1:0] original_block);
  logic [BLOCK_WIDTH-1:0] poisoned_block;
  poisoned_block = original_block ^ (1 << error_position);
  return poisoned_block;
endfunction

// Task to check the outputs of all modules for a given data without errors
task check_all_modules_no_error(input logic [DATA_WIDTH-1:0] test_data);

  // Calculate the expected Hamming code and block
  expected_code  = extended_hamming_code(test_data);
  expected_block = extended_hamming_block_pack(test_data, expected_code);

  // Check the encoder
  encoder_data = test_data;
  #1;
  assert (encoder_code === expected_code)
    else $error("[%0tns] Incorrect code from encoder for data '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, encoder_code);
  assert (encoder_block === expected_block)
    else $error("[%0tns] Incorrect block from encoder for data '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_block, encoder_block);

  // Check the packer
  packer_data = test_data;
  packer_code = expected_code;
  #1;
  assert (packer_block === expected_block)
    else $error("[%0tns] Incorrect block from packer for data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, expected_block, packer_block);

  // Check the unpacker
  unpacker_block = packer_block;
  #1;
  assert (unpacker_data === test_data)
    else $error("[%0tns] Incorrect data from unpacker for block '%b'. Expected '%b', got '%b'.",
                $time, packer_block, test_data, unpacker_data);
  assert (unpacker_code === expected_code)
    else $error("[%0tns] Incorrect code from unpacker for block '%b'. Expected '%b', got '%b'.",
                $time, packer_block, expected_code, unpacker_code);

  // Check the checker
  checker_data = test_data;
  checker_code = expected_code;
  #1;
  assert (checker_error === 1'b0)
    else $error("[%0tns] False error detected by checker for data '%b' and code '%b'.",
                $time, test_data, expected_code);

  // Check the corrector
  corrector_data = test_data;
  corrector_code = expected_code;
  #1;
  assert (corrector_error === 1'b0)
    else $error("[%0tns] False error detected by corrector for data '%b' and code '%b'.",
                $time, test_data, expected_code);
  assert (corrector_corrected_data === test_data)
    else $error("[%0tns] Incorrect corrected data by corrector for data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, test_data, corrector_corrected_data);

  // Check the block checker
  block_checker_block = expected_block;
  #1;
  assert (block_checker_error === 1'b0)
    else $error("[%0tns] False error detected by block checker for block '%b'.",
                $time, expected_block);

  // Check the block corrector
  block_corrector_block = expected_block;
  #1;
  assert (block_corrector_error === 1'b0)
    else $error("[%0tns] False error detected by block corrector for block '%b'.",
                $time, expected_block);
  assert (block_corrector_corrected_block === expected_block)
    else $error("[%0tns] Incorrect corrected block by block corrector for block '%b'. Expected '%b', got '%b'.",
                $time, expected_block, expected_block, block_corrector_corrected_block);
endtask

// Task to check the outputs of the checker and corrector modules for a given data with a single bit error
task check_checker_and_corrector_single_bit_error(input logic [DATA_WIDTH-1:0] test_data, input integer error_position);

  // Calculate the expected Hamming code and block
  expected_code  = extended_hamming_code(test_data);
  expected_block = extended_hamming_block_pack(test_data, expected_code);

  // Poison block with single bit error
  poisoned_block = inject_single_bit_error(error_position, expected_block);

  // Use the unpacker to get the data and code from the poisoned block
  unpacker_block = poisoned_block;
  #1;
  poisoned_data = unpacker_data;
  poisoned_code = unpacker_code;

  // Check the checker
  checker_data = poisoned_data;
  checker_code = poisoned_code;
  #1;
  assert (checker_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by checker for data '%b' and code '%b'.",
                $time, poisoned_data, poisoned_code);

  // Check the corrector
  corrector_data = poisoned_data;
  corrector_code = poisoned_code;
  #1;
  assert (corrector_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by corrector for poisoned data '%b' and code '%b'.",
                $time, poisoned_data, poisoned_code);
  assert (corrector_corrected_data === test_data)
    else $error("[%0tns] Single-bit error not corrected by corrector for poisoned data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, poisoned_data, poisoned_code, test_data, corrector_corrected_data);

  // Check the block checker
  block_checker_block = poisoned_block;
  #1;
  assert (block_checker_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by block checker for poisoned block '%b'.",
                $time, poisoned_block);

  // Check the block corrector
  block_corrector_block = poisoned_block;
  #1;
  assert (block_corrector_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by block corrector for poisoned block '%b'.",
                $time, poisoned_block);
  assert (block_corrector_corrected_block === expected_block)
    else $error("[%0tns] Single-bit error not corrected by block corrector for poisoned block '%b'. Expected '%b', got '%b'.",
                $time, poisoned_block, expected_block, block_corrector_corrected_block);
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("extended_hamming.testbench.vcd");
  $dumpvars(0, extended_hamming__testbench);

  // Initialization
  encoder_data          = 0;
  packer_data           = 0;
  packer_code           = 0;
  unpacker_block        = 0;
  checker_data          = 0;
  checker_code          = 0;
  corrector_data        = 0;
  corrector_code        = 0;
  block_checker_block   = 0;
  block_corrector_block = 0;

  // Small delay after initialization
  #1;

  // If the data width is small, we perform exhaustive testing
  if (DATA_WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test without error
    $display("CHECK 1: Exhaustive test without error.");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      test_data = data_configuration;
      check_all_modules_no_error(test_data);
    end

    // Check 2: Exhaustive test with single bit flip error
    $display("CHECK 2: Exhaustive test with single bit flip error.");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      test_data = data_configuration;
      for (integer error_position = 0; error_position < BLOCK_WIDTH; error_position++) begin
        check_checker_and_corrector_single_bit_error(test_data, error_position);
      end
    end

  end

  // If the data width is large, we perform random testing
  else begin

    // Check 1: Random test without error
    $display("CHECK 1: Random test without error.");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
      test_data = $urandom_range(0, DATA_WIDTH_POW2-1);
      check_all_modules_no_error(test_data);
    end

    // Check 2: Random test with single bit flip error
    $display("CHECK 2: Random test with single bit flip error.");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
      test_data = $urandom_range(0, DATA_WIDTH_POW2-1);
      error_position = $urandom_range(0, BLOCK_WIDTH-1);
      check_checker_and_corrector_single_bit_error(test_data, error_position);
    end

  end

  // End of test
  $finish;
end

endmodule