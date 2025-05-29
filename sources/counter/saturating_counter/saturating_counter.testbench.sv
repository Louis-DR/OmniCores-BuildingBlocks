// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        saturating_counter__testbench.sv                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the saturating counter.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module saturating_counter__testbench ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer RANGE        = 4;
localparam integer RANGE_LOG2   = $clog2(RANGE);
localparam integer RESET_VALUE  = 0;

// Check parameters
localparam integer RANDOM_CHECK_DURATION              = 100;
localparam integer RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic                  clock;
logic                  resetn;
logic                  increment;
logic                  decrement;
logic [RANGE_LOG2-1:0] count;

// Test variables
integer min_count = 0;
integer max_count = RANGE - 1;
integer expected_count;

// Device under test
saturating_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE )
) saturating_counter_dut (
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

// Main block
initial begin
  // Log waves
  $dumpfile("saturating_counter__testbench.vcd");
  $dumpvars(0,saturating_counter__testbench);

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

  // Check 2 : Increment
  $display("CHECK 2 : Increment.");
  expected_count = min_count;
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
  @(posedge clock);

  // Check 3 : Decrement
  $display("CHECK 3 : Decrement.");
  expected_count = max_count;
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
  @(posedge clock);

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
  repeat(RANDOM_CHECK_DURATION) begin
    if (count != max_count && $random < RANDOM_CHECK_INCREMENT_PROBABILITY) begin
      decrement = 0;
      increment = 1;
      @(posedge clock);
      expected_count += 1;
    end else if (count != min_count && $random < RANDOM_CHECK_DECREMENT_PROBABILITY) begin
      decrement = 1;
      increment = 0;
      @(posedge clock);
      expected_count -= 1;
    end else begin
      decrement = 0;
      increment = 0;
    end
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;
  decrement = 0;
  @(posedge clock);

  // End of test
  $finish;
end

endmodule
