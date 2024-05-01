// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_dual_port_ram.v                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with separate asynchronous ports for    ║
// ║              read and write.                                              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module asynchronous_dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  // Write interface
  input                      write_clock,
  input                      write_resetn,
  input                      write_enable,
  input  [ADDRESS_WIDTH-1:0] write_address,
  input          [WIDTH-1:0] write_data,
  // Read interface
  input                      read_clock,
  input                      read_resetn,
  input                      read_enable,
  input  [ADDRESS_WIDTH-1:0] read_address,
  output logic   [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

integer depth_index;
always @(posedge write_clock or negedge write_resetn) begin
  // Reset
  if (!write_resetn) begin
    for (depth_index=0; depth_index<DEPTH; depth_index=depth_index+1) begin
      memory[depth_index] <= 0;
    end
  end
  // Write
  else if (write_enable) begin
    memory[write_address] <= write_data;
  end
end

always @(posedge read_clock or negedge read_resetn) begin
  // Reset
  if (!read_resetn) begin
    read_data <= 0;
  end
  // Read
  else if (read_enable) begin
    read_data <= memory[read_address];
  end
end

endmodule
