// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        lifo_controller.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous Last-In First-Out stack controller.              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module lifo_controller #(
  parameter WIDTH = 8,
  parameter DEPTH = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                   clock,
  input                   resetn,
  output                  full,
  output                  empty,
  // Write interface
  input                   write_enable,
  input       [WIDTH-1:0] write_data,
  // Read interface
  input                   read_enable,
  output      [WIDTH-1:0] read_data,
  // Memory interface
  output                  memory_enable,
  output                  memory_write_enable,
  output [DEPTH_LOG2-1:0] memory_address,
  output      [WIDTH-1:0] memory_write_data,
  input       [WIDTH-1:0] memory_read_data
);



// ┌──────────────────┐
// │ Pointer register │
// └──────────────────┘

// Pointer to the top of the stack
reg [DEPTH_LOG2:0] pointer;



// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Stack is full if the pointer equals the depth
assign full  = pointer == DEPTH;

// Stack is empty if the pointer is zero
assign empty = pointer == 0;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

// Pointer sequential logic
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    pointer <= 0;
  end
  // Operation
  else begin
    // Simultaneous read and write - pointer doesn't change
    if (write_enable && read_enable) begin
      // Pointer stays the same, just replace top item
    end
    // Write only (push)
    else if (write_enable) begin
      pointer <= pointer + 1;
    end
    // Read only (pop)
    else if (read_enable) begin
      pointer <= pointer - 1;
    end
  end
end



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

// Calculate addresses
wire [DEPTH_LOG2:0] pointer_minus_one = pointer - 1;
wire [DEPTH_LOG2-1:0] read_address  = pointer_minus_one [DEPTH_LOG2-1:0];
wire [DEPTH_LOG2-1:0] write_address = pointer           [DEPTH_LOG2-1:0];

// Memory access logic
// When read+write simultaneously: write to read_address (replace top)
// When write only: write to write_address (push new)
// When read only: read from read_address (access top)
assign memory_enable       = write_enable || read_enable;
assign memory_write_enable = write_enable;
assign memory_address      = write_enable ? (read_enable ? read_address : write_address) : read_address;
assign memory_write_data   = write_data;

// Read data comes from memory
// Even when writing, the read is combinational and shows the value before the write
assign read_data = memory_read_data;

endmodule
