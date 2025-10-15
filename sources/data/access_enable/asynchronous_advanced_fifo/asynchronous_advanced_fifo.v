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
  parameter STAGES_WRITE = 2,
  parameter STAGES_READ  = 2,
  parameter DEPTH_LOG2   = `CLOG2(DEPTH)
) (
  // Write clock domain
  input                 write_clock,
  input                 write_resetn,
  input                 write_flush,
  // Write interface
  input                 write_enable,
  input     [WIDTH-1:0] write_data,
  // Write status flags
  output                write_empty,
  output                write_almost_empty,
  output                write_half_empty,
  output                write_not_empty,
  output                write_not_full,
  output                write_half_full,
  output                write_almost_full,
  output                write_full,
  output                write_miss,
  // Write level and thresholds
  output [DEPTH_LOG2:0] write_level,
  output [DEPTH_LOG2:0] write_space,
  input  [DEPTH_LOG2:0] write_lower_threshold_level,
  output                write_lower_threshold_status,
  input  [DEPTH_LOG2:0] write_upper_threshold_level,
  output                write_upper_threshold_status,
  // Read clock domain
  input                 read_clock,
  input                 read_resetn,
  input                 read_flush,
  // Read interface
  input                 read_enable,
  output    [WIDTH-1:0] read_data,
  // Read status flags
  output                read_empty,
  output                read_almost_empty,
  output                read_half_empty,
  output                read_not_empty,
  output                read_not_full,
  output                read_half_full,
  output                read_almost_full,
  output                read_full,
  output                read_error,
  // Read level and thresholds
  output [DEPTH_LOG2:0] read_level,
  output [DEPTH_LOG2:0] read_space,
  input  [DEPTH_LOG2:0] read_lower_threshold_level,
  output                read_lower_threshold_status,
  input  [DEPTH_LOG2:0] read_upper_threshold_level,
  output                read_upper_threshold_status
);

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
  .write_empty                   ( write_empty                   ),
  .write_almost_empty            ( write_almost_empty            ),
  .write_half_empty              ( write_half_empty              ),
  .write_not_empty               ( write_not_empty               ),
  .write_not_full                ( write_not_full                ),
  .write_half_full               ( write_half_full               ),
  .write_almost_full             ( write_almost_full             ),
  .write_full                    ( write_full                    ),
  .write_miss                    ( write_miss                    ),
  .write_level                   ( write_level                   ),
  .write_space                   ( write_space                   ),
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
  .read_almost_empty             ( read_almost_empty             ),
  .read_half_empty               ( read_half_empty               ),
  .read_not_empty                ( read_not_empty                ),
  .read_not_full                 ( read_not_full                 ),
  .read_half_full                ( read_half_full                ),
  .read_almost_full              ( read_almost_full              ),
  .read_full                     ( read_full                     ),
  .read_error                    ( read_error                    ),
  .read_level                    ( read_level                    ),
  .read_space                    ( read_space                    ),
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