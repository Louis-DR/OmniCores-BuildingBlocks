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



module fifo_controller #(
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



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

assign memory_clock         = clock;
assign memory_write_enable  = write_enable;
assign memory_write_address = write_address;
assign memory_write_data    = write_data;
assign memory_read_enable   = read_enable;
assign memory_read_address  = read_address;
assign read_data            = memory_read_data;

endmodule
