// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wide_clock_multiplexer.testbench.sv                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the glitch-free wide clock multiplexer.        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "measure_frequency.svh"
`include "absolute.svh"
`include "boolean.svh"



module wide_clock_multiplexer__testbench ();

// Device parameters
localparam int STAGES       = 2;
localparam int CLOCKS       = 3;
localparam int SELECT_WIDTH = $clog2(CLOCKS);

// Test parameters
localparam real   LOWER_CLOCK_PERIOD              = 10;
localparam real   UPPER_CLOCK_PERIOD              = 5*LOWER_CLOCK_PERIOD;
localparam string FREQUENCY_UNIT                  = "MHz";
localparam real   FREQUENCY_MEASUREMENT_TOLERANCE = 0.05;
localparam real   GLITCH_PERIOD_TOLERANCE         = 0.05;
localparam int    BACK_AND_FORTH_ITERATIONS       = 10;
localparam int    RANDOM_GLITCH_CHECK_ITERATIONS  = 100;

// Device ports
logic       [CLOCKS-1:0] clocks;
logic       [CLOCKS-1:0] resetns;
logic [SELECT_WIDTH-1:0] select;
logic                    clock_out;

// Test variables
real clocks_frequency [CLOCKS-1:0] ;
real clock_out_frequency;
real expected_clock_out_frequency;
real time_posedge_clock_out;
real time_negedge_clock_out;
bool pulse_width_valid;

// Device under test
wide_clock_multiplexer #(
  .STAGES    ( STAGES    ),
  .CLOCKS    ( CLOCKS    )
) wide_clock_multiplexer_dut (
  .clocks    ( clocks    ),
  .resetns   ( resetns   ),
  .select    ( select    ),
  .clock_out ( clock_out )
);

// Initialize clock periods
real clock_periods [CLOCKS-1:0];
initial begin
  for (int clock_index = 0; clock_index < CLOCKS; clock_index++) begin
    clock_periods[clock_index] = LOWER_CLOCK_PERIOD + clock_index * (UPPER_CLOCK_PERIOD - LOWER_CLOCK_PERIOD) / (CLOCKS - 1);
  end
end

// Clock generation for all clocks
genvar clock_index;
generate
  for (clock_index = 0; clock_index < CLOCKS; clock_index++) begin : gen_clocks
    initial begin
      clocks[clock_index] = 1;
      forever begin
        #(clock_periods[clock_index]/2) clocks[clock_index] = ~clocks[clock_index];
      end
    end
  end
endgenerate

// Main block
initial begin
  // Log waves
  $dumpfile("wide_clock_multiplexer.testbench.vcd");
  $dumpvars(0,wide_clock_multiplexer__testbench);

  // Initialization
  select = 0;

  // Reset
  resetns = '0;
  @(posedge clocks[0]);
  @(posedge clocks[CLOCKS-1]);
  resetns = '1;
  @(posedge clocks[0]);
  @(posedge clocks[CLOCKS-1]);

  // Measure the input clocks frequency
  for (int clock_index = 0; clock_index < CLOCKS; clock_index++) begin
    @(posedge clocks[clock_index]);
    `measure_frequency(clocks[clock_index], clocks_frequency[clock_index])
  end

  // Check 1 : Switching back and forth between clocks
  $display("CHECK 1 : Switching back and forth between clocks.");
  for (int check_step = 0; check_step <= BACK_AND_FORTH_ITERATIONS; check_step++) begin
    select = (select + 1) % CLOCKS;
    #(STAGES*2*UPPER_CLOCK_PERIOD);
    `measure_frequency(clock_out, clock_out_frequency)
    expected_clock_out_frequency = clocks_frequency[select];
    if      (clock_out_frequency == 0) $error("[%t] Output clock is not running with select at %0d.", $time, select);
    else if (absolute(expected_clock_out_frequency - clock_out_frequency) > FREQUENCY_MEASUREMENT_TOLERANCE * expected_clock_out_frequency) begin
      $error("[%t] Output clock frequency (%d%s) doesn't match the expected clock %0d frequency (%d%s) with select at %0d.",
             $time, clock_out_frequency, FREQUENCY_UNIT, select, expected_clock_out_frequency, FREQUENCY_UNIT, select);
    end
  end

  // Check 2 : Glitch-free output clock
  $display("CHECK 2 : Glitch-free output clock.");
  fork
    // Stimulus
    begin
      repeat (RANDOM_GLITCH_CHECK_ITERATIONS) begin
        #($urandom_range(10*STAGES*UPPER_CLOCK_PERIOD));
        select = $urandom_range(0, CLOCKS-1);
      end
    end
    // Check
    begin
      forever begin
        @(posedge clock_out);
        time_posedge_clock_out = $realtime;
        @(negedge clock_out);
        time_negedge_clock_out = $realtime;
        // Check if the pulse width matches any of the expected clock periods
        pulse_width_valid = false;
        for (int clock_index = 0; clock_index < CLOCKS; clock_index++) begin
          if (absolute(time_negedge_clock_out-time_posedge_clock_out - clock_periods[clock_index]/2) <= GLITCH_PERIOD_TOLERANCE * clock_periods[clock_index]/2) begin
            pulse_width_valid = true;
`ifndef SIMUMLATOR_NO_BREAK
            break;
`endif
          end
        end
        if (!pulse_width_valid) begin
          $error("[%t] Glitch detected on the output clock.", $time);
        end
      end
    end
  join_any

  // End of test
  $finish;
end

endmodule
