// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        skid_buffer.v                                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Two-entry data buffer for bus pipelining with write/read-    ║
// ║              enable flow control, full and empty status flags, and no     ║
// ║              safety mechanism for writing when full or reading when       ║
// ║              empty.                                                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module skid_buffer #(
  parameter WIDTH = 8
) (
  input              clock,
  input              resetn,
  output             full,
  output             empty,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data
);

// Internal buffer
reg [WIDTH-1:0] buffer [1:0];
reg       [1:0] buffer_valid;

// Selectors
reg write_buffer_selector;
reg read_buffer_selector;

// IO connections
assign full      =  buffer_valid [write_buffer_selector];
assign empty     = ~buffer_valid [read_buffer_selector];
assign read_data =  buffer       [read_buffer_selector];

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer[0]    <= 0;
    buffer[1]    <= 0;
    buffer_valid <= 0;
    write_buffer_selector <= 0;
    read_buffer_selector  <= 0;
  end else begin
    if (write_enable) begin
      buffer       [write_buffer_selector] <= write_data;
      buffer_valid [write_buffer_selector] <= 1;
      write_buffer_selector <= ~write_buffer_selector;
    end
    if (read_enable) begin
      buffer_valid [read_buffer_selector] <= 0;
      read_buffer_selector <= ~read_buffer_selector;
    end
  end
end

endmodule
