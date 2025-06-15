// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_block_checker.sv                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check a Hamming block for errors using syndrome calculation. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_block_checker #(
  parameter  BLOCK_WIDTH  = 15,
  localparam DATA_WIDTH   = `GET_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH)
) (
  input [BLOCK_WIDTH-1:0] block,
  output                  error
);

// Extract the data and code from the block
logic   [DATA_WIDTH-1:0] data;
logic [PARITY_WIDTH-1:0] received_code;

hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) unpacker (
  .block ( block        ),
  .data  ( data         ),
  .code  ( received_code )
);

// Calculate the expected code
logic [PARITY_WIDTH-1:0] expected_code;

hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) encoder (
  .data  ( data          ),
  .code  ( expected_code ),
  .block (               )
);

// Calculate the syndrome
logic [PARITY_WIDTH-1:0] syndrome;
assign syndrome = received_code ^ expected_code;

// Error detected if the syndrome is non-zero
assign error = |syndrome;

endmodule