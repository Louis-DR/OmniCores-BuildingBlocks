// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        simple_dual_port_ram.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with separate ports for read and write. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module simple_dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter WRITE_THROUGH = 0,
  parameter READ_LATENCY  = 1,
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  input                     clock,
  // Write interface
  input                     write_enable,
  input [ADDRESS_WIDTH-1:0] write_address,
  input         [WIDTH-1:0] write_data,
  // Read interface
  input                     read_enable,
  input [ADDRESS_WIDTH-1:0] read_address,
  output        [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Write logic
always @(posedge clock) begin
  if (write_enable) memory[write_address] <= write_data;
end

// Read-write conflict
wire same_address = write_address == read_address;

// Registered read logic
if (READ_LATENCY) begin
  reg [WIDTH-1:0] registered_read_data;
  always @(posedge clock) begin
    if (read_enable) begin
      // Write through
      if (WRITE_THROUGH && write_enable && same_address) begin
        registered_read_data <= write_data;
      // Read before write
      end else begin
        registered_read_data <= memory[read_address];
      end
    end
  end
  assign read_data = registered_read_data;
end

// Combinational read logic
else begin
  assign read_data = (WRITE_THROUGH && write_enable && same_address) ? write_data : memory[read_address];
end

endmodule
