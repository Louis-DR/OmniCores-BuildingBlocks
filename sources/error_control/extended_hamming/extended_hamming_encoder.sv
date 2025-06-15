// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_encoder.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Computes the Hamming code of the given data with an extra    ║
// ║              parity bit.                                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_encoder #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input    [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code,
  output  [BLOCK_WIDTH-1:0] block
);

// Generate the standard Hamming code
wire [PARITY_WIDTH-2:0] hamming_code;
wire  [BLOCK_WIDTH-2:0] hamming_block;
hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_encoder (
  .data  ( data          ),
  .code  ( hamming_code  ),
  .block ( hamming_block )
);

// Generate the extra parity bit
wire extra_parity;
parity_encoder #(
  .DATA_WIDTH ( BLOCK_WIDTH-1 )
) parity_encoder (
  .data ( hamming_block ),
  .code ( extra_parity  )
);

// Concatenate the code and the block
assign code  = {hamming_code,  extra_parity};
assign block = {hamming_block, extra_parity};

endmodule
