// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_multiplexer__testbench.sv                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the glitch-free clock multiplexer.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs



module clock_multiplexer__testbench ();

// Test parameters
localparam integer DUT_STAGES                       = 2;
localparam real    CLOCK_0_PERIOD                   = 10;
localparam real    CLOCK_1_PERIOD                   = CLOCK_0_PERIOD*2;
localparam integer FREQUENCY_MEASUREMENT_LENGTH     = 100;
localparam integer FREQUENCY_MEASUREMENT_MULTIPLIER = 1e3;
localparam         FREQUENCY_MEASUREMENT_UNIT       = "MHz";
localparam integer FREQUENCY_MEASUREMENT_TIMEOUT    = FREQUENCY_MEASUREMENT_LENGTH * CLOCK_0_PERIOD * 100;
localparam real    FREQUENCY_MEASUREMENT_TOLERANCE  = 0.05;
localparam real    GLITCH_PERIOD_TOLERANCE          = 0.05;
localparam integer BACK_AND_FORTH_ITERATIONS        = 10;
localparam integer RANDOM_GLITCH_CHECK_ITERATIONS   = 100;

// Device ports
logic clock_0;
logic clock_1;
logic resetn;
logic select;
logic clock_out;

// Test variables
real clock_0_frequency;
real clock_1_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;

// Device under test
clock_multiplexer #(
  .STAGES      ( DUT_STAGES  )
) clock_multiplexer_dut (
  .clock_0     ( clock_0     ),
  .clock_1     ( clock_1     ),
  .resetn      ( resetn      ),
  .select      ( select      ),
  .clock_out   ( clock_out   )
);

// Clock 0 generation
initial begin
  clock_0 = 1;
  forever begin
    #(CLOCK_0_PERIOD/2) clock_0 = ~clock_0;
  end
end

// Clock 1 generation
initial begin
  clock_1 = 1;
  forever begin
    #(CLOCK_1_PERIOD/2) clock_1 = ~clock_1;
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

// Absolute value of real number
function real absolute(input real x);
  return (x >= 0.0) ? x : -x;
endfunction

// Main block
initial begin
  // Log waves
  $dumpfile("clock_multiplexer__testbench.vcd");
  $dumpvars(0,clock_multiplexer__testbench);

  // Initialization
  select = 0;

  // Reset
  resetn = 0;
  @(posedge clock_0);
  @(posedge clock_1);
  resetn = 1;
  @(posedge clock_0);
  @(posedge clock_1);

  // Measure the input clocks frequency
  @(posedge clock_0);
  `measure_frequency(clock_0, clock_0_frequency)
  @(posedge clock_1);
  `measure_frequency(clock_1, clock_1_frequency)

  // Check 1 : Switching back and forth between clocks
  $display("CHECK 1 : Switching back and forth between clocks.");
  for (integer check_step = 0; check_step <= BACK_AND_FORTH_ITERATIONS; check_step++) begin
    select = ~select;
    #(DUT_STAGES*2*(CLOCK_0_PERIOD+CLOCK_1_PERIOD));
    `measure_frequency(clock_out, clock_out_frequency)
    expected_clock_out_frequency = select ? clock_1_frequency : clock_0_frequency;
    if      (clock_out_frequency == 0) $error("[%t] Output clock is not running with select at %0d.", $time, select);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) with select at %0d.",
             $time, clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, select, expected_clock_out_frequency, FREQUENCY_MEASUREMENT_UNIT, select);
    end
  end

  // Check 2 : Glitch-free output clock
  $display("CHECK 2 : Glitch-free output clock.");
  fork
    // Stimulus
    begin
      repeat(RANDOM_GLITCH_CHECK_ITERATIONS) begin
        #($urandom_range(10*DUT_STAGES*(CLOCK_0_PERIOD+CLOCK_1_PERIOD)));
        select = ~select;
      end
    end
    // Check
    begin
      forever begin
        @(posedge clock_out);
        time_posedge_clock_out = $realtime;
        @(negedge clock_out);
        time_negedge_clock_out = $realtime;
        if (   absolute(time_negedge_clock_out-time_posedge_clock_out - CLOCK_0_PERIOD/2) > GLITCH_PERIOD_TOLERANCE * CLOCK_0_PERIOD/2
            && absolute(time_negedge_clock_out-time_posedge_clock_out - CLOCK_1_PERIOD/2) > GLITCH_PERIOD_TOLERANCE * CLOCK_1_PERIOD/2) begin
          $error("[%t] Glitch detected on the output clock.", $time);
        end
      end
    end
  join_any

  // End of test
  $finish;
end

endmodule
