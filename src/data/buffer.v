// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
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
  input clk,
  input arstn,
  // Slave interface
  input  [WIDTH-1:0] slave_data,
  input              slave_valid,
  output             slave_ready,
  // Master interface
  output [WIDTH-1:0] master_data,
  output             master_valid,
  input              master_ready
);

// Buffer register
reg [WIDTH-1:0] buffer;
wire [WIDTH-1:0] buffer_next;

// Buffer state
reg buffer_valid;



// ┌────────────────┐
// │ IO connections │
// └────────────────┘

assign buffer_next  =  slave_data;
assign slave_ready  = ~buffer_valid | master_ready;
assign master_valid =  buffer_valid;
assign master_data  =  buffer;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

always @(posedge clk or negedge arstn) begin
  if (!arstn) begin
    buffer <= '0;
    buffer_valid <= '0;
  end else begin
    if (slave_valid & ~buffer_valid) begin
      buffer <= buffer_next;
      buffer_valid <= '1;
    end else if (master_ready) begin
      if (slave_ready) begin
        buffer <= buffer_next;
      end else begin
        buffer <= '0;
        buffer_valid <= '0;
      end
    end
  end
end

endmodule
