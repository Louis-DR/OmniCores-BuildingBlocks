// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_extender_tb.sv                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the pulse extender.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "common.svh"



module pulse_extender_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer PULSE_LENGTH = 2;

// Check value
localparam integer EXTENDER_LATENCY = 1;

// Device ports
logic clock;
logic resetn;
logic pulse_in;
logic pulse_out;

// Test variables
integer test_pulse_count;
integer pulse_count;
integer current_pulse_length;
integer current_pulse_polarity;
bool    waiting_first_pulse;

// Device under test
pulse_extender #(
  .PULSE_LENGTH ( PULSE_LENGTH )
) pulse_extender_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .pulse_in  ( pulse_in  ),
  .pulse_out ( pulse_out )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Checker task for output pulse
task automatic check_pulse_out(integer duration);
  if (pulse_out) begin
    $error("[%0tns] Output is already high at the start of the check.", $time);
  end
  current_pulse_length   = 0;
  current_pulse_polarity = 0;
  repeat (duration) begin
    @(posedge clock);
    current_pulse_length += 1;
    if (pulse_out != current_pulse_polarity) begin
      if (current_pulse_polarity && current_pulse_length < PULSE_LENGTH) begin
        if (current_pulse_polarity) begin
          $error("[%0tns] Output pulse is narrower than the extender parameter.", $time);
        end
      end
      current_pulse_polarity = pulse_out;
      current_pulse_length   = 0;
    end
  end
  if (pulse_out) begin
    $error("[%0tns] Output is still high at the end of the check.", $time);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("pulse_extender_tb.vcd");
  $dumpvars(0,pulse_extender_tb);

  // Initialization
  pulse_in = 0;

  // Reset
  resetn = 0;
  #(CLOCK_PERIOD);
  resetn = 1;
  #(CLOCK_PERIOD);

  // Check 1 : Single one-cycle pulse
  $display("CHECK 1 : Single one-cycle pulse.");
  test_pulse_count = 1;
  @(posedge clock);
  fork
    // Stimulus
    begin
      pulse_in = 1;
      @(posedge clock);
      pulse_in = 0;
      @(posedge clock);
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join

  // Check 2 : Single multi-cycle pulse
  $display("CHECK 2 : Single multi-cycle pulse.");
  test_pulse_count = 4;
  @(posedge clock);
  fork
    // Stimulus
    begin
      pulse_in = 1;
      repeat (test_pulse_count) @(posedge clock);
      pulse_in = 0;
      @(posedge clock);
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join

  // Check 3 : Multiple single-cycle pulses
  $display("CHECK 3 : Multiple single-cycle pulses.");
  test_pulse_count = 4;
  @(posedge clock);
  fork
    // Stimulus
    begin
      repeat (test_pulse_count) begin
        pulse_in = 1;
        @(posedge clock);
        pulse_in = 0;
        @(posedge clock);
      end
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join

  // Check 5 : Random stimulus
  $display("CHECK 5 : Random stimulus.");
  test_pulse_count = 1;
  @(posedge clock);
  fork
    // Stimulus
    begin
      pulse_in = 1;
      @(posedge clock);
      repeat(100) begin
        // Random pulse in with low being twice as likely
        pulse_in = $urandom_range(2);
        test_pulse_count += pulse_in;
        @(posedge clock);
      end
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(100*2);
    end
  join

  // End of test
  $finish;
end

endmodule
