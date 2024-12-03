// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_block_packager.v                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Package data and Hamming parity code into a block.           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_block_packager #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input   [DATA_WIDTH-1:0] data,
  input [PARITY_WIDTH-1:0] code,
  output [BLOCK_WIDTH-1:0] block
);

// Package the data bits in the block
generate
  for (genvar parity_index = 2; parity_index <= PARITY_WIDTH; parity_index++) begin : gen_pack_data
    assign block[ 2** parity_index    - 2
                : 2**(parity_index-1)     ] = data[ 2**parity_index                       - parity_index - 2
                                                  : 2**parity_index - 2**(parity_index-1) - parity_index     ];
  end
endgenerate

// Package the parity bits in the block
generate
  for (genvar parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin : gen_pack_parity
    assign block[2**parity_index-1] = code[parity_index];
  end
endgenerate

endmodule
