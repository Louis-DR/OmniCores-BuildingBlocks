// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_checker.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check replicated data for errors.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_checker #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input                [DATA_WIDTH-1:0] data,
  input [(REPETITION-1)*DATA_WIDTH-1:0] code,
  output                                error
);

wire [REPETITION*DATA_WIDTH-1:0] block = {code, data};

repetition_block_checker #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) block_checker (
  .block ( block ),
  .error ( error )
);

endmodule
