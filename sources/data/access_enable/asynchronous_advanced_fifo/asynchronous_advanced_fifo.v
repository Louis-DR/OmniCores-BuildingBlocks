// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_advanced_fifo.v                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue.                       ║
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



`include "clog2.vh"



module asynchronous_advanced_fifo #(
  parameter WIDTH        = 8,
  parameter DEPTH        = 4,
  parameter DEPTH_LOG2   = `CLOG2(DEPTH),
  parameter STAGES_WRITE = 2,
  parameter STAGES_READ  = 2
) (
  // Write interface
  input                 write_clock,
  input                 write_resetn,
  input                 write_flush,
  input                 write_enable,
  input     [WIDTH-1:0] write_data,
  // Write status
  output reg            write_miss,
  input                 write_clear_miss,
  output                write_empty,
  output                write_not_empty,
  output                write_almost_empty,
  output                write_full,
  output                write_not_full,
  output                write_almost_full,
  output [DEPTH_LOG2:0] write_level,
  input  [DEPTH_LOG2:0] write_lower_threshold_level,
  output                write_lower_threshold_status,
  input  [DEPTH_LOG2:0] write_upper_threshold_level,
  output                write_upper_threshold_status,
  // Read interface
  input                 read_clock,
  input                 read_resetn,
  input                 read_flush,
  input                 read_enable,
  output    [WIDTH-1:0] read_data,
  // Read status
  output reg            read_error,
  input                 read_clear_error,
  output                read_empty,
  output                read_not_empty,
  output                read_almost_empty,
  output                read_full,
  output                read_not_full,
  output                read_almost_full,
  output [DEPTH_LOG2:0] read_level,
  input  [DEPTH_LOG2:0] read_lower_threshold_level,
  output                read_lower_threshold_status,
  input  [DEPTH_LOG2:0] read_upper_threshold_level,
  output                read_upper_threshold_status
);

