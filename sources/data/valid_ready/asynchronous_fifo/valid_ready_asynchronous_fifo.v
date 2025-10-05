// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_asynchronous_fifo.v                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue with valid-ready flow  ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_asynchronous_fifo #(
  parameter WIDTH  = 8,
  parameter DEPTH  = 4,
  parameter STAGES = 2
) (
  // Write clock domain
  input              write_clock,
  input              write_resetn,
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output             write_ready,
  output             write_full,
  // Read clock domain
  input              read_clock,
  input              read_resetn,
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_ready,
  output             read_empty
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Handshake logic
wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

assign write_ready = ~write_full;
assign  read_valid = ~read_empty;

// Memory interface signals
logic                  memory_write_enable;
logic [DEPTH_LOG2-1:0] memory_write_address;
logic      [WIDTH-1:0] memory_write_data;
logic                  memory_read_enable;
logic [DEPTH_LOG2-1:0] memory_read_address;
logic      [WIDTH-1:0] memory_read_data;

// Controller
asynchronous_fifo_controller #(
  .WIDTH  ( WIDTH  ),
  .DEPTH  ( DEPTH  ),
  .STAGES ( STAGES )
) controller (
  .write_clock          ( write_clock          ),
  .write_resetn         ( write_resetn         ),
  .write_enable         ( write_enable         ),
  .write_data           ( write_data           ),
  .write_full           ( write_full           ),
  .read_clock           ( read_clock           ),
  .read_resetn          ( read_resetn          ),
  .read_enable          ( read_enable          ),
  .read_data            ( read_data            ),
  .read_empty           ( read_empty           ),
  .memory_write_enable  ( memory_write_enable  ),
  .memory_write_address ( memory_write_address ),
  .memory_write_data    ( memory_write_data    ),
  .memory_read_enable   ( memory_read_enable   ),
  .memory_read_address  ( memory_read_address  ),
  .memory_read_data     ( memory_read_data     )
);

// Memory
asynchronous_simple_dual_port_ram #(
  .WIDTH           ( WIDTH ),
  .DEPTH           ( DEPTH ),
  .REGISTERED_READ ( 0     )
) memory (
  .write_clock   ( write_clock          ),
  .write_enable  ( memory_write_enable  ),
  .write_address ( memory_write_address ),
  .write_data    ( memory_write_data    ),
  .read_clock    ( read_clock           ),
  .read_enable   ( memory_read_enable   ),
  .read_address  ( memory_read_address  ),
  .read_data     ( memory_read_data     )
);

endmodule