// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        toggle_flip_flop.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Toggle (T) flip flop.                                        ║
// ║                                                                           ║
// ║              This variant doesn't have a reset, so the initial state will ║
// ║              be random in real silicon, but is set to 0 for simulation.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module toggle_flip_flop (
  input      clock,
  input      toggle,
  output reg state = 0
);

always @(posedge clock) begin
  if (toggle) state <= ~state;
end

endmodule
