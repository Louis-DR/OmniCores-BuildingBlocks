// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_corrector.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects single-bit errors and detects double-bit errors in  ║
// ║              data with extended Hamming code.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "extended_hamming.svh"



module extended_hamming_corrector #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_EXTENDED_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input   [DATA_WIDTH-1:0] data,
  input [PARITY_WIDTH-1:0] code,
  output                   uncorrectable_error,
  output                   correctable_error,
  output  [DATA_WIDTH-1:0] corrected_data
);

// Pad the data to the message length corresponding to the number of parity bits
localparam PADDED_DATA_WIDTH = `GET_EXTENDED_HAMMING_DATA_WIDTH(PARITY_WIDTH);
logic [PADDED_DATA_WIDTH-1:0] data_padded;
assign data_padded = {{(PADDED_DATA_WIDTH - DATA_WIDTH){1'b0}}, data};

// Pad the block
localparam PADDED_BLOCK_WIDTH = PADDED_DATA_WIDTH + PARITY_WIDTH;
logic [PADDED_BLOCK_WIDTH-1:0] block_padded;
logic [PADDED_BLOCK_WIDTH-1:0] corrected_block_padded;
logic  [PADDED_DATA_WIDTH-1:0] corrected_data_padded;

extended_hamming_block_packer #(
  .DATA_WIDTH ( PADDED_DATA_WIDTH )
) packager (
  .data  ( data_padded  ),
  .code  ( code         ),
  .block ( block_padded )
);

extended_hamming_block_corrector #(
  .BLOCK_WIDTH ( PADDED_BLOCK_WIDTH )
) block_corrector (
  .block               ( block_padded           ),
  .uncorrectable_error ( uncorrectable_error    ),
  .correctable_error   ( correctable_error      ),
  .corrected_block     ( corrected_block_padded )
);

extended_hamming_block_unpacker #(
  .BLOCK_WIDTH ( PADDED_BLOCK_WIDTH )
) unpacker (
  .block ( corrected_block_padded ),
  .data  ( corrected_data_padded  ),
  .code  (                        )
);

// Extract the original data width from the padded corrected data
assign corrected_data = corrected_data_padded[DATA_WIDTH-1:0];

endmodule