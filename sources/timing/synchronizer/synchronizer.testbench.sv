// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        synchronizer.testbench.sv                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the regular flip-flop synchronizer.            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ps
`include "random.svh"
`include "absolute.svh"
`include "real_modulo.svh"



module synchronizer__testbench ();

// Device parameters
localparam int STAGES = 2;

// Test parameters
localparam real CLOCK_PERIOD            = 10;
localparam int  RANDOM_TEST_DURATION    = 1000;
localparam real GLITCH_PERIOD_TOLERANCE = 0.05;

// Device ports
logic clock;
logic resetn;
logic data_in;
logic data_out;

// Test signals
logic data_queue [$];
logic data_out_expected;

// Test variables
real time_posedge_data_out;
real time_negedge_data_out;
real data_out_pulse_duration;

// Device under test
synchronizer #(
  .STAGES ( STAGES )
) synchronizer_dut (
  .clock    ( clock    ),
  .resetn   ( resetn   ),
  .data_in  ( data_in  ),
  .data_out ( data_out )
);

// Clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("synchronizer.testbench.vcd");
  $dumpvars(0,synchronizer__testbench);

  // Initialization
  data_in = 0;

  // Reset test
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1: Random test
  $display("CHECK 1 : Random test.");
  fork
    // Stimulus
    begin
      forever begin
        #(random_ratio() * CLOCK_PERIOD * STAGES);
        data_in = ~data_in;
      end
    end
    // Check output data
    begin
      repeat (RANDOM_TEST_DURATION) begin
        @(posedge clock);
        data_queue.push_back(data_in);
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
        time_posedge_data_out = $time;
        @(negedge data_out);
        time_negedge_data_out = $time;
        data_out_pulse_duration = time_negedge_data_out - time_posedge_data_out;
        assert (absolute(real_modulo(data_out_pulse_duration, CLOCK_PERIOD)) < GLITCH_PERIOD_TOLERANCE * CLOCK_PERIOD)
          else $error("[%0tns] Glitch detected on the output data.", $time);
      end
    end
  join_any
  disable fork;

  // End of test
  $finish;
end

endmodule
