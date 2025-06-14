// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_corrector.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects single-bit errors in Hamming encoded data.          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_corrector #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH
) (
  input   [DATA_WIDTH-1:0] data,
  input [PARITY_WIDTH-1:0] code,
  output                   error,
  output  [DATA_WIDTH-1:0] corrected_data
);

logic [BLOCK_WIDTH-1:0] block;

hamming_block_packager #(
  .DATA_WIDTH ( DATA_WIDTH )
) packager (
  .data  ( data  ),
  .code  ( code  ),
  .block ( block )
);

hamming_block_corrector #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) block_corrector (
  .block          ( block          ),
  .error          ( error          ),
  .corrected_data ( corrected_data )
);

endmodule