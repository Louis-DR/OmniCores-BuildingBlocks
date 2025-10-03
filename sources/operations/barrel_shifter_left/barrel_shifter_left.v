// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        barrel_shifter_left.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Shift a vector to the left and pad with a given value.       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module barrel_shifter_left #(
  parameter DATA_WIDTH  = 8,
  parameter SHIFT_WIDTH = `CLOG2(DATA_WIDTH)
) (
  input  [DATA_WIDTH-1:0] data_in,
  input [SHIFT_WIDTH-1:0] shift,
  input                   pad_value,
  output [DATA_WIDTH-1:0] data_out
);

wire [2*DATA_WIDTH-1:0] data_in_extended = {data_in, {DATA_WIDTH{pad_value}}};
assign data_out = data_in_extended[DATA_WIDTH - shift +: DATA_WIDTH];

endmodule
