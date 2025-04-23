// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_first_one_tb.sv                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the fast variant of the first one operation.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "common.svh"



module fast_first_one_tb ();

// Test parameters
localparam WIDTH = 8;

// Device ports
logic [WIDTH-1:0] data;
logic [WIDTH-1:0] first_one;

// Test signals
logic [WIDTH-1:0] first_one_expected;
bool              found_first_one;

// Device under test
fast_first_one #(
  .WIDTH     ( WIDTH     )
) fast_first_one_dut (
  .data      ( data      ),
  .first_one ( first_one )
);

// Main block
initial begin
  // Log waves
  $dumpfile("fast_first_one_tb.vcd");
  $dumpvars(0,fast_first_one_tb);

  // Initialization
  data = 0;

  // Small delay after initialization
  #1;

  // Check 1 : Exhaustive test
  $display("CHECK 1 : Exhaustive test.");
  for (integer data_configuration = 0; data_configuration < 2**WIDTH; data_configuration++) begin
    data = data_configuration;
    // Calculate expected first one position
    first_one_expected = '0;
    found_first_one    = false;
    for (integer data_index = 0; data_index < WIDTH; data_index++) begin
      if (data[data_index] == 1'b1 && !found_first_one) begin
        first_one_expected = (1 << data_index);
        found_first_one    = true;
      end
    end
    // Wait for combinatorial logic propagation
    #1;
    // Check the first one output
    assert (first_one === first_one_expected) else begin
      $error("[%0tns] Incorrect first_one for data configuration %b. Expected %b, got %b.", $time, data_configuration, first_one_expected, first_one);
    end
    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule
