// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        set_reset_flip_flop_with_reset.v                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Set-reset (SR) flip flop with active-low asynchronous reset. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module set_reset_flip_flop_with_reset #(
  parameter RESET_VALUE = 0
) (
  input      clock,
  input      resetn,
  input      set,
  input      reset,
  output reg state
);

always @(posedge clock or negedge resetn) begin
  if      (!resetn) state <= RESET_VALUE;
  else if (set)     state <= 1;
  else if (reset)   state <= 0;
end

endmodule
