// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_vector_synchronizer.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Registers a vector of signals in its source clock domain,    ║
// ║              then encodes it to Gray-code, resynchronize it to a          ║
// ║              destination clock with flip-flop stages, and finally decodes ║
// ║              it from Gray to binary.                                      ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              The synchronized signal must last at least one clock cycle   ║
// ║              of the synchronizing clock. In practice, this synchronizer   ║
// ║              should be used between clock domains of the same frequency   ║
// ║              or when moving to to a faster clock domain.                  ║
// ║                                                                           ║
// ║              When the synchronized signal changes, it should only be      ║
// ║              incremented or decremented between two clock cycles of the   ║
// ║              synchronization clock. This synchronizer uses Gray encoding  ║
// ║              internally such that a single bit changes between cycles.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module gray_vector_synchronizer #(
  parameter WIDTH  = 8,
  parameter STAGES = 2
) (
  input              source_clock,
  input              source_resetn,
  input              destination_clock,
  input              destination_resetn,
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

wire [WIDTH-1:0] data_gray_in;
wire [WIDTH-1:0] data_gray_out;

binary_to_gray #(
  .WIDTH  ( WIDTH )
) gray_encoder (
  .binary ( data_in      ),
  .gray   ( data_gray_in )
);

registered_vector_synchronizer #(
  .WIDTH  ( WIDTH  ),
  .STAGES ( STAGES )
) registered_vector_synchronizer (
  .source_clock       ( source_clock       ),
  .source_resetn      ( source_resetn      ),
  .destination_clock  ( destination_clock  ),
  .destination_resetn ( destination_resetn ),
  .data_in            ( data_gray_in       ),
  .data_out           ( data_gray_out      )
);

gray_to_binary #(
  .WIDTH  ( WIDTH )
) gray_decoder (
  .gray   ( data_gray_out ),
  .binary ( data_out      )
);

endmodule
