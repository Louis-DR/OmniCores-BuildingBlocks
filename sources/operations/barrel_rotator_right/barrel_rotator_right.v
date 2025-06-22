// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        barrel_rotator_right.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Rotate a vector to the right.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module barrel_rotator_right #(
  parameter WIDTH      = 8,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH)
) (
  input      [WIDTH-1:0] data_in,
  input [WIDTH_LOG2-1:0] rotation,
  output     [WIDTH-1:0] data_out
);

wire [2*WIDTH-1:0] data_in_extended = {data_in, data_in};
assign data_out = data_in_extended[rotation +: WIDTH];

endmodule
