// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_advanced_fifo.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue with valid-ready flow   ║
// ║              control.                                                     ║
// ║                                                                           ║
// ║              Compared to the normal FIFO, this one also features a level  ║
// ║              outout, and dynamic threshold flags.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_advanced_fifo #(
  parameter WIDTH      = 8,
  parameter DEPTH      = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                 clock,
  input                 resetn,
  input                 flush,
  // Write interface
  input     [WIDTH-1:0] write_data,
  input                 write_valid,
  output                write_ready,
  // Read interface
  output    [WIDTH-1:0] read_data,
  output                read_valid,
  input                 read_ready,
  // Level
  output                full,
  output                empty,
  output [DEPTH_LOG2:0] level,
  // Threshold
  input  [DEPTH_LOG2:0] lower_threshold_level,
  output                lower_threshold_status,
  input  [DEPTH_LOG2:0] upper_threshold_level,
  output                upper_threshold_status
);

wire write_enable = write_valid;
wire read_enable  = read_ready;

advanced_fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) advanced_fifo (
  .clock                  ( clock                  ),
  .resetn                 ( resetn                 ),
  .flush                  ( flush                  ),
  .clear_flags            ( 1'b0                   ),
  // Write interface
  .write_enable           ( write_enable           ),
  .write_data             ( write_data             ),
  .write_miss             (                        ),
  .full                   ( full                   ),
  // Read interface
  .read_enable            ( read_enable            ),
  .read_data              ( read_data              ),
  .read_error             (                        ),
  .empty                  ( empty                  ),
  // Level and threshold
  .level                  ( level                  ),
  .lower_threshold_level  ( lower_threshold_level  ),
  .lower_threshold_status ( lower_threshold_status ),
  .upper_threshold_level  ( upper_threshold_level  ),
  .upper_threshold_status ( upper_threshold_status )
);

assign write_ready = ~full;
assign read_valid  = ~empty;

endmodule
