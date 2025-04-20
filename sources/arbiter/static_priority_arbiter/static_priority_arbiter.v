// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_arbiter.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The grant is    ║
// ║              given to the first ready request channel (the least          ║
// ║              significant one bit).                                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module static_priority_arbiter #(
  parameter SIZE = 4
) (
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

wire [SIZE-1:0] grant_mask;
assign grant_mask[0] = 1'b1;
assign grant[0] = requests[0];

genvar bit_index;
generate
  for (bit_index = 1; bit_index < SIZE; bit_index = bit_index+1) begin : gen_bits
    // Mask is enabled if no higher priority request was asserted
    assign grant_mask[bit_index] = grant_mask[bit_index-1] & ~grant[bit_index-1];
    // Grant is given if request is active and mask is enabled
    assign grant[bit_index] = requests[bit_index] & grant_mask[bit_index];
  end
endgenerate

endmodule
