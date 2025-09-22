// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        single_port_ram.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with a single port for read and write.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module single_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter REGISTERED_READ = 1,
  parameter ADDRESS_WIDTH   = `CLOG2(DEPTH)
) (
  input                     clock,
  // Read-write interface
  input                     access_enable,
  input                     write,
  input [ADDRESS_WIDTH-1:0] address,
  input         [WIDTH-1:0] write_data,
  output        [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Internal enable signals
wire write_enable = access_enable &  write;
wire read_enable  = access_enable & ~write;

// Write logic
always @(posedge clock) begin
  if (write_enable) memory[address] <= write_data;
end

// Registered read logic
if (REGISTERED_READ) begin
  reg registered_read_data;
  always @(posedge clock) begin
    if (read_enable) registered_read_data <= memory[address];
  end
  assign read_data = registered_read_data;
end

// Combinational read logic
else begin
  assign read_data = memory[address];
end

endmodule
