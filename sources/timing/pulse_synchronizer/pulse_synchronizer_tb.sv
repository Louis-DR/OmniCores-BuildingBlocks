// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_synchronizer_tb.sv                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the pulse synchronizer.                        ║
// ║                                                                           ║
// ║              It verifies for multiple number of synchronizing stages and  ║
// ║              different source and destination clock ratios that the pulse ║
// ║              is propagated with the expected width and delay.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ps



module pulse_synchronizer_tb ();

// Test parameters
localparam real    CLOCK_SLOW_PERIOD = 10;
localparam real    CLOCK_FAST_PERIOD = CLOCK_SLOW_PERIOD/3;
localparam real    CLOCK_PHASE_SHIFT = CLOCK_FAST_PERIOD*3/2;
localparam integer MAX_TEST_STAGES   = 5;

// Variable frequency test clocks
real SOURCE_CLOCK_PERIOD      = CLOCK_SLOW_PERIOD;
real DESTINATION_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;

// Device ports
logic                     source_clock;
logic                     destination_clock;
logic                     resetn;
logic                     pulse_in;
logic [MAX_TEST_STAGES:1] pulse_out;

// Test signals
logic [MAX_TEST_STAGES:1] pulse_out_expected;

// Generate device with different parameter values
generate
  for (genvar stages=1 ; stages<=MAX_TEST_STAGES ; stages++) begin : gen_stages
    // Device under test
    pulse_synchronizer #(
      .STAGES            ( stages            )
    ) pulse_synchronizer_dut (
      .source_clock      ( source_clock      ),
      .destination_clock ( destination_clock ),
      .resetn            ( resetn            ),
      .pulse_in          ( pulse_in          ),
      .pulse_out         ( pulse_out[stages] )
    );
  end
endgenerate

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

// Checker task for synchronizer output
task automatic check_pulse_out(logic [MAX_TEST_STAGES:1] pulse_out_expected);
  if (pulse_out != pulse_out_expected) begin
    $error("[%0tns] Synchronizer output value differs from the expected value (%b != %b).", $time, pulse_out, pulse_out_expected);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("pulse_synchronizer_tb.vcd");
  $dumpvars(0,pulse_synchronizer_tb);

  // Initialization
  pulse_in = 0;

  // Reset
  resetn = 0;
  #(SOURCE_CLOCK_PERIOD+DESTINATION_CLOCK_PERIOD);
  resetn = 1;
  #(SOURCE_CLOCK_PERIOD+DESTINATION_CLOCK_PERIOD);

  // Check 1 : Between same frequencies
  $display("CHECK 1 : Between same frequencies.");
  SOURCE_CLOCK_PERIOD      = CLOCK_SLOW_PERIOD;
  DESTINATION_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
  @(posedge destination_clock);
  fork
    // Stimulus
    begin
      @(posedge source_clock);
      pulse_in = 1;
      @(posedge source_clock);
      pulse_in = 0;
      @(posedge source_clock);
    end
    // Check
    begin
      pulse_out_expected = MAX_TEST_STAGES'(0);
      check_pulse_out(pulse_out_expected);
      @(posedge destination_clock);
      pulse_out_expected = { (MAX_TEST_STAGES-1)'(0) , 1'b1 };
      for (int check_step = 0 ; check_step <= MAX_TEST_STAGES*2 ; check_step++) begin
        @(posedge destination_clock);
        check_pulse_out(pulse_out_expected);
        pulse_out_expected = { pulse_out_expected[MAX_TEST_STAGES-1:1] , 1'b0};
      end
    end
  join

  // Check 2 : Fast to slow
  $display("CHECK 2 : Fast to slow.");
  SOURCE_CLOCK_PERIOD      = CLOCK_FAST_PERIOD;
  DESTINATION_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
  @(posedge destination_clock);
  fork
    // Stimulus
    begin
      @(posedge source_clock);
      pulse_in = 1;
      @(posedge source_clock);
      pulse_in = 0;
      @(posedge source_clock);
    end
    // Check
    begin
      pulse_out_expected = MAX_TEST_STAGES'(0);
      check_pulse_out(pulse_out_expected);
      @(posedge destination_clock);
      pulse_out_expected = { (MAX_TEST_STAGES-1)'(0) , 1'b1 };
      for (int check_step = 0 ; check_step <= MAX_TEST_STAGES*2 ; check_step++) begin
        @(posedge destination_clock);
        check_pulse_out(pulse_out_expected);
        pulse_out_expected = { pulse_out_expected[MAX_TEST_STAGES-1:1] , 1'b0};
      end
    end
  join

  // Check 3 : Slow to fast
  $display("CHECK 3 : Slow to fast.");
  SOURCE_CLOCK_PERIOD      = CLOCK_SLOW_PERIOD;
  DESTINATION_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
  @(posedge source_clock);
  fork
    // Stimulus
    begin
      pulse_in = 1;
      @(posedge source_clock);
      pulse_in = 0;
      @(posedge source_clock);
    end
    // Check
    begin
      pulse_out_expected = MAX_TEST_STAGES'(0);
      check_pulse_out(pulse_out_expected);
      @(posedge destination_clock);
      pulse_out_expected = { (MAX_TEST_STAGES-1)'(0) , 1'b1 };
      for (int check_step = 0 ; check_step <= MAX_TEST_STAGES*2 ; check_step++) begin
        @(posedge destination_clock);
        check_pulse_out(pulse_out_expected);
        pulse_out_expected = { pulse_out_expected[MAX_TEST_STAGES-1:1] , 1'b0};
      end
    end
  join

  // End of test
  $finish;
end

endmodule
