// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fibonacci_lfsr.testbench.sv                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Fibonacci linear feedback shift register.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module fibonacci_lfsr__testbench ();

// Device parameters
localparam int WIDTH = 8;
localparam int SEED  = 1;

// Derived parameters
localparam int MAXIMAL_LENGTH = 2 ** WIDTH - 1;

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Device ports
logic             clock;
logic             resetn;
logic             enable;
logic [WIDTH-1:0] value;

// Test variables
int check;
int count;

// Device under test
fibonacci_lfsr #(
  .WIDTH ( WIDTH ),
  .SEED  ( SEED  )
) fibonacci_lfsr_dut (
  .clock  ( clock  ),
  .resetn ( resetn ),
  .enable ( enable ),
  .value  ( value  )
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
  $dumpfile("fibonacci_lfsr.testbench.vcd");
  $dumpvars(0,fibonacci_lfsr__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  enable = 0;

  // Reset
  @(posedge clock);
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value."); check = 1;
  assert(value === SEED) else $error("[%t] LFSR value should be equal to the seed after reset.", $realtime);

  repeat(10) @(posedge clock);

  // Check 2 : Disabled state
  $display("CHECK 2 : Disabled state."); check = 2;
  @(negedge clock);
  enable = 0;
  @(posedge clock); #1;
  assert(value === SEED) else $error("[%t] LFSR value should not change when disabled.", $realtime);

  repeat(10) @(posedge clock);

  // Check 3 : Maximal length sequence
  $display("CHECK 3 : Maximal length sequence."); check = 3;
  count  = 0;
  @(negedge clock);
  enable = 1;
  do begin
    @(posedge clock); #1;
    assert(value !== 0) else $error("[%t] LFSR value should never be 0 when seed is not zero.", $realtime);
    count++;
  end while (value !== SEED && count <= MAXIMAL_LENGTH + 1);
  assert(count <=  MAXIMAL_LENGTH) else $error("[%t] LFSR sequence exceeded maximal length limit without repeating.", $realtime);
  assert(count === MAXIMAL_LENGTH) else $error("[%t] LFSR sequence length '%0d' does not match expected maximal length '%0d'.", $realtime, count, MAXIMAL_LENGTH);
  @(negedge clock);
  enable = 0;

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
