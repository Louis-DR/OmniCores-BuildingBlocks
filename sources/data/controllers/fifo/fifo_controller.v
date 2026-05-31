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
  parameter DEPTH_LOG2 = `CLOG2(DEPTH),
  parameter MEMORY_SEQUENTIAL_READ = 0
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


// ┌───────────────┐
// │ Pointer logic │
// └───────────────┘

// If accessing, increment the pointers
wire [DEPTH_LOG2:0] write_pointer_next = write_enable ? write_pointer + 1 : write_pointer;
wire [DEPTH_LOG2:0] read_pointer_next  = read_enable  ? read_pointer  + 1 : read_pointer;

// Write and read pointers sequential logic
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    write_pointer <= 0;
    read_pointer  <= 0;
  end
  // Operation
  else begin
    write_pointer <= write_pointer_next;
    read_pointer  <= read_pointer_next;
  end
end



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

// Forward the clock
assign memory_clock = clock;

// Write port
assign memory_write_enable  = write_enable;
assign memory_write_address = write_address;
assign memory_write_data    = write_data;

// Read port
generate
  // With sequential read (one cycle latency), use a head buffer to decouple
  // read_data from the RAM output. The buffer acts as the true FIFO head.
  if (MEMORY_SEQUENTIAL_READ) begin : gen_sequential_read
    // Head buffer register
    reg [WIDTH-1:0] head_buffer;

    // Detect if reading would leave the FIFO empty (exactly one entry)
    wire read_empties = (read_pointer + 1'b1) == write_pointer;

    // Bypass write data to head buffer when:
    // 1. Writing to empty FIFO, or
    // 2. Simultaneous read+write when FIFO has exactly one entry
    wire head_bypass = write_enable & (empty | (read_enable & read_empties));

    always @(posedge clock) begin
      if (head_bypass) begin
        head_buffer <= write_data;
      end else if (read_enable) begin
        head_buffer <= memory_read_data;
      end
    end

    // Read data comes from head buffer
    assign read_data = head_buffer;

    // Memory continuously pre-fetches
    assign memory_read_enable = ~empty;

    // Pre-fetch address accounts for reads advancing the pointer
    assign memory_read_address = read_address + 1'b1 + read_enable;
  end
  // With combinational read (zero cycle latency), continuously read from head of queue
  else begin : gen_combinational_read
    assign read_data            = memory_read_data;
    assign memory_read_enable   = ~empty;
    assign memory_read_address  = read_address;
  end
endgenerate

endmodule
