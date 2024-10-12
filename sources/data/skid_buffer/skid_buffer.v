// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        skid_buffer.v                                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Two-entry data buffer that decouples the two sides of an     ║
// ║              interface with valid-ready flow control. It allows back-to-  ║
// ║              back transfers. It breaks the timing path for both the data  ║
// ║              and the control signals.                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module skid_buffer #(
  parameter WIDTH = 8
) (
  input              clock,
  input              resetn,
  // Upstream interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  output             full,
  // Downstream interface
  input              read_enable,
  output [WIDTH-1:0] read_data,
  output             empty
);

// Internal buffer
reg [WIDTH-1:0] buffer [1:0];
reg       [1:0] buffer_valid;

// Selectors
reg upstream_buffer_selector;
reg downstream_buffer_selector;

// IO connections
assign full      =  buffer_valid [upstream_buffer_selector];
assign empty     = ~buffer_valid [downstream_buffer_selector];
assign read_data =  buffer       [downstream_buffer_selector];

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer[0]    <= 0;
    buffer[1]    <= 0;
    buffer_valid <= 0;
    upstream_buffer_selector   <= 0;
    downstream_buffer_selector <= 0;
  end else begin
    if (write_enable) begin
      buffer       [upstream_buffer_selector] <= write_data;
      buffer_valid [upstream_buffer_selector] <= 1;
      upstream_buffer_selector <= ~upstream_buffer_selector;
    end
    if (read_enable) begin
      buffer_valid [downstream_buffer_selector] <= 0;
      downstream_buffer_selector <= ~downstream_buffer_selector;
    end
  end
end

endmodule
