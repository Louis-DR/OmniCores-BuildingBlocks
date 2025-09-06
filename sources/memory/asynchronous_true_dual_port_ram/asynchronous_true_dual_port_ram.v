// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_true_dual_port_ram.v                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with two asynchronous read-write ports. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module asynchronous_true_dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  // First read-write interface
  input                      port_0_clock,
  input                      port_0_write_enable,
  input                      port_0_read_enable,
  input  [ADDRESS_WIDTH-1:0] port_0_address,
  input          [WIDTH-1:0] port_0_write_data,
  output         [WIDTH-1:0] port_0_read_data,
  // Second read-write interface
  input                      port_1_clock,
  input                      port_1_write_enable,
  input                      port_1_read_enable,
  input  [ADDRESS_WIDTH-1:0] port_1_address,
  input          [WIDTH-1:0] port_1_write_data,
  output         [WIDTH-1:0] port_1_read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Read logic
assign port_0_read_data = port_0_read_enable ? memory[port_0_address] : 0;
assign port_1_read_data = port_1_read_enable ? memory[port_1_address] : 0;

// Write logic
always @(posedge port_0_clock) begin
  if (port_0_write_enable) memory[port_0_address] <= port_0_write_data;
end

// Write logic
always @(posedge port_1_clock) begin
  if (port_1_write_enable) memory[port_1_address] <= port_1_write_data;
end

endmodule
