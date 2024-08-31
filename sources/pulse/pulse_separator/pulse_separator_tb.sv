// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     VerSiTile-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_separator_tb.sv                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the pulse separator.                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module pulse_separator_tb ();

// Test parameters
localparam real    CLOCK_PERIOD        = 10;
localparam integer PULSE_COUNTER_WIDTH = 6;

// Check value
localparam integer SEPARATOR_LATENCY = 1;

// Device ports
logic clock;
logic resetn;
logic pulse_in;
logic pulse_out;
logic busy;

// Test variables
integer test_pulse_count;
integer pulse_count;
integer current_pulse_length;
integer current_pulse_polarity;
bit     waiting_first_pulse;

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
task automatic check_pulse_out(integer expected_pulse_count);
  if (pulse_out) begin
    $error("[%0tns] Output is already high at the start of the check.", $time);
  end
  pulse_count            = 0;
  current_pulse_length   = 0;
  current_pulse_polarity = 0;
  waiting_first_pulse    = 1;
  repeat (expected_pulse_count*4) begin
    @(posedge clock);
    current_pulse_length += 1;
    if (pulse_out != current_pulse_polarity) begin
      if (pulse_out) begin
        pulse_count += 1;
      end
      if (waiting_first_pulse) begin
        if (current_pulse_length > SEPARATOR_LATENCY+1) begin
          $error("[%0tns] Latency of the first pulse is too high.", $time);
        end
      end else if (current_pulse_length > 1) begin
        if (current_pulse_polarity) begin
          $error("[%0tns] Output pulse is more than one cycle wide.", $time);
        end else begin
          $error("[%0tns] Delay between pulses is more that one cycle.", $time);
        end
      end
      current_pulse_polarity = pulse_out;
      current_pulse_length   = 0;
      waiting_first_pulse    = 0;
    end
  end
  if (pulse_out) begin
    $error("[%0tns] Output is still high at the end of the check.", $time);
  end
  if (pulse_count == 0) begin
    $error("[%0tns] No output pulse.", $time);
  end else if (pulse_count > expected_pulse_count) begin
    $error("[%0tns] Too many output pulses.", $time);
  end else if (pulse_count < expected_pulse_count) begin
    $error("[%0tns] Not enough output pulses.", $time);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("pulse_separator_tb.vcd");
  $dumpvars(0,pulse_separator_tb);

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
      repeat (test_pulse_count) @(posedge clock);
      pulse_in = 0;
      @(posedge clock);
    end
    // Check
    begin
      check_pulse_out(test_pulse_count);
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
      check_pulse_out(test_pulse_count);
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
      check_pulse_out(test_pulse_count);
    end
  join

  // Check 4 : Saturating pulse
  $display("CHECK 4 : Saturating pulse.");
  test_pulse_count = 2 ** (PULSE_COUNTER_WIDTH + 1) - 4;
  @(posedge clock);
  fork
    // Stimulus
    begin
      pulse_in = 1;
      while (!busy) begin
        @(posedge clock);
      end
      pulse_in = 0;
    end
    // Check
    begin
      check_pulse_out(test_pulse_count);
    end
  join

  // End of test
  $finish;
end

endmodule
