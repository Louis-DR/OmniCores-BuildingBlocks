// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_multiplexer.v                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Multiplex between two input clocks while avoiding glitches.  ║
// ║                                                                           ║
// ║              The number of synchronizing stages can be set to 1 if the    ║
// ║              two clocks are synchronous.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module clock_multiplexer #(
  STAGES = 2
) (
  input  clock_0,
  input  clock_1,
  input  resetn,
  input  select,
  output clock_out
);

wire enable_clock_0;
wire enable_clock_1;

wire enable_clock_0_synchronized;
wire enable_clock_1_synchronized;

assign enable_clock_0 =  select & ~enable_clock_1_synchronized;
assign enable_clock_1 = ~select & ~enable_clock_0_synchronized;

synchronizer #(
  .STAGES   ( STAGES                      )
) enable_clock_0_synchronizer (
  .clock    ( clock_0                     ),
  .resetn   ( resetn                      ),
  .data_in  ( enable_clock_0              ),
  .data_out ( enable_clock_0_synchronized )
);

synchronizer #(
  .STAGES   ( STAGES                      )
) enable_clock_1_synchronizer (
  .clock    ( clock_1                     ),
  .resetn   ( resetn                      ),
  .data_in  ( enable_clock_1              ),
  .data_out ( enable_clock_1_synchronized )
);

wire clock_0_gated;
wire clock_1_gated;

assign clock_0_gated = clock_0 & enable_clock_0_synchronized;
assign clock_1_gated = clock_1 & enable_clock_1_synchronized;

assign clock_out = clock_0_gated | clock_1_gated;

endmodule
