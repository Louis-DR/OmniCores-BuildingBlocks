// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_fallback.testbench.sv                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock fallback.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "boolean.svh"
`include "absolute.svh"



module clock_fallback__testbench ();

// Test parameters
localparam integer STAGES                           = 2;
localparam real    FALLBACK_CLOCK_PERIOD            = 10;
localparam real    PRIORITY_CLOCK_PERIOD            = FALLBACK_CLOCK_PERIOD/3.14159265359;
localparam         FREQUENCY_UNIT                   = "MHz";
localparam real    FREQUENCY_MEASUREMENT_TOLERANCE  = 0.05;
localparam real    GLITCH_PERIOD_TOLERANCE          = 0.05;

// Device ports
logic priority_clock;
logic fallback_clock;
logic resetn;
logic clock_out;

// Test variables
bool priority_clock_active  = true;
bool fallback_clock_active = true;
real priority_clock_frequency;
real fallback_clock_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;

// Device under test
clock_fallback #(
  .STAGES         ( STAGES          )
) clock_fallback_dut (
  .priority_clock ( priority_clock  ),
  .fallback_clock ( fallback_clock  ),
  .resetn         ( resetn          ),
  .clock_out      ( clock_out       )
);

// First clock generation
initial begin
  priority_clock = 1;
  forever begin
    if (priority_clock_active) begin
      #(PRIORITY_CLOCK_PERIOD/2) priority_clock = ~priority_clock;
    end else begin
      #(PRIORITY_CLOCK_PERIOD/2) priority_clock = 0;
    end
  end
end

// Second clock generation
initial begin
  fallback_clock = 1;
  forever begin
    if (fallback_clock_active) begin
      #(FALLBACK_CLOCK_PERIOD/2) fallback_clock = ~fallback_clock;
    end else begin
      #(FALLBACK_CLOCK_PERIOD/2) fallback_clock = 0;
    end
  end
end

// Passive check for glitches
initial begin
  forever begin
    @(posedge clock_out);
    time_posedge_clock_out = $realtime;
    @(negedge clock_out);
    time_negedge_clock_out = $realtime;
    if (resetn) begin
      if (   absolute(time_negedge_clock_out-time_posedge_clock_out - PRIORITY_CLOCK_PERIOD/2) > GLITCH_PERIOD_TOLERANCE * PRIORITY_CLOCK_PERIOD/2
          && absolute(time_negedge_clock_out-time_posedge_clock_out - FALLBACK_CLOCK_PERIOD/2) > GLITCH_PERIOD_TOLERANCE * FALLBACK_CLOCK_PERIOD/2) begin
        $error("[%t] Glitch detected on the output clock.", $time);
      end
    end
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("clock_fallback.testbench.vcd");
  $dumpvars(0,clock_fallback__testbench);

  // Reset assertion
  resetn = 0;
  @(posedge priority_clock);
  @(posedge fallback_clock);

  // Measure the running clocks frequency
  @(posedge priority_clock);
  `measure_frequency(priority_clock, priority_clock_frequency)
  @(posedge fallback_clock);
  `measure_frequency(fallback_clock, fallback_clock_frequency)

  // Turn off both clocks
  @(negedge priority_clock); priority_clock_active = false;
  @(negedge fallback_clock); fallback_clock_active = false;
  #(PRIORITY_CLOCK_PERIOD + FALLBACK_CLOCK_PERIOD);

  // Reset deassertion
  resetn = 1;
  #1;

  // Check 1 : No clock running
  $display("CHECK 1 : No clock running.");
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = 0;
  if (clock_out_frequency != 0) $error("[%t] Output clock is running with frequency %d%s when neither input clocks are running.",
                                        $time, clock_out_frequency, FREQUENCY_UNIT);

  // Check 2 : Fallback clock only
  $display("CHECK 2 : Fallback clock only.");
  priority_clock_active = false;
  fallback_clock_active = true;
  repeat(2*STAGES) @(posedge fallback_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = fallback_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when only the fallback clock is running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when only the fallback clock is running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 3 : Both clocks running
  $display("CHECK 3 : Both clocks running.");
  priority_clock_active = true;
  fallback_clock_active = true;
  repeat(2*STAGES) @(posedge priority_clock);
  repeat(2*STAGES) @(posedge fallback_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = priority_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when both clocks are running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when both clocks are running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 4 : Priority clock only
  $display("CHECK 4 : Priority clock only.");
  priority_clock_active = true;
  fallback_clock_active = false;
  repeat(2*STAGES) @(posedge priority_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = priority_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when only the priority clock is running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when only the priority clock is running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 5 : No clock running
  $display("CHECK 5 : No clock running.");
  priority_clock_active = false;
  fallback_clock_active = false;
  #(PRIORITY_CLOCK_PERIOD + FALLBACK_CLOCK_PERIOD);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = 0;
  if (clock_out_frequency != 0) $error("[%t] Output clock is running with frequency %d%s when neither input clocks are running.",
                                        $time, clock_out_frequency, FREQUENCY_UNIT);

  // Check 6 : Priority clock only
  $display("CHECK 6 : Priority clock only.");
  priority_clock_active = true;
  fallback_clock_active = false;
  repeat(2*STAGES) @(posedge priority_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = priority_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when only the priority clock is running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when only the priority clock is running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 7 : Both clocks running
  $display("CHECK 7 : Both clocks running.");
  priority_clock_active = true;
  fallback_clock_active = true;
  repeat(2*STAGES) @(posedge priority_clock);
  repeat(2*STAGES) @(posedge fallback_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = priority_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when both clocks are running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when both clocks are running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 8 : Fallback clock only
  $display("CHECK 8 : Fallback clock only.");
  priority_clock_active = false;
  fallback_clock_active = true;
  repeat(2*STAGES) @(posedge fallback_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = fallback_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running when only the fallback clock is running.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) when only the fallback clock is running.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // End of test
  $finish;
end

endmodule
