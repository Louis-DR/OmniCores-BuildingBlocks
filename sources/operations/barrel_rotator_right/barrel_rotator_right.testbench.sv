// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        barrel_rotator_right.testbench.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the barrel right rotator.                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module barrel_rotator_right__testbench ();

// Device parameters
localparam int DATA_WIDTH     = 8;
localparam int ROTATION_WIDTH = $clog2(DATA_WIDTH);

// Derived parameters
localparam int DATA_WIDTH_POW2 = 2 ** DATA_WIDTH;

// Test parameters
localparam int RANDOM_CHECK_DURATION = 1000;

// Device ports
logic     [DATA_WIDTH-1:0] data_in;
logic [ROTATION_WIDTH-1:0] rotation;
logic     [DATA_WIDTH-1:0] data_out;

// Test signals
logic [DATA_WIDTH-1:0] data_out_expected;

// Test variables
int check;

// Device under test
barrel_rotator_right #(
  .DATA_WIDTH     ( DATA_WIDTH     ),
  .ROTATION_WIDTH ( ROTATION_WIDTH )
) barrel_rotator_right_dut (
  .data_in  ( data_in  ),
  .rotation ( rotation ),
  .data_out ( data_out )
);

// Main block
initial begin
  // Log waves
  $dumpfile("barrel_rotator_right.testbench.vcd");
  $dumpvars(0,barrel_rotator_right__testbench);

  // Initialization
  data_in  = 0;
  rotation = 0;

  #10;

  // Check 1 : Walking one
  $display("CHECK 1 : Walking one."); check = 1;
  data_in = 1 << (DATA_WIDTH-1);
  for (int rotation_index = 0; rotation_index < DATA_WIDTH; rotation_index++) begin
    rotation = rotation_index;
    data_out_expected = 1 << (DATA_WIDTH-1-rotation_index);
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b' and rotation '%b' : expected '%b' but got '%b'.", $time, data_in, rotation, data_out_expected, data_out);
  end

  #10;

  // Check 2 : Walking zero
  $display("CHECK 2 : Walking zero."); check = 2;
  data_in = ~(1 << (DATA_WIDTH-1));
  for (int rotation_index = 0; rotation_index < DATA_WIDTH; rotation_index++) begin
    rotation = rotation_index;
    data_out_expected = ~(1 << (DATA_WIDTH-1-rotation_index));
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b' and rotation '%b' : expected '%b' but got '%b'.", $time, data_in, rotation, data_out_expected, data_out);
  end

  #10;

  // Check 3 : Random
  $display("CHECK 3 : Random."); check = 3;
  repeat (RANDOM_CHECK_DURATION) begin
    data_in  = $urandom_range(0, DATA_WIDTH_POW2-1);
    rotation = $urandom_range(0, ROTATION_WIDTH-1);
    data_out_expected = (data_in >> rotation) | (data_in << (DATA_WIDTH - rotation));
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b' and rotation '%b' : expected '%b' but got '%b'.", $time, data_in, rotation, data_out_expected, data_out);
    #1;
  end

  #10;

  // End of test
  $finish;
end

endmodule
