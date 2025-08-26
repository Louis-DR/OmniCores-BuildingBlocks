// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        reset_synchronizer.testbench.sv                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the reset synchronizer.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ps
`include "random.svh"



module reset_synchronizer__testbench ();

// Device parameters
localparam int STAGES = 2;

// Test parameters
localparam real CLOCK_PERIOD         = 10;
localparam int  RANDOM_TEST_DURATION = 1000;

// Device ports
logic clock;
logic resetn_in;
logic resetn_out;

// Test signals
logic resetn_queue [$];
logic resetn_out_expected;

// Test variables
real time_posedge_resetn_out;
real time_negedge_resetn_out;
real resetn_out_pulse_duration;

// Device under test
reset_synchronizer #(
  .STAGES ( STAGES )
) reset_synchronizer_dut (
  .clock      ( clock      ),
  .resetn_in  ( resetn_in  ),
  .resetn_out ( resetn_out )
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
  $dumpfile("reset_synchronizer.testbench.vcd");
  $dumpvars(0,reset_synchronizer__testbench);

  // Initialization
  resetn_in = 0;

  // Reset test
  @(posedge clock);

  // Check 1: Random test
  $display("CHECK 1 : Random test.");
  fork
    // Stimulus
    begin
      forever begin
        #(random_ratio() * CLOCK_PERIOD * STAGES * 2);
        resetn_in = ~resetn_in;
      end
    end
    // Check instant output reset assertion
    begin
      forever begin
        @(negedge resetn_in);
        foreach (resetn_queue[i]) resetn_queue[i] = 0;
        #1ps;
        resetn_out_expected = 0;
        assert (resetn_out === resetn_out_expected)
          else $error("[%0tns] Ouput resetn '%b' differs from the expected value '%b'.", $time, resetn_out, resetn_out_expected);
      end
    end
    // Check synchronized output reset deassertion
    begin
      repeat (RANDOM_TEST_DURATION) begin
        @(posedge clock);
        if (resetn_in) resetn_queue.push_back(resetn_in);
        #1ps;
        if (resetn_queue.size() == STAGES) begin
          resetn_out_expected = resetn_queue.pop_front();
          assert (resetn_out === resetn_out_expected)
            else $error("[%0tns] Ouput resetn '%b' differs from the expected value '%b'.", $time, resetn_out, resetn_out_expected);
        end
      end
    end
    // Check output glitches
    begin
      forever begin
        @(negedge resetn_out);
        time_negedge_resetn_out = $time;
        @(posedge resetn_out);
        time_posedge_resetn_out = $time;
        resetn_out_pulse_duration = time_posedge_resetn_out - time_negedge_resetn_out;
        assert (resetn_out_pulse_duration >= CLOCK_PERIOD)
          else $error("[%0tns] Glitch detected on the output resetn.", $time);
      end
    end
  join_any
  disable fork;

  // End of test
  $finish;
end

endmodule
