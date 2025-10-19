// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_fifo_controller.v                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue controller for clock   ║
// ║              domain crossing.                                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module asynchronous_fifo_controller #(
  parameter WIDTH      = 8,
  parameter DEPTH      = 4,
  parameter STAGES     = 2,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  // Write clock domain
  input                   write_clock,
  input                   write_resetn,
  input                   write_enable,
  input       [WIDTH-1:0] write_data,
  output                  write_full,
  // Read clock domain
  input                   read_clock,
  input                   read_resetn,
  input                   read_enable,
  output      [WIDTH-1:0] read_data,
  output                  read_empty,
  // Memory interface
  output                  memory_write_clock,
  output                  memory_write_enable,
  output [DEPTH_LOG2-1:0] memory_write_address,
  output      [WIDTH-1:0] memory_write_data,
  output                  memory_read_clock,
  output                  memory_read_enable,
  output [DEPTH_LOG2-1:0] memory_read_address,
  input       [WIDTH-1:0] memory_read_data
);



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;

// Write address without wrap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Gray-coded pointers in write clock domain
reg  [DEPTH_LOG2:0] write_pointer_gray_w;
wire [DEPTH_LOG2:0] read_pointer_gray_w;

// Write pointer incremented and corresponding gray-code
wire [DEPTH_LOG2:0] write_pointer_incremented = write_pointer + 1;
wire [DEPTH_LOG2:0] write_pointer_incremented_gray;

// Write pointer gray-code encoder
binary_to_gray #(
  .WIDTH  ( DEPTH_LOG2+1 )
) write_pointer_incremented_gray_encoder (
  .binary ( write_pointer_incremented      ),
  .gray   ( write_pointer_incremented_gray )
);

// The queue is full if the gray-coded read and write pointers differ only in their two most significant bits
assign write_full =  write_pointer_gray_w[DEPTH_LOG2:DEPTH_LOG2-1] == ~read_pointer_gray_w[DEPTH_LOG2:DEPTH_LOG2-1]
                  && write_pointer_gray_w[DEPTH_LOG2-2:0]          ==  read_pointer_gray_w[DEPTH_LOG2-2:0];

// Write pointer sequential logic
always @(posedge write_clock or negedge write_resetn) begin
  if (!write_resetn) begin
    write_pointer        <= 0;
    write_pointer_gray_w <= 0;
  end else begin
    if (write_enable) begin
      write_pointer        <= write_pointer_incremented;
      write_pointer_gray_w <= write_pointer_incremented_gray;
    end
  end
end



// ┌───────────────────┐
// │ Read clock domain │
// └───────────────────┘

// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;

// Read address without wrap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Gray-coded pointers in read clock domain
wire [DEPTH_LOG2:0] write_pointer_gray_r;
reg  [DEPTH_LOG2:0] read_pointer_gray_r;

// Read pointer incremented and corresponding gray-code
wire [DEPTH_LOG2:0] read_pointer_incremented = read_pointer + 1;
wire [DEPTH_LOG2:0] read_pointer_incremented_gray;

// Read pointer gray-code encoder
binary_to_gray #(
  .WIDTH  ( DEPTH_LOG2+1 )
) read_pointer_incremented_gray_encoder (
  .binary ( read_pointer_incremented      ),
  .gray   ( read_pointer_incremented_gray )
);

// Queue is empty if the gray-coded read and write pointers are the same
assign read_empty = write_pointer_gray_r == read_pointer_gray_r;

// Read pointer sequential logic
always @(posedge read_clock or negedge read_resetn) begin
  if (!read_resetn) begin
    read_pointer        <= 0;
    read_pointer_gray_r <= 0;
  end else begin
    if (read_enable) begin
      read_pointer        <= read_pointer_incremented;
      read_pointer_gray_r <= read_pointer_incremented_gray;
    end
  end
end



// ┌───────────────────────┐
// │ Clock domain crossing │
// └───────────────────────┘

// Gray-coded read pointer synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2+1        ),
  .STAGES   ( STAGES              )
) read_pointer_gray_sync (
  .clock    ( write_clock         ),
  .resetn   ( write_resetn        ),
  .data_in  ( read_pointer_gray_r ),
  .data_out ( read_pointer_gray_w )
);

// Gray-coded write pointer synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2+1         ),
  .STAGES   ( STAGES               )
) write_pointer_gray_sync (
  .clock    ( read_clock           ),
  .resetn   ( read_resetn          ),
  .data_in  ( write_pointer_gray_w ),
  .data_out ( write_pointer_gray_r )
);



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

// Write port
assign memory_write_clock   = write_clock;
assign memory_write_enable  = write_enable;
assign memory_write_address = write_address;
assign memory_write_data    = write_data;

// Read port
// Continuously read from head of queue for low latency read
assign memory_read_clock    = read_clock;
assign memory_read_enable   = ~read_empty;
assign memory_read_address  = read_address;
assign read_data            = memory_read_data;

endmodule