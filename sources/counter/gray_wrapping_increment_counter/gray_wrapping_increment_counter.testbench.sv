// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_wrapping_increment_counter.testbench.sv                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the gray wrapping increment counter.           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "count_differences.svh"



module gray_wrapping_increment_counter__testbench ();

// Device parameters
localparam int  RANGE       = 4;
localparam int  RESET_VALUE = 0;

// Derived parameters
localparam int  WIDTH     = $clog2(RANGE);
localparam int  COUNT_MIN = 0;
localparam int  COUNT_MAX = RANGE - 1;

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int  CHECK_TIMEOUT                      = 1000;
localparam int  RANDOM_CHECK_DURATION              = 1000;
localparam real RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;

// Device ports
logic             clock;
logic             resetn;
logic             increment;
logic [WIDTH-1:0] count_gray;
logic [WIDTH-1:0] count_binary;

// Test variables
int               expected_count;
int               timeout_countdown;
logic [WIDTH-1:0] previous_binary;
logic [WIDTH-1:0] previous_gray;

// Device under test
gray_wrapping_increment_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE )
) gray_wrapping_increment_counter_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .increment    ( increment    ),
  .count_gray   ( count_gray   ),
  .count_binary ( count_binary )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Reference function for binary to gray conversion (matches design mapping)
function automatic logic [WIDTH-1:0] reference_binary_to_gray;
  input logic [WIDTH-1:0] binary;
  logic [WIDTH-1:0] offset_binary;
  int offset = ((2 ** WIDTH) - RANGE) / 2;
  offset_binary = binary + offset;
  return offset_binary ^ (offset_binary >> 1);
endfunction

// Check single-bit difference between two successive gray codes
task check_bit_difference;
  input logic [WIDTH-1:0] gray1;
  input logic [WIDTH-1:0] gray2;
  int bit_differences;
  `COUNT_BIT_DIFFERENCES(WIDTH, gray1, gray2, bit_differences)
  assert (bit_differences === 1)
    else $error("[%t] More than one bit difference between successive gray codes '%b' and '%b': %0d bit differences.",
                $time, gray1, gray2, bit_differences);
endtask

// Function to predict next count value with wrapping
function int predict_next_count(input int current_count, input logic increment_signal);
  if (increment_signal) begin
    if (current_count == COUNT_MAX) begin
      return COUNT_MIN; // Wrap to min
    end else begin
      return current_count + 1;
    end
  end else begin
    return current_count;
  end
endfunction

// Main block
initial begin
  // Log waves
  $dumpfile("gray_wrapping_increment_counter.testbench.vcd");
  $dumpvars(0,gray_wrapping_increment_counter__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  increment = 0;

  // Reset
  @(posedge clock);
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  expected_count = RESET_VALUE;
  assert (count_binary == expected_count)
    else $error("[%t] Value at reset '%0d' is different than the one given as parameter '%0d'.", $realtime, count_binary, RESET_VALUE);
  // Gray mapping check at reset
  assert (count_gray == reference_binary_to_gray(count_binary))
    else $error("[%t] Gray code does not match binary at reset.", $realtime);

  repeat(10) @(posedge clock);

  // Check 2 : Increment without wrapping
  $display("CHECK 2 : Increment without wrapping.");
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count_binary != COUNT_MAX) begin
        previous_binary = count_binary;
        previous_gray   = count_gray;
        @(posedge clock);
        expected_count += 1;
        @(negedge clock);
        #(1);
        assert (count_binary == expected_count)
          else $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count_binary, expected_count);
        // Gray single-bit difference and mapping
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%t] Gray mapping mismatch after increment.", $realtime);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%t] Timeout, could not reach max count.", $realtime);
    end
  join_any
  disable fork;
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Increment with wrapping
  $display("CHECK 3 : Increment with wrapping.");
  assert (count_binary == COUNT_MAX)
    else $error("[%t] Counter should be at maximum '%0d' but is at '%0d'.", $realtime, COUNT_MAX, count_binary);
  previous_binary = count_binary;
  previous_gray   = count_gray;
  @(negedge clock);
  increment = 1;
  @(posedge clock);
  expected_count = predict_next_count(previous_binary, 1);
  @(negedge clock);
  #(1);
  assert (count_binary == COUNT_MIN)
    else $error("[%t] Counter should wrap to minimum '%0d' but is at '%0d'.", $realtime, COUNT_MIN, count_binary);
  check_bit_difference(previous_gray, count_gray);
  assert (count_gray == reference_binary_to_gray(count_binary))
    else $error("[%t] Gray mapping mismatch after wrap up.", $realtime);
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Full cycle increment
  $display("CHECK 4 : Full cycle increment.");
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        previous_binary = count_binary;
        previous_gray   = count_gray;
        @(posedge clock);
        expected_count = predict_next_count(previous_binary, 1);
        @(negedge clock);
        #(1);
        assert (count_binary == expected_count)
          else $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count_binary, expected_count);
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%t] Gray mapping mismatch during full-cycle increment.", $realtime);
      end
      // Should be back to minimum after full cycle
      assert (count_binary == COUNT_MIN)
        else $error("[%t] Counter should be back to minimum '%0d' after full cycle but is at '%0d'.", $realtime, COUNT_MIN, count_binary);
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%t] Timeout, could not complete full increment cycle.", $realtime);
    end
  join_any
  disable fork;
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Random
  $display("CHECK 5 : Random.");
  @(negedge clock);
  increment = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    increment = random_boolean(RANDOM_CHECK_INCREMENT_PROBABILITY);
    previous_binary = count_binary;
    previous_gray   = count_gray;
    @(posedge clock);
    expected_count = predict_next_count(previous_binary, increment);
    @(negedge clock);
    #(1);
    if (increment) begin
      check_bit_difference(previous_gray, count_gray);
    end else begin
      // No change expected
      assert (count_gray === previous_gray) else $error("[%t] Gray code changed without a step.", $realtime);
    end
    assert (count_binary == expected_count) else $error("[%t] Counter value mismatch in random test.", $realtime);
    assert (count_gray == reference_binary_to_gray(count_binary)) else $error("[%t] Gray mapping mismatch in random test.", $realtime);
  end
  increment = 0;

  // End of test
  $finish;
end

endmodule
