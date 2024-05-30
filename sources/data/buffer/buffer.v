// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     VerSiTile-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        buffer.v                                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Data buffer.                                                 ║
// ║                                                                           ║
// ║              Breaks the timing path for the data but not the valid-ready  ║
// ║              flow control handshake.                                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module buffer #(
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

// Buffer register
reg  [WIDTH-1:0] buffer;
wire [WIDTH-1:0] buffer_next;

// Buffer state
reg buffer_valid;



// ┌────────────────┐
// │ IO connections │
// └────────────────┘

assign buffer_next      =  upstream_data;
assign upstream_ready   = ~buffer_valid | downstream_ready;
assign downstream_valid =  buffer_valid;
assign downstream_data  =  buffer;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer       <= 0;
    buffer_valid <= 0;
  end else begin
    if (upstream_valid & ~buffer_valid) begin
      buffer       <= buffer_next;
      buffer_valid <= 1;
    end else if (downstream_ready) begin
      if (upstream_valid) begin
        buffer       <= buffer_next;
      end else begin
        buffer       <= 0;
        buffer_valid <= 0;
      end
    end
  end
end

endmodule
