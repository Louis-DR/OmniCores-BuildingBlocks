// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rising_edge_detector.testbench.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the rising edge detector.                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module rising_edge_detector__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int CONSECUTIVE_CHECK_DURATION = 100;
localparam int RANDOM_CHECK_DURATION      = 100;

// Device ports
logic clock;
logic resetn;
logic signal;
logic rising_edge;

// Test variables
logic previous_signal;
logic rising_edge_expected;

// Device under test
rising_edge_detector rising_edge_detector_dut (
  .clock       ( clock       ),
  .resetn      ( resetn      ),
  .signal      ( signal      ),
  .rising_edge ( rising_edge )
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
  $dumpfile("rising_edge_detector.testbench.vcd");
  $dumpvars(0,rising_edge_detector__testbench);
  $timeformat(-9, 0, " ns", 0);

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
    else $error("[%t] Rising edge is not low after reset.", $realtime);

  repeat(10) @(posedge clock);

  // Check 2 : Rising edge detection
  $display("CHECK 2 : Rising edge detection.");
  @(negedge clock);
  signal = 0;
  @(negedge clock);
  signal = 1;
  @(posedge clock);
  assert (rising_edge)
    else $error("[%t] Rising edge is not asserted on the rising edge.", $realtime);
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%t] Rising edge is still asserted after the rising edge.", $realtime);

  repeat(10) @(posedge clock);

  // Check 3 : No detection on falling edge
  $display("CHECK 3 : No detection on falling edge.");
  @(negedge clock);
  signal = 1;
  @(negedge clock);
  signal = 0;
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%t] Rising edge is incorrectly asserted on the falling edge.", $realtime);
  @(posedge clock);
  assert (!rising_edge)
    else $error("[%t] Rising edge is still asserted after the falling edge.", $realtime);

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
    assert (rising_edge)
      else $error("[%t] Rising edge is not asserted on the rising edge.", $realtime);
    // Falling edge
    @(negedge clock);
    signal = 0;
    @(posedge clock);
    assert (!rising_edge)
      else $error("[%t] Rising edge is asserted on the falling edge.", $realtime);
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
    rising_edge_expected = signal & ~previous_signal;
    @(posedge clock);
    assert (rising_edge === rising_edge_expected)
      else $error("[%t] Incorrect rising edge during random stimulus, expected '%0b', got '%0b'.",
                  $time, rising_edge_expected, rising_edge);
    previous_signal = signal;
  end

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule