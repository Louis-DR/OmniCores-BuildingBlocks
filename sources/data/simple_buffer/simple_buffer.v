// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        simple_buffer.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Single-entry data buffer that partially decouples the two    ║
// ║              sides of an interface with valid-ready flow control. It only ║
// ║              allows one transfer every two cycles. It breaks the timing   ║
// ║              path for the data but not the handshake.                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module simple_buffer #(
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
reg [WIDTH-1:0] buffer;
reg             buffer_valid;

// IO connection
assign upstream_ready   = ~buffer_valid | downstream_ready;
assign downstream_valid =  buffer_valid;
assign downstream_data  =  buffer;

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer       <= 0;
    buffer_valid <= 0;
  end else begin
    if (upstream_valid & ~buffer_valid) begin
      buffer       <= upstream_data;
      buffer_valid <= 1;
    end else if (downstream_ready) begin
      if (upstream_valid) begin
        buffer       <= upstream_data;
        buffer_valid <= 1;
      end else begin
        buffer       <= 0;
        buffer_valid <= 0;
      end
    end
  end
end

endmodule
