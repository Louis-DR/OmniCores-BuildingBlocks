// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        probabilistic_saturating_counter.testbench.sv                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the probabilistic saturating counter.          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "absolute.svh"



module probabilistic_saturating_counter__testbench ();

// Device parameters
localparam int  RANGE                  = 4;
localparam int  RESET_VALUE            = 0;
localparam int  RANDOM_NUMBER_WIDTH    = 8;
localparam real SATURATION_PROBABILITY = 0.25;

// Derived parameters
localparam int  WIDTH                  = $clog2(RANGE);
localparam int  COUNT_MIN              = 0;
localparam int  COUNT_MAX              = RANGE - 1;
localparam int  COUNT_MIN_PLUS_ONE     = COUNT_MIN + 1;
localparam int  COUNT_MAX_MINUS_ONE    = COUNT_MAX - 1;

// Test parameters
localparam real CLOCK_PERIOD           = 10;

// Check parameters
localparam int  CHECK_TIMEOUT                      = 1000;
localparam int  PROBABILITY_MEASUREMENT_DURATION   = 1000;
localparam real PROBABILITY_MEASUREMENT_TOLERANCE  = 0.05;
localparam int  PROBABILITY_MEASUREMENT_TIMEOUT    = PROBABILITY_MEASUREMENT_DURATION * CHECK_TIMEOUT;
localparam int  RANDOM_CHECK_DURATION              = 1000;
localparam real RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic                           clock;
logic                           resetn;
logic                           increment;
logic                           decrement;
logic [RANDOM_NUMBER_WIDTH-1:0] random_number;
logic               [WIDTH-1:0] count;

// Test variables
int  expected_count;
bool force_saturation;
int  timeout_countdown;

// Probability measurement variables
int  saturation_attempts;
int  saturation_successes;
real measured_probability;

