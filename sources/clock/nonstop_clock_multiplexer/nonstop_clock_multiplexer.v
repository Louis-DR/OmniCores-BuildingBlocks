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
  input  select,
  output clock_out
);

wire clock_0_inverted = ~clock_0;
wire clock_1_inverted = ~clock_1;

wire select_clock_0 = ~select;
wire select_clock_1 =  select;

wire disable_clock_0;
wire disable_clock_1;

synchronizer #(
  .STAGES   ( STAGES )
) disable_clock_0_synchronizer (
  .clock    ( clock_1          ),
  .resetn   ( clock_0_inverted ),
  .data_in  ( select_clock_1   ),
  .data_out ( disable_clock_0  )
);

synchronizer #(
  .STAGES   ( STAGES )
) disable_clock_1_synchronizer (
  .clock    ( clock_0          ),
  .resetn   ( clock_1_inverted ),
  .data_in  ( select_clock_0   ),
  .data_out ( disable_clock_1  )
);

wire core_resetn_0 = ~disable_clock_0;
wire core_resetn_1 = ~disable_clock_1;

fast_clock_multiplexer #(
  .STAGES    ( STAGES )
) core_clock_multiplexer (
  .clock_0   ( clock_0       ),
  .clock_1   ( clock_1       ),
  .resetn_0  ( core_resetn_0 ),
  .resetn_1  ( core_resetn_1 ),
  .select    ( select        ),
  .clock_out ( clock_out     )
);

endmodule
