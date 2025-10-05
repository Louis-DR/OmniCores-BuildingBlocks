// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_fifo.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue with valid-ready flow   ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  output             full,
  output             empty,
  // Write interface
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output             write_ready,
  // Read interface
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_ready
);

wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) fifo (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .full         ( full         ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .empty        ( empty        )
);

assign write_ready = ~full;
assign  read_valid = ~empty;

endmodule
