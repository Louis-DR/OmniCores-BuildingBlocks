// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        programmable_clock_multiplier.testbench.sv                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the programmable clock multiplier.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "absolute.svh"



module programmable_clock_multiplier__testbench ();

// Device parameters
localparam int MULTIPLICATION_WIDTH      = 4;
localparam int MULTIPLICATION_WIDTH_POW2 = 2 ** MULTIPLICATION_WIDTH;

// Test parameters
localparam real   CLOCK_PERIOD                    = 10;
localparam string FREQUENCY_UNIT                  = "MHz";
localparam int    FREQUENCY_MEASUREMENT_DURATION  = 100;
localparam real   FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;
localparam int    RANDOM_GLITCH_CHECK_ITERATIONS  = 1000;
localparam int    RANDOM_GLITCH_CHECK_MIN_DELAY   = CLOCK_PERIOD;
localparam int    RANDOM_GLITCH_CHECK_MAX_DELAY   = CLOCK_PERIOD * 10;
localparam real   PULSE_WIDTH_TOLERANCE           = 0.10;

// Device ports
logic       clock_in;
logic [3:0] multiplication; // Matches default MULTIPLICATION_WIDTH of 4
logic       clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;
real expected_high_pulse_width_ns;
real time_posedge_clock_out;
real time_negedge_clock_out;
int  sampled_multiplication;

// Device under test
programmable_clock_multiplier programmable_clock_multiplier_dut (
  .clock_in       ( clock_in       ),
  .multiplication ( multiplication ),
  .clock_out      ( clock_out      )
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
  $dumpfile("programmable_clock_multiplier.testbench.vcd");
  $dumpvars(0,programmable_clock_multiplier__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  multiplication = 0;

  // Measure the input clock frequency
  @(posedge clock_in);
  `MEASURE_FREQUENCY(clock_in, clock_in_frequency, FREQUENCY_MEASUREMENT_DURATION)

  // Check 1 : Output multiplied frequency across a range
  $display("CHECK 1 : Output multiplied frequency across a range.");
  for (int multiplication_value = 0; multiplication_value < MULTIPLICATION_WIDTH_POW2; multiplication_value++) begin
    @(posedge clock_in);
    multiplication = multiplication_value;
    expected_clock_out_frequency = clock_in_frequency * (multiplication_value + 1);
    `MEASURE_FREQUENCY(clock_out, clock_out_frequency, FREQUENCY_MEASUREMENT_DURATION)
    if      (clock_out_frequency == 0) $error("[%t] Output clock with multiplication factor of %0d is not running.", $realtime, multiplication_value);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency)
      $error("[%t] Output clock frequency (%d%s) with multiplication factor of %0d doesn't match the expected clock frequency (%d%s).",
             $time, clock_out_frequency, FREQUENCY_UNIT, multiplication_value, clock_in_frequency*multiplication_value, FREQUENCY_UNIT);
  end

  // Check 2 : Glitch-free output on random multiplication updates
  $display("CHECK 2 : Glitch-free output on random multiplication updates.");
  multiplication = 0;
  @(posedge clock_in);
  fork
    // Stimulus
    begin
      repeat (RANDOM_GLITCH_CHECK_ITERATIONS) begin
        #($urandom_range(RANDOM_GLITCH_CHECK_MIN_DELAY, RANDOM_GLITCH_CHECK_MAX_DELAY));
        multiplication = $urandom_range(MULTIPLICATION_WIDTH_POW2);
      end
    end
    // Check
    begin
      forever begin
        @(posedge clock_in);
        sampled_multiplication = multiplication;
        @(posedge clock_out);
        time_posedge_clock_out = $realtime;
        @(negedge clock_out);
        time_negedge_clock_out = $realtime;
        // Expected high pulse width in ns from measured input frequency and sampled multiplication
        expected_high_pulse_width_ns = (1000.0 / (clock_in_frequency * (sampled_multiplication + 1))) / 2.0;
        if (absolute((time_negedge_clock_out - time_posedge_clock_out) - expected_high_pulse_width_ns) > PULSE_WIDTH_TOLERANCE * expected_high_pulse_width_ns)
          $error("[%t] Glitch detected on the output clock: high pulse width %0.3f ns, expected %0.3f ns (mult=%0d).",
                 $time, time_negedge_clock_out - time_posedge_clock_out, expected_high_pulse_width_ns, sampled_multiplication);
      end
    end
  join_any
  disable fork;

  // End of test
  $finish;
end

endmodule
