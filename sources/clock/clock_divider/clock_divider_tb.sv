// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_divider_tb.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock divider.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module clock_divider_tb ();

// Test parameters
localparam CLOCK_PERIOD = 10;
localparam FREQUENCY_MEASUREMENT_LENGTH     = 10;
localparam FREQUENCY_MEASUREMENT_MULTIPLIER = 1e3;
localparam FREQUENCY_MEASUREMENT_UNIT       = "MHz";
localparam FREQUENCY_MEASUREMENT_TIMEOUT    = FREQUENCY_MEASUREMENT_LENGTH * CLOCK_PERIOD * 100;
localparam MAX_TEST_DIVISION = 10;

// Device ports
logic                       clock_in;
logic                       resetn;
logic [MAX_TEST_DIVISION:1] clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;

// Generate device with different parameter values
generate
  for (genvar division=1 ; division<=MAX_TEST_DIVISION ; division++) begin : gen_division
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

// Macro to measure the frequency of a clock
real time_start;
real time_stop;
`define measure_frequency(clock, frequency, length=FREQUENCY_MEASUREMENT_LENGTH)        \
  fork                                                                                  \
    begin                                                                               \
      @(posedge clock)                                                                  \
      time_start = $time;                                                               \
      repeat(length) @(posedge clock)                                                   \
      time_stop = $time;                                                                \
      frequency = FREQUENCY_MEASUREMENT_MULTIPLIER * length / (time_stop - time_start); \
    end                                                                                 \
    begin                                                                               \
      #(FREQUENCY_MEASUREMENT_TIMEOUT);                                                 \
      frequency = 0;                                                                    \
    end                                                                                 \
  join_any                                                                              \
  disable fork;

// Main block
initial begin
  // Log waves
  $dumpfile("clock_divider_tb.vcd");
  $dumpvars(0,clock_divider_tb);

  // Reset
  resetn = 0;
  #(CLOCK_PERIOD);
  resetn = 1;
  #(CLOCK_PERIOD);

  // Measure the input clock frequency
  @(posedge clock_in);
  `measure_frequency(clock_in, clock_in_frequency)


  // Check 1 : Output divided frequency
  $display("CHECK 1 : Output divided frequency.");
  for (integer division=1 ; division<=MAX_TEST_DIVISION ; division++) begin
    `measure_frequency(clock_out[division], clock_out_frequency)
    if      (clock_out_frequency == 0) $error("[%t] Output clock with division factor of %0d is not running.", $time,  division);
    else if (clock_out_frequency != clock_in_frequency/division) $error("[%t] Output clock frequency (%d%s) with division factor of %0d doesn't match the expected clock frequency (%d%s).",
                                                                        $time, clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, division, clock_in_frequency/division, FREQUENCY_MEASUREMENT_UNIT);
  end

  // End of test
  $finish;
end

endmodule
