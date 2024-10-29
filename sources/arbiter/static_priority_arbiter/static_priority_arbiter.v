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

assign grant[0] = requests[0];
generate
  for (genvar bit_index = 1; bit_index < SIZE; bit_index++) begin : gen_bits
    assign grant[bit_index] = ~grant[bit_index-1] & requests[bit_index];
  end
endgenerate

endmodule
