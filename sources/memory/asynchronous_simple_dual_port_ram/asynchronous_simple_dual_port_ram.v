// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_simple_dual_port_ram.v                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with separate asynchronous ports for    ║
// ║              read and write.                                              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module asynchronous_simple_dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  // Write interface
  input                      write_clock,
  input                      write_enable,
  input  [ADDRESS_WIDTH-1:0] write_address,
  input          [WIDTH-1:0] write_data,
  // Read interface
  input                      read_clock,
  input                      read_enable,
  input  [ADDRESS_WIDTH-1:0] read_address,
  output reg     [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Write logic
always @(posedge write_clock) begin
  if (write_enable) memory[write_address] <= write_data;
end

// Read logic
always @(posedge read_clock) begin
  if (read_enable) read_data <= memory[read_address];
end

endmodule
