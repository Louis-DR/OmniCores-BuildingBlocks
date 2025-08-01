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
  parameter WIDTH      = 8,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH)
) (
  input      [WIDTH-1:0] data_in,
  input [WIDTH_LOG2-1:0] shift,
  input                  pad_value,
  output     [WIDTH-1:0] data_out
);

wire [2*WIDTH-1:0] data_in_extended = {data_in, {WIDTH{pad_value}}};
assign data_out = data_in_extended[WIDTH - shift +: WIDTH];

endmodule
