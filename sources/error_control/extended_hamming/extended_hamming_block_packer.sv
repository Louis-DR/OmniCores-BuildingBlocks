// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_block_packer.v                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Pack data and extended Hamming parity code into a block.     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_block_packer #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input   [DATA_WIDTH-1:0] data,
  input [PARITY_WIDTH-1:0] code,
  output [BLOCK_WIDTH-1:0] block
);

// Separate the extra parity bit and the standard Hamming code
logic                    extra_parity;
logic [PARITY_WIDTH-2:0] hamming_code;
assign extra_parity = code[0];
assign hamming_code = code[PARITY_WIDTH-1:1];

// Pack the data and the standard Hamming code into a block
logic [BLOCK_WIDTH-1:0] hamming_block;
hamming_block_packer #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_block_packer (
  .data  ( data          ),
  .code  ( hamming_code  ),
  .block ( hamming_block )
);

// Append the extra parity bit to the Hamming block
assign block = {hamming_block, extra_parity};

endmodule
