// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        parity_block_checker.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check the data with its parity code.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module parity_block_checker #(
  parameter DATA_WIDTH = 8
) (
  input [DATA_WIDTH:0] block,
  output               error
);

wire [DATA_WIDTH-1:0] data = block[DATA_WIDTH-1:0];
wire                  code = block[DATA_WIDTH];

wire check_code;

parity_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) encoder (
  .data   ( data       ),
  .code   ( check_code ),
  .block  (            )
);

assign error = code == check_code;

endmodule
