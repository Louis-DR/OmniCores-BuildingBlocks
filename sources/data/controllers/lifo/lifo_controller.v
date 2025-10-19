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
  output                  memory_clock,
  output                  memory_write_enable,
  output [DEPTH_LOG2-1:0] memory_write_address,
  output      [WIDTH-1:0] memory_write_data,
  output                  memory_read_enable,
  output [DEPTH_LOG2-1:0] memory_read_address,
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

// Pointer is the top empty entry
// Pointer minus one is the top valid entry
wire [DEPTH_LOG2:0] pointer_minus_one = pointer - 1;

// Forward the clock
assign memory_clock = clock;

// Write port
// When simultaneously reading (pop+push), write to read location to replace top valid entry
assign memory_write_enable  = write_enable;
assign memory_write_address = (write_enable && read_enable) ? pointer_minus_one[DEPTH_LOG2-1:0] : pointer[DEPTH_LOG2-1:0];
assign memory_write_data    = write_data;

// Read port
// Continuously read from top of stack for low latency read
assign memory_read_enable  = ~empty;
assign memory_read_address = pointer_minus_one[DEPTH_LOG2-1:0];
assign read_data           = memory_read_data;

endmodule
