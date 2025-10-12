// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo.v                                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue for data buffering and  ║
// ║              temporary storage with configurable depth.                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  output             full,
  output             empty,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory interface signals
wire                  memory_clock;
wire                  memory_write_enable;
wire [DEPTH_LOG2-1:0] memory_write_address;
wire      [WIDTH-1:0] memory_write_data;
wire                  memory_read_enable;
wire [DEPTH_LOG2-1:0] memory_read_address;
wire      [WIDTH-1:0] memory_read_data;

// Controller
fifo_controller #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) controller (
  .clock                ( clock                ),
  .resetn               ( resetn               ),
  .full                 ( full                 ),
  .empty                ( empty                ),
  // Write interface
  .write_enable         ( write_enable         ),
  .write_data           ( write_data           ),
  // Read interface
  .read_enable          ( read_enable          ),
  .read_data            ( read_data            ),
  // Memory interface
  .memory_clock         ( memory_clock         ),
  .memory_write_enable  ( memory_write_enable  ),
  .memory_write_address ( memory_write_address ),
  .memory_write_data    ( memory_write_data    ),
  .memory_read_enable   ( memory_read_enable   ),
  .memory_read_address  ( memory_read_address  ),
  .memory_read_data     ( memory_read_data     )
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