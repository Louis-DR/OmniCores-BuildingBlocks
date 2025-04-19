// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        jk_flip_flop.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: JK flip flop.                                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module jk_flip_flop (
  input      clock,
  input      j,
  input      k,
  output reg state
);

always @(posedge clock) begin
  if      (j && k) state <= ~state;
  else if (j)      state <= 1;
  else if (k)      state <= 0;
end

endmodule
