// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        array_select.testbench.sv                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the array select module.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module array_select__testbench ();

// Device parameters
localparam int ELEMENT_WIDTH = 8;
localparam int ARRAY_SIZE    = 4;
localparam int SELECT_ONEHOT = 0;

// Derived parameters
localparam int SELECT_WIDTH  = SELECT_ONEHOT ? ARRAY_SIZE : $clog2(ARRAY_SIZE);

// Test parameters
localparam int  RANDOM_CHECK_ITERATIONS = 1000;

// Device ports
logic [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] array;
logic                   [SELECT_WIDTH-1:0] select;
logic                  [ELEMENT_WIDTH-1:0] element;

// Test signals
int                       select_index;
logic [ELEMENT_WIDTH-1:0] expected_element;

// Device under test
array_select #(
  .ELEMENT_WIDTH ( ELEMENT_WIDTH ),
  .ARRAY_SIZE    ( ARRAY_SIZE    ),
  .SELECT_ONEHOT ( SELECT_ONEHOT )
) array_select_dut (
  .array         ( array         ),
  .select        ( select        ),
  .element       ( element       )
);

// Main block
initial begin
  // Log waves
  $dumpfile("array_select.testbench.vcd");
  $dumpvars(0,array_select__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  array  = '0;
  select = '0;

  // Small delay after initialization
  #1;

  // Check 1 : Random stimulus
  $display("CHECK 1 : Random stimulus.");
  repeat (RANDOM_CHECK_ITERATIONS) begin
    // Random stimulus
    for (int array_index = 0; array_index < ARRAY_SIZE; array_index++) begin
      array[array_index] = $urandom();
    end

    if (SELECT_ONEHOT) begin
      select_index = $urandom_range(0, ARRAY_SIZE);
      if (select_index == ARRAY_SIZE) begin
        select           = '0;
        expected_element = '0;
      end else begin
        select           = 1 << select_index;
        expected_element = array[select_index];
      end
    end else begin
      select_index     = $urandom_range(0, ARRAY_SIZE - 1);
      select           = select_index;
      expected_element = array[select_index];
    end

    // Wait for combinational logic propagation
    #1;

    // Check output
    assert (element === expected_element) else begin
      $error("[%t] Incorrect element with select '%b', expected '%h', got '%h'", $realtime, select, expected_element, element);
    end

    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule
