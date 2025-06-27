// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        toggle_flip_flop_with_reset.testbench.sv                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the toggle flip-flop with asynchronous reset.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module toggle_flip_flop_with_reset__testbench ();

// Test parameters
localparam CLOCK_PERIOD = 10;

// Check parameters
localparam integer RANDOM_CHECK_DURATION = 1000;

// Device ports
logic clock;
logic resetn;
logic toggle;
logic state;

// Test signals
logic state_expected;

// Device under test
toggle_flip_flop_with_reset toggle_flip_flop_with_reset_dut (
  .clock  ( clock  ),
  .resetn ( resetn ),
  .toggle ( toggle ),
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
  $dumpfile("toggle_flip_flop_with_reset.testbench.vcd");
  $dumpvars(0,toggle_flip_flop_with_reset__testbench);

  // Initialization
  toggle = 0;

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
    toggle = random_boolean(0.5);
    @(posedge clock);
    if (toggle) state_expected = ~state_expected;
    #1;
    assert (state === state_expected)
      else $error("[%0tns] State output value differs from the expected value (%b != %b).", $time, state, state_expected);
  end

  // End of test
  $finish;
end

endmodule
