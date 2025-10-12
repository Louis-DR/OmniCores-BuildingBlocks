// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        reorder_buffer.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Reorder buffer with in-order reservation, out-of-order       ║
// ║              writing, and in-order reading.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module reorder_buffer #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output logic             reserve_full,
  output logic             reserve_empty,
  output logic             data_full,
  output logic             data_empty,
  // Reservation interface
  input                    reserve_enable,
  output [INDEX_WIDTH-1:0] reserve_index,
  // Write interface
  input                    write_enable,
  input  [INDEX_WIDTH-1:0] write_index,
  input        [WIDTH-1:0] write_data,
  output logic             write_error,
  // Read interface
  input                    read_enable,
  output       [WIDTH-1:0] read_data
);

// Memory interface signals
logic                   memory_write_enable;
logic [INDEX_WIDTH-1:0] memory_write_address;
logic       [WIDTH-1:0] memory_write_data;
logic                   memory_read_enable;
logic [INDEX_WIDTH-1:0] memory_read_address;
logic       [WIDTH-1:0] memory_read_data;

// Controller
reorder_buffer_controller #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) controller (
  .clock                ( clock                ),
  .resetn               ( resetn               ),
  .reserve_full         ( reserve_full         ),
  .reserve_empty        ( reserve_empty        ),
  .data_full            ( data_full            ),
  .data_empty           ( data_empty           ),
  .reserve_enable       ( reserve_enable       ),
  .reserve_index        ( reserve_index        ),
  .write_enable         ( write_enable         ),
  .write_index          ( write_index          ),
  .write_data           ( write_data           ),
  .write_error          ( write_error          ),
  .read_enable          ( read_enable          ),
  .read_data            ( read_data            ),
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