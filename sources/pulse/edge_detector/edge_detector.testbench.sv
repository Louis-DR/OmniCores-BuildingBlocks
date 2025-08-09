// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        edge_detector.testbench.sv                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the edge detector.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module edge_detector__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int CONSECUTIVE_CHECK_DURATION = 100;
localparam int RANDOM_CHECK_DURATION      = 100;

// Device ports
logic clock;
logic resetn;
logic signal;
logic edge_pulse;

// Test variables
logic previous_signal;
logic edge_pulse_expected;

// Device under test
edge_detector edge_detector_dut (
  .clock      ( clock      ),
  .resetn     ( resetn     ),
  .signal     ( signal     ),
  .edge_pulse ( edge_pulse )
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
  $dumpfile("edge_detector.testbench.vcd");
  $dumpvars(0,edge_detector__testbench);

  // Initialization
  signal = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset state
  $display("CHECK 1 : Reset state.");
  assert (!edge_pulse)
    else $error("[%0tns] Edge pulse is not low after reset.", $time);

  repeat(10) @(posedge clock);

  // Check 2 : Rising edge detection
  $display("CHECK 2 : Rising edge detection.");
  @(negedge clock);
  signal = 0;
  @(negedge clock);
  signal = 1;
  @(posedge clock);
  assert (edge_pulse)
    else $error("[%0tns] Edge pulse is not asserted on the rising edge.", $time);
  @(posedge clock);
  assert (!edge_pulse)
    else $error("[%0tns] Edge pulse is still asserted after the rising edge.", $time);

  repeat(10) @(posedge clock);

  // Check 3 : Falling edge detection
  $display("CHECK 3 : Falling edge detection.");
  @(negedge clock);
  signal = 1;
  @(negedge clock);
  signal = 0;
  @(posedge clock);
  assert (edge_pulse)
    else $error("[%0tns] Edge pulse is not asserted on the falling edge.", $time);
  @(posedge clock);
  assert (!edge_pulse)
    else $error("[%0tns] Edge pulse is still asserted after the falling edge.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Consecutive edges
  $display("CHECK 4 : Consecutive edges.");
  repeat (CONSECUTIVE_CHECK_DURATION) begin
    @(negedge clock);
    signal = ~signal;
    @(posedge clock);
    assert (edge_pulse)
      else $error("[%0tns] Edge pulse is not asserted on consecutive edges.", $time);
  end
  @(posedge clock);
  assert (!edge_pulse)
    else $error("[%0tns] Edge pulse is still asserted after the last edge.", $time);

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
    edge_pulse_expected = signal ^ previous_signal;
    @(posedge clock);
    assert (edge_pulse === edge_pulse_expected)
      else $error("[%0tns] Incorrect edge pulse during random stimulus, expected '%0b', got '%0b'.",
                  $time, edge_pulse_expected, edge_pulse);
    previous_signal = signal;
  end

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule