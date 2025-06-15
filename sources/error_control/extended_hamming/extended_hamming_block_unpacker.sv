// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_block_unpacker.v                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Unpack data and extended Hamming parity code from a block.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_block_unpacker #(
  parameter  BLOCK_WIDTH  = 8,
  localparam DATA_WIDTH   = `GET_EXTENDED_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH)
) (
  input   [BLOCK_WIDTH-1:0] block,
  output   [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code
);

// Separate the extra parity bit and the standard Hamming code
logic                   extra_parity;
logic [BLOCK_WIDTH-2:0] hamming_block;
assign extra_parity  = block[0];
assign hamming_block = block[PARITY_WIDTH-1:1];

// Unpack the data and the standard Hamming code
logic [PARITY_WIDTH-2:0] hamming_code;
hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH-1 ),
) hamming_block_unpacker (
  .block ( hamming_block ),
  .data  ( data          ),
  .code  ( hamming_code  )
);

// Append the extra parity bit to the Hamming code
assign code = {extra_parity, hamming_code};

endmodule