// Depth properties
localparam DEPTH_IS_POW2 = `IS_POW2(DEPTH);
localparam DEPTH_IS_ODD  = DEPTH % 2 == 1;

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Write pointer counter with lap bit
wire [DEPTH_LOG2:0] write_pointer;
wire [DEPTH_LOG2:0] write_pointer_gray;

// Write when not full and not flushing
wire do_write = write_enable && !write_full && !write_flush;

// Write pointer counter
// The counter range is double so the Gray MSB acts as lap bit
gray_wrapping_counter #(
  .RANGE        ( DEPTH*2 ),
  .RESET_VALUE  ( 0       ),
  .LOAD_BINARY  ( 1       )
) write_pointer_counter (
  .clock        ( write_clock        ),
  .resetn       ( write_resetn       ),
  .load_enable  ( write_flush        ),
  .load_count   ( read_pointer_w     ),
  .decrement    ( '0                 ),
  .increment    ( do_write           ),
  .count_gray   ( write_pointer_gray ),
  .count_binary ( write_pointer      ),
  .minimum      (                    ),
  .maximum      (                    ),
  .underflow    (                    ),
  .overflow     (                    )
);

// Write address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Read pointer in write clock domain
wire [DEPTH_LOG2:0] read_pointer_gray_w;
wire [DEPTH_LOG2:0] read_pointer_w;

// Read pointer gray-code decoder
gray_to_binary #(
  .RANGE  ( DEPTH * 2 )
) read_pointer_gray_decoder (
  .gray   ( read_pointer_gray_w ),
  .binary ( read_pointer_w      )
);

// Calculate FIFO level by comparing write and read pointers
assign write_level = write_pointer - read_pointer_w;

// Queue is empty if the gray-coded read and write pointers are the same
assign write_empty        = write_pointer_gray == read_pointer_gray_w;
assign write_not_empty    = ~write_empty;
assign write_almost_empty = write_level == 1;

// Queue is full if only the two MSB of the gray-coded pointers differ (this only works for power-of-2 depths)
if (DEPTH_IS_POW2) assign write_full = write_pointer_gray == {~read_pointer_gray_w[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_gray_w[DEPTH_LOG2-2:0]};
else               assign write_full = write_level == DEPTH;
assign write_not_full     = ~write_full;
assign write_almost_full  = write_level == DEPTH - 1;

// Thresholds status
assign write_lower_threshold_status = write_level <= write_lower_threshold_level;
assign write_upper_threshold_status = write_level >= write_upper_threshold_level;

// Write pointer and flag sequential logic
always @(posedge write_clock or negedge write_resetn) begin
  if (!write_resetn) begin
    write_miss <= 0;
  end else begin
    if (write_enable && write_full && !write_clear_miss && !write_flush) begin
      write_miss <= 1;
    end
    if (write_clear_miss) begin
      write_miss <= 0;
    end
  end
end

// Write to memory without reset
always @(posedge write_clock) begin
  if (write_enable && !write_full) begin
    memory[write_address] <= write_data;
  end
end



// ┌───────────────────┐
// │ Read clock domain │
// └───────────────────┘

// Read pointer counter with lap bit
wire [DEPTH_LOG2:0] read_pointer;
wire [DEPTH_LOG2:0] read_pointer_gray;

// Read when not empty and not flushing
wire do_read = read_enable && !read_empty && !read_flush;

// Read pointer counter
// The counter range is double so the Gray MSB acts as lap bit
gray_wrapping_counter #(
  .RANGE        ( DEPTH * 2 ),
  .RESET_VALUE  ( 0         ),
  .LOAD_BINARY  ( 1         )
) read_pointer_counter (
  .clock        ( read_clock        ),
  .resetn       ( read_resetn       ),
  .load_enable  ( read_flush        ),
  .load_count   ( write_pointer_r   ),
  .decrement    ( '0                ),
  .increment    ( do_read           ),
  .count_gray   ( read_pointer_gray ),
  .count_binary ( read_pointer      ),
  .minimum      (                   ),
  .maximum      (                   ),
  .underflow    (                   ),
  .overflow     (                   )
);

// Read address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Write pointer in read clock domain
wire [DEPTH_LOG2:0] write_pointer_gray_r;
wire [DEPTH_LOG2:0] write_pointer_r;

// Write pointer gray-code decoder
gray_to_binary #(
  .RANGE  ( DEPTH * 2 )
) write_pointer_gray_decoder (
  .gray   ( write_pointer_gray_r ),
  .binary ( write_pointer_r      )
);

// Calculate FIFO level by comparing write and read pointers
assign read_level = write_pointer_r - read_pointer;

// Queue is empty if the gray-coded read and write pointers are the same
assign read_empty        = write_pointer_gray_r == read_pointer_gray;
assign read_not_empty    = ~read_empty;
assign read_almost_empty = read_level == 1;

// Queue is full if only the two MSB of the gray-coded pointers differ (this only works for power-of-2 depths)
if (DEPTH_IS_POW2) assign read_full = write_pointer_gray_r == {~read_pointer_gray[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_gray[DEPTH_LOG2-2:0]};
else               assign read_full = read_level == DEPTH;
assign read_not_full     = ~read_full;
assign read_almost_full  = read_level == DEPTH - 1;

// Thresholds status
assign read_lower_threshold_status = read_level <= read_lower_threshold_level;
assign read_upper_threshold_status = read_level >= read_upper_threshold_level;

// Value at the read pointer is always on the read data bus
assign read_data = memory[read_address];

// Read pointer and flag sequential logic
always @(posedge read_clock or negedge read_resetn) begin
  if (!read_resetn) begin
    read_error <= 0;
  end else begin
    if (read_enable && read_empty && !read_clear_error && !read_flush) begin
      read_error <= 1;
    end
    if (read_clear_error) begin
      read_error <= 0;
    end
  end
end



// ┌───────────────────────┐
// │ Clock domain crossing │
// └───────────────────────┘

// Gray-coded read pointer synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2 + 1 ),
  .STAGES   ( STAGES_WRITE   )
) read_pointer_gray_sync (
  .clock    ( write_clock         ),
  .resetn   ( write_resetn        ),
  .data_in  ( read_pointer_gray   ),
  .data_out ( read_pointer_gray_w )
);

// Gray-coded write pointer synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2 + 1 ),
  .STAGES   ( STAGES_READ    )
) write_pointer_gray_sync (
  .clock    ( read_clock           ),
  .resetn   ( read_resetn          ),
  .data_in  ( write_pointer_gray   ),
  .data_out ( write_pointer_gray_r )
);

endmodule
