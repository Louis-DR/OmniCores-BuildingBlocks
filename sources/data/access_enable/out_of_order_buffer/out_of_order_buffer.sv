// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        out_of_order_buffer.sv                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Buffer with out-of-order reading.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module out_of_order_buffer #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output logic             full,
  output logic             empty,
  // Write interface
  input                    write_enable,
  input        [WIDTH-1:0] write_data,
  output [INDEX_WIDTH-1:0] write_index,
  // Read interface
  input                    read_enable,
  input                    read_clear,
  input  [INDEX_WIDTH-1:0] read_index,
  output       [WIDTH-1:0] read_data,
  output logic             read_error
);

// Memory interface signals
logic                   memory_write_enable;
logic [INDEX_WIDTH-1:0] memory_write_address;
logic       [WIDTH-1:0] memory_write_data;
logic                   memory_read_enable;
logic [INDEX_WIDTH-1:0] memory_read_address;
logic       [WIDTH-1:0] memory_read_data;

// Controller
out_of_order_buffer_controller #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) controller (
  .clock                ( clock                ),
  .resetn               ( resetn               ),
  .full                 ( full                 ),
  .empty                ( empty                ),
  .write_enable         ( write_enable         ),
  .write_data           ( write_data           ),
  .write_index          ( write_index          ),
  .read_enable          ( read_enable          ),
  .read_clear           ( read_clear           ),
  .read_index           ( read_index           ),
  .read_data            ( read_data            ),
  .read_error           ( read_error           ),
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
  .clock         ( clock                ),
  .write_enable  ( memory_write_enable  ),
  .write_address ( memory_write_address ),
  .write_data    ( memory_write_data    ),
  .read_enable   ( memory_read_enable   ),
  .read_address  ( memory_read_address  ),
  .read_data     ( memory_read_data     )
);

endmodule