// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        switchover_clock_selector.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Starts on the first clock, then it switches to the second    ║
// ║              clock once it is running.                                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module switchover_clock_selector #(
  parameter STAGES = 2
) (
  input  first_clock,
  input  second_clock,
  input  resetn,
  output clock_out
);

reg second_clock_started;

always @(posedge second_clock or negedge resetn) begin
  if (!resetn) second_clock_started <= 0;
  else         second_clock_started <= 1;
end

wire first_clock_inverted  = ~first_clock;
wire second_clock_inverted = ~second_clock;

wire disable_first_clock;
wire enable_second_clock;

synchronizer #(
  .STAGES   ( STAGES )
) disable_first_clock_synchronizer (
  .clock    ( first_clock_inverted ),
  .resetn   ( resetn               ),
  .data_in  ( second_clock_started ),
  .data_out ( disable_first_clock  )
);

synchronizer #(
  .STAGES   ( STAGES )
) enable_second_clock_synchronizer (
  .clock    ( second_clock_inverted ),
  .resetn   ( resetn                ),
  .data_in  ( disable_first_clock   ),
  .data_out ( enable_second_clock   )
);

wire first_clock_gated  = first_clock  & ~disable_first_clock;
wire second_clock_gated = second_clock &  enable_second_clock;

assign clock_out = first_clock_gated | second_clock_gated;

endmodule
