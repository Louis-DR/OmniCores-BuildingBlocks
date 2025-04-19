// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        set_reset_flip_flop.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Set-reset (SR) flip flop.                                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module set_reset_flip_flop (
  input      clock,
  input      set,
  input      reset,
  output reg state
);

always @(posedge clock) begin
  if      (set)   state <= 1;
  else if (reset) state <= 0;
end

endmodule
