// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_out_of_order_buffer.sv                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Buffer with out-of-order reading with valid-ready flow       ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module valid_ready_out_of_order_buffer #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output                   full,
  output                   empty,
  // Write interface
  input                    write_valid,
  input        [WIDTH-1:0] write_data,
  output [INDEX_WIDTH-1:0] write_index,
  output                   write_ready,
  // Read interface
  input                    read_valid,
  input                    read_clear,
  input  [INDEX_WIDTH-1:0] read_index,
  output       [WIDTH-1:0] read_data,
  output                   read_ready,
  output logic             read_error
);

// Internal controller signals
wire controller_full;
wire controller_empty;

// Handshake logic
logic  write_enable;
logic   read_enable;
assign write_enable = write_valid & write_ready;
assign  read_enable =  read_valid &  read_ready;

assign write_ready = ~controller_full;
assign  read_ready = 1'b1;  // Always ready for indexed reads

// Connect to outputs
assign full  = controller_full;
assign empty = controller_empty;

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
  .full                 ( controller_full      ),
  .empty                ( controller_empty     ),
  .write_enable         ( write_enable         ),
  .write_data           ( write_data           ),
  .write_index          ( write_index          ),
  .read_enable          ( read_enable          ),
  .read_clear           ( read_clear           ),
  .read_index           ( read_index           ),
  .read_data            ( read_data            ),
  .read_error           ( read_error           ),
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
  .WIDTH        ( WIDTH ),
  .DEPTH        ( DEPTH ),
  .READ_LATENCY ( 0     )
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