// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_advanced_fifo_controller.v                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous advanced First-In First-Out queue controller    ║
// ║              for clock domain crossing with advanced features.            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module asynchronous_advanced_fifo_controller #(
  parameter WIDTH        = 8,
  parameter DEPTH        = 4,
  parameter DEPTH_LOG2   = `CLOG2(DEPTH),
  parameter STAGES_WRITE = 2,
  parameter STAGES_READ  = 2
) (
  // Write clock domain
  input                   write_clock,
  input                   write_resetn,
  input                   write_flush,
  // Write interface
  input                   write_enable,
  input       [WIDTH-1:0] write_data,
  // Write status flags
  output                  write_empty,
  output                  write_almost_empty,
  output                  write_half_empty,
  output                  write_not_empty,
  output                  write_not_full,
  output                  write_half_full,
  output                  write_almost_full,
  output                  write_full,
  output reg              write_miss,
  // Write level and thresholds
  output [DEPTH_LOG2:0]   write_level,
  output [DEPTH_LOG2:0]   write_space,
  input  [DEPTH_LOG2:0]   write_lower_threshold_level,
  output                  write_lower_threshold_status,
  input  [DEPTH_LOG2:0]   write_upper_threshold_level,
  output                  write_upper_threshold_status,
  // Read clock domain
  input                   read_clock,
  input                   read_resetn,
  input                   read_flush,
  // Read interface
  input                   read_enable,
  output      [WIDTH-1:0] read_data,
  // Read status flags
  output                  read_empty,
  output                  read_almost_empty,
  output                  read_half_empty,
  output                  read_not_empty,
  output                  read_not_full,
  output                  read_half_full,
  output                  read_almost_full,
  output                  read_full,
  output reg              read_error,
  // Read level and thresholds
  output [DEPTH_LOG2:0]   read_level,
  output [DEPTH_LOG2:0]   read_space,
  input  [DEPTH_LOG2:0]   read_lower_threshold_level,
  output                  read_lower_threshold_status,
  input  [DEPTH_LOG2:0]   read_upper_threshold_level,
  output                  read_upper_threshold_status,
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

// Depth properties
localparam DEPTH_IS_POW2 = `IS_POW2(DEPTH);
localparam DEPTH_IS_ODD  = DEPTH % 2 == 1;



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Write pointer counter with lap bit
wire [DEPTH_LOG2:0] write_pointer;
wire [DEPTH_LOG2:0] write_pointer_gray;

// Write address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Read pointer in write clock domain
wire [DEPTH_LOG2:0] read_pointer_gray_w;
wire [DEPTH_LOG2:0] read_pointer_w;

// Write when not full and not flushing
wire do_write = write_enable && !write_full && !write_flush;

// Write pointer counter
// The counter range is double so the Gray MSB acts as lap bit
gray_wrapping_counter #(
  .RANGE        ( DEPTH * 2 ),
  .RESET_VALUE  ( 0         ),
  .LOAD_BINARY  ( 1         )
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

// Read pointer gray-code decoder
gray_to_binary #(
  .RANGE  ( DEPTH * 2 )
) read_pointer_gray_decoder (
  .gray   ( read_pointer_gray_w ),
  .binary ( read_pointer_w      )
);

// Calculate FIFO level by comparing write and read pointers
assign write_level = write_pointer - read_pointer_w;
assign write_space = DEPTH - write_level;

// Queue is empty if the gray-coded read and write pointers are the same
assign write_empty        =  write_pointer_gray == read_pointer_gray_w;
assign write_almost_empty =  write_level == 1;
assign write_half_empty   =  write_level <= (DEPTH + 1) / 2;
assign write_not_empty    = ~write_empty;

