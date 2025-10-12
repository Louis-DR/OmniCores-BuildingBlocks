// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        onehot.testbench.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the One-hot encoding modules.                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "count_ones.svh"



module onehot__testbench ();

// Device parameters
localparam int WIDTH_BINARY = 8;
localparam int WIDTH_ONEHOT = 2**WIDTH_BINARY;

// Test parameters
localparam int WIDTH_BINARY_POW2       = 2**WIDTH_BINARY;
localparam int FULL_CHECK_MAX_DURATION = 1024; // Exhaustive up to 2^10
localparam int RANDOM_CHECK_DURATION   = 1000; // Number of random iterations

// Device ports
logic [WIDTH_BINARY-1:0] binary_to_onehot_binary;
logic [WIDTH_ONEHOT-1:0] binary_to_onehot_onehot;

logic [WIDTH_ONEHOT-1:0] onehot_to_binary_onehot;
logic [WIDTH_BINARY-1:0] onehot_to_binary_binary;

// Devices under test
binary_to_onehot #(
  .WIDTH_BINARY ( WIDTH_BINARY ),
  .WIDTH_ONEHOT ( WIDTH_ONEHOT )
) binary_to_onehot_dut (
  .binary ( binary_to_onehot_binary ),
  .onehot ( binary_to_onehot_onehot )
);

onehot_to_binary #(
  .WIDTH_ONEHOT ( WIDTH_ONEHOT ),
  .WIDTH_BINARY ( WIDTH_BINARY )
) onehot_to_binary_dut (
  .onehot ( onehot_to_binary_onehot ),
  .binary ( onehot_to_binary_binary )
);

// Reference function for binary to one-hot conversion
function logic [WIDTH_ONEHOT-1:0] reference_binary_to_onehot(input logic [WIDTH_BINARY-1:0] binary);
  return 1'b1 << binary;
endfunction

// Reference function for one-hot to binary conversion
function logic [WIDTH_BINARY-1:0] reference_onehot_to_binary(input logic [WIDTH_ONEHOT-1:0] onehot);
  logic [WIDTH_BINARY-1:0] binary;
  binary = 0;
  for (int bit_index = 0; bit_index < WIDTH_ONEHOT; bit_index++) begin
    if (onehot[bit_index]) binary = bit_index;
  end
  return binary;
endfunction

// Task to check conversion correctness for a single binary value
task check_conversion(input logic [WIDTH_BINARY-1:0] binary_value);
  logic [WIDTH_ONEHOT-1:0] expected_onehot;
  logic [WIDTH_BINARY-1:0] expected_binary;

  // Test binary-to-onehot conversion
  expected_onehot = reference_binary_to_onehot(binary_value);
  binary_to_onehot_binary = binary_value;
  #1;
  assert (binary_to_onehot_onehot === expected_onehot)
    else $error("[%t] Incorrect binary-to-onehot conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_value, expected_onehot, binary_to_onehot_onehot);

  // Test onehot-to-binary conversion (round-trip test)
  onehot_to_binary_onehot = binary_to_onehot_onehot;
  #1;
  expected_binary = reference_onehot_to_binary(binary_to_onehot_onehot);
  assert (onehot_to_binary_binary === binary_value)
    else $error("[%t] Incorrect round-trip conversion. Original binary '%b' -> Onehot '%b' -> Decoded binary '%b'.",
                $time, binary_value, binary_to_onehot_onehot, onehot_to_binary_binary);
  assert (onehot_to_binary_binary === expected_binary)
    else $error("[%t] Incorrect onehot-to-binary conversion for input '%b'. Expected '%b', got '%b'.",
                $time, binary_to_onehot_onehot, expected_binary, onehot_to_binary_binary);
endtask

// Task to check one-hot property (exactly one bit set)
task check_onehot_property(input logic [WIDTH_ONEHOT-1:0] onehot_value);
  int bit_count;

  `COUNT_ONES(WIDTH_ONEHOT, onehot_value, bit_count)

  assert (bit_count === 1)
    else $error("[%t] One-hot should have exactly one bit set, but value '%b' has %0d bits set.",
                $time, onehot_value, bit_count);
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("onehot.testbench.vcd");
  $dumpvars(0, onehot__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  binary_to_onehot_binary = 0;
  onehot_to_binary_onehot = 0;

  // Small delay after initialization
  #1;

  // If the binary width is small, we perform exhaustive testing
  if (WIDTH_BINARY_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test
    $display("CHECK 1: Exhaustive test.");
    for (int value = 0; value < WIDTH_BINARY_POW2; value++) begin
      logic [WIDTH_BINARY-1:0] current_binary;
      logic [WIDTH_ONEHOT-1:0] current_onehot;

      current_binary = value[WIDTH_BINARY-1:0];

      // Check conversion correctness
      check_conversion(current_binary);
      current_onehot = binary_to_onehot_onehot;

      // Check one-hot property
      check_onehot_property(current_onehot);
    end

  end

  // If the binary width is large, we perform random testing
  else begin

    // Check 1: Random test
    $display("CHECK 1: Random test.");
    repeat (RANDOM_CHECK_DURATION) begin
      logic [WIDTH_BINARY-1:0] current_binary;
      logic [WIDTH_ONEHOT-1:0] current_onehot;

      current_binary = $urandom_range(0, WIDTH_BINARY_POW2-1);

      // Check conversion correctness
      check_conversion(current_binary);
      current_onehot = binary_to_onehot_onehot;

      // Check one-hot property
      check_onehot_property(current_onehot);
    end

  end

  // End of test
  $finish;
end

endmodule