// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_asynchronous_fifo.v                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue with valid-ready flow  ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_asynchronous_fifo #(
  parameter WIDTH  = 8,
  parameter DEPTH  = 4,
  parameter STAGES = 2
) (
  // Write clock domain
  input              write_clock,
  input              write_resetn,
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output             write_ready,
  output             write_full,
  // Read clock domain
  input              read_clock,
  input              read_resetn,
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_ready,
  output             read_empty
);

wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

asynchronous_fifo #(
  .WIDTH  ( WIDTH  ),
  .DEPTH  ( DEPTH  ),
  .STAGES ( STAGES )
) asynchronous_fifo (
  .write_clock  ( write_clock  ),
  .write_resetn ( write_resetn ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .write_full   ( write_full   ),
  .read_clock   ( read_clock   ),
  .read_resetn  ( read_resetn  ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .read_empty   ( read_empty   )
);

assign write_ready = ~write_full;
assign  read_valid = ~read_empty;

endmodule