// Queue is full if only the two MSB of the gray-coded pointers differ (this only works for power-of-2 depths)
if (DEPTH_IS_POW2) assign write_full = write_pointer_gray == {~read_pointer_gray_w[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_gray_w[DEPTH_LOG2-2:0]};
else               assign write_full = write_level == DEPTH;
assign write_almost_full =  write_space ==  1;
assign write_half_full   =  write_space <= DEPTH / 2;
assign write_not_full    = ~write_full;

// Thresholds status
assign write_lower_threshold_status = write_level <= write_lower_threshold_level;
assign write_upper_threshold_status = write_level >= write_upper_threshold_level;

// Write miss flag sequential logic
always @(posedge write_clock or negedge write_resetn) begin
  if (!write_resetn) begin
    write_miss <= 0;
  end else begin
    write_miss <= 0;
    if (!write_flush) begin
      if (write_enable && write_full) begin
        write_miss <= 1;
      end
    end
  end
end



// ┌───────────────────┐
// │ Read clock domain │
// └───────────────────┘

// Read pointer counter with lap bit
wire [DEPTH_LOG2:0] read_pointer;
wire [DEPTH_LOG2:0] read_pointer_gray;

// Read address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Write pointer in read clock domain
wire [DEPTH_LOG2:0] write_pointer_gray_r;
wire [DEPTH_LOG2:0] write_pointer_r;

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

// Write pointer gray-code decoder
gray_to_binary #(
  .RANGE  ( DEPTH * 2 )
) write_pointer_gray_decoder (
  .gray   ( write_pointer_gray_r ),
  .binary ( write_pointer_r      )
);

// Calculate FIFO level by comparing write and read pointers
assign read_level = write_pointer_r - read_pointer;
assign read_space = DEPTH - read_level;

// Queue is empty if the gray-coded read and write pointers are the same
assign read_empty        =  write_pointer_gray_r == read_pointer_gray;
assign read_almost_empty =  read_level == 1;
assign read_half_empty   =  read_level <= (DEPTH + 1) / 2;
assign read_not_empty    = ~read_empty;

// Queue is full if only the two MSB of the gray-coded pointers differ (this only works for power-of-2 depths)
if (DEPTH_IS_POW2) assign read_full = write_pointer_gray_r == {~read_pointer_gray[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_gray[DEPTH_LOG2-2:0]};
else               assign read_full = read_level == DEPTH;
assign read_almost_full  =  read_space ==  1;
assign read_half_full    =  read_space <= DEPTH / 2;
assign read_not_full     = ~read_full;

// Thresholds status
assign read_lower_threshold_status = read_level <= read_lower_threshold_level;
assign read_upper_threshold_status = read_level >= read_upper_threshold_level;

// Read error flag sequential logic
always @(posedge read_clock or negedge read_resetn) begin
  if (!read_resetn) begin
    read_error <= 0;
  end else begin
    read_error <= 0;
    if (!read_flush) begin
      if (read_enable && read_empty) begin
        read_error <= 1;
      end
    end
  end
end



// ┌───────────────────────┐
// │ Clock domain crossing │
// └───────────────────────┘

// Read pointer gray-code synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2 + 1      ),
  .STAGES   ( STAGES_WRITE        )
) read_pointer_gray_sync (
  .clock    ( write_clock         ),
  .resetn   ( write_resetn        ),
  .data_in  ( read_pointer_gray   ),
  .data_out ( read_pointer_gray_w )
);

// Write pointer gray-code synchronizer
vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2 + 1       ),
  .STAGES   ( STAGES_READ          )
) write_pointer_gray_sync (
  .clock    ( read_clock           ),
  .resetn   ( read_resetn          ),
  .data_in  ( write_pointer_gray   ),
  .data_out ( write_pointer_gray_r )
);



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

assign memory_write_clock   = write_clock;
assign memory_write_enable  = do_write;
assign memory_write_address = write_address;
assign memory_write_data    = write_data;
assign memory_read_clock    = read_clock;
assign memory_read_enable   = 1'b1;  // Always read for combinational access
assign memory_read_address  = read_address;
assign read_data            = memory_read_data;

endmodule
