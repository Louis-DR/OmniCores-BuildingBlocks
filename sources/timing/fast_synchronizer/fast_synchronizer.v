// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_synchronizer.v                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a signal to a clock with flip-flop stages      ║
// ║              using both rising and falling edges of the destination       ║
// ║              clock. The last stage is always clocked with the rising      ║
// ║              edge.                                                        ║
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



module fast_synchronizer #(
  parameter STAGES = 2
) (
  input  clock,
  input  resetn,
  input  data_in,
  output data_out
);

reg [STAGES-1:0] stages;

integer stage_index;

always @(negedge clock or negedge resetn) begin
  if (!resetn) begin
    for (stage_index = STAGES-2; stage_index >= 0; stage_index = stage_index-2) begin
      stages[stage_index] <= 0;
    end
  end else begin
    for (stage_index = STAGES-2; stage_index >= 0; stage_index = stage_index-2) begin
      if (stage_index == 0) begin
        stages[stage_index] <= data_in;
      end else begin
        stages[stage_index] <= stages[stage_index-1];
      end
    end
  end
end

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    for (stage_index = STAGES-1; stage_index >= 0; stage_index = stage_index-2) begin
      stages[stage_index] <= 0;
    end
  end else begin
    for (stage_index = STAGES-1; stage_index >= 0; stage_index = stage_index-2) begin
      if (stage_index == 0) begin
        stages[stage_index] <= data_in;
      end else begin
        stages[stage_index] <= stages[stage_index-1];
      end
    end
  end
end

assign data_out = stages[STAGES-1];

endmodule
