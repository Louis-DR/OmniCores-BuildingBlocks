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

wire [DATA_WIDTH:0] block = {code, data};

parity_block_checker #(
  .DATA_WIDTH ( DATA_WIDTH )
) block_checker (
  .block ( block ),
  .error ( error )
);

endmodule
