// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo.v                                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue.                        ║
// ║                                                                           ║
// ║              If the FIFO isn't empty, the read_data output is the value   ║
// ║              of the tail of the queue. Toggling the read input signal     ║
// ║              only moves the read pointer to the next entry for the next   ║
// ║              clock cycle. Therefore, the value can be read instantly and  ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  output             full,
  output             empty,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];



// ┌─────────────┐
// │ Write logic │
// └─────────────┘

// Write pointer with lap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;

// Write address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Write lap bit
wire write_lap = write_pointer[DEPTH_LOG2];



// ┌────────────┐
// │ Read logic │
// └────────────┘

// Read pointer with lap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;

// Read address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Value at the read pointer is always on the read data bus
assign read_data = memory[read_address];

// Read lap bit
wire read_lap = read_pointer[DEPTH_LOG2];


// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Queue is full if the read and write pointers are the same but the lap bits are different
assign full  = write_address == read_address && write_lap != read_lap;

// Queue is empty if the read and write pointers are the same and the lap bits are equal
assign empty = write_address == read_address && write_lap == read_lap;



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

// Write to memory without reset
always @(posedge clock) begin
  if (write_enable) begin
    memory[write_address] <= write_data;
  end
end

endmodule
