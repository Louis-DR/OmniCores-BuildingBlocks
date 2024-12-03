// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_block_extractor.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Extract data and Hamming parity code from a block.           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_block_extractor #(
  parameter  BLOCK_WIDTH  = 8,
  localparam DATA_WIDTH   = `GET_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH)
) (
  input   [BLOCK_WIDTH-1:0] block,
  output   [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code
);

// Extract the data bits from the block
generate
  for (genvar parity_index = 2; parity_index <= PARITY_WIDTH; parity_index++) begin : gen_unpack_data
    assign data[ 2**parity_index                       - parity_index - 2
               : 2**parity_index - 2**(parity_index-1) - parity_index     ] = block[ 2** parity_index    - 2
                                                                                   : 2**(parity_index-1)     ];
  end
endgenerate

// Extract the parity bits from the block
generate
  for (genvar parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin : gen_unpack_parity
    assign code[parity_index] = block[2**parity_index-1];
  end
endgenerate

endmodule
