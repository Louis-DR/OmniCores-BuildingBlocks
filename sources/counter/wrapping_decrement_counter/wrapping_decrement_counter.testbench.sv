// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wrapping_decrement_counter.testbench.sv                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the wrapping decrement counter.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module wrapping_decrement_counter__testbench ();

// Device parameters
localparam int  RANGE       = 4;
localparam int  RESET_VALUE = 0;

// Derived parameters
localparam int  WIDTH       = $clog2(RANGE);
localparam int  COUNT_MIN   = 0;
localparam int  COUNT_MAX   = RANGE - 1;

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int  CHECK_TIMEOUT                      = 1000;
localparam int  RANDOM_CHECK_DURATION              = 1000;
localparam real RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic             clock;
logic             resetn;
logic             decrement;
logic [WIDTH-1:0] count;

// Test variables
int expected_count;
int timeout_countdown;

// Device under test
wrapping_decrement_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE )
) wrapping_decrement_counter_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .decrement ( decrement ),
  .count     ( count     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Function to predict next count value with wrapping
function int predict_next_count(input int current_count, input logic decrement_signal);
  if (decrement_signal) begin
    if (current_count == COUNT_MIN) begin
      return COUNT_MAX; // Wrap to max
    end else begin
      return current_count - 1;
    end
  end else begin
    return current_count;
  end
endfunction

// Main block
initial begin
  // Log waves
  $dumpfile("wrapping_decrement_counter.testbench.vcd");
  $dumpvars(0,wrapping_decrement_counter__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  decrement = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  expected_count = RESET_VALUE;
  if (count != expected_count) begin
    $error("[%t] Value at reset '%0d' is different than the one given as parameter '%0d'.", $realtime, count, RESET_VALUE);
  end

  repeat(10) @(posedge clock);

    // Check 2 : Decrement without wrapping
  $display("CHECK 2 : Decrement without wrapping.");
  // First, get to COUNT_MAX by wrapping from COUNT_MIN (one decrement from 0 goes to max)
  @(negedge clock);
  decrement = 1;
  @(posedge clock);
  @(negedge clock);
  decrement = 0;
  if (count != COUNT_MAX) begin
    $error("[%t] Counter should be at maximum '%0d' after wrapping but is at '%0d'.", $realtime, COUNT_MAX, count);
  end

  // Now test decrement without wrapping from max to min
  expected_count = COUNT_MAX;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count != COUNT_MIN) begin
        @(posedge clock);
        expected_count -= 1;
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%t] Timeout, could not reach min count.", $realtime);
    end
  join_any
  disable fork;
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Decrement with wrapping
  $display("CHECK 3 : Decrement with wrapping.");
  if (count != COUNT_MIN) begin
    $error("[%t] Counter should be at minimum '%0d' but is at '%0d'.", $realtime, COUNT_MIN, count);
  end
  @(negedge clock);
  decrement = 1;
  @(negedge clock);
  if (count != COUNT_MAX) begin
    $error("[%t] Counter should wrap to maximum '%0d' but is at '%0d'.", $realtime, COUNT_MAX, count);
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Full cycle decrement
  $display("CHECK 4 : Full cycle decrement.");
  expected_count = COUNT_MAX;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        @(posedge clock);
        expected_count = predict_next_count(count, 1);
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
        end
      end
      // Should be back to COUNT_MAX after full cycle
      if (count != COUNT_MAX) begin
        $error("[%t] Counter should be back to maximum '%0d' after full cycle but is at '%0d'.", $realtime, COUNT_MAX, count);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%t] Timeout, could not complete full decrement cycle.", $realtime);
    end
  join_any
  disable fork;
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Random
  $display("CHECK 5 : Random.");
  @(negedge clock);
  decrement = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    decrement = random_boolean(RANDOM_CHECK_DECREMENT_PROBABILITY);
    @(posedge clock);
    expected_count = predict_next_count(count, decrement);
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
    end
  end
  decrement = 0;

  // End of test
  $finish;
end

endmodule