// Device under test
probabilistic_saturating_counter #(
  .RANGE                  ( RANGE                  ),
  .RESET_VALUE            ( RESET_VALUE            ),
  .RANDOM_NUMBER_WIDTH    ( RANDOM_NUMBER_WIDTH    ),
  .SATURATION_PROBABILITY ( SATURATION_PROBABILITY )
) probabilistic_saturating_counter_dut (
  .clock         ( clock         ),
  .resetn        ( resetn        ),
  .increment     ( increment     ),
  .decrement     ( decrement     ),
  .random_number ( random_number ),
  .count         ( count         )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Random number generation
always @(posedge clock) begin
  if (force_saturation) begin
    random_number <= '0;
  end else begin
    random_number <= $urandom;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("probabilistic_saturating_counter.testbench.vcd");
  $dumpvars(0,probabilistic_saturating_counter__testbench);

  // Initialization
  increment        = 0;
  decrement        = 0;
  random_number    = 0;
  force_saturation = false;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  expected_count = RESET_VALUE;
  if (count != expected_count) begin
    $error("[%0tns] Value at reset '%0d' is different than the one given as parameter '%0d'.", $time, count, RESET_VALUE);
  end

  repeat(10) @(posedge clock);

  // Check 2 : Increment and force saturation
  $display("CHECK 2 : Increment and force saturation.");
  @(negedge clock);
  increment         = 1;
  force_saturation  = true;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count != COUNT_MAX) begin
        @(posedge clock);
        expected_count += 1;
        @(negedge clock);
      end
      if (count != expected_count) begin
        $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not reach max count.", $time);
    end
  join_any
  disable fork;
  increment = 0;
  force_saturation = false;

  repeat(10) @(posedge clock);

  // Check 3 : Decrement and force saturation
  $display("CHECK 3 : Decrement and force saturation.");
  @(negedge clock);
  decrement         = 1;
  force_saturation  = true;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count != COUNT_MIN) begin
        @(posedge clock);
        expected_count -= 1;
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not reach min count.", $time);
    end
  join_any
  disable fork;
  decrement = 0;
  force_saturation = false;

  repeat(10) @(posedge clock);

  // Check 4 : Measure max saturation probability
  $display("CHECK 4 : Measure max saturation probability.");
  saturation_attempts  = 0;
  saturation_successes = 0;
  timeout_countdown    = PROBABILITY_MEASUREMENT_TIMEOUT;
  fork
    // Check
    begin
      // First, get to max-1
      @(negedge clock);
      increment = 1;
      while (count != COUNT_MAX_MINUS_ONE) begin
        @(negedge clock);
      end
      increment = 0;
      @(posedge clock);
      // Now measure saturation probability
      repeat (PROBABILITY_MEASUREMENT_DURATION) begin
        if (count != COUNT_MAX_MINUS_ONE) begin
          $error("[%0tns] Counter should be at max-1 ('%0d') but is at '%0d'.", $time, COUNT_MAX_MINUS_ONE, count);
        end
        // Increment to try saturating
        @(negedge clock);
        increment = 1;
        saturation_attempts += 1;
        @(negedge clock);
        increment = 0;
        // Check if the counter has saturated
        if (count == COUNT_MAX) begin
          saturation_successes += 1;
          // Reset back to max-1 for next attempt
          @(negedge clock);
          decrement = 1;
          @(negedge clock);
          decrement = 0;
        end
      end
      measured_probability = real'(saturation_successes) / real'(saturation_attempts);
      if (absolute(measured_probability - SATURATION_PROBABILITY) > PROBABILITY_MEASUREMENT_TOLERANCE) begin
        $error("[%0tns] Measured max saturation probability %.3f%% is outside tolerance of expected %.3f%% ± %.3f%%",
              $time, measured_probability*100, SATURATION_PROBABILITY*100, PROBABILITY_MEASUREMENT_TOLERANCE*100);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not measure max saturation probability.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // Check 5 : Measure min saturation probability
  $display("CHECK 5 : Measure min saturation probability.");
  saturation_attempts  = 0;
  saturation_successes = 0;
  timeout_countdown    = PROBABILITY_MEASUREMENT_TIMEOUT;
  fork
    // Check
    begin
      // First, get to min+1
      @(negedge clock);
      decrement = 1;
      while (count != COUNT_MIN_PLUS_ONE) begin
        @(negedge clock);
      end
      decrement = 0;
      @(posedge clock);
      // Now measure saturation probability
      repeat (PROBABILITY_MEASUREMENT_DURATION) begin
        if (count != COUNT_MIN_PLUS_ONE) begin
          $error("[%0tns] Counter should be at min+1 ('%0d') but is at '%0d'.", $time, COUNT_MIN_PLUS_ONE, count);
        end
        // Decrement to try saturating
        @(negedge clock);
        decrement = 1;
        saturation_attempts += 1;
        @(negedge clock);
        decrement = 0;
        // Check if the counter has saturated
        if (count == COUNT_MIN) begin
          saturation_successes += 1;
          // Reset back to min+1 for next attempt
          @(negedge clock);
          increment = 1;
          @(negedge clock);
          increment = 0;
        end
      end
      measured_probability = real'(saturation_successes) / real'(saturation_attempts);
      if (absolute(measured_probability - SATURATION_PROBABILITY) > PROBABILITY_MEASUREMENT_TOLERANCE) begin
        $error("[%0tns] Measured min saturation probability %.3f%% is outside tolerance of expected %.3f%% ± %.3f%%",
              $time, measured_probability*100, SATURATION_PROBABILITY*100, PROBABILITY_MEASUREMENT_TOLERANCE*100);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not measure min saturation probability.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // Check 6 : Random
  $display("CHECK 6 : Random.");
  @(negedge clock);
  decrement = 0;
  increment = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    increment = random_boolean(RANDOM_CHECK_INCREMENT_PROBABILITY);
    decrement = random_boolean(RANDOM_CHECK_DECREMENT_PROBABILITY);
    @(posedge clock);
    if (!(increment && decrement)) begin
      if (increment && count != COUNT_MAX) begin
        expected_count += 1;
      end else if (decrement && count != COUNT_MIN) begin
        expected_count -= 1;
      end
    end
    @(negedge clock);
    // If we tried to increment to saturation, but the counter is not saturated, it is fine
    if (expected_count == COUNT_MAX && increment && count == COUNT_MAX_MINUS_ONE) begin
      expected_count = COUNT_MAX_MINUS_ONE;
    end
    // If we tried to decrement to saturation, but the counter is not saturated, it is fine
    if (expected_count == COUNT_MIN && decrement && count == COUNT_MIN_PLUS_ONE) begin
      expected_count = COUNT_MIN_PLUS_ONE;
    end
    // Check if the counter is at the expected value
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;
  decrement = 0;

  // End of test
  $finish;
end

endmodule