// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        falling_edge_detector.testbench.sv                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the falling edge detector.                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module falling_edge_detector__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int CONSECUTIVE_CHECK_DURATION = 100;
localparam int RANDOM_CHECK_DURATION      = 100;

// Device ports
logic clock;
logic resetn;
logic signal;
logic falling_edge;

// Test variables
logic previous_signal;
logic falling_edge_expected;

// Device under test
falling_edge_detector falling_edge_detector_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .signal       ( signal       ),
  .falling_edge ( falling_edge )
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
  $dumpfile("falling_edge_detector.testbench.vcd");
  $dumpvars(0,falling_edge_detector__testbench);

  // Initialization
  signal = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset state
  $display("CHECK 1 : Reset state.");
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is not low after reset.", $time);

  repeat(10) @(posedge clock);

  // Check 2 : No detection on rising edge
  $display("CHECK 2 : No detection on rising edge.");
  @(negedge clock);
  signal = 0;
  @(negedge clock);
  signal = 1;
  @(posedge clock);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is incorrectly asserted on the rising edge.", $time);
  @(posedge clock);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is still asserted after the rising edge.", $time);

  repeat(10) @(posedge clock);

  // Check 3 : Falling edge detection
  $display("CHECK 3 : Falling edge detection.");
  @(negedge clock);
  signal = 1;
  @(negedge clock);
  signal = 0;
  @(posedge clock);
  assert (falling_edge)
    else $error("[%0tns] Falling edge is not asserted on the falling edge.", $time);
  @(posedge clock);
  assert (!falling_edge)
    else $error("[%0tns] Falling edge is still asserted after the falling edge.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Consecutive rising edges
  $display("CHECK 4 : Consecutive rising edges.");
  @(negedge clock);
  signal = 0;
  repeat (CONSECUTIVE_CHECK_DURATION/2) begin
    // Rising edge
    @(negedge clock);
    signal = 1;
    @(posedge clock);
    assert (!falling_edge)
      else $error("[%0tns] Falling edge is asserted on the rising edge.", $time);
    // Falling edge
    @(negedge clock);
    signal = 0;
    @(posedge clock);
    assert (falling_edge)
      else $error("[%0tns] Falling edge is not asserted on the falling edge.", $time);
  end

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
    falling_edge_expected = ~signal & previous_signal;
    @(posedge clock);
    assert (falling_edge === falling_edge_expected)
      else $error("[%0tns] Incorrect falling edge during random stimulus, expected '%0b', got '%0b'.",
                  $time, falling_edge_expected, falling_edge);
    previous_signal = signal;
  end

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule