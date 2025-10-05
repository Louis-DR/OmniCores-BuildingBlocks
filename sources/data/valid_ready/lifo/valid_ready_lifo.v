// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_lifo.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous Last-In First-Out stack with valid-ready flow    ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module valid_ready_lifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  output             full,
  output             empty,
  // Write interface
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output             write_ready,
  // Read interface
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_ready
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Handshake logic
wire write_enable = write_valid & write_ready;
wire  read_enable =  read_valid &  read_ready;

assign write_ready = ~full;
assign  read_valid = ~empty;

// Memory interface signals
logic                  memory_enable;
logic                  memory_write_enable;
logic [DEPTH_LOG2-1:0] memory_address;
logic      [WIDTH-1:0] memory_write_data;
logic      [WIDTH-1:0] memory_read_data;

// Controller
lifo_controller #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) controller (
  .clock               ( clock               ),
  .resetn              ( resetn              ),
  .full                ( full                ),
  .empty               ( empty               ),
  // Write interface
  .write_enable        ( write_enable        ),
  .write_data          ( write_data          ),
  // Read interface
  .read_enable         ( read_enable         ),
  .read_data           ( read_data           ),
  // Memory interface
  .memory_enable       ( memory_enable       ),
  .memory_write_enable ( memory_write_enable ),
  .memory_address      ( memory_address      ),
  .memory_write_data   ( memory_write_data   ),
  .memory_read_data    ( memory_read_data    )
);

// Memory
single_port_ram #(
  .WIDTH           ( WIDTH ),
  .DEPTH           ( DEPTH ),
  .REGISTERED_READ ( 0     )
) memory (
  .clock         ( clock               ),
  .access_enable ( memory_enable       ),
  .write         ( memory_write_enable ),
  .address       ( memory_address      ),
  .write_data    ( memory_write_data   ),
  .read_data     ( memory_read_data    )
);

endmodule
