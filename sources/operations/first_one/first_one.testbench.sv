// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        first_one.testbench.sv                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the first one operation wrapper.               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "boolean.svh"



module first_one__testbench ();

// Test parameters
localparam int WIDTH = 8;

// Device ports
logic [WIDTH-1:0] data;
logic [WIDTH-1:0] first_one_small;
logic [WIDTH-1:0] first_one_fast;

// Test signals
logic [WIDTH-1:0] first_one_expected;
bool              found_first_one;

// Devices under test
first_one #(
  .WIDTH    ( WIDTH           ),
  .VARIANT  ( "small"         )
) small_first_one_dut (
  .data     ( data            ),
  .first_one( first_one_small )
);

first_one #(
  .WIDTH    ( WIDTH          ),
  .VARIANT  ( "fast"         )
) fast_first_one_dut (
  .data     ( data           ),
  .first_one( first_one_fast )
);

// Main block
initial begin
  // Log waves
  $dumpfile("first_one.testbench.vcd");
  $dumpvars(0,first_one__testbench);

  // Initialization
  data = 0;

  // Small delay after initialization
  #1;

  // Check 1 : Exhaustive test
  $display("CHECK 1 : Exhaustive test.");
  for (int data_configuration = 0; data_configuration < 2**WIDTH; data_configuration++) begin
    data = data_configuration;
    // Calculate expected first one position
    first_one_expected = '0;
    found_first_one    = false;
    for (int data_index = 0; data_index < WIDTH; data_index++) begin
      if (data[data_index] && !found_first_one) begin
        first_one_expected = (1 << data_index);
        found_first_one    = true;
      end
    end
    // Wait for combinatorial logic propagation
    #1;
    // Check the first one output
    assert (first_one_small === first_one_expected)
      else $error("[%0tns] Incorrect first_one (small) for data configuration %b. Expected %b, got %b.", $time, data_configuration, first_one_expected, first_one_small);
    assert (first_one_fast === first_one_expected)
      else $error("[%0tns] Incorrect first_one (fast) for data configuration %b. Expected %b, got %b.", $time, data_configuration, first_one_expected, first_one_fast);
    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule
