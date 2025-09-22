// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray.testbench.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Gray encoding modules.                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "count_differences.svh"



module gray__testbench ();

// Device parameters
localparam int WIDTH = 8;

// Test parameters
localparam int WIDTH_POW2              = 2**WIDTH;
localparam int FULL_CHECK_MAX_DURATION = 1024; // Exhaustive up to 2^10
localparam int RANDOM_SEQUENCE_COUNT   = 32;   // Number of random sequences
localparam int RANDOM_SEQUENCE_LENGTH  = 32;   // Length of each random sequence

// Device ports
logic [WIDTH-1:0] binary_to_gray_binary;
logic [WIDTH-1:0] binary_to_gray_gray;

logic [WIDTH-1:0] gray_to_binary_gray;
logic [WIDTH-1:0] gray_to_binary_binary;

// Devices under test
binary_to_gray #(
  .WIDTH  ( WIDTH )
) binary_to_gray_dut (
  .binary ( binary_to_gray_binary ),
  .gray   ( binary_to_gray_gray   )
);

gray_to_binary #(
  .WIDTH  ( WIDTH )
) gray_to_binary_dut (
  .gray   ( gray_to_binary_gray   ),
  .binary ( gray_to_binary_binary )
);

// Reference function for binary to gray conversion
function logic [WIDTH-1:0] reference_binary_to_gray(input logic [WIDTH-1:0] binary);
  return binary ^ (binary >> 1);
endfunction

// Reference function for gray to binary conversion
function logic [WIDTH-1:0] reference_gray_to_binary(input logic [WIDTH-1:0] gray);
  logic [WIDTH-1:0] binary;
  binary[WIDTH-1] = gray[WIDTH-1];
  for (int bit_index = WIDTH-2; bit_index >= 0; bit_index--) begin
    binary[bit_index] = binary[bit_index+1] ^ gray[bit_index];
  end
  return binary;
endfunction

// Task to check conversion correctness for a single binary value
task check_conversion(input logic [WIDTH-1:0] binary_value);
  logic [WIDTH-1:0] expected_gray;
  logic [WIDTH-1:0] expected_binary;

  // Test binary-to-gray conversion
  expected_gray = reference_binary_to_gray(binary_value);
  binary_to_gray_binary = binary_value;
  #1;
  assert (binary_to_gray_gray === expected_gray)
    else $error("[%0tns] Incorrect binary-to-gray conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_value, expected_gray, binary_to_gray_gray);

  // Test gray-to-binary conversion (round-trip test)
  gray_to_binary_gray = binary_to_gray_gray;
  #1;
  expected_binary = reference_gray_to_binary(binary_to_gray_gray);
  assert (gray_to_binary_binary === binary_value)
    else $error("[%0tns] Incorrect round-trip conversion. Original binary '%b' -> Gray '%b' -> Decoded binary '%b'.",
                $time, binary_value, binary_to_gray_gray, gray_to_binary_binary);
  assert (gray_to_binary_binary === expected_binary)
    else $error("[%0tns] Incorrect gray-to-binary conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_to_gray_gray, expected_binary, gray_to_binary_binary);
endtask

// Task to check single-bit difference between two successive gray codes
task check_bit_difference(input logic [WIDTH-1:0] gray1, input logic [WIDTH-1:0] gray2);
  int bit_differences;

  `COUNT_BIT_DIFFERENCES(WIDTH, gray1, gray2, bit_differences)

  assert (bit_differences === 1)
    else $error("[%0tns] More than one bit difference between successive gray codes '%b' and '%b': %0d bit differences.",
                $time, gray1, gray2, bit_differences);
endtask

// Task to check a sequence from start_value to stop_value
task check_sequence(input logic [WIDTH-1:0] start_value, input logic [WIDTH-1:0] stop_value);
  logic [WIDTH-1:0] current_binary;
  logic [WIDTH-1:0] current_gray;
  logic [WIDTH-1:0] previous_gray;
  logic [WIDTH-1:0] iterations;

  // Support wrapping
  iterations = stop_value >= start_value
             ? stop_value - start_value + 1
             : WIDTH_POW2 - start_value + stop_value + 1;

  for (int step = 0; step < iterations; step++) begin
    current_binary = (start_value + step) % WIDTH_POW2;

    // Check conversion correctness
    check_conversion(current_binary);
    current_gray = binary_to_gray_gray;

    // Check single-bit difference property (except for first value)
    if (step > 0) begin
      check_bit_difference(previous_gray, current_gray);
    end

    previous_gray = current_gray;
  end
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("gray.testbench.vcd");
  $dumpvars(0, gray__testbench);

  // Initialization
  binary_to_gray_binary = 0;
  gray_to_binary_gray   = 0;

  // Small delay after initialization
  #1;

  // If the width is small, we perform exhaustive testing
  if (WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test
    $display("CHECK 1: Exhaustive test.");
    for (int step = 0; step <= WIDTH_POW2; step++) begin
      logic [WIDTH-1:0] current_binary;
      logic [WIDTH-1:0] current_gray;
      logic [WIDTH-1:0] previous_gray;

      current_binary = step % WIDTH_POW2;

      // Check conversion correctness
      check_conversion(current_binary);
      current_gray = binary_to_gray_gray;

      // Check single-bit difference property (except for first value)
      if (step > 0) begin
        check_bit_difference(previous_gray, current_gray);
      end

      previous_gray = current_gray;
    end

  end

  // If the width is large, we perform random testing
  else begin

    // Check 1: Random test
    $display("CHECK 1: Random test.");
    for (int sequence_index = 0; sequence_index < RANDOM_SEQUENCE_COUNT; sequence_index++) begin
      logic [WIDTH-1:0] start_value;
      logic [WIDTH-1:0] stop_value;
      start_value = $urandom_range(0, WIDTH_POW2-1);
      stop_value  = (start_value + RANDOM_SEQUENCE_LENGTH - 1) % WIDTH_POW2;
      check_sequence(start_value, stop_value);
    end

  end

  // End of test
  $finish;
end

endmodule