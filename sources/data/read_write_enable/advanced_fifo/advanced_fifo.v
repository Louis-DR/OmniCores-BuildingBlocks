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
// ║              write protection, write miss and read error flags, a level   ║
// ║              outout, and a dynamic threshold flag.                        ║
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
  input                 flush,
  input                 clear_flags,
  // Write interface
  input                 write_enable,
  input     [WIDTH-1:0] write_data,
  output reg            write_miss,
  // Read interface
  input                 read_enable,
  output    [WIDTH-1:0] read_data,
  output reg            read_error,
  // Level
  output                empty,
  output                not_empty,
  output                almost_empty,
  output                full,
  output                not_full,
  output                almost_full,
  output [DEPTH_LOG2:0] level,
  // Threshold
  input  [DEPTH_LOG2:0] lower_threshold_level,
  output                lower_threshold_status,
  input  [DEPTH_LOG2:0] upper_threshold_level,
  output                upper_threshold_status
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

// Calculate FIFO level by comparing write and read pointers
assign level = write_pointer - read_pointer;

// Queue is empty if the read and write pointers are the same and the wrap bits are equal
assign empty        = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] == read_pointer[DEPTH_LOG2];
assign not_empty    = ~empty;
assign almost_empty = level == 1;

// Queue is full if the read and write pointers are the same but the wrap bits are different
assign full         = write_pointer[DEPTH_LOG2-1:0] == read_pointer[DEPTH_LOG2-1:0] && write_pointer[DEPTH_LOG2] != read_pointer[DEPTH_LOG2];
assign not_full     = ~full;
assign almost_full  = level == DEPTH - 1;

// Thresholds status
assign lower_threshold_status = level <= lower_threshold_level;
assign upper_threshold_status = level >= upper_threshold_level;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

// Pointer and flags sequential logic
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    write_pointer <= 0;
    read_pointer  <= 0;
    write_miss    <= 0;
    read_error    <= 0;
  end
  // Operation
  else begin
    // Flush
    if (flush) begin
      read_pointer <= write_pointer;
    end
    // Not flush
    else begin
      // Write
      if (write_enable) begin
        if (full) begin
          if (!clear_flags) begin
            write_miss <= 1;
          end
        end else begin
          write_pointer <= write_pointer + 1;
        end
      end
      // Read
      if (read_enable) begin
        if (empty) begin
          if (!clear_flags) begin
            read_error <= 1;
          end
        end else begin
          read_pointer <= read_pointer + 1;
        end
      end
    end
    // Clear
    if (clear_flags) begin
      write_miss <= 0;
      read_error <= 0;
    end
  end
end

// Write to memory without reset
always @(posedge clock) begin
  if (write_enable && !full) begin
    memory[write_address] <= write_data;
  end
end

endmodule
