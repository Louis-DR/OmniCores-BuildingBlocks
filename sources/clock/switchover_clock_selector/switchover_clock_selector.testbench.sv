// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        switchover_clock_selector.testbench.sv                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the switchover clock selector.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "boolean.svh"
`include "absolute.svh"



module switchover_clock_selector__testbench ();

// Test parameters
localparam int     STAGES                          = 2;
localparam real    FIRST_CLOCK_PERIOD              = 10;
localparam real    SECOND_CLOCK_PERIOD             = FIRST_CLOCK_PERIOD/3.14159265359;
localparam string  FREQUENCY_UNIT                  = "MHz";
localparam real    FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;
localparam real    GLITCH_PERIOD_TOLERANCE         = 0.05;

// Device ports
logic first_clock;
logic second_clock;
logic resetn;
logic clock_out;

// Test variables
bool first_clock_active  = true;
bool second_clock_active = true;
real first_clock_frequency;
real second_clock_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;

// Device under test
switchover_clock_selector #(
  .STAGES       ( STAGES       )
) switchover_clock_selector_dut (
  .first_clock  ( first_clock  ),
  .second_clock ( second_clock ),
  .resetn       ( resetn       ),
  .clock_out    ( clock_out    )
);

// First clock generation
initial begin
  first_clock = 1;
  forever begin
    if (first_clock_active) begin
      #(FIRST_CLOCK_PERIOD/2) first_clock = ~first_clock;
    end else begin
      #(FIRST_CLOCK_PERIOD/2) first_clock = 0;
    end
  end
end

// Second clock generation
initial begin
  second_clock = 1;
  forever begin
    if (second_clock_active) begin
      #(SECOND_CLOCK_PERIOD/2) second_clock = ~second_clock;
    end else begin
      #(SECOND_CLOCK_PERIOD/2) second_clock = 0;
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
      if (   absolute(time_negedge_clock_out-time_posedge_clock_out -  FIRST_CLOCK_PERIOD/2) > GLITCH_PERIOD_TOLERANCE *  FIRST_CLOCK_PERIOD/2
          && absolute(time_negedge_clock_out-time_posedge_clock_out - SECOND_CLOCK_PERIOD/2) > GLITCH_PERIOD_TOLERANCE * SECOND_CLOCK_PERIOD/2) begin
        $error("[%t] Glitch detected on the output clock.", $time);
      end
    end
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("switchover_clock_selector.testbench.vcd");
  $dumpvars(0,switchover_clock_selector__testbench);

  // Reset assertion
  resetn = 0;
  @(posedge first_clock);
  @(posedge second_clock);

  // Measure the running clocks frequency
  @(posedge first_clock);
  `measure_frequency(first_clock, first_clock_frequency)
  @(posedge second_clock);
  `measure_frequency(second_clock, second_clock_frequency)

  // Turn off both clocks
  @(negedge first_clock);  first_clock_active  = false;
  @(negedge second_clock); second_clock_active = false;
  #(FIRST_CLOCK_PERIOD + SECOND_CLOCK_PERIOD);

  // Reset deassertion
  resetn = 1;
  #1;

  // Check 1 : No clock running
  $display("CHECK 1 : No clock running.");
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = 0;
  if (clock_out_frequency != 0) $error("[%t] Output clock is running with frequency %d%s when neither input clocks are running.",
                                        $time, clock_out_frequency, FREQUENCY_UNIT);

  // Check 2 : Start first clock
  $display("CHECK 2 : Start first clock.");
  first_clock_active = true;
  @(posedge first_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = first_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running after the first clock has started.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) after the first clock has started.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 3 : Start second clock
  $display("CHECK 3 : Start second clock.");
  second_clock_active = true;
  @(posedge second_clock);
  repeat (STAGES) @(posedge first_clock);
  repeat (STAGES) @(posedge second_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = second_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running after the second clock has started.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) after the second clock has started.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // Check 4 : Stop first clock
  $display("CHECK 4 : Stop first clock.");
  first_clock_active = false;
  repeat (STAGES) @(posedge second_clock);
  `measure_frequency(clock_out, clock_out_frequency)
  expected_clock_out_frequency = second_clock_frequency;
  if      (clock_out_frequency == 0) $error("[%t] Output clock is not running after the first clock has stopped.", $time);
  else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
    $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) after the first clock has stopped.",
           $time, clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency, FREQUENCY_UNIT, expected_clock_out_frequency);
  end

  // End of test
  $finish;
end

endmodule
