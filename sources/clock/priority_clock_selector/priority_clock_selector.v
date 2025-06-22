// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        priority_clock_selector.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Switches to the primary clock if it is running, else it      ║
// ║              switches to the fallback clock.                              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module priority_clock_selector #(
  parameter STAGES = 2
) (
  input  priority_clock,
  input  fallback_clock,
  input  resetn,
  output clock_out
);

wire priority_clock_inverted = ~priority_clock;
wire priority_clock_not_running;

synchronizer #(
  .STAGES   ( STAGES )
) disable_clock_0_synchronizer (
  .clock    ( fallback_clock             ),
  .resetn   ( priority_clock_inverted    ),
  .data_in  ( 1                          ),
  .data_out ( priority_clock_not_running )
);

nonstop_clock_multiplexer #(
  .STAGES    ( STAGES )
) core_clock_multiplexer (
  .clock_0   ( priority_clock             ),
  .clock_1   ( fallback_clock             ),
  .resetn_0  ( resetn                     ),
  .resetn_1  ( resetn                     ),
  .select    ( priority_clock_not_running ),
  .clock_out ( clock_out                  )
);

endmodule
