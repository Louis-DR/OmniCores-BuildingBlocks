// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_encoder.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Duplicates the data according to the replication parameter.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_encoder #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input                   [DATA_WIDTH-1:0] data,
  output [(REPETITION-1)*(DATA_WIDTH-1):0] code
);

assign code = {(REPETITION-1){data}};

endmodule
