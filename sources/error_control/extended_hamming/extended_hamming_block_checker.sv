// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_block_checker.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Detects correctable single-bit errors and uncorrectable      ║
// ║              double-bit errors in extended Hamming blocks.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_block_checker #(
  parameter  BLOCK_WIDTH  = 8,
  localparam DATA_WIDTH   = `GET_EXTENDED_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH)
) (
  input [BLOCK_WIDTH-1:0] block,
  output                  correctable_error,
  output                  uncorrectable_error
);

// Extract the data and code from the block
logic   [DATA_WIDTH-1:0] data;
logic [PARITY_WIDTH-1:0] received_code;

extended_hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) extractor (
  .block ( block         ),
  .data  ( data          ),
  .code  ( received_code )
);

// Calculate the expected code
logic [PARITY_WIDTH-1:0] expected_code;

extended_hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) encoder (
  .data  ( data          ),
  .code  ( expected_code ),
  .block (               )
);

// Calculate the syndrome
logic [PARITY_WIDTH-1:0] syndrome;
assign syndrome = received_code ^ expected_code;

// Separate the extra parity syndrome and standard Hamming syndrome
logic                    extra_parity_syndrome;
logic [PARITY_WIDTH-2:0] hamming_syndrome;
assign extra_parity_syndrome = syndrome[0];
assign hamming_syndrome      = syndrome[PARITY_WIDTH-1:1];

// Correctable error if the extra parity is incorrect
assign correctable_error = extra_parity_syndrome;

// Uncorrectable error if the Hamming syndrome is non-zero and the extra parity is correct
assign uncorrectable_error = |hamming_syndrome && !extra_parity_syndrome;

endmodule