// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        jk_flip_flop_with_reset.testbench.sv                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the JK flip-flop with asynchronous reset.      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module jk_flip_flop_with_reset__testbench ();

// Test parameters
localparam CLOCK_PERIOD = 10;

// Check parameters
localparam integer RANDOM_CHECK_DURATION = 1000;

// Device ports
logic clock;
logic resetn;
logic j;
logic k;
logic state;

// Test signals
logic state_expected;

// Device under test
jk_flip_flop_with_reset jk_flip_flop_with_reset_dut (
  .clock  ( clock  ),
  .resetn ( resetn ),
  .j      ( j      ),
  .k      ( k      ),
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
  $dumpfile("jk_flip_flop_with_reset.testbench.vcd");
  $dumpvars(0,jk_flip_flop_with_reset__testbench);

  // Initialization
  j = 0;
  k = 0;

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
    case ($urandom_range(0, 3))
      0: begin j = 0; k = 0; end
      1: begin j = 1; k = 0; end
      2: begin j = 0; k = 1; end
      3: begin j = 1; k = 1; end
    endcase
    @(posedge clock);
    if (j && k) state_expected = ~state_expected;
    else if (j) state_expected = 1;
    else if (k) state_expected = 0;
    #1;
    assert (state === state_expected)
      else $error("[%0tns] State output value differs from the expected value (%b != %b).", $time, state, state_expected);
  end

  // End of test
  $finish;
end

endmodule
