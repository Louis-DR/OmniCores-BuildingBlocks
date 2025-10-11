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
  // Write clock domain
  input                 write_clock,
  input                 write_resetn,
  input                 write_flush,
  // Write interface
  input     [WIDTH-1:0] write_data,
  input                 write_valid,
  output                write_ready,
  // Write status flags
  output                write_full,
  // Write level and thresholds
  output [DEPTH_LOG2:0] write_level,
  input  [DEPTH_LOG2:0] write_lower_threshold_level,
  output                write_lower_threshold_status,
  input  [DEPTH_LOG2:0] write_upper_threshold_level,
  output                write_upper_threshold_status,
  // Read clock domain
  input                 read_clock,
  input                 read_resetn,
  input                 read_flush,
  // Read interface
  output    [WIDTH-1:0] read_data,
  output                read_valid,
  input                 read_ready,
  // Read status flags
  output                read_empty,
  // Read level and thresholds
  output [DEPTH_LOG2:0] read_level,
  input  [DEPTH_LOG2:0] read_lower_threshold_level,
  output                read_lower_threshold_status,
  input  [DEPTH_LOG2:0] read_upper_threshold_level,
  output                read_upper_threshold_status
);

// Handshake logic
wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

assign write_ready = ~write_full;
assign  read_valid = ~read_empty;

// Memory interface signals
wire                  memory_write_clock;
wire                  memory_write_enable;
wire [DEPTH_LOG2-1:0] memory_write_address;
wire      [WIDTH-1:0] memory_write_data;
wire                  memory_read_clock;
wire                  memory_read_enable;
wire [DEPTH_LOG2-1:0] memory_read_address;
wire      [WIDTH-1:0] memory_read_data;

// Controller
asynchronous_advanced_fifo_controller #(
  .WIDTH        ( WIDTH        ),
  .DEPTH        ( DEPTH        ),
  .STAGES_WRITE ( STAGES_WRITE ),
  .STAGES_READ  ( STAGES_READ  )
) controller (
  .write_clock                   ( write_clock                   ),
  .write_resetn                  ( write_resetn                  ),
  .write_flush                   ( write_flush                   ),
  .write_enable                  ( write_enable                  ),
  .write_data                    ( write_data                    ),
  .write_empty                   (                               ),
  .write_not_empty               (                               ),
  .write_almost_empty            (                               ),
  .write_full                    ( write_full                    ),
  .write_not_full                (                               ),
  .write_almost_full             (                               ),
  .write_miss                    (                               ),
  .write_level                   ( write_level                   ),
  .write_lower_threshold_level   ( write_lower_threshold_level   ),
  .write_lower_threshold_status  ( write_lower_threshold_status  ),
  .write_upper_threshold_level   ( write_upper_threshold_level   ),
  .write_upper_threshold_status  ( write_upper_threshold_status  ),
  .read_clock                    ( read_clock                    ),
  .read_resetn                   ( read_resetn                   ),
  .read_flush                    ( read_flush                    ),
  .read_enable                   ( read_enable                   ),
  .read_data                     ( read_data                     ),
  .read_empty                    ( read_empty                    ),
  .read_not_empty                (                               ),
  .read_almost_empty             (                               ),
  .read_full                     (                               ),
  .read_not_full                 (                               ),
  .read_almost_full              (                               ),
  .read_error                    (                               ),
  .read_level                    ( read_level                    ),
  .read_lower_threshold_level    ( read_lower_threshold_level    ),
  .read_lower_threshold_status   ( read_lower_threshold_status   ),
  .read_upper_threshold_level    ( read_upper_threshold_level    ),
  .read_upper_threshold_status   ( read_upper_threshold_status   ),
  .memory_write_clock            ( memory_write_clock            ),
  .memory_write_enable           ( memory_write_enable           ),
  .memory_write_address          ( memory_write_address          ),
  .memory_write_data             ( memory_write_data             ),
  .memory_read_clock             ( memory_read_clock             ),
  .memory_read_enable            ( memory_read_enable            ),
  .memory_read_address           ( memory_read_address           ),
  .memory_read_data              ( memory_read_data              )
);

// Memory
asynchronous_simple_dual_port_ram #(
  .WIDTH           ( WIDTH ),
  .DEPTH           ( DEPTH ),
  .REGISTERED_READ ( 0     )
) memory (
  .write_clock   ( memory_write_clock   ),
  .write_enable  ( memory_write_enable  ),
  .write_address ( memory_write_address ),
  .write_data    ( memory_write_data    ),
  .read_clock    ( memory_read_clock    ),
  .read_enable   ( memory_read_enable   ),
  .read_address  ( memory_read_address  ),
  .read_data     ( memory_read_data     )
);

endmodule