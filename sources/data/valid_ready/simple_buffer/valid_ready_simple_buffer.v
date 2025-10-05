// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_simple_buffer.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Single-entry data buffer with valid-ready flow control that  ║
// ║              doesn't support reading and writing in the same cycle. It    ║
// ║              breaks the timing path for both the data and the control     ║
// ║              signals.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module valid_ready_simple_buffer #(
  parameter WIDTH = 8
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

simple_buffer #(
  .WIDTH ( WIDTH )
) simple_buffer (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .full         ( full         ),
  .empty        ( empty        ),
  // Write interface
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  // Read interface
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    )
);

assign write_ready = ~full;
assign  read_valid = ~empty;

endmodule
