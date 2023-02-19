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
  input              clk,
  input              arstn,
  input  [WIDTH-1:0] din,
  output [WIDTH-1:0] dout
);

reg [WIDTH-1:0] stages [STAGES-1:0];

integer idx;
always @(posedge clk or negedge arstn) begin
  if (!arstn) begin
    for (idx=0; idx<STAGES; idx=idx+1) begin
      stages[idx] <= '0;
    end
  end else begin
    stages[0] <= din;
    for (idx=1; idx<STAGES; idx=idx+1) begin
      stages[idx] <= stages[idx-1];
    end
  end
end

assign dout = stages[STAGES-1];

endmodule
