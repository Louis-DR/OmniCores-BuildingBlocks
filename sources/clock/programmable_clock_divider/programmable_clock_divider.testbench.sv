// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        programmable_clock_divider.testbench.sv                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the programmable clock divider.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "measure_frequency.svh"
`include "absolute.svh"



module static_clock_divider__testbench ();

// Device parameter
localparam int DIVISION_WIDTH = 4;
localparam int POWER_OF_TWO   = 0;

// Test parameters
localparam int    DIVISION_WIDTH_POW2             = 2 ** DIVISION_WIDTH;
localparam real   CLOCK_PERIOD                    = 10;
localparam string FREQUENCY_UNIT                  = "MHz";
localparam int    FREQUENCY_MEASUREMENT_DURATION  = 10;
localparam int    FREQUENCY_MEASUREMENT_TIMEOUT   = POWER_OF_TWO ? 1e7 : 1e4;
localparam real   FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;

// Device ports
logic                      clock_in;
logic                      resetn;
logic [DIVISION_WIDTH-1:0] division;
logic                      clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;

// Device under test
programmable_clock_divider #(
  .DIVISION_WIDTH ( DIVISION_WIDTH ),
  .POWER_OF_TWO   ( POWER_OF_TWO   )
) static_clock_divider_dut (
  .clock_in  ( clock_in  ),
  .resetn    ( resetn    ),
  .division  ( division  ),
  .clock_out ( clock_out )
);

// Clock generation
initial begin
  clock_in = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock_in = ~clock_in;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("programmable_clock_divider.testbench.vcd");
  $dumpvars(0,static_clock_divider__testbench);

  // Initialization
  division = 0;

  // Reset
  resetn = 0;
  @(posedge clock_in);
  resetn = 1;
  @(posedge clock_in);

  // Measure the input clock frequency
  @(posedge clock_in);
  `MEASURE_FREQUENCY(clock_in, clock_in_frequency)

  // Check 1 : Output divided frequency
  $display("CHECK 1 : Output divided frequency.");
  for (int division_value = 0; division_value < DIVISION_WIDTH_POW2; division_value++) begin
    division = division_value;
    if (POWER_OF_TWO == 1) begin
      repeat(2**(division_value+1)) @(posedge clock_in);
      expected_clock_out_frequency = clock_in_frequency / (2**division);
    end else begin
      repeat(division_value+1) @(posedge clock_in);
      expected_clock_out_frequency = clock_in_frequency / (division+1);
    end
    `MEASURE_FREQUENCY(clock_out, clock_out_frequency, FREQUENCY_MEASUREMENT_DURATION, FREQUENCY_MEASUREMENT_TIMEOUT)
    if      (clock_out_frequency == 0) $error("[%0tns] Output clock with division factor of %0d is not running.", $time,  division);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%0tns] Output clock frequency (%d%s) with division factor of %0d doesn't match the expected clock frequency (%d%s).",
             $time, clock_out_frequency, FREQUENCY_UNIT, division, expected_clock_out_frequency, FREQUENCY_UNIT);
    end
  end

  // End of test
  $finish;
end

endmodule
