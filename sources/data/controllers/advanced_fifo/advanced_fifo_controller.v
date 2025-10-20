// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_fifo_controller.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue controller with         ║
// ║              advanced features.                                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module advanced_fifo_controller #(
  parameter WIDTH      = 8,
  parameter DEPTH      = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                   clock,
  input                   resetn,
  input                   flush,
  // Status flags
  output                  empty,
  output                  almost_empty,
  output                  half_empty,
  output                  not_empty,
  output                  not_full,
  output                  half_full,
  output                  almost_full,
  output                  full,
  output reg              write_miss,
  output reg              read_error,
  // Write interface
  input                   write_enable,
  input       [WIDTH-1:0] write_data,
  // Read interface
  input                   read_enable,
  output      [WIDTH-1:0] read_data,
  // Level and thresholds
  output [DEPTH_LOG2:0]   level,
  output [DEPTH_LOG2:0]   space,
  input  [DEPTH_LOG2:0]   lower_threshold_level,
  output                  lower_threshold_status,
  input  [DEPTH_LOG2:0]   upper_threshold_level,
  output                  upper_threshold_status,
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

// Write pointer with lap bit handled by advanced counter
wire [DEPTH_LOG2:0] write_pointer;

// Write address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Write lap bit
wire write_lap = write_pointer[DEPTH_LOG2];

// Write when not full and not flushing
wire do_write = write_enable && !full && !flush;

// Write pointer counter
advanced_wrapping_counter #(
  .RANGE       ( DEPTH ),
  .RESET_VALUE ( 0     ),
  .LAP_BIT     ( 1     )
) write_pointer_counter (
  .clock       ( clock         ),
  .resetn      ( resetn        ),
  .load_enable ( '0            ),
  .load_count  ( '0            ),
  .decrement   ( '0            ),
  .increment   ( do_write      ),
  .count       ( write_pointer ),
  .minimum     (               ),
  .maximum     (               ),
  .underflow   (               ),
  .overflow    (               )
);



// ┌────────────┐
// │ Read logic │
// └────────────┘

// Read pointer with lap bit handled by advanced counter
wire [DEPTH_LOG2:0] read_pointer;

// Read address without lap bit to index the memory
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Read lap bit
wire read_lap = read_pointer[DEPTH_LOG2];

// Read when not empty and not flushing
wire do_read = read_enable && !empty && !flush;

// Read pointer counter with flush control
advanced_wrapping_counter #(
  .RANGE       ( DEPTH ),
  .RESET_VALUE ( 0     ),
  .LAP_BIT     ( 1     )
) read_pointer_counter (
  .clock       ( clock         ),
  .resetn      ( resetn        ),
  .load_enable ( flush         ),
  .load_count  ( write_pointer ),
  .decrement   ( '0            ),
  .increment   ( do_read       ),
  .count       ( read_pointer  ),
  .minimum     (               ),
  .maximum     (               ),
  .underflow   (               ),
  .overflow    (               )
);



// ┌──────────────┐
// │ Status logic │
// └──────────────┘

// Calculate FIFO level
if (`IS_POW2(DEPTH)) begin : gen_pow2_level
  // For power-of-2 depths, the level is simply the difference between the write and read pointers
  assign level = write_pointer - read_pointer;
end else begin : gen_non_pow2_level
  // For non-power-of-2 depths, we need to handle the lap bit explicitly and use the address difference
  assign level = write_address - read_address + (write_lap == read_lap ? 0 : DEPTH);
end
assign space = DEPTH - level;

// Queue is empty if the read and write pointers are the same and the lap bits are equal
assign empty        = write_address == read_address && write_lap == read_lap;
assign almost_empty = level == 1;
assign half_empty   = level <= DEPTH / 2;
assign not_empty    = ~empty;

// Queue is full if the read and write pointers are the same but the lap bits are different
assign full         = write_address == read_address && write_lap != read_lap;
assign almost_full  = space ==  1;
assign half_full    = space <= DEPTH / 2;
assign not_full     = ~full;

// Thresholds status
assign lower_threshold_status = level <= lower_threshold_level;
assign upper_threshold_status = level >= upper_threshold_level;



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

// Flags sequential logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    write_miss <= 0;
    read_error <= 0;
  end else begin
    write_miss <= 0;
    read_error <= 0;
    if (!flush) begin
      if (write_enable && full) begin
        write_miss <= 1;
      end
      if (read_enable && empty) begin
        read_error <= 1;
      end
    end
  end
end



// ┌────────────────────────┐
// │ Memory interface logic │
// └────────────────────────┘

// Forward the clock
assign memory_clock = clock;

// Write port
assign memory_write_enable  = do_write;
assign memory_write_address = write_address;
assign memory_write_data    = write_data;

// Read port
// Continuously read from head of queue for low latency read
assign memory_read_enable   = ~empty;
assign memory_read_address  = read_address;
assign read_data            = memory_read_data;

endmodule
