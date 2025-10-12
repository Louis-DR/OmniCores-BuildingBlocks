// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        nonstop_clock_multiplexer.testbench.sv                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the glitch-free clock multiplexer.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "boolean.svh"
`include "absolute.svh"



module nonstop_clock_multiplexer__testbench ();

// Device parameters
localparam int STAGES = 2;

// Test parameters
localparam real    CLOCK_0_PERIOD                  = 10;
localparam real    CLOCK_1_PERIOD                  = CLOCK_0_PERIOD/3.14159265359;
localparam string  FREQUENCY_UNIT                  = "MHz";
localparam real    FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;
localparam real    GLITCH_PERIOD_TOLERANCE         = 0.05;
localparam int     BACK_AND_FORTH_ITERATIONS       = 10;
localparam int     RANDOM_GLITCH_CHECK_ITERATIONS  = 100;

// Device ports
logic clock_0;
logic clock_1;
logic resetn_0;
logic resetn_1;
logic select;
logic clock_out;

// Test variables
bool clock_0_active = true;
bool clock_1_active = true;
real clock_0_frequency;
real clock_1_frequency;
real clock_out_frequency;
real expected_clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;

// Device under test
nonstop_clock_multiplexer #(
  .STAGES    ( STAGES     )
) nonstop_clock_multiplexer_dut (
  .clock_0   ( clock_0    ),
  .clock_1   ( clock_1    ),
  .resetn_0  ( resetn_0   ),
  .resetn_1  ( resetn_1   ),
  .select    ( select     ),
  .clock_out ( clock_out  )
);

// Clock 0 generation
initial begin
  clock_0 = 1;
  forever begin
    if (clock_0_active) begin
      #(CLOCK_0_PERIOD/2) clock_0 = ~clock_0;
    end else begin
      #(CLOCK_0_PERIOD/2) clock_0 = 0;
    end
  end
end

// Clock 1 generation
initial begin
  clock_1 = 1;
  forever begin
    if (clock_1_active) begin
      #(CLOCK_1_PERIOD/2) clock_1 = ~clock_1;
    end else begin
      #(CLOCK_1_PERIOD/2) clock_1 = 0;
    end
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("nonstop_clock_multiplexer.testbench.vcd");
  $dumpvars(0,nonstop_clock_multiplexer__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  select = 0;

  // Reset
  resetn_0 = 0;
  resetn_1 = 0;
  @(posedge clock_0);
  @(posedge clock_1);
  resetn_0 = 1;
  resetn_1 = 1;
  @(posedge clock_0);
  @(posedge clock_1);

  // Measure the input clocks frequency
  @(posedge clock_0);
  `MEASURE_FREQUENCY(clock_0, clock_0_frequency)
  @(posedge clock_1);
  `MEASURE_FREQUENCY(clock_1, clock_1_frequency)

  // Check 1 : Switching back and forth between clocks
  $display("CHECK 1 : Switching back and forth between clocks.");
  for (int check_step = 0 ; check_step <= BACK_AND_FORTH_ITERATIONS ; check_step++) begin
    select = ~select;
    #(STAGES*2*(CLOCK_0_PERIOD+CLOCK_1_PERIOD));
    `MEASURE_FREQUENCY(clock_out, clock_out_frequency)
    expected_clock_out_frequency = select ? clock_1_frequency : clock_0_frequency;
    if      (clock_out_frequency == 0) $error("[%t] Output clock is not running with select at %0d.", $realtime, select);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) with select at %0d.",
             $time, clock_out_frequency, FREQUENCY_UNIT, select, expected_clock_out_frequency, FREQUENCY_UNIT, select);
    end
  end

  repeat(5) @(posedge clock_0);
  repeat(5) @(posedge clock_1);

  // Check 2 : Switching between clocks with clock 0 inactive
  $display("CHECK 2 : Switching between clocks with clock 0 inactive.");
  @(negedge clock_0);
  clock_0_active = false;
  clock_1_active = true;
  for (int check_step = 0 ; check_step <= BACK_AND_FORTH_ITERATIONS ; check_step++) begin
    select = ~select;
    #(STAGES*2*(CLOCK_0_PERIOD+CLOCK_1_PERIOD));
    `MEASURE_FREQUENCY(clock_out, clock_out_frequency)
    expected_clock_out_frequency = select ? clock_1_frequency : 0;
    if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) with select at %0d.",
             $time, clock_out_frequency, FREQUENCY_UNIT, select, expected_clock_out_frequency, FREQUENCY_UNIT, select);
    end
  end
  clock_0_active = true;

  repeat(5) @(posedge clock_0);
  repeat(5) @(posedge clock_1);

  // Check 3 : Switching between clocks with clock 1 inactive
  $display("CHECK 3 : Switching between clocks with clock 1 inactive.");
  @(negedge clock_1);
  clock_0_active = true;
  clock_1_active = false;
  for (int check_step = 0 ; check_step <= BACK_AND_FORTH_ITERATIONS ; check_step++) begin
    select = ~select;
    #(STAGES*2*(CLOCK_0_PERIOD+CLOCK_1_PERIOD));
    `MEASURE_FREQUENCY(clock_out, clock_out_frequency)
    expected_clock_out_frequency = select ? 0 : clock_0_frequency;
    if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) with select at %0d.",
             $time, clock_out_frequency, FREQUENCY_UNIT, select, expected_clock_out_frequency, FREQUENCY_UNIT, select);
    end
  end
  clock_0_active = true;
  clock_1_active = true;

  repeat(5) @(posedge clock_0);
  repeat(5) @(posedge clock_1);

  // Check 4 : Glitch-free output clock
  $display("CHECK 4 : Glitch-free output clock.");
  fork
    // Stimulus
    begin
      repeat (RANDOM_GLITCH_CHECK_ITERATIONS) begin
        #($urandom_range(10*STAGES*(CLOCK_0_PERIOD+CLOCK_1_PERIOD)));
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
          $error("[%t] Glitch detected on the output clock.", $realtime);
        end
      end
    end
  join_any

  repeat(5) @(posedge clock_0);
  repeat(5) @(posedge clock_1);

  // End of test
  $finish;
end

endmodule
