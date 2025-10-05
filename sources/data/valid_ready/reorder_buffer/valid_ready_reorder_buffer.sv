// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_reorder_buffer.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Reorder buffer with in-order reservation, out-of-order       ║
// ║              writing, and in-order reading.                               ║
// ║                                                                           ║
// ║              First, the order is declared by reserving a slot which gives ║
// ║              an index. Then, writes are performed out-of-order with the   ║
// ║              reservation index. Finally, the data is read in order of the ║
// ║              indicies when available.                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module valid_ready_reorder_buffer #(
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
  input                    reserve_valid,
  output [INDEX_WIDTH-1:0] reserve_index,
  output                   reserve_ready,
  // Write interface
  input                    write_valid,
  input  [INDEX_WIDTH-1:0] write_index,
  input        [WIDTH-1:0] write_data,
  output                   write_ready,
  // Read interface
  output                   read_valid,
  output       [WIDTH-1:0] read_data,
  input                    read_ready
);

wire reserve_enable = reserve_valid & reserve_ready;
wire   write_enable =   write_valid &   write_ready;
wire    read_enable =    read_valid &    read_ready;

reorder_buffer #(
  .WIDTH          ( WIDTH          ),
  .DEPTH          ( DEPTH          ),
  .INDEX_WIDTH    ( INDEX_WIDTH    )
) reorder_buffer (
  .clock          ( clock          ),
  .resetn         ( resetn         ),
  .reserve_full   ( reserve_full   ),
  .reserve_empty  ( reserve_empty  ),
  .data_full      ( data_full      ),
  .data_empty     ( data_empty     ),
  .reserve_enable ( reserve_enable ),
  .reserve_index  ( reserve_index  ),
  .write_enable   ( write_enable   ),
  .write_index    ( write_index    ),
  .write_data     ( write_data     ),
  .read_enable    ( read_enable    ),
  .read_data      ( read_data      )
);

assign reserve_ready = ~reserve_full;
assign   write_ready = ~data_full;
assign    read_valid = reorder_buffer.valid[reorder_buffer.read_pointer[INDEX_WIDTH-1:0]];

endmodule