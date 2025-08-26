// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_divider.testbench.sv                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock divider.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "measure_frequency.svh"



module clock_divider__testbench ();

// Test parameters
localparam real   CLOCK_PERIOD      = 10;
localparam string FREQUENCY_UNIT    = "MHz";
localparam int    MAX_TEST_DIVISION = 10;

// Device ports
logic                       clock_in;
logic                       resetn;
logic [MAX_TEST_DIVISION:1] clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;

// Generate device with different parameter values
generate
  for (genvar division = 1; division <= MAX_TEST_DIVISION; division++) begin : gen_division
    // Device under test
    clock_divider #(
      .DIVISION  ( division            )
    ) clock_divider_dut (
      .clock_in  ( clock_in            ),
      .resetn    ( resetn              ),
      .clock_out ( clock_out[division] )
    );
  end
endgenerate

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
  $dumpfile("clock_divider.testbench.vcd");
  $dumpvars(0,clock_divider__testbench);

  // Reset
  resetn = 0;
  @(posedge clock_in);
  resetn = 1;
  @(posedge clock_in);

  // Measure the input clock frequency
  @(posedge clock_in);
  `measure_frequency(clock_in, clock_in_frequency)

  // Check 1 : Output divided frequency
  $display("CHECK 1 : Output divided frequency.");
  for (int division = 1; division <= MAX_TEST_DIVISION; division++) begin
    `measure_frequency(clock_out[division], clock_out_frequency)
    if      (clock_out_frequency == 0) $error("[%0tns] Output clock with division factor of %0d is not running.", $time,  division);
    else if (clock_out_frequency != clock_in_frequency/division) $error("[%0tns] Output clock frequency (%d%s) with division factor of %0d doesn't match the expected clock frequency (%d%s).",
                                                                        $time, clock_out_frequency, FREQUENCY_UNIT, division, clock_in_frequency/division, FREQUENCY_UNIT);
  end

  // End of test
  $finish;
end

endmodule
