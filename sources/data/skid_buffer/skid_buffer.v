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
// ║              and the handshake.                                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module skid_buffer #(
  parameter WIDTH = 8
) (
  input clock,
  input resetn,
  // Upstream interface
  input  [WIDTH-1:0] upstream_data,
  input              upstream_valid,
  output             upstream_ready,
  // Downstream interface
  output [WIDTH-1:0] downstream_data,
  output             downstream_valid,
  input              downstream_ready
);

// Internal buffer
reg [WIDTH-1:0] buffer [1:0];
reg       [1:0] buffer_valid;

// Selectors
reg upstream_buffer_selector;
reg downstream_buffer_selector;

// IO connections
assign upstream_ready   = ~buffer_valid [upstream_buffer_selector];
assign downstream_valid =  buffer_valid [downstream_buffer_selector];
assign downstream_data  =  buffer       [downstream_buffer_selector];

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer[0]    <= 0;
    buffer[1]    <= 0;
    buffer_valid <= 0;
    upstream_buffer_selector   <= 0;
    downstream_buffer_selector <= 0;
  end else begin
    if (upstream_valid & upstream_ready) begin
      buffer       [upstream_buffer_selector] <= upstream_data;
      buffer_valid [upstream_buffer_selector] <= 1;
      upstream_buffer_selector <= ~upstream_buffer_selector;
    end
    if (downstream_valid & downstream_ready) begin
      buffer_valid [downstream_buffer_selector] <= 0;
      downstream_buffer_selector <= ~downstream_buffer_selector;
    end
  end
end

endmodule
