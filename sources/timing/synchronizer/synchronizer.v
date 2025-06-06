// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        synchronizer.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a signal to a clock with flip-flop stages.     ║
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
// ╚═══════════════════════════════════════════════════════════════════════════╝



module synchronizer #(
  parameter STAGES = 2
) (
  input  clock,
  input  resetn,
  input  data_in,
  output data_out
);

reg [STAGES-1:0] stages;

integer stage_index;
always @(posedge clock or negedge resetn) begin
  if (!resetn) stages <= 0;
  else begin
    stages[0] <= data_in;
    for (stage_index = 1; stage_index < STAGES; stage_index = stage_index+1) begin
      stages[stage_index] <= stages[stage_index-1];
    end
  end
end

assign data_out = stages[STAGES-1];

endmodule
