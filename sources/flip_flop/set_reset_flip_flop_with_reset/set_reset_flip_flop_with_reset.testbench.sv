// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        set_reset_flip_flop_with_reset.testbench.sv                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the set-reset flip-flop with asynchronous      ║
// ║              reset.                                                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module set_reset_flip_flop_with_reset__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int RANDOM_CHECK_DURATION = 1000;

// Device ports
logic clock;
logic resetn;
logic set;
logic reset;
logic state;

// Test signals
logic state_expected;

// Device under test
set_reset_flip_flop_with_reset set_reset_flip_flop_with_reset_dut (
  .clock  ( clock  ),
  .resetn ( resetn ),
  .set    ( set    ),
  .reset  ( reset  ),
  .state  ( state  )
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
  $dumpfile("set_reset_flip_flop_with_reset.testbench.vcd");
  $dumpvars(0,set_reset_flip_flop_with_reset__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  set   = 0;
  reset = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Random stimulus
  $display("CHECK 1 : Random stimulus.");
  state_expected = 0;
  repeat (RANDOM_CHECK_DURATION) begin
    @(negedge clock);
    case ($urandom_range(0, 2))
      0: begin set = 0; reset = 0; end
      1: begin set = 1; reset = 0; end
      2: begin set = 0; reset = 1; end
    endcase
    @(posedge clock);
    if      (set)   state_expected = 1;
    else if (reset) state_expected = 0;
    #1;
    assert (state === state_expected)
      else $error("[%t] State output value differs from the expected value (%b != %b).", $realtime, state, state_expected);
  end

  // End of test
  $finish;
end

endmodule
