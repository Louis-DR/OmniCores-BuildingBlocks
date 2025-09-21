// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo_controller.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue controller.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                   clock,
  input                   resetn,
  // Write interface
  input                   write_enable,
  input       [WIDTH-1:0] write_data,
  output                  full,
  // Read interface
  input                   read_enable,
  output      [WIDTH-1:0] read_data,
  output                  empty,
  // Memory interface
  output                  memory_write_enable,
  output                  memory_read_enable,
  output [DEPTH_LOG2-1:0] memory_address,
  output      [WIDTH-1:0] memory_write_data,
  input       [WIDTH-1:0] memory_read_data
);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];



// ┌─────────────┐
// │ Write logic │
// └─────────────┘

// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;

// Write address without wrap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];



// ┌────────────┐
// │ Read logic │
// └────────────┘

// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;

// Read address without wrap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Value at the read pointer is always on the read data bus
assign read_data = memory[read_address];



// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Queue is full if the read and write pointers are the same but the wrap bits are different
assign full  = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] != read_pointer[DEPTH_LOG2];

// Queue is empty if the read and write pointers are the same and the wrap bits are equal
assign empty = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] == read_pointer[DEPTH_LOG2];



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

// Write and read pointers sequential logic
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    write_pointer <= 0;
    read_pointer  <= 0;
  end
  // Operation
  else begin
    // Write
    if (write_enable) begin
      write_pointer <= write_pointer + 1;
    end
    // Read
    if (read_enable) begin
      read_pointer <= read_pointer + 1;
    end
  end
end



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

assign memory_write_enable = write_enable;
assign memory_read_enable  = read_enable;
assign memory_address      = write_enable ? write_address : read_address;
assign memory_write_data   = write_data;
assign read_data           = memory_read_data;

endmodule
