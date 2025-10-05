// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_lifo.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous Last-In First-Out stack with valid-ready flow    ║
// ║              control.                                                     ║
// ║                                                                           ║
// ║              Attempting to read and write at the same time will read the  ║
// ║              last value of the stack then write the next value, thus not  ║
// ║              moving the stack pointer. Passing the data from write_data   ║
// ║              to read_data in such a case would create a single timing     ║
// ║              path through the structure.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_lifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  // Write interface
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output             write_ready,
  output             full,
  // Read interface
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_ready,
  output             empty
);

wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

lifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) lifo (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  // Write interface
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .full         ( full         ),
  // Read interface
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .empty        ( empty        )
);

assign write_ready = ~full;
assign read_valid  = ~empty;

endmodule
