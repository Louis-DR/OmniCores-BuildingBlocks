// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_block_corrector.sv                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects single-bit errors and detects double-bit errors in  ║
// ║              extended Hamming blocks.                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_block_corrector #(
  parameter  BLOCK_WIDTH  = 8,
  localparam DATA_WIDTH   = `GET_EXTENDED_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH)
) (
  input  [BLOCK_WIDTH-1:0] block,
  output                   correctable_error,
  output                   uncorrectable_error,
  output [BLOCK_WIDTH-1:0] corrected_block
);

// Separate the extra parity and the Hamming block
logic [BLOCK_WIDTH-2:0] hamming_block;
logic                    extra_parity;
assign hamming_block = block[BLOCK_WIDTH-1:1];
assign extra_parity  = block[0];

// Calculate the expected extra parity
logic expected_extra_parity;
parity_encoder #(
  .DATA_WIDTH ( BLOCK_WIDTH-1 )
) parity_encoder (
  .data ( hamming_block         ),
  .code ( expected_extra_parity )
);

// Check extra parity
logic extra_parity_error;
assign extra_parity_error = extra_parity ^ expected_extra_parity;

// Check Hamming code and correct the Hamming block
logic hamming_error;
logic [BLOCK_WIDTH-2:0] corrected_hamming_block;
hamming_block_corrector #(
  .BLOCK_WIDTH ( BLOCK_WIDTH-1 )
) hamming_corrector (
  .block           ( hamming_block           ),
  .error           ( hamming_error           ),
  .corrected_block ( corrected_hamming_block )
);

// Correctable error if the extra parity is incorrect
assign correctable_error = extra_parity_error;

// Uncorrectable error if the Hamming code is incorrect and the extra parity is correct
assign uncorrectable_error = hamming_error && !extra_parity_error;

// Assemble the corrected extended block with the corrected Hamming block and the expected extra parity
assign corrected_block = {corrected_hamming_block, expected_extra_parity};

endmodule