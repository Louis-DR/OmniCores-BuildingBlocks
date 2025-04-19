// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        toggle_flip_flop_with_asynchronous_reset.v                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Toggle (T) flip flop with asynchronous reset.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module toggle_flip_flop_with_asynchronous_reset #(
  parameter RESET_VALUE = 0
) (
  input      clock,
  input      resetn,
  input      toggle,
  output reg state
);

always @(posedge clock or negedge resetn) begin
  if      (!resetn) state <= RESET_VALUE;
  else if (toggle)  state <= ~state;
end

endmodule
