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

// Pad the block to the upper Hamming block width
localparam PADDED_BLOCK_WIDTH = `GET_HAMMING_UPPER_BLOCK_WIDTH(BLOCK_WIDTH);
logic [PADDED_BLOCK_WIDTH-1:0] block_padded;
assign block_padded = {{(PADDED_BLOCK_WIDTH - BLOCK_WIDTH){1'b0}}, block};

// Pad the data
localparam PADDED_DATA_WIDTH = `GET_HAMMING_DATA_WIDTH(PARITY_WIDTH);
logic [PADDED_DATA_WIDTH-1:0] data_padded;

// Extract the data bits from the block
generate
  for (genvar parity_index = 2; parity_index <= PARITY_WIDTH; parity_index++) begin : gen_unpack_data
    assign data_padded[ 2**parity_index                       - parity_index - 2
                      : 2**parity_index - 2**(parity_index-1) - parity_index     ] = block_padded[ 2** parity_index    - 2
                                                                                                 : 2**(parity_index-1)     ];
  end
endgenerate

// Extract the parity bits from the block
generate
  for (genvar parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin : gen_unpack_parity
    assign code[parity_index] = block_padded[2**parity_index-1];
  end
endgenerate

assign data = data_padded[DATA_WIDTH-1:0];

endmodule
