// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        set_reset_flip_flop.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Set-reset (SR) flip flop.                                    ║
// ║                                                                           ║
// ║              This variant doesn't have a reset, so the initial state will ║
// ║              be random in real silicon, but is set to 0 for simulation.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module set_reset_flip_flop (
  input      clock,
  input      set,
  input      reset,
  output reg state = 0
);

always @(posedge clock) begin
  if      (set)   state <= 1;
  else if (reset) state <= 0;
end

endmodule
