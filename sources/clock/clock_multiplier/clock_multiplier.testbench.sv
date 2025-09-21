// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_multiplier.testbench.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock multiplier.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "absolute.svh"



module clock_multiplier__testbench ();

// Test parameters
localparam real   CLOCK_PERIOD                    = 10;
localparam string FREQUENCY_UNIT                  = "MHz";
localparam int    MAX_TEST_MULTIPLICATION         = 10;
localparam int    FREQUENCY_MEASUREMENT_DURATION  = 100;
localparam real   FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;

// Device ports
logic                             clock_in;
logic [MAX_TEST_MULTIPLICATION:1] clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;

// Generate device with different parameter values
generate
  for (genvar multiplication = 1; multiplication <= MAX_TEST_MULTIPLICATION; multiplication++) begin : gen_multiplication
    // Device under test
    clock_multiplier #(
      .MULTIPLICATION ( multiplication )
    ) clock_multiplier_dut (
      .clock_in  ( clock_in                  ),
      .clock_out ( clock_out[multiplication] )
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
  $dumpfile("clock_multiplier.testbench.vcd");
  $dumpvars(0,clock_multiplier__testbench);

  // Measure the input clock frequency
  @(posedge clock_in);
  `MEASURE_FREQUENCY(clock_in, clock_in_frequency, FREQUENCY_MEASUREMENT_DURATION)

  // Check 1 : Output multiplied frequency
  $display("CHECK 1 : Output multiplied frequency.");
  for (int multiplication = 1; multiplication <= MAX_TEST_MULTIPLICATION; multiplication++) begin
    expected_clock_out_frequency = clock_in_frequency * multiplication;
    `MEASURE_FREQUENCY(clock_out[multiplication], clock_out_frequency, FREQUENCY_MEASUREMENT_DURATION)
    if      (clock_out_frequency == 0) $error("[%0tns] Output clock with multiplication factor of %0d is not running.", $time,  multiplication);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency)
      $error("[%0tns] Output clock frequency (%d%s) with multiplication factor of %0d doesn't match the expected clock frequency (%d%s).",
             $time, clock_out_frequency, FREQUENCY_UNIT, multiplication, clock_in_frequency*multiplication, FREQUENCY_UNIT);
  end

  // End of test
  $finish;
end

endmodule
