// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        grey_vector_synchronizer.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a vector of signals to a clock with flip-flop  ║
// ║              stages and a Grey encoder-decoder.                           ║
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
// ║              synchronization clock. This synchronizer uses Grey encoding  ║
// ║              internally such that a single bit changes between cycles.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module grey_vector_synchronizer #(
  parameter WIDTH  = 8,
  parameter STAGES = 2
) (
  input              clock,
  input              resetn,
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

wire [WIDTH-1:0] data_grey_in;
wire [WIDTH-1:0] data_grey_out;


binary_to_grey #(
  .WIDTH  ( WIDTH )
) grey_encoder (
  .binary ( data_in      ),
  .grey   ( data_grey_in )
);

vector_synchronizer #(
  .WIDTH    ( WIDTH  ),
  .STAGES   ( STAGES )
) vector_synchronizer (
  .clock    ( clock         ),
  .resetn   ( resetn        ),
  .data_in  ( data_grey_in  ),
  .data_out ( data_grey_out )
);

grey_to_binary #(
  .WIDTH  ( WIDTH )
) grey_decoder (
  .grey   ( data_grey_out ),
  .binary ( data_out      )
);

endmodule
