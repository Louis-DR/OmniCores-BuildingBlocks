// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_asynchronous_advanced_fifo.v                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue with valid-ready flow  ║
// ║              control.                                                     ║
// ║                                                                           ║
// ║              Compared to the normal FIFO, this one also features a level  ║
// ║              outout, and dynamic threshold flags.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_asynchronous_advanced_fifo #(
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
  input     [WIDTH-1:0] write_data,
  input                 write_valid,
  output                write_ready,
  // Write status
  output                write_full,
  output [DEPTH_LOG2:0] write_level,
  input  [DEPTH_LOG2:0] write_lower_threshold_level,
  output                write_lower_threshold_status,
  input  [DEPTH_LOG2:0] write_upper_threshold_level,
  output                write_upper_threshold_status,
  // Read interface
  input                 read_clock,
  input                 read_resetn,
  input                 read_flush,
  output    [WIDTH-1:0] read_data,
  output                read_valid,
  input                 read_ready,
  // Read status
  output                read_empty,
  output [DEPTH_LOG2:0] read_level,
  input  [DEPTH_LOG2:0] read_lower_threshold_level,
  output                read_lower_threshold_status,
  input  [DEPTH_LOG2:0] read_upper_threshold_level,
  output                read_upper_threshold_status
);

wire write_enable = write_valid;
wire read_enable  = read_ready;

asynchronous_advanced_fifo #(
  .WIDTH        ( WIDTH        ),
  .DEPTH        ( DEPTH        ),
  .STAGES_WRITE ( STAGES_WRITE ),
  .STAGES_READ  ( STAGES_READ  )
) asynchronous_advanced_fifo (
  // Write interface
  .write_clock                  ( write_clock                  ),
  .write_resetn                 ( write_resetn                 ),
  .write_flush                  ( write_flush                  ),
  .write_enable                 ( write_enable                 ),
  .write_data                   ( write_data                   ),
  .write_full                   ( write_full                   ),
  .write_miss                   (                              ),
  .write_clear_miss             ( 1'b0                         ),
  .write_level                  ( write_level                  ),
  .write_lower_threshold_level  ( write_lower_threshold_level  ),
  .write_lower_threshold_status ( write_lower_threshold_status ),
  .write_upper_threshold_level  ( write_upper_threshold_level  ),
  .write_upper_threshold_status ( write_upper_threshold_status ),
  // Read interface
  .read_clock                   ( read_clock                   ),
  .read_resetn                  ( read_resetn                  ),
  .read_flush                   ( read_flush                   ),
  .read_enable                  ( read_enable                  ),
  .read_data                    ( read_data                    ),
  .read_empty                   ( read_empty                   ),
  .read_error                   (                              ),
  .read_clear_error             ( 1'b0                         ),
  .read_level                   ( read_level                   ),
  .read_lower_threshold_level   ( read_lower_threshold_level   ),
  .read_lower_threshold_status  ( read_lower_threshold_status  ),
  .read_upper_threshold_level   ( read_upper_threshold_level   ),
  .read_upper_threshold_status  ( read_upper_threshold_status  )
);

assign write_ready = ~write_full;
assign read_valid  = ~read_empty;

endmodule