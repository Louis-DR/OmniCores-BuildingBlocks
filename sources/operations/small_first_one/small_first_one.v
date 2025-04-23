// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        small_first_one.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Determine the position of the first one in a vector using a  ║
// ║              ripple chain.                                                ║
// ║                                                                           ║
// ║              This variant is small (O(log2(WIDTH)) gates) but slow        ║
// ║              (O(WIDTH) delay). There is a faster variant.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module small_first_one #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] data,
  output [WIDTH-1:0] first_one
);

wire [WIDTH-1:0] mask;
assign mask[0] = 1'b1;
assign first_one[0] = data[0];

genvar bit_index;
generate
  for (bit_index = 1; bit_index < WIDTH; bit_index = bit_index+1) begin : gen_bits
    // Mask is enabled if no higher priority request was asserted
    assign mask[bit_index] = mask[bit_index-1] & ~first_one[bit_index-1];
    // First_one is given if request is active and mask is enabled
    assign first_one[bit_index] = data[bit_index] & mask[bit_index];
  end
endgenerate

endmodule
