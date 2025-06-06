// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        set_reset_flip_flop_with_asynchronous_reset.testbench.sv     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the set-reset flip-flop with asynchronous      ║
// ║              reset.                                                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module set_reset_flip_flop_with_asynchronous_reset__testbench ();

// Test parameters
localparam CLOCK_PERIOD = 10;

// Check parameters
localparam integer RANDOM_CHECK_DURATION = 1000;

// Device ports
logic clock;
logic resetn;
logic set;
logic reset;
logic state;

// Test signals
logic state_expected;

// Device under test
set_reset_flip_flop_with_asynchronous_reset set_reset_flip_flop_with_asynchronous_reset_dut (
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
  $dumpfile("set_reset_flip_flop_with_asynchronous_reset.testbench.vcd");
  $dumpvars(0,set_reset_flip_flop_with_asynchronous_reset__testbench);

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
      else $error("[%0tns] State output value differs from the expected value (%b != %b).", $time, state, state_expected);
  end

  // End of test
  $finish;
end

endmodule
