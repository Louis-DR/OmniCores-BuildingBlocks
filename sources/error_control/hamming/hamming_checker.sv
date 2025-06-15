// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_checker.sv                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check the data with its Hamming parity code.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_checker #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input   [DATA_WIDTH-1:0] data,
  input [PARITY_WIDTH-1:0] code,
  output                   error
);

// Pad the data to the message length corresponding to the number of parity bits
localparam PADDED_DATA_WIDTH = `GET_HAMMING_DATA_WIDTH(PARITY_WIDTH);
logic [PADDED_DATA_WIDTH-1:0] data_padded;
assign data_padded = {{(PADDED_DATA_WIDTH - DATA_WIDTH){1'b0}}, data};

// Pad the block
localparam PADDED_BLOCK_WIDTH = PADDED_DATA_WIDTH + PARITY_WIDTH;
logic [PADDED_BLOCK_WIDTH-1:0] block_padded;

hamming_block_packer #(
  .DATA_WIDTH ( PADDED_DATA_WIDTH )
) packer (
  .data  ( data_padded  ),
  .code  ( code         ),
  .block ( block_padded )
);

hamming_block_checker #(
  .BLOCK_WIDTH ( PADDED_BLOCK_WIDTH )
) block_checker (
  .block ( block_padded ),
  .error ( error        )
);

endmodule