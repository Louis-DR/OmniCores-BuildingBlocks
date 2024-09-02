// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        saturating_counter_tb.sv                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the saturating counter.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module saturating_counter_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 3;
localparam integer RESET        = 0;

// Device ports
logic             clock;
logic             resetn;
logic             increment;
logic             decrement;
logic [WIDTH-1:0] count;

// Test variables
integer min_count = 0;
integer max_count = 2 ** WIDTH - 1;
integer expected_count;

// Device under test
saturating_counter #(
  .WIDTH ( WIDTH ),
  .RESET ( RESET )
) saturating_counter_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .increment ( increment ),
  .decrement ( decrement ),
  .count     ( count     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("saturating_counter_tb.vcd");
  $dumpvars(0,saturating_counter_tb);

  // Initialization
  increment = 0;
  decrement = 0;

  // Reset
  resetn = 0;
  #(CLOCK_PERIOD);
  resetn = 1;
  #(CLOCK_PERIOD);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  if (count != RESET) begin
    $error("[%0tns] Reset value is different than the one given as parameter.", $time);
  end

  // Check 2 : Increment
  $display("CHECK 2 : Increment.");
  expected_count = min_count;
  @(negedge clock);
  increment = 1;
  while (count != max_count) begin
    @(posedge clock);
    expected_count += 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;
  @(posedge clock);

  // Check 3 : Decrement
  $display("CHECK 3 : Decrement.");
  expected_count = max_count;
  @(negedge clock);
  decrement = 1;
  while (count != min_count) begin
    @(posedge clock);
    expected_count -= 1;
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  decrement = 0;
  @(posedge clock);

  // End of test
  $finish;
end

endmodule
