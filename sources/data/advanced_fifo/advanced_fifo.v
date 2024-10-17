// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_fifo.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue.                        ║
// ║                                                                           ║
// ║              Compared to the normal FIFO, this one also features read and ║
// ║              write protection, a miss flag, and a dynamic threshold flag. ║
// ║                                                                           ║
// ║              If the FIFO isn't empty, the read_data output is the value   ║
// ║              of the tail of the queue. Toggling the read input signal     ║
// ║              only moves the read pointer to the next entry for the next   ║
// ║              clock cycle. Therefore, the value can be read instantly and  ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module advanced_fifo #(
  parameter WIDTH      = 8,
  parameter DEPTH      = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                 clock,
  input                 resetn,
  // Write interface
  input                 write_enable,
  input     [WIDTH-1:0] write_data,
  output                write_miss,
  output                full,
  // Read interface
  input                 read_enable,
  output    [WIDTH-1:0] read_data,
  output                read_error,
  output                empty,
  // Level and threshold
  output [DEPTH_LOG2:0] level,
  input  [DEPTH_LOG2:0] lower_threshold_level,
  output                lower_threshold_status,
  input  [DEPTH_LOG2:0] upper_threshold_level,
  output                upper_threshold_status
);



// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];



// ┌─────────────┐
// │ Write logic │
// └─────────────┘

// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;

// Write address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];



// ┌────────────┐
// │ Read logic │
// └────────────┘

// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;

// Read address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Value at the read pointer is always on the read data bus
assign read_data = buffer[read_address];



// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Queue is full if the read and write pointers are the same but the wrap bits are different
assign full  = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] != read_pointer[DEPTH_LOG2];

// Queue is empty if the read and write pointers are the same and the wrap bits are equal
assign empty = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] == read_pointer[DEPTH_LOG2];

// Calculate FIFO level by comparing write and read pointers
assign level = write_pointer - read_pointer;

// Thresholds status
assign lower_threshold_status = level <= lower_threshold_level;
assign upper_threshold_status = level >= upper_threshold_level;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

integer depth_index;
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    write_pointer <= 0;
    read_pointer  <= 0;
    for (depth_index=0; depth_index<DEPTH; depth_index=depth_index+1) begin
      buffer[depth_index] <= 0;
    end
  end
  // Operation
  else begin
    // Write
    if (write_enable && !full) begin
      write_pointer         <= write_pointer + 1;
      buffer[write_address] <= write_data;
    end
    // Read
    if (read_enable && !empty) begin
      read_pointer <= read_pointer + 1;
    end
  end
end

endmodule
