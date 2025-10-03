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
  parameter DATA_WIDTH     = 8,
  parameter ROTATION_WIDTH = `CLOG2(DATA_WIDTH)
) (
  input     [DATA_WIDTH-1:0] data_in,
  input [ROTATION_WIDTH-1:0] rotation,
  output    [DATA_WIDTH-1:0] data_out
);

wire [2*DATA_WIDTH-1:0] data_in_extended = {data_in, data_in};
assign data_out = data_in_extended[rotation +: DATA_WIDTH];

endmodule
