// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        bcd.testbench.sv                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Binary-Coded Decimal encoding modules.     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "bcd.vh"



module bcd__testbench ();

// Device parameters
localparam int WIDTH_BINARY = 8;
localparam int WIDTH_BCD    = `BINARY_TO_BCD_WIDTH(WIDTH_BINARY) * 4;

// Test parameters
localparam int WIDTH_BINARY_POW2       = 2**WIDTH_BINARY;
localparam int FULL_CHECK_MAX_DURATION = 1024; // Exhaustive up to 2^10
localparam int RANDOM_CHECK_DURATION   = 1000; // Number of random iterations
localparam int BCD_DIGIT_WIDTH         = 4;
localparam int NUMBER_BCD_DIGITS       = WIDTH_BCD / BCD_DIGIT_WIDTH;

// Device ports
logic [WIDTH_BINARY-1:0] binary_to_bcd_binary;
logic [WIDTH_BCD   -1:0] binary_to_bcd_bcd;

logic [WIDTH_BCD   -1:0] bcd_to_binary_bcd;
logic [WIDTH_BINARY-1:0] bcd_to_binary_binary;

// Devices under test
binary_to_bcd #(
  .WIDTH_BINARY ( WIDTH_BINARY ),
  .WIDTH_BCD    ( WIDTH_BCD    )
) binary_to_bcd_dut (
  .binary ( binary_to_bcd_binary ),
  .bcd    ( binary_to_bcd_bcd    )
);

bcd_to_binary #(
  .WIDTH_BCD    ( WIDTH_BCD    ),
  .WIDTH_BINARY ( WIDTH_BINARY )
) bcd_to_binary_dut (
  .bcd    ( bcd_to_binary_bcd    ),
  .binary ( bcd_to_binary_binary )
);

// Reference function for binary to BCD conversion using string conversion
function logic [WIDTH_BCD-1:0] reference_binary_to_bcd(input logic [WIDTH_BINARY-1:0] binary);
  logic [WIDTH_BCD-1:0] bcd_result;
  string decimal_string;
  string digit_string;
  int    digit_value;
  int    decimal_length;
  int    digit_index;

  // Convert binary to decimal string
  decimal_string = $sformatf("%0d", binary);
  decimal_length = decimal_string.len();

  // Initialize BCD result to zero
  bcd_result = 0;

  // Convert each decimal digit to BCD
  for (int character_index = 0; character_index < decimal_length; character_index++) begin
    digit_string = decimal_string.substr(character_index, character_index);
    digit_value  = digit_string.atoi();
    digit_index  = decimal_length - 1 - character_index;

    // Store BCD digit in appropriate position (if within our BCD width)
    if (digit_index < NUMBER_BCD_DIGITS) begin
      bcd_result[BCD_DIGIT_WIDTH * digit_index +: BCD_DIGIT_WIDTH] = digit_value[BCD_DIGIT_WIDTH-1:0];
    end
  end

  return bcd_result;
endfunction

// Reference function for BCD to binary conversion
function logic [WIDTH_BINARY-1:0] reference_bcd_to_binary(input logic [WIDTH_BCD-1:0] bcd);
  logic    [WIDTH_BINARY-1:0] binary_result;
  logic [BCD_DIGIT_WIDTH-1:0] digit_value;
  int power_of_ten;

  binary_result = 0;
  power_of_ten = 1;

  // Convert each BCD digit to binary and accumulate
  for (int digit_index = 0; digit_index < NUMBER_BCD_DIGITS; digit_index++) begin
    digit_value    = bcd[BCD_DIGIT_WIDTH * digit_index +: BCD_DIGIT_WIDTH];
    binary_result += (digit_value * power_of_ten);
    power_of_ten  *= 10;
  end

  return binary_result;
endfunction

// Task to check conversion correctness for a single binary value
task check_conversion(input logic [WIDTH_BINARY-1:0] binary_value);
  logic [WIDTH_BCD   -1:0] expected_bcd;
  logic [WIDTH_BINARY-1:0] expected_binary;

  // Test binary-to-BCD conversion
  expected_bcd = reference_binary_to_bcd(binary_value);
  binary_to_bcd_binary = binary_value;
  #1;
  assert (binary_to_bcd_bcd === expected_bcd)
    else $error("[%t] Incorrect binary-to-BCD conversion for input '%b' (%0d). Expected '%b' (%0d), got '%b' (%0d).",
                $time, binary_value, binary_value, expected_bcd, expected_bcd, binary_to_bcd_bcd, binary_to_bcd_bcd);

  // Test BCD-to-binary conversion (round-trip test)
  bcd_to_binary_bcd = binary_to_bcd_bcd;
  #1;
  expected_binary = reference_bcd_to_binary(binary_to_bcd_bcd);
  assert (bcd_to_binary_binary === binary_value)
    else $error("[%t] Incorrect round-trip conversion. Original binary '%b' (%0d) -> BCD '%b' -> Decoded binary '%b' (%0d).",
                $time, binary_value, binary_value, binary_to_bcd_bcd, bcd_to_binary_binary, bcd_to_binary_binary);
  assert (bcd_to_binary_binary === expected_binary)
    else $error("[%t] Incorrect BCD-to-binary conversion for input '%b' (%0d). Expected '%b' (%0d), got '%b' (%0d).",
                $time, binary_to_bcd_bcd, binary_to_bcd_bcd, expected_binary, expected_binary, bcd_to_binary_binary, bcd_to_binary_binary);
endtask

// Task to check BCD property (all digits ≤ 9)
task check_bcd_property(input logic [WIDTH_BCD-1:0] bcd_value);
  logic [BCD_DIGIT_WIDTH-1:0] digit_value;

  for (int digit_index = 0; digit_index < NUMBER_BCD_DIGITS; digit_index++) begin
    digit_value = bcd_value[BCD_DIGIT_WIDTH * digit_index +: BCD_DIGIT_WIDTH];
    assert (digit_value <= 9)
      else $error("[%t] BCD digit %0d should be ≤ 9, but digit at position %0d has value %0d in BCD '%b'.",
                  $time, digit_value, digit_index, digit_value, bcd_value);
  end
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("bcd.testbench.vcd");
  $dumpvars(0, bcd__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  binary_to_bcd_binary = 0;
  bcd_to_binary_bcd = 0;

  // Small delay after initialization
  #1;

  // If the binary width is small, we perform exhaustive testing
  if (WIDTH_BINARY_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test
    $display("CHECK 1: Exhaustive test.");
    for (int value = 0; value < WIDTH_BINARY_POW2; value++) begin
      logic [WIDTH_BINARY-1:0] current_binary;
      logic [WIDTH_BCD   -1:0] current_bcd;

      current_binary = value[WIDTH_BINARY-1:0];

      // Check conversion correctness
      check_conversion(current_binary);
      current_bcd = binary_to_bcd_bcd;

      // Check BCD property
      check_bcd_property(current_bcd);
    end

  end

  // If the binary width is large, we perform random testing
  else begin

    // Check 1: Random test
    $display("CHECK 1: Random test.");
    repeat (RANDOM_CHECK_DURATION) begin
      logic [WIDTH_BINARY-1:0] current_binary;
      logic [WIDTH_BCD   -1:0] current_bcd;

      current_binary = $urandom_range(0, WIDTH_BINARY_POW2-1);

      // Check conversion correctness
      check_conversion(current_binary);
      current_bcd = binary_to_bcd_bcd;

      // Check BCD property
      check_bcd_property(current_bcd);
    end

  end

  // End of test
  $finish;
end

endmodule
