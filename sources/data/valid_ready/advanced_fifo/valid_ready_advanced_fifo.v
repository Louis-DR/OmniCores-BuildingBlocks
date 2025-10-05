// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_advanced_fifo.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue with valid-ready flow   ║
// ║              control and advanced features.                               ║
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
  // Status flags
  output                full,
  output                empty,
  // Write interface
  input     [WIDTH-1:0] write_data,
  input                 write_valid,
  output                write_ready,
  // Read interface
  output    [WIDTH-1:0] read_data,
  output                read_valid,
  input                 read_ready,
  // Level and thresholds
  output [DEPTH_LOG2:0] level,
  input  [DEPTH_LOG2:0] lower_threshold_level,
  output                lower_threshold_status,
  input  [DEPTH_LOG2:0] upper_threshold_level,
  output                upper_threshold_status
);

// Handshake logic
wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

assign write_ready = ~full;
assign  read_valid = ~empty;

// Memory interface signals
logic                  memory_write_enable;
logic [DEPTH_LOG2-1:0] memory_write_address;
logic      [WIDTH-1:0] memory_write_data;
logic                  memory_read_enable;
logic [DEPTH_LOG2-1:0] memory_read_address;
logic      [WIDTH-1:0] memory_read_data;

// Internal signals for unused controller outputs
wire not_empty;
wire almost_empty;
wire not_full;
wire almost_full;
wire write_miss;
wire read_error;

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
  .clock         ( clock                ),
  .write_enable  ( memory_write_enable  ),
  .write_address ( memory_write_address ),
  .write_data    ( memory_write_data    ),
  .read_enable   ( memory_read_enable   ),
  .read_address  ( memory_read_address  ),
  .read_data     ( memory_read_data     )
);

endmodule