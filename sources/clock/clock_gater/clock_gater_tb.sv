// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_gater_tb.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the clock gater behavioral model.              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module clock_gater_tb ();

// Test parameters
localparam CLOCK_PERIOD = 10;
localparam FREQUENCY_MEASUREMENT_LENGTH     = 10;
localparam FREQUENCY_MEASUREMENT_MULTIPLIER = 1e3;
localparam FREQUENCY_MEASUREMENT_UNIT       = "MHz";
localparam FREQUENCY_MEASUREMENT_TIMEOUT    = FREQUENCY_MEASUREMENT_LENGTH * CLOCK_PERIOD * 100;
localparam RANDOM_GLITCH_CHECK_ITERATIONS   = 1000;

// Device ports
logic clock_in;
logic enable;
logic test_enable;
logic clock_out;

// Test variables
real clock_in_frequency;
real clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;

// Device under test
clock_gater clock_gater_dut (
  .clock_in    ( clock_in    ),
  .enable      ( enable      ),
  .test_enable ( test_enable ),
  .clock_out   ( clock_out   )
);

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
`define measure_frequency(clock, frequency, length=FREQUENCY_MEASUREMENT_LENGTH)                 \
  fork                                                      \
    begin                                                   \
      @(posedge clock)                                      \
      time_start = $time;                                   \
      repeat(length) @(posedge clock)                       \
      time_stop = $time;                                    \
      frequency = FREQUENCY_MEASUREMENT_MULTIPLIER * length / (time_stop - time_start); \
    end                                                     \
    begin                                                   \
      #(FREQUENCY_MEASUREMENT_TIMEOUT);                     \
      frequency = 0;                                        \
    end                                                     \
  join_any                                                  \
  disable fork;

// Main block
initial begin
  // Log waves
  $dumpfile("clock_gater_tb.vcd");
  $dumpvars(0,clock_gater_tb);

  // Initialization
  enable      = 0;
  test_enable = 0;

  @(posedge clock_in);
  `measure_frequency(clock_in, clock_in_frequency)

  // Check 1 : Normal disbale-enable-disable sequence
  $display("CHECK 1 : Normal disbale-enable-disable sequence.");
  @(posedge clock_in);
  enable = 0;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency != 0) $error("[%t] Output clock is running but should be gated.", $time);
  @(posedge clock_in);
  enable = 1;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency == 0) $error("[%t] Output clock is gated but should be running.", $time);
  if (clock_out_frequency != clock_in_frequency) $error("[%t] Output clock frequency (%d%s) doesn't match the input clock frequency (%d%s).", $time, clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, clock_in_frequency, FREQUENCY_MEASUREMENT_UNIT);
  @(posedge clock_in);
  enable = 0;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency != 0) $error("[%t] Output clock is running but should be gated.", $time);

  // Check 2 : Test mode disbale-enable-disable sequence
  $display("CHECK 2 : Test mode disbale-enable-disable sequence.");
  @(posedge clock_in);
  test_enable = 0;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency != 0) $error("[%t] Output clock is running but should be gated.", $time);
  @(posedge clock_in);
  test_enable = 1;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency == 0) $error("[%t] Output clock is gated but should be running.", $time);
  if (clock_out_frequency != clock_in_frequency) $error("[%t] Output clock frequency (%d%s) doesn't match the input clock frequency (%d%s).", $time, clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, clock_in_frequency, FREQUENCY_MEASUREMENT_UNIT);
  @(posedge clock_in);
  test_enable = 0;
  `measure_frequency(clock_out, clock_out_frequency)
  if (clock_out_frequency != 0) $error("[%t] Output clock is running but should be gated.", $time);

  // Check 3 : Clock frequency division with enable
  $display("CHECK 3 : Clock frequency division with enable.");
  @(posedge clock_in);
  fork
    // Stimulus
    begin
      forever begin
        @(posedge clock_in);
        enable = ~enable;
      end
    end
    // Check
    begin
      `measure_frequency(clock_out, clock_out_frequency, FREQUENCY_MEASUREMENT_LENGTH*10)
      if (clock_out_frequency != clock_in_frequency/2) $error("[%t] Output clock frequency (%d%s) isn't equal to the input clock frequency divided by two (%d%s).", $time, clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, clock_in_frequency/2, FREQUENCY_MEASUREMENT_UNIT);
    end
  join_any
  disable fork;

  // Check 4 : Glitch-free output clock
  $display("CHECK 4 : Glitch-free output clock.");
  enable = 0;
  @(posedge clock_in);
  fork
    // Stimulus
    begin
      repeat(RANDOM_GLITCH_CHECK_ITERATIONS) begin
        @(posedge clock_in or negedge clock_in);
        #($urandom_range(CLOCK_PERIOD));
        enable = ~enable;
      end
    end
    // Check
    begin
      forever begin
        @(posedge clock_out);
        time_posedge_clock_out = $time;
        @(negedge clock_out);
        time_negedge_clock_out = $time;
        if (time_negedge_clock_out-time_posedge_clock_out != CLOCK_PERIOD/2) $error("[%t] Glitch detected on the output clock.", $time);
      end
    end
  join_any

  // End of test
  $finish;
end

endmodule
