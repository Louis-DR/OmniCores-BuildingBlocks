// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        grey.testbench.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Grey encoding modules.                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "count_differences.svh"



module grey__testbench ();

// Device parameters
localparam WIDTH = 4;

// Test parameters
localparam WIDTH_POW2              = 2**WIDTH;
localparam FULL_CHECK_MAX_DURATION = 1024; // Exhaustive up to 2^10
localparam RANDOM_SEQUENCE_COUNT   = 32;   // Number of random sequences
localparam RANDOM_SEQUENCE_LENGTH  = 32;   // Length of each random sequence

// Device ports
logic [WIDTH-1:0] binary_to_grey_binary;
logic [WIDTH-1:0] binary_to_grey_grey;

logic [WIDTH-1:0] grey_to_binary_grey;
logic [WIDTH-1:0] grey_to_binary_binary;

// Devices under test
binary_to_grey #(
  .WIDTH  ( WIDTH )
) binary_to_grey_dut (
  .binary ( binary_to_grey_binary ),
  .grey   ( binary_to_grey_grey   )
);

grey_to_binary #(
  .WIDTH  ( WIDTH )
) grey_to_binary_dut (
  .grey   ( grey_to_binary_grey   ),
  .binary ( grey_to_binary_binary )
);

// Reference function for binary to grey conversion
function logic [WIDTH-1:0] reference_binary_to_grey(input logic [WIDTH-1:0] binary);
  return binary ^ (binary >> 1);
endfunction

// Reference function for grey to binary conversion
function logic [WIDTH-1:0] reference_grey_to_binary(input logic [WIDTH-1:0] grey);
  logic [WIDTH-1:0] binary;
  binary[WIDTH-1] = grey[WIDTH-1];
  for (integer bit_index = WIDTH-2; bit_index >= 0; bit_index--) begin
    binary[bit_index] = binary[bit_index+1] ^ grey[bit_index];
  end
  return binary;
endfunction

// Task to check conversion correctness for a single binary value
task check_conversion(input logic [WIDTH-1:0] binary_value);
  logic [WIDTH-1:0] expected_grey;
  logic [WIDTH-1:0] expected_binary;

  // Test binary-to-grey conversion
  expected_grey = reference_binary_to_grey(binary_value);
  binary_to_grey_binary = binary_value;
  #1;
  assert (binary_to_grey_grey === expected_grey)
    else $error("[%0tns] Incorrect binary-to-grey conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_value, expected_grey, binary_to_grey_grey);

  // Test grey-to-binary conversion (round-trip test)
  grey_to_binary_grey = binary_to_grey_grey;
  #1;
  expected_binary = reference_grey_to_binary(binary_to_grey_grey);
  assert (grey_to_binary_binary === binary_value)
    else $error("[%0tns] Incorrect round-trip conversion. Original binary '%b' -> Grey '%b' -> Decoded binary '%b'.",
                $time, binary_value, binary_to_grey_grey, grey_to_binary_binary);
  assert (grey_to_binary_binary === expected_binary)
    else $error("[%0tns] Incorrect grey-to-binary conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_to_grey_grey, expected_binary, grey_to_binary_binary);
endtask

// Task to check single-bit difference between two successive grey codes
task check_bit_difference(input logic [WIDTH-1:0] grey1, input logic [WIDTH-1:0] grey2);
  integer bit_differences;

  `COUNT_BIT_DIFFERENCES(WIDTH, grey1, grey2, bit_differences)

  assert (bit_differences === 1)
    else $error("[%0tns] More than one bit difference between successive grey codes '%b' and '%b': %0d bit differences.",
                $time, grey1, grey2, bit_differences);
endtask

// Task to check a sequence from start_value to stop_value
task check_sequence(input logic [WIDTH-1:0] start_value, input logic [WIDTH-1:0] stop_value);
  logic [WIDTH-1:0] current_binary;
  logic [WIDTH-1:0] current_grey;
  logic [WIDTH-1:0] previous_grey;
  logic [WIDTH-1:0] iterations;

  // Support wrapping
  iterations = stop_value >= start_value
             ? stop_value - start_value + 1
             : WIDTH_POW2 - start_value + stop_value + 1;

  for (integer step = 0; step < iterations; step++) begin
    current_binary = (start_value + step) % WIDTH_POW2;

    // Check conversion correctness
    check_conversion(current_binary);
    current_grey = binary_to_grey_grey;

    // Check single-bit difference property (except for first value)
    if (step > 0) begin
      check_bit_difference(previous_grey, current_grey);
    end

    previous_grey = current_grey;
  end
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("grey.testbench.vcd");
  $dumpvars(0, grey__testbench);

  // Initialization
  binary_to_grey_binary = 0;
  grey_to_binary_grey   = 0;

  // Small delay after initialization
  #1;

  // If the width is small, we perform exhaustive testing
  if (WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test
    $display("CHECK 1: Exhaustive test.");
    for (integer step = 0; step <= WIDTH_POW2; step++) begin
      logic [WIDTH-1:0] current_binary;
      logic [WIDTH-1:0] current_grey;
      logic [WIDTH-1:0] previous_grey;

      current_binary = step % WIDTH_POW2;

      // Check conversion correctness
      check_conversion(current_binary);
      current_grey = binary_to_grey_grey;

      // Check single-bit difference property (except for first value)
      if (step > 0) begin
        check_bit_difference(previous_grey, current_grey);
      end

      previous_grey = current_grey;
    end

  end

  // If the width is large, we perform random testing
  else begin

    // Check 1: Random test
    $display("CHECK 1: Random test.");
    for (integer sequence_index = 0; sequence_index < RANDOM_SEQUENCE_COUNT; sequence_index++) begin
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