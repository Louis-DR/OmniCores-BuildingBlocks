// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        reset_synchronizer.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize the de-assertion edge of a reset signal to a   ║
// ║              clock. The output reset can be considered to be asserted     ║
// ║              asynchronously and deasserted synchronously to the           ║
// ║              destination clock. The reset must be active-low.             ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module reset_synchronizer #(
  parameter STAGES = 2
) (
  input  clock,
  input  resetn_in,
  output resetn_out
);

reg [STAGES-1:0] stages;

integer stage_index;
always @(posedge clock or negedge resetn_in) begin
  if (!resetn_in) stages <= 0;
  else begin
    stages[0] <= 1;
    for (stage_index=1; stage_index<STAGES; stage_index=stage_index+1) begin
      stages[stage_index] <= stages[stage_index-1];
    end
  end
end

assign resetn_out = stages[STAGES-1];

endmodule
