// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        synchronizer_tb.sv                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the regular flip-flop synchronizer.            ║
// ║                                                                           ║
// ║              It verifies for multiple values of the parameter that sets   ║
// ║              the number of stages of the synchronizer that the signal is  ║
// ║              propagated with the expected number of clock cycles of       ║
// ║              delay.                                                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module synchronizer_tb ();

// Test parameters
localparam CLOCK_PERIOD    = 10;
localparam MAX_TEST_STAGES =  5;

// Device ports
logic                     clock;
logic                     resetn;
logic                     data_in;
logic [MAX_TEST_STAGES:1] data_out;

// Test signals
logic [MAX_TEST_STAGES:1] data_out_expected;

// Generate device with different parameter values
generate
  for (genvar stages=1 ; stages<=MAX_TEST_STAGES ; stages++) begin : gen_stages
    // Device under test
    synchronizer #(
      .STAGES   ( stages           )
    ) synchronizer_dut (
      .clock    ( clock            ),
      .resetn   ( resetn           ),
      .data_in  ( data_in          ),
      .data_out ( data_out[stages] )
    );
  end
endgenerate

// Clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Checker task for synchronizer output
task automatic check_data_out(logic [MAX_TEST_STAGES:1] data_out_expected);
  if (data_out != data_out_expected) begin
    $error("[%0tns] Synchronizer output value differs from the expected value (%b != %b).", $time, data_out, data_out_expected);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("synchronizer_tb.vcd");
  $dumpvars(0,synchronizer_tb);

  // Initialization
  data_in = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : low-to-high at 25% of clock cycle
  $display("CHECK 1 : Low-to-high at 25%% of clock cycle.");
  fork
    // Stimulus
    begin
      #(CLOCK_PERIOD*0.25);
      data_in = 1;
    end
    // Check
    begin
      @(posedge clock);
      data_out_expected = MAX_TEST_STAGES'(0);
      check_data_out(data_out_expected);
      @(posedge clock);
      for (int check_step = 0 ; check_step < MAX_TEST_STAGES ; check_step++) begin
        data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b1 };
        check_data_out(data_out_expected);
        @(posedge clock);
      end
      check_data_out(data_out_expected);
      @(posedge clock);
    end
  join

  // Check 2 : high-to-low at 25% of clock cycle
  $display("CHECK 2 : High-to-low at 25%% of clock cycle.");
  fork
    // Stimulus
    begin
      #(CLOCK_PERIOD*0.25);
      data_in = 0;
    end
    // Check
    begin
      @(posedge clock);
      data_out_expected = ~MAX_TEST_STAGES'(0);
      check_data_out(data_out_expected);
      @(posedge clock);
      for (int check_step = 0 ; check_step < MAX_TEST_STAGES ; check_step++) begin
        data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b0 };
        check_data_out(data_out_expected);
        @(posedge clock);
      end
      check_data_out(data_out_expected);
      @(posedge clock);
    end
  join

  // Check 3 : low-to-high at 75% of clock cycle
  $display("CHECK 3 : Low-to-high at 75%% of clock cycle.");
  fork
    // Stimulus
    begin
      #(CLOCK_PERIOD*0.75);
      data_in = 1;
    end
    // Check
    begin
      @(posedge clock);
      data_out_expected = MAX_TEST_STAGES'(0);
      check_data_out(data_out_expected);
      @(posedge clock);
      for (int check_step = 0 ; check_step < MAX_TEST_STAGES ; check_step++) begin
        data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b1 };
        check_data_out(data_out_expected);
        @(posedge clock);
      end
      check_data_out(data_out_expected);
      @(posedge clock);
    end
  join

  // Check 4 : high-to-low at 75% of clock cycle
  $display("CHECK 4 : High-to-low at 75%% of clock cycle.");
  fork
    // Stimulus
    begin
      #(CLOCK_PERIOD*0.75);
      data_in = 0;
    end
    // Check
    begin
      @(posedge clock);
      data_out_expected = ~MAX_TEST_STAGES'(0);
      check_data_out(data_out_expected);
      @(posedge clock);
      for (int check_step = 0 ; check_step < MAX_TEST_STAGES ; check_step++) begin
        data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b0 };
        check_data_out(data_out_expected);
        @(posedge clock);
      end
      check_data_out(data_out_expected);
      @(posedge clock);
    end
  join

  // End of test
  $finish;
end

endmodule
