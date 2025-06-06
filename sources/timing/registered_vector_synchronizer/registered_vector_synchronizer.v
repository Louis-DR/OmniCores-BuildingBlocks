// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        registered_vector_synchronizer.v                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Registers a vector of signals in its source clock domain and ║
// ║              then resynchronize it to a clock with flip-flop stages.      ║
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
// ║              The synchronized signal must only change by one bit between  ║
// ║              two clock cycles of the synchronization clock. In practice,  ║
// ║              this module may be used for grey-coded incremental counters  ║
// ║              or for bit fields in certain cases.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module registered_vector_synchronizer #(
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

reg [WIDTH-1:0] presynchronization_stage;

always @(posedge source_clock or negedge source_resetn) begin
  if (!source_resetn) presynchronization_stage <= 0;
  else begin
    presynchronization_stage <= data_in;
  end
end

vector_synchronizer #(
  .WIDTH    ( WIDTH  ),
  .STAGES   ( STAGES )
) vector_synchronizer (
  .clock    ( destination_clock        ),
  .resetn   ( destination_resetn       ),
  .data_in  ( presynchronization_stage ),
  .data_out ( data_out                 )
);

endmodule
