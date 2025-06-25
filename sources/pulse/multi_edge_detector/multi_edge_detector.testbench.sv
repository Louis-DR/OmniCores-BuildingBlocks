// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        multi_edge_detector.testbench.sv                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the multi edge detector.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module multi_edge_detector__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam integer CONSECUTIVE_CHECK_DURATION = 100;
localparam integer RANDOM_CHECK_DURATION      = 100;

// Device ports
logic clock;
logic resetn;
logic signal;
logic rising_edge;
logic falling_edge;
logic any_edge;

// Test variables
logic previous_signal;
logic rising_edge_expected;
logic falling_edge_expected;
logic any_edge_expected;

// Device under test
multi_edge_detector multi_edge_detector_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .signal       ( signal       ),
  .rising_edge  ( rising_edge  ),
  .falling_edge ( falling_edge ),
  .any_edge     ( any_edge     )
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
  $dumpfile("multi_edge_detector.testbench.vcd");
  $dumpvars(0,multi_edge_detector__testbench);

  // Initialization
  signal = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset state
  $display("CHECK 1 : Reset state.");
  assert (!rising_edge)
    else $error("[%0tns] Rising edge is not low after reset.", $time);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is not low after reset.", $time);
  assert (!any_edge)
    else $error("[%0tns] Any edge is not low after reset.", $time);

  repeat(10) @(posedge clock);

  // Check 2 : Rising edge detection
  $display("CHECK 2 : Rising edge detection.");
  @(negedge clock);
  signal = 0;
  @(negedge clock);
  signal = 1;
  @(posedge clock);
  assert (rising_edge)
    else $error("[%0tns] Rising edge is not asserted on the rising edge.", $time);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is asserted on the rising edge.", $time);
  assert (any_edge)
    else $error("[%0tns] Any edge is not asserted on the rising edge.", $time);
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%0tns] Rising edge is still asserted after the rising edge.", $time);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is asserted after the rising edge.", $time);
  assert (!any_edge)
    else $error("[%0tns] Any edge is still asserted after the rising edge.", $time);

  repeat(10) @(posedge clock);

  // Check 3 : Falling edge detection
  $display("CHECK 3 : Falling edge detection.");
  @(negedge clock);
  signal = 1;
  @(negedge clock);
  signal = 0;
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%0tns] Rising edge is asserted on the falling edge.", $time);
  assert (falling_edge)
    else $error("[%0tns] Falling edge is not asserted on the falling edge.", $time);
  assert (any_edge)
    else $error("[%0tns] Any edge is not asserted on the falling edge.", $time);
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%0tns] Rising edge is asserted after the falling edge.", $time);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is still asserted after the falling edge.", $time);
  assert (!any_edge)
    else $error("[%0tns] Any edge is still asserted after the falling edge.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Consecutive edges
  $display("CHECK 4 : Consecutive edges.");
  @(negedge clock);
  signal = 0;
  repeat (CONSECUTIVE_CHECK_DURATION/2) begin
    // Rising edge
    @(negedge clock);
    signal = 1;
    @(posedge clock);
    assert (rising_edge)
      else $error("[%0tns] Rising edge is not asserted on the rising edge.", $time);
    assert (!falling_edge)
      else $error("[%0tns] Falling edge is asserted on the rising edge.", $time);
    assert (any_edge)
      else $error("[%0tns] Any edge is not asserted on the rising edge.", $time);
    // Falling edge
    @(negedge clock);
    signal = 0;
    @(posedge clock);
    assert (!rising_edge)
      else $error("[%0tns] Rising edge is asserted on the falling edge.", $time);
    assert (falling_edge)
      else $error("[%0tns] Falling edge is not asserted on the falling edge.", $time);
    assert (any_edge)
      else $error("[%0tns] Any edge is not asserted on the falling edge.", $time);
  end
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%0tns] Rising edge is still asserted after the last edge.", $time);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is still asserted after the last edge.", $time);
  assert (!any_edge)
    else $error("[%0tns] Any edge is still asserted after the last edge.", $time);

  repeat(10) @(posedge clock);

  // Check 5 : Random stimulus
  $display("CHECK 5 : Random stimulus.");
  @(negedge clock);
  previous_signal = 0;
  signal          = 0;
  repeat(2) @(posedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    @(negedge clock);
    signal = $urandom_range(1);
    rising_edge_expected  =  signal & ~previous_signal;
    falling_edge_expected = ~signal &  previous_signal;
    any_edge_expected   = rising_edge_expected | falling_edge_expected;
    @(posedge clock);
    assert (rising_edge === rising_edge_expected)
      else $error("[%0tns] Incorrect rising edge during random stimulus, expected '%0b', got '%0b'.",
                  $time, rising_edge_expected, rising_edge);
    assert (falling_edge === falling_edge_expected)
      else $error("[%0tns] Incorrect falling edge during random stimulus, expected '%0b', got '%0b'.",
                  $time, falling_edge_expected, falling_edge);
    assert (any_edge === any_edge_expected)
      else $error("[%0tns] Incorrect any edge during random stimulus, expected '%0b', got '%0b'.",
                  $time, any_edge_expected, any_edge);
    previous_signal = signal;
  end

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule