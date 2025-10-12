// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        saturating_counter.testbench.sv                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the saturating counter.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module saturating_counter__testbench ();

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
localparam int  RANDOM_CHECK_DURATION              = 100;
localparam real RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic             clock;
logic             resetn;
logic             decrement;
logic             increment;
logic [WIDTH-1:0] count;

// Test variables
int expected_count;

// Device under test
saturating_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE )
) saturating_counter_dut (
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

// Main block
initial begin
  // Log waves
  $dumpfile("saturating_counter.testbench.vcd");
  $dumpvars(0,saturating_counter__testbench);
  $timeformat(-9, 0, " ns", 0);

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
    $error("[%t] Value at reset '%0d' is different than the one given as parameter '%0d'.", $realtime, count, RESET_VALUE);
  end

  repeat(10) @(posedge clock);

  // Check 2 : Increment
  $display("CHECK 2 : Increment.");
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  while (count != COUNT_MAX) begin
    @(posedge clock);
    expected_count += 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
    end
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Decrement
  $display("CHECK 3 : Decrement.");
  expected_count = COUNT_MAX;
  @(negedge clock);
  decrement = 1;
  while (count != COUNT_MIN) begin
    @(posedge clock);
    expected_count -= 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
    end
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Random
  $display("CHECK 4 : Random.");
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
    if (count != expected_count) begin
      $error("[%t] Counter value is '%0d' instead of expected value '%0d'.", $realtime, count, expected_count);
    end
  end
  decrement = 0;
  increment = 0;

  // End of test
  $finish;
end

endmodule
