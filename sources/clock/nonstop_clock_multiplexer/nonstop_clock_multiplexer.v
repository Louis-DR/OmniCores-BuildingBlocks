// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        nonstop_clock_multiplexer.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Multiplex between two input clocks while avoiding glitches.  ║
// ║              This variant can also switch to another clock if the current ║
// ║              selected clock stops running.                                ║
// ║                                                                           ║
// ║              The number of synchronizing stages can be set to 1 if the    ║
// ║              two clocks are synchronous.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module nonstop_clock_multiplexer #(
  parameter STAGES = 2
) (
  input  clock_0,
  input  clock_1,
  input  resetn,
  input  select,
  output clock_out
);

wire clock_0_inverted = ~clock_0;
wire clock_1_inverted = ~clock_1;

wire disable_clock_0 =  select;
wire disable_clock_1 = ~select;

wire disable_clock_0_synchronized;
wire disable_clock_1_synchronized;

synchronizer #(
  .STAGES   ( STAGES+2 )
) disable_clock_0_synchronizer (
  .clock    ( clock_1                      ),
  .resetn   ( clock_0_inverted             ),
  .data_in  ( disable_clock_0              ),
  .data_out ( disable_clock_0_synchronized )
);

synchronizer #(
  .STAGES   ( STAGES+2 )
) disable_clock_1_synchronizer (
  .clock    ( clock_0                      ),
  .resetn   ( clock_1_inverted             ),
  .data_in  ( disable_clock_1              ),
  .data_out ( disable_clock_1_synchronized )
);

wire enable_clock_0_synchronized;
wire enable_clock_1_synchronized;

wire enable_clock_0 = ~select & ~enable_clock_1_synchronized;
wire enable_clock_1 =  select & ~enable_clock_0_synchronized;

fast_synchronizer #(
  .STAGES   ( STAGES )
) enable_clock_0_synchronizer (
  .clock    ( clock_0_inverted              ),
  .resetn   ( ~disable_clock_0_synchronized ),
  .data_in  ( enable_clock_0                ),
  .data_out ( enable_clock_0_synchronized   )
);

fast_synchronizer #(
  .STAGES   ( STAGES )
) enable_clock_1_synchronizer (
  .clock    ( clock_1_inverted              ),
  .resetn   ( ~disable_clock_1_synchronized ),
  .data_in  ( enable_clock_1                ),
  .data_out ( enable_clock_1_synchronized   )
);

wire clock_0_gated = clock_0 & enable_clock_0_synchronized;
wire clock_1_gated = clock_1 & enable_clock_1_synchronized;

assign clock_out = clock_0_gated | clock_1_gated;

endmodule
