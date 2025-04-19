// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        jk_flip_flop_with_asynchronous_reset.v                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: JK flip flop with asynchronous reset.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module jk_flip_flop_with_asynchronous_reset #(
  parameter RESET_VALUE = 0
) (
  input      clock,
  input      resetn,
  input      j,
  input      k,
  output reg state
);

always @(posedge clock or negedge resetn) begin
  if      (!resetn) state <= RESET_VALUE;
  else if (j && k)  state <= ~state;
  else if (j)       state <= 1;
  else if (k)       state <= 0;
end

endmodule
