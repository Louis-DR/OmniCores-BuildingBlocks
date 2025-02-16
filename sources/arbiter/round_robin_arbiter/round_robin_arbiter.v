// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        round_robin_arbiter.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The priority of ║
// ║              the request channels shifts each cycle to ensure fairness of ║
// ║              arbitration.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module round_robin_arbiter #(
  parameter SIZE = 4
) (
  input             clock,
  input             resetn,
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

localparam SIZE_LOG2 = `CLOG2(SIZE);

reg [SIZE_LOG2-1:0] rotating_pointer;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    rotating_pointer <= 0;
  end else begin
    rotating_pointer <= rotating_pointer + 1;
  end
end

wire [SIZE-1:0] rotated_requests;
wire [SIZE-1:0] rotated_grants;

assign rotated_requests = (requests << rotating_pointer) | (requests >> SIZE - requests);

static_priority_arbiter #(
  .SIZE ( SIZE )
) static_priority_arbiter (
  .requests ( rotated_requests ),
  .grant    ( rotated_grants   )
);

assign grants = (rotated_grants >> rotating_pointer) | (rotated_grants << SIZE - requests);

endmodule
