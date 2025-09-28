// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hysteresis_saturating_counter.testbench.sv                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the hysteresis saturating counter.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module hysteresis_saturating_counter__testbench ();

// Device parameters
localparam int  RANGE           = 4;
localparam int  RESET_VALUE     = 0;
localparam int  COERCIVITY      = 1;

// Derived parameters
localparam int  WIDTH           = $clog2(RANGE);
localparam int  COUNT_MIN       = 0;
localparam int  COUNT_MAX       = RANGE - 1;
localparam int  COUNT_HALF_LOW  = RANGE/2 - 1;
localparam int  COUNT_HALF_HIGH = RANGE/2;
localparam int  COUNT_JUMP_LOW  = COUNT_HALF_LOW  - COERCIVITY;
localparam int  COUNT_JUMP_HIGH = COUNT_HALF_HIGH + COERCIVITY;

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int  RANDOM_CHECK_DURATION              = 100;
localparam real RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic                  clock;
logic                  resetn;
logic                  decrement;
logic                  increment;
logic [WIDTH-1:0] count;

// Test variables
int expected_count;

// Device under test
hysteresis_saturating_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE ),
  .COERCIVITY  ( COERCIVITY  )
) hysteresis_saturating_counter_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .decrement ( decrement ),
  .increment ( increment ),
  .count     ( count     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Function to predict next count value with hysteresis
function int predict_next_count(input int current_count, input logic increment, input logic decrement);
  if (increment && !decrement && current_count != COUNT_MAX) begin
    if (current_count == COUNT_HALF_LOW) begin
      return COUNT_JUMP_HIGH;
    end else begin
      return current_count + 1;
    end
  end else if (decrement && !increment && current_count != COUNT_MIN) begin
    if (current_count == COUNT_HALF_HIGH) begin
      return COUNT_JUMP_LOW;
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
  $dumpfile("hysteresis_saturating_counter.testbench.vcd");
  $dumpvars(0,hysteresis_saturating_counter__testbench);

  // Initialization
  decrement = 0;
  increment = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  if (count != RESET_VALUE) begin
    $error("[%0tns] Value at reset '%0d' is different than the one given as parameter '%0d'.", $time, count, RESET_VALUE);
  end

  repeat(10) @(posedge clock);

  // Check 2 : Increment without hysteresis
  $display("CHECK 2 : Increment without hysteresis.");
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  while (count != COUNT_HALF_LOW) begin
    @(posedge clock);
    expected_count += 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Hysteresis jump up
  $display("CHECK 3 : Hysteresis jump up.");
  if (count != COUNT_HALF_LOW) begin
    $error("[%0tns] Counter should be at half-low '%0d' but is at '%0d'.", $time, COUNT_HALF_LOW, count);
  end
  @(negedge clock);
  increment = 1;
  @(negedge clock);
  if (count != COUNT_JUMP_HIGH) begin
    $error("[%0tns] Counter should jump to '%0d' but is at '%0d'.", $time, COUNT_JUMP_HIGH, count);
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Continue increment to max
  $display("CHECK 4 : Continue increment to max.");
  expected_count = COUNT_JUMP_HIGH;
  @(negedge clock);
  increment = 1;
  while (count != COUNT_MAX) begin
    @(posedge clock);
    expected_count += 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Decrement without hysteresis
  $display("CHECK 5 : Decrement without hysteresis.");
  expected_count = COUNT_MAX;
  @(negedge clock);
  decrement = 1;
  while (count != COUNT_HALF_HIGH) begin
    @(posedge clock);
    expected_count -= 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 6 : Hysteresis jump down
  $display("CHECK 6 : Hysteresis jump down.");
  if (count != COUNT_HALF_HIGH) begin
    $error("[%0tns] Counter should be at half-high '%0d' but is at '%0d'.", $time, COUNT_HALF_HIGH, count);
  end
  @(negedge clock);
  decrement = 1;
  @(negedge clock);
  if (count != COUNT_JUMP_LOW) begin
    $error("[%0tns] Counter should jump to '%0d' but is at '%0d'.", $time, COUNT_JUMP_LOW, count);
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 7 : Continue decrement to min
  $display("CHECK 7 : Continue decrement to min.");
  expected_count = COUNT_JUMP_LOW;
  @(negedge clock);
  decrement = 1;
  while (count != COUNT_MIN) begin
    @(posedge clock);
    expected_count -= 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 8 : Random
  $display("CHECK 8 : Random.");
  @(negedge clock);
  increment = 0;
  decrement = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    increment = random_boolean(RANDOM_CHECK_INCREMENT_PROBABILITY);
    decrement = random_boolean(RANDOM_CHECK_DECREMENT_PROBABILITY);
    @(posedge clock);
    expected_count = predict_next_count(count, increment, decrement);
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  decrement = 0;
  increment = 0;

  // End of test
  $finish;
end

endmodule