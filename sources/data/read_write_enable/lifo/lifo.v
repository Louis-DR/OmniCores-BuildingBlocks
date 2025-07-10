// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        lifo.v                                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous Last-In First-Out stack.                         ║
// ║                                                                           ║
// ║              If the LIFO isn't empty, the read_data output is the value   ║
// ║              of the top of the stack. Toggling the read input signal only ║
// ║              moves the stack pointer to the next entry for the next clock ║
// ║              cycle. Therefore, the value can be read instantly and        ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ║              Attempting to read and write at the same time will read the  ║
// ║              current top value then write the new value, thus not moving  ║
// ║              the stack pointer. Passing the data from write_data to       ║
// ║              read_data in such a case would create a single timing path   ║
// ║              through the structure.                                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module lifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  output             full,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data,
  output             empty
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];



// ┌─────────────┐
// │ Stack logic │
// └─────────────┘

// Stack pointer points to the current top of stack
reg [DEPTH_LOG2:0] stack_pointer;

// Read and write addresses for memory indexing
wire [DEPTH_LOG2-1:0] read_address  = stack_pointer[DEPTH_LOG2-1:0] - 1;
wire [DEPTH_LOG2-1:0] write_address = stack_pointer[DEPTH_LOG2-1:0];

// Value at the top of stack is always on the read data bus
assign read_data = memory[read_address];



// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Stack is full if the stack pointer reaches the maximum depth
assign full  = stack_pointer == DEPTH;

// Stack is empty if the stack pointer is zero
assign empty = stack_pointer == 0;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

// Stack pointer sequential logic
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    stack_pointer <= 0;
  end
  // Operation
  else begin
    // Simultaneous read and write - stack pointer doesn't change
    if (write_enable && read_enable) begin
      // Stack pointer stays the same, just replace top item
    end
    // Write only, push to stack
    else if (write_enable) begin
      stack_pointer <= stack_pointer + 1;
    end
    // Read only, pop from stack
    else if (read_enable) begin
      stack_pointer <= stack_pointer - 1;
    end
  end
end

// Write to memory without reset
always @(posedge clock) begin
  if (write_enable) begin
    // Simultaneous read/write
    if (read_enable) begin
      // Replace top item
      memory[read_address] <= write_data;
    end
    // Write only
    else begin
      memory[write_address] <= write_data;
    end
  end
end

endmodule
