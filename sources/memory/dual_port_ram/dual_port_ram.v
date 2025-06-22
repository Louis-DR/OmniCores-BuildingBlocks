// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        dual_port_ram.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Random access memory with separate ports for read and write. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module dual_port_ram #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDRESS_WIDTH = `CLOG2(DEPTH)
) (
  input                      clock,
  input                      resetn,
  // Write interface
  input                      write_enable,
  input  [ADDRESS_WIDTH-1:0] write_address,
  input          [WIDTH-1:0] write_data,
  // Read interface
  input                      read_enable,
  input  [ADDRESS_WIDTH-1:0] read_address,
  output         [WIDTH-1:0] read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Read logic
assign read_data = read_enable ? memory[read_address] : 0;

integer depth_index;
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      memory[depth_index] <= 0;
    end
  end
  // Write
  else if (write_enable) begin
    memory[write_address] <= write_data;
  end
end

endmodule
