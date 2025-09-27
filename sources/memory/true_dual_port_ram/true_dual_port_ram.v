// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        true_dual_port_ram.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with two read-write ports.              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module true_dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter WRITE_THROUGH   = 0,
  parameter REGISTERED_READ = 1,
  parameter ADDRESS_WIDTH   = `CLOG2(DEPTH)
) (
  input                     clock,
  // First read-write interface
  input                     port_0_access_enable,
  input                     port_0_write,
  input [ADDRESS_WIDTH-1:0] port_0_address,
  input         [WIDTH-1:0] port_0_write_data,
  output        [WIDTH-1:0] port_0_read_data,
  // Second read-write interface
  input                     port_1_access_enable,
  input                     port_1_write,
  input [ADDRESS_WIDTH-1:0] port_1_address,
  input         [WIDTH-1:0] port_1_write_data,
  output        [WIDTH-1:0] port_1_read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Internal enable signals
wire port_0_write_enable = port_0_access_enable &  port_0_write;
wire port_0_read_enable  = port_0_access_enable & ~port_0_write;
wire port_1_write_enable = port_1_access_enable &  port_1_write;
wire port_1_read_enable  = port_1_access_enable & ~port_1_write;

// Write logic
always @(posedge clock) begin
  if (port_0_write_enable) memory[port_0_address] <= port_0_write_data;
  if (port_1_write_enable) memory[port_1_address] <= port_1_write_data;
end

// Read-write conflict
wire same_address = port_0_address == port_1_address;

// Registered read logic
if (REGISTERED_READ) begin
  reg [WIDTH-1:0] port_0_registered_read_data;
  reg [WIDTH-1:0] port_1_registered_read_data;
  always @(posedge clock) begin
    // Port 0 read logic
    if (port_0_read_enable) begin
      if (WRITE_THROUGH && port_1_write_enable && same_address) begin
        port_0_registered_read_data <= port_1_write_data;
      end else if (WRITE_THROUGH && port_0_write_enable) begin
        port_0_registered_read_data <= port_0_write_data;
      end else begin
        port_0_registered_read_data <= memory[port_0_address];
      end
    end
    // Port 1 read logic
    if (port_1_read_enable) begin
      if (WRITE_THROUGH && port_0_write_enable && same_address) begin
        port_1_registered_read_data <= port_0_write_data;
      end else if (WRITE_THROUGH && port_1_write_enable) begin
        port_1_registered_read_data <= port_1_write_data;
      end else begin
        port_1_registered_read_data <= memory[port_1_address];
      end
    end
  end
  assign port_0_read_data = port_0_registered_read_data;
  assign port_1_read_data = port_1_registered_read_data;
end

// Combinational read logic
else begin
  assign port_0_read_data = (WRITE_THROUGH && port_1_write_enable && same_address) ? port_1_write_data :
                            (WRITE_THROUGH && port_0_write_enable)                 ? port_0_write_data :
                            memory[port_0_address];
  assign port_1_read_data = (WRITE_THROUGH && port_1_write_enable)                 ? port_1_write_data :
                            (WRITE_THROUGH && port_0_write_enable && same_address) ? port_0_write_data :
                            memory[port_1_address];
end

endmodule
