// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        simple_buffer.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Single-entry data buffer that doesn't support reading and    ║
// ║              writing in the same cycle. It breaks the timing path for     ║
// ║              both the data and the control signals.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module simple_buffer #(
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
assign full      =  buffer_valid;
assign empty     = ~buffer_valid;
assign read_data =  buffer;

// Synchronous logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    buffer       <= 0;
    buffer_valid <= 0;
  end else begin
    if (write_enable & read_enable) begin
      buffer       <= write_data;
    end else if (write_enable) begin
      buffer       <= write_data;
      buffer_valid <= 1;
    end else if (read_enable) begin
      buffer_valid <= 0;
    end
  end
end

endmodule
