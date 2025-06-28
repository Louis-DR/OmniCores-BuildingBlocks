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

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer RANGE        = 4;
localparam integer RANGE_LOG2   = $clog2(RANGE);
localparam integer RESET_VALUE  = 0;
localparam integer COERCIVITY   = 1;

// Check parameters
localparam integer RANDOM_CHECK_DURATION              = 100;
localparam real    RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real    RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic                  clock;
logic                  resetn;
logic                  increment;
logic                  decrement;
logic [RANGE_LOG2-1:0] count;

// Test variables
integer min_count       = 0;
integer max_count       = RANGE - 1;
integer half_low_count  = RANGE/2 - 1;
integer half_high_count = RANGE/2;
integer jump_low_count  = half_low_count - COERCIVITY;
integer jump_high_count = half_high_count + COERCIVITY;
integer expected_count;
logic   try_increment;
logic   try_decrement;

// Device under test
hysteresis_saturating_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE ),
  .COERCIVITY  ( COERCIVITY  )
) hysteresis_saturating_counter_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .increment ( increment ),
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

// Function to predict next count value with hysteresis
function integer predict_next_count(input integer current_count, input logic increment, input logic decrement);
  if (increment && !decrement && current_count != max_count) begin
    if (current_count == half_low_count) begin
      return jump_high_count;
    end else begin
      return current_count + 1;
    end
  end else if (decrement && !increment && current_count != min_count) begin
    if (current_count == half_high_count) begin
      return jump_low_count;
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
  increment = 0;
  decrement = 0;

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
  expected_count = min_count;
  @(negedge clock);
  increment = 1;
  while (count != half_low_count) begin
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
  if (count != half_low_count) begin
    $error("[%0tns] Counter should be at half_low_count '%0d' but is at '%0d'.", $time, half_low_count, count);
  end
  @(negedge clock);
  increment = 1;
  @(negedge clock);
  if (count != jump_high_count) begin
    $error("[%0tns] Counter should jump to '%0d' but is at '%0d'.", $time, jump_high_count, count);
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Continue increment to max
  $display("CHECK 4 : Continue increment to max.");
  expected_count = jump_high_count;
  @(negedge clock);
  increment = 1;
  while (count != max_count) begin
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
  expected_count = max_count;
  @(negedge clock);
  decrement = 1;
  while (count != half_high_count) begin
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
  if (count != half_high_count) begin
    $error("[%0tns] Counter should be at half_high_count '%0d' but is at '%0d'.", $time, half_high_count, count);
  end
  @(negedge clock);
  decrement = 1;
  @(negedge clock);
  if (count != jump_low_count) begin
    $error("[%0tns] Counter should jump to '%0d' but is at '%0d'.", $time, jump_low_count, count);
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 7 : Continue decrement to min
  $display("CHECK 7 : Continue decrement to min.");
  expected_count = jump_low_count;
  @(negedge clock);
  decrement = 1;
  while (count != min_count) begin
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
  decrement = 0;
  increment = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    try_increment = random_boolean(RANDOM_CHECK_INCREMENT_PROBABILITY);
    try_decrement = random_boolean(RANDOM_CHECK_DECREMENT_PROBABILITY);
    if (try_increment && !try_decrement && count != max_count) begin
      decrement = 0;
      increment = 1;
    end else if (try_decrement && !try_increment && count != min_count) begin
      decrement = 1;
      increment = 0;
    end else begin
      decrement = 0;
      increment = 0;
    end
    @(posedge clock);
    expected_count = predict_next_count(count, increment, decrement);
    @(negedge clock);
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