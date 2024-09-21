// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        parity_encoder.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Computes the parity code of the given data.                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module parity_encoder #(
  parameter DATA_WIDTH = 8
) (
  input [DATA_WIDTH-1:0] data,
  output                 code
);

assign code = ^data;

endmodule
