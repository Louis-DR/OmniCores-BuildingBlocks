// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        jk_flip_flop.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: JK flip flop.                                                ║
// ║                                                                           ║
// ║              This variant doesn't have a reset, so the initial state will ║
// ║              be random in real silicon, but is set to 0 for simulation.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module jk_flip_flop (
  input      clock,
  input      j,
  input      k,
  output reg state = 0
);

always @(posedge clock) begin
  if      (j && k) state <= ~state;
  else if (j)      state <= 1;
  else if (k)      state <= 0;
end

endmodule
