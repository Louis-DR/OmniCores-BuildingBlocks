// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_bypass_buffer.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Single-entry data buffer with valid-ready flow control that  ║
// ║              is bypassed if it is read and written to in the same cycle.  ║
// ║              Writing without reading stores in the buffer, and reading    ║
// ║              empties first the buffer and then the bypass path. This      ║
// ║              buffer doesn't break any timing path.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module valid_ready_bypass_buffer #(
  parameter WIDTH = 8
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

wire write_enable = write_valid;
wire read_enable  = read_ready;

bypass_buffer #(
  .WIDTH ( WIDTH )
) bypass_buffer (
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
