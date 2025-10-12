// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_fifo.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue with advanced features. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module advanced_fifo #(
  parameter WIDTH      = 8,
  parameter DEPTH      = 4,
  parameter DEPTH_LOG2 = `CLOG2(DEPTH)
) (
  input                 clock,
  input                 resetn,
  input                 flush,
  // Status flags
  output                empty,
  output                not_empty,
  output                almost_empty,
  output                full,
  output                not_full,
  output                almost_full,
  output                write_miss,
  output                read_error,
  // Write interface
  input                 write_enable,
  input     [WIDTH-1:0] write_data,
  // Read interface
  input                 read_enable,
  output    [WIDTH-1:0] read_data,
  // Level and thresholds
  output [DEPTH_LOG2:0] level,
  input  [DEPTH_LOG2:0] lower_threshold_level,
  output                lower_threshold_status,
  input  [DEPTH_LOG2:0] upper_threshold_level,
  output                upper_threshold_status
);

// Memory interface signals
wire                  memory_clock;
wire                  memory_write_enable;
wire [DEPTH_LOG2-1:0] memory_write_address;
wire      [WIDTH-1:0] memory_write_data;
wire                  memory_read_enable;
wire [DEPTH_LOG2-1:0] memory_read_address;
wire      [WIDTH-1:0] memory_read_data;

// Controller
advanced_fifo_controller #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) controller (
  .clock                   ( clock                   ),
  .resetn                  ( resetn                  ),
  .flush                   ( flush                   ),
  .empty                   ( empty                   ),
  .not_empty               ( not_empty               ),
  .almost_empty            ( almost_empty            ),
  .full                    ( full                    ),
  .not_full                ( not_full                ),
  .almost_full             ( almost_full             ),
  .write_miss              ( write_miss              ),
  .read_error              ( read_error              ),
  .write_enable            ( write_enable            ),
  .write_data              ( write_data              ),
  .read_enable             ( read_enable             ),
  .read_data               ( read_data               ),
  .level                   ( level                   ),
  .lower_threshold_level   ( lower_threshold_level   ),
  .lower_threshold_status  ( lower_threshold_status  ),
  .upper_threshold_level   ( upper_threshold_level   ),
  .upper_threshold_status  ( upper_threshold_status  ),
  .memory_clock            ( memory_clock            ),
  .memory_write_enable     ( memory_write_enable     ),
  .memory_write_address    ( memory_write_address    ),
  .memory_write_data       ( memory_write_data       ),
  .memory_read_enable      ( memory_read_enable      ),
  .memory_read_address     ( memory_read_address     ),
  .memory_read_data        ( memory_read_data        )
);

// Memory
simple_dual_port_ram #(
  .WIDTH           ( WIDTH ),
  .DEPTH           ( DEPTH ),
  .REGISTERED_READ ( 0     )
) memory (
  .clock         ( memory_clock         ),
  .write_enable  ( memory_write_enable  ),
  .write_address ( memory_write_address ),
  .write_data    ( memory_write_data    ),
  .read_enable   ( memory_read_enable   ),
  .read_address  ( memory_read_address  ),
  .read_data     ( memory_read_data     )
);

endmodule