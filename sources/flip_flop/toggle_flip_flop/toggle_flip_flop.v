// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        toggle_flip_flop.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Toggle (T) flip flop.                                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module toggle_flip_flop (
  input      clock,
  input      toggle,
  output reg state
);

always @(posedge clock) begin
  if (toggle) state <= ~state;
end

endmodule
