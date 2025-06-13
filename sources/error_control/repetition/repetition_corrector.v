// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_corrector.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects errors in replicated data using majority voting.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_corrector #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input                [DATA_WIDTH-1:0] data,
  input [(REPETITION-1)*DATA_WIDTH-1:0] code,
  output                                error,
  output               [DATA_WIDTH-1:0] corrected_data
);

wire [REPETITION*DATA_WIDTH-1:0] block = {code, data};

repetition_block_corrector #(
  .DATA_WIDTH ( DATA_WIDTH ),
  .REPETITION ( REPETITION )
) block_corrector (
  .block          ( block          ),
  .error          ( error          ),
  .corrected_data ( corrected_data )
);

endmodule
