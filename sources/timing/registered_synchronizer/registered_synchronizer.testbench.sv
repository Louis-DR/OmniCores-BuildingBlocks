// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        registered_synchronizer.testbench.sv                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the registered flip-flop synchronizer.         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "random.svh"
`include "absolute.svh"
`include "real_modulo.svh"



module registered_synchronizer__testbench ();

// Device parameters
localparam int STAGES = 2;

// Test parameters
localparam real CLOCK_SLOW_PERIOD        = 10;
localparam real CLOCK_FAST_PERIOD        = CLOCK_SLOW_PERIOD/3.14159265359;
localparam real CLOCK_PHASE_SHIFT        = CLOCK_FAST_PERIOD*3/2;
localparam real SOURCE_CLOCK_PERIOD      = CLOCK_SLOW_PERIOD;
localparam real DESTINATION_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
localparam int  RANDOM_TEST_DURATION     = 1000;
localparam int  RANDOM_SOURCE_MIN_PULSE  = 1;
localparam int  RANDOM_SOURCE_MAX_PULSE  = 8;
localparam real GLITCH_PERIOD_TOLERANCE  = 0.05;

// Device ports
logic source_clock;
logic source_resetn;
logic destination_clock;
logic destination_resetn;
logic data_in;
logic data_out;

// Test signals
logic presynchronization_stage_model;
logic data_queue [$];
logic data_out_expected;

// Test variables
real time_posedge_data_out;
real time_negedge_data_out;
real data_out_pulse_duration;

// Device under test
registered_synchronizer #(
  .STAGES ( STAGES )
) registered_synchronizer_dut (
  .source_clock       ( source_clock       ),
  .source_resetn      ( source_resetn      ),
  .destination_clock  ( destination_clock  ),
  .destination_resetn ( destination_resetn ),
  .data_in            ( data_in            ),
  .data_out           ( data_out           )
);

// Source clock generation
initial begin
  source_clock = 1;
  if (CLOCK_PHASE_SHIFT < 0) #(-CLOCK_PHASE_SHIFT);
  forever begin
    #(SOURCE_CLOCK_PERIOD/2) source_clock = ~source_clock;
  end
end

// Destination clock generation
initial begin
  destination_clock = 1;
  if (CLOCK_PHASE_SHIFT > 0) #(CLOCK_PHASE_SHIFT);
  forever begin
    #(DESTINATION_CLOCK_PERIOD/2) destination_clock = ~destination_clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("registered_synchronizer.testbench.vcd");
  $dumpvars(0,registered_synchronizer__testbench);

  // Initialization
  data_in = 0;
  presynchronization_stage_model = 0;

  // Reset test
  source_resetn      = 0;
  destination_resetn = 0;
  @(posedge source_clock);
  @(posedge destination_clock);
  source_resetn      = 1;
  destination_resetn = 1;
  @(posedge source_clock);
  @(posedge destination_clock);

  // Check 1: Random test
  $display("CHECK 1 : Random test.");
  fork
    // Stimulus
    begin
      forever begin
        repeat ($urandom_range(RANDOM_SOURCE_MIN_PULSE, RANDOM_SOURCE_MAX_PULSE)) @(negedge source_clock);
        data_in = ~data_in;
        @(posedge source_clock);
        presynchronization_stage_model = data_in;
      end
    end
    // Check output data
    begin
      repeat (RANDOM_TEST_DURATION) begin
        @(posedge destination_clock);
        data_queue.push_back(presynchronization_stage_model);
        #1ps;
        if (data_queue.size() == STAGES) begin
          data_out_expected = data_queue.pop_front();
          assert (data_out === data_out_expected)
            else $error("[%0tns] Ouput data '%b' differs from the expected value '%b'.", $time, data_out, data_out_expected);
        end
      end
    end
    // Check output glitches
    begin
      forever begin
        @(posedge data_out);
        time_posedge_data_out = $realtime;
        @(negedge data_out);
        time_negedge_data_out = $realtime;
        data_out_pulse_duration = time_negedge_data_out - time_posedge_data_out;
        assert (absolute(real_modulo(data_out_pulse_duration, DESTINATION_CLOCK_PERIOD)) < GLITCH_PERIOD_TOLERANCE * DESTINATION_CLOCK_PERIOD)
          else $error("[%0tns] Glitch detected on the output data.", $time);
      end
    end
  join_any
  disable fork;

  // End of test
  $finish;
end

endmodule
