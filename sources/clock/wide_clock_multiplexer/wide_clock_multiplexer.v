// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wide_clock_multiplexer.v                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Multiplex between two or more input clocks while avoiding    ║
// ║              glitches.                                                    ║
// ║                                                                           ║
// ║              The number of synchronizing stages can be set to 1 if the    ║
// ║              two clocks are synchronous.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module wide_clock_multiplexer #(
  parameter STAGES       = 2,
  parameter CLOCKS       = 2,
  parameter SELECT_WIDTH = `CLOG2(CLOCKS)
) (
  input       [CLOCKS-1:0] clocks,
  input       [CLOCKS-1:0] resetns,
  input [SELECT_WIDTH-1:0] select,
  output                   clock_out
);

wire [CLOCKS-1:0] clocks_inverted = ~clocks;
wire [CLOCKS-1:0] clocks_gated;

wire [CLOCKS-1:0] clock_enables;
wire [CLOCKS-1:0] clock_enables_synchronized;

genvar clock_index;
generate
  for (clock_index = 0; clock_index < CLOCKS; clock_index = clock_index+1) begin : gen_clocks
    assign clock_enables[clock_index] = (select == clock_index) & &(~clock_enables_synchronized | (1 << clock_index));
    synchronizer #(
      .STAGES   ( STAGES )
    ) clock_enable_synchronizer (
      .clock    ( clocks_inverted            [clock_index] ),
      .resetn   ( resetns                    [clock_index] ),
      .data_in  ( clock_enables              [clock_index] ),
      .data_out ( clock_enables_synchronized [clock_index] )
    );
    assign clocks_gated[clock_index] = clocks[clock_index] & clock_enables_synchronized[clock_index];
  end
endgenerate

assign clock_out = |clocks_gated;

endmodule
