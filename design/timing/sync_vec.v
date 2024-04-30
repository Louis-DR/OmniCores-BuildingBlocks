// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        sync_vec.v                                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a vector of signals to a clock with flip-flop  ║
// ║              stages.                                                      ║
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



module sync_vec #(
  parameter WIDTH  = 8,
  parameter STAGES = 2
) (
  input              clock,
  input              resetn,
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

reg [WIDTH-1:0] stages [STAGES-1:0];

integer stage_index;
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    for (stage_index=0; stage_index<STAGES; stage_index=stage_index+1) begin
      stages[stage_index] <= 0;
    end
  end else begin
    stages[0] <= data_in;
    for (stage_index=1; stage_index<STAGES; stage_index=stage_index+1) begin
      stages[stage_index] <= stages[stage_index-1];
    end
  end
end

assign data_out = stages[STAGES-1];

endmodule
