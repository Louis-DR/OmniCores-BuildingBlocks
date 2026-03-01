// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        running_clock_detector.testbench.sv                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock detector.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "boolean.svh"



module running_clock_detector__testbench ();

// Device parameters
localparam int DETECTOR_STAGES     = 2;
localparam int SYNCHRONIZER_STAGES = 2;

// Test parameters
localparam real REFERENCE_CLOCK_PERIOD = 10;
localparam real OBSERVED_CLOCK_PERIOD  = REFERENCE_CLOCK_PERIOD/3.14159265359;

// Device ports
logic reference_clock;
logic observed_clock;
logic resetn;
logic clock_is_running;

// Test variables
int  check;
bool enabled_observed_clock = false;

// Device under test
running_clock_detector #(
  .DETECTOR_STAGES     ( DETECTOR_STAGES     ),
  .SYNCHRONIZER_STAGES ( SYNCHRONIZER_STAGES )
) running_clock_detector_dut (
  .reference_clock  ( reference_clock  ),
  .observed_clock   ( observed_clock   ),
  .resetn           ( resetn           ),
  .clock_is_running ( clock_is_running )
);

// Reference clock generation
initial begin
  reference_clock = 1;
  forever begin
    #(REFERENCE_CLOCK_PERIOD/2) reference_clock = ~reference_clock;
  end
end

// Observed clock generation
initial begin
  observed_clock = 0;
  forever begin
    if (enabled_observed_clock) begin
      #(OBSERVED_CLOCK_PERIOD/2) observed_clock = ~observed_clock;
    end else begin
      #(OBSERVED_CLOCK_PERIOD/2) observed_clock = 0;
    end
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("running_clock_detector.testbench.vcd");
  $dumpvars(0,running_clock_detector__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  enabled_observed_clock = false;

  // Reset
  resetn = 0;
  @(posedge reference_clock);
  resetn = 1;
  @(posedge reference_clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value."); check = 1;
  assert(!clock_is_running) else $error("[%t] Clock detector output should be low after reset.", $realtime);

  repeat(10) @(posedge reference_clock);

  // Check 2 : Disabled observed clock
  $display("CHECK 2 : Disabled observed clock."); check = 2;
  enabled_observed_clock = false;
  repeat (DETECTOR_STAGES+SYNCHRONIZER_STAGES+1) @(posedge reference_clock);
  assert(!clock_is_running) else $error("[%t] Clock detector detects a clock while the observed clock is disabled.", $realtime);

  repeat(10) @(posedge reference_clock);

  // Check 3 : Enabled observed clock
  $display("CHECK 3 : Enabled observed clock."); check = 3;
  enabled_observed_clock = true;
  repeat (DETECTOR_STAGES+SYNCHRONIZER_STAGES+1) @(posedge reference_clock);
  assert(clock_is_running) else $error("[%t] Clock detector detects no clock while the observed clock is enabled.", $realtime);

  repeat(10) @(posedge reference_clock);

  // Check 4 : Disabled observed clock
  $display("CHECK 4 : Disabled observed clock."); check = 4;
  @(negedge observed_clock);
  enabled_observed_clock = false;
  repeat (DETECTOR_STAGES+SYNCHRONIZER_STAGES+1) @(posedge reference_clock);
  assert(!clock_is_running) else $error("[%t] Clock detector detects a clock while the observed clock is disabled.", $realtime);

  repeat(10) @(posedge reference_clock);

  // End of test
  $finish;
end

endmodule
