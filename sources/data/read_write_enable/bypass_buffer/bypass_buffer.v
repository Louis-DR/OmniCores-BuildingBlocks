// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        bypass_buffer.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Single-entry data buffer that is bypassed if it is read and  ║
// ║              written to in the same cycle. Writing without reading stores ║
// ║              in the buffer, and reading empties first the buffer and then ║
// ║              the bypass path. This buffer doesn't break any timing path.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module bypass_buffer #(
  parameter WIDTH = 8
) (
  input              clock,
  input              resetn,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  output             full,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data,
  output             empty
);

// Internal buffer
reg [WIDTH-1:0] buffer;
reg             buffer_valid;

// IO connection
assign full      =  buffer_valid & ~read_enable;
assign empty     = ~buffer_valid & ~write_enable;
assign read_data =  buffer_valid ? buffer : write_data;

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer       <= 0;
    buffer_valid <= 0;
  end else begin
    if (buffer_valid) begin
      if (write_enable) begin
        buffer       <= write_data;
      end else if (read_enable) begin
        buffer_valid <= 0;
      end
    end else begin
      if (write_enable & ~read_enable) begin
        buffer       <= write_data;
        buffer_valid <= 1;
      end
    end
  end
end

endmodule
