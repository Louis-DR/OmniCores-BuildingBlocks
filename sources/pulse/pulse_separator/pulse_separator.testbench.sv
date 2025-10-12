// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_separator.testbench.sv                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the pulse separator.                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "boolean.svh"
`include "random.svh"



module pulse_separator__testbench ();

// Test parameters
localparam real CLOCK_PERIOD        = 10;
localparam int  PULSE_COUNTER_WIDTH = 3;

// Check parameters
localparam int  LONG_PULSE_CHECK_LENGTH        = 4;
localparam int  MULTI_PULSE_CHECK_LENGTH       = 4;
localparam int  RANDOM_CHECK_DURATION          = 1000;
localparam real RANDOM_CHECK_PULSE_PROBABILITY = 0.3;

// Check value
localparam int SEPARATOR_LATENCY = 1;

// Device ports
logic clock;
logic resetn;
logic pulse_in;
logic pulse_out;
logic busy;

// Test variables
int  test_pulse_count;
int  pulse_count;
int  current_pulse_length;
int  current_pulse_polarity;
bool waiting_first_pulse;

// Device under test
pulse_separator #(
  .PULSE_COUNTER_WIDTH ( PULSE_COUNTER_WIDTH )
) pulse_separator_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .pulse_in  ( pulse_in  ),
  .pulse_out ( pulse_out ),
  .busy      ( busy      )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Checker task for output pulse
task automatic check_pulse_out(int duration, bool check_low_time = true);
  if (pulse_out) begin
    $error("[%t] Output is already high at the start of the check.", $realtime);
  end
  pulse_count            = 0;
  current_pulse_length   = 0;
  current_pulse_polarity = 0;
  waiting_first_pulse    = true;
  repeat (duration) begin
    @(posedge clock);
    if (pulse_out != current_pulse_polarity) begin
      if (pulse_out) begin
        pulse_count += 1;
      end
      if (waiting_first_pulse) begin
        if (current_pulse_length > SEPARATOR_LATENCY + 1) begin
          $error("[%t] Latency of the first pulse is too high.", $realtime);
        end
      end else if (current_pulse_length > 1) begin
        if (current_pulse_polarity) begin
          $error("[%t] Output pulse is more than one cycle wide.", $realtime);
        end else if (check_low_time) begin
          $error("[%t] Delay between pulses is more that one cycle.", $realtime);
        end
      end
      current_pulse_polarity = pulse_out;
      current_pulse_length   = 0;
      waiting_first_pulse    = false;
    end
    current_pulse_length += 1;
  end
  if (pulse_out) begin
    $error("[%t] Output is still high at the end of the check.", $realtime);
  end
endtask

// Checker task for output pulse
task automatic check_pulse_count(int expected_pulse_count);
  if (pulse_count == 0) begin
    $error("[%t] No output pulse.", $realtime);
  end else if (pulse_count > expected_pulse_count) begin
    $error("[%t] Too many output pulses. Received '%0d' but expected '%0d'", $realtime, pulse_count, expected_pulse_count);
  end else if (pulse_count < expected_pulse_count) begin
    $error("[%t] Not enough output pulses. Received '%0d' but expected '%0d'", $realtime, pulse_count, expected_pulse_count);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("pulse_separator.testbench.vcd");
  $dumpvars(0,pulse_separator__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  pulse_in = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Single one-cycle pulse
  $display("CHECK 1 : Single one-cycle pulse.");
  test_pulse_count = 1;
  fork
    // Stimulus
    begin
      @(negedge clock);
      pulse_in = 1;
      @(negedge clock);
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join
  check_pulse_count(test_pulse_count);

  repeat(10) @(posedge clock);

  // Check 2 : Single multi-cycle pulse
  $display("CHECK 2 : Single multi-cycle pulse.");
  test_pulse_count = LONG_PULSE_CHECK_LENGTH;
  fork
    // Stimulus
    begin
      @(negedge clock);
      pulse_in = 1;
      repeat (test_pulse_count) @(negedge clock);
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join
  check_pulse_count(test_pulse_count);

  repeat(10) @(posedge clock);

  // Check 3 : Multiple single-cycle pulses
  $display("CHECK 3 : Multiple single-cycle pulses.");
  test_pulse_count = MULTI_PULSE_CHECK_LENGTH;
  fork
    // Stimulus
    begin
      repeat (test_pulse_count) begin
        @(negedge clock);
        pulse_in = 1;
        @(negedge clock);
        pulse_in = 0;
      end
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join
  check_pulse_count(test_pulse_count);

  repeat(10) @(posedge clock);

  // Check 4 : Saturating pulse
  $display("CHECK 4 : Saturating pulse.");
  test_pulse_count = 2 ** (PULSE_COUNTER_WIDTH + 1) - 4;
  fork
    // Stimulus
    begin
      @(negedge clock);
      pulse_in = 1;
      while (!busy) begin
        @(negedge clock);
      end
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(test_pulse_count*4);
    end
  join
  check_pulse_count(test_pulse_count);

  repeat(10) @(posedge clock);

  // Check 5 : Random stimulus
  $display("CHECK 5 : Random stimulus.");
  test_pulse_count = 1;
  fork
    // Stimulus
    begin
      @(negedge clock);
      pulse_in = 1;
      repeat (RANDOM_CHECK_DURATION) begin
        @(negedge clock);
        // Random pulse if not busy
        pulse_in = random_boolean(RANDOM_CHECK_PULSE_PROBABILITY) & ~busy;
        test_pulse_count += pulse_in;
      end
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(RANDOM_CHECK_DURATION*2, false);
    end
  join
  check_pulse_count(test_pulse_count);

  // End of test
  $finish;
end

endmodule
