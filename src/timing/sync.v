// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        sync.v                                                       ║
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



module sync #(
  parameter STAGES = 2
) (
  input  clk,
  input  arstn,
  input  din,
  output dout
);

reg [STAGES-1:0] stages;

integer idx;
always @(posedge clk or negedge arstn) begin
  if (!arstn) stages <= '0;
  else begin
    stages[0] <= din;
    for (idx=1; idx<STAGES; idx=idx+1) begin
      stages[idx] <= stages[idx-1];
    end
  end
end

assign dout = stages[STAGES-1];

endmodule
