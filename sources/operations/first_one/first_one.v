// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        first_one.v                                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Determine the position of the first one in a vector.         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module first_one #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] data,
  output [WIDTH-1:0] first_one
);

assign first_one[0] = data[0];
generate
  for (genvar bit_index = 1; bit_index < WIDTH; bit_index++) begin : gen_bits
    assign first_one[bit_index] = ~first_one[0:bit_index-1] & data[bit_index];
  end
endgenerate

endmodule
