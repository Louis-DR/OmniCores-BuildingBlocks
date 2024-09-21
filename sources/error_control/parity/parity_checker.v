// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        parity_checker.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check the data with its parity code.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module parity_checker #(
  parameter DATA_WIDTH = 8
) (
  input [DATA_WIDTH-1:0] data,
  input                  code,
  output                 error
);

wire check_code;

parity_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) encoder (
  .clock  ( clock      ),
  .resetn ( resetn     ),
  .data   ( data       ),
  .code   ( check_code )
);

assign error = code == check_code;

endmodule
