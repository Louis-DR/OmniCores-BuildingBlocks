// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        array_onehot_select.testbench.sv                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the static priority stream arbiter.            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module array_onehot_select__testbench ();

// Device parameters
localparam int ELEMENT_WIDTH = 8;
localparam int ARRAY_SIZE    = 4;

// Test parameters
localparam int  RANDOM_CHECK_ITERATIONS = 1000;

// Device ports
logic [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] array;
logic [ARRAY_SIZE-1:0]                     onehot_select;
logic                  [ELEMENT_WIDTH-1:0] element;

// Test signals
int                       onehot_index;
logic [ELEMENT_WIDTH-1:0] expected_element;

// Device under test
array_onehot_select #(
  .ELEMENT_WIDTH ( ELEMENT_WIDTH ),
  .ARRAY_SIZE    ( ARRAY_SIZE    )
) array_onehot_select_dut (
  .array         ( array         ),
  .onehot_select ( onehot_select ),
  .element       ( element       )
);

// Main block
initial begin
  // Log waves
  $dumpfile("array_onehot_select.testbench.vcd");
  $dumpvars(0,array_onehot_select__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  array         = '0;
  onehot_select = '0;

  // Small delay after initialization
  #1;

  // Check 1 : Random stimulus
  $display("CHECK 1 : Random stimulus.");
  repeat (RANDOM_CHECK_ITERATIONS) begin
    // Random stimulus
    for (int array_index = 0; array_index < ARRAY_SIZE; array_index++) begin
      array[array_index] = $urandom();
    end
    onehot_index = $urandom_range(0, ARRAY_SIZE);
    if (onehot_index == ARRAY_SIZE) begin
      onehot_select    = '0;
      expected_element = '0;
    end else begin
      onehot_select    = 1 << onehot_index;
      expected_element = array[onehot_index];
    end

    // Wait for combinational logic propagation
    #1;

    // Check output
    assert (element === expected_element) else begin
      $error("[%t] Incorrect element with select '%b', expected '%h', got '%h'", $realtime, onehot_select, expected_element, element);
    end

    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule
