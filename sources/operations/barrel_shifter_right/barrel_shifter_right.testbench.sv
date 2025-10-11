// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        barrel_shifter_right.testbench.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the barrel right shifter.                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module barrel_shifter_right__testbench ();

// Device parameters
localparam int DATA_WIDTH  = 8;
localparam int SHIFT_WIDTH = $clog2(DATA_WIDTH);

// Derived parameters
localparam int DATA_WIDTH_POW2 = 2 ** DATA_WIDTH;

// Test parameters
localparam int RANDOM_CHECK_DURATION = 1000;

// Device ports
logic  [DATA_WIDTH-1:0] data_in;
logic [SHIFT_WIDTH-1:0] shift;
logic                   pad_value;
logic  [DATA_WIDTH-1:0] data_out;

// Test signals
logic [DATA_WIDTH-1:0] data_out_expected;

// Test variables
int check;

// Device under test
barrel_shifter_right #(
  .DATA_WIDTH  ( DATA_WIDTH  ),
  .SHIFT_WIDTH ( SHIFT_WIDTH )
) barrel_shifter_right_dut (
  .data_in   ( data_in   ),
  .shift     ( shift     ),
  .pad_value ( pad_value ),
  .data_out  ( data_out  )
);

// Main block
initial begin
  // Log waves
  $dumpfile("barrel_shifter_right.testbench.vcd");
  $dumpvars(0,barrel_shifter_right__testbench);

  // Initialization
  data_in   = 0;
  shift     = 0;
  pad_value = 0;

  #10;

  // Check 1 : Walking one with pad value zero
  $display("CHECK 1 : Walking one with pad value zero."); check = 1;
  data_in = 1 << (DATA_WIDTH-1);
  pad_value = 0;
  for (int shift_index = 0; shift_index < DATA_WIDTH; shift_index++) begin
    shift = shift_index;
    data_out_expected = 1 << (DATA_WIDTH-1-shift_index);
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b', shift '%b' and pad value '%b' : expected '%b' but got '%b'.", $time, data_in, shift, pad_value, data_out_expected, data_out);
  end

  #10;

  // Check 2 : Walking zero with pad value one
  $display("CHECK 2 : Walking zero with pad value one."); check = 2;
  data_in = ~(1 << (DATA_WIDTH-1));
  pad_value = 1;
  for (int shift_index = 0; shift_index < DATA_WIDTH; shift_index++) begin
    shift = shift_index;
    data_out_expected = ~(1 << (DATA_WIDTH-1-shift_index));
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b', shift '%b' and pad value '%b' : expected '%b' but got '%b'.", $time, data_in, shift, pad_value, data_out_expected, data_out);
  end

  #10;

  // Check 3 : Walking one with pad value one
  $display("CHECK 3 : Walking one with pad value one."); check = 3;
  data_in = 1 << (DATA_WIDTH-1);
  pad_value = 1;
  for (int shift_index = 0; shift_index < DATA_WIDTH; shift_index++) begin
    shift = shift_index;
    data_out_expected = (1 << (DATA_WIDTH-1-shift_index)) | (((1 << shift_index) - 1) << (DATA_WIDTH - shift_index));
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b', shift '%b' and pad value '%b' : expected '%b' but got '%b'.", $time, data_in, shift, pad_value, data_out_expected, data_out);
  end

  #10;

  // Check 4 : Walking zero with pad value zero
  $display("CHECK 4 : Walking zero with pad value zero."); check = 4;
  data_in = ~(1 << (DATA_WIDTH-1));
  pad_value = 0;
  for (int shift_index = 0; shift_index < DATA_WIDTH; shift_index++) begin
    shift = shift_index;
    data_out_expected = (~(1 << (DATA_WIDTH-1)) >> shift_index) & ((1 << (DATA_WIDTH - shift_index)) - 1);
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b', shift '%b' and pad value '%b' : expected '%b' but got '%b'.", $time, data_in, shift, pad_value, data_out_expected, data_out);
  end

  #10;

  // Check 5 : Random
  $display("CHECK 5 : Random."); check = 5;
  repeat (RANDOM_CHECK_DURATION) begin
    data_in   = $urandom_range(0, DATA_WIDTH_POW2-1);
    shift     = $urandom_range(0, DATA_WIDTH-1);
    pad_value = $urandom_range(0, 1);
    data_out_expected = ((data_in >> shift) | ({DATA_WIDTH{pad_value}} & (((1 << shift) - 1) << (DATA_WIDTH - shift)))) & ((1 << DATA_WIDTH) - 1);
    #1;
    assert (data_out === data_out_expected)
      else $error("[%0tns] Incorrect output for input data '%b', shift '%b' and pad value '%b' : expected '%b' but got '%b'.", $time, data_in, shift, pad_value, data_out_expected, data_out);
    #1;
  end

  #10;

  // End of test
  $finish;
end

endmodule
