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
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  input                      clock,
  // Read-write interface
  input                      write_enable,
  input                      read_enable,
  input  [ADDRESS_WIDTH-1:0] address,
  input          [WIDTH-1:0] write_data,
  output reg     [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Write logic
always @(posedge clock) begin
  if (write_enable) memory[address] <= write_data;
end

// Read logic
always @(posedge clock) begin
  if (read_enable) read_data <= memory[address];
end

endmodule
