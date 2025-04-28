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
// ║              When writting, the data is stored in the first free slot and ║
// ║              the corresponding index is returned. The data can then be    ║
// ║              read at the same index. The data can also be cleared during  ║
// ║              the read operation, which frees the slot.                    ║
// ║                                                                           ║
// ║              It is impossible to write when the memory is full, and       ║
// ║              reading to an invalid index will return an error (but not    ║
// ║              break the memory.                                            ║
// ║                                                                           ║
// ║              The write index is available on the same cycle as the write  ║
// ║              operation, and the data is available for reading in the next ║
// ║              cycle. The read operation is fully combinatorial and         ║
// ║              clearing frees the spot for writing in the next cycle.       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module valid_ready_out_of_order_buffer #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output logic             full,
  output logic             empty,
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
  output                   read_ready
);

wire write_enable = write_valid & write_ready;
wire read_enable  = read_valid  & read_ready;

wire read_error;

out_of_order_buffer #(
  .WIDTH        ( WIDTH        ),
  .DEPTH        ( DEPTH        ),
  .INDEX_WIDTH  ( INDEX_WIDTH  )
) out_of_order_buffer (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .empty        ( empty        ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .write_index  ( write_index  ),
  .full         ( full         ),
  .read_enable  ( read_enable  ),
  .read_clear   ( read_clear   ),
  .read_index   ( read_index   ),
  .read_data    ( read_data    ),
  .read_error   ( read_error   )
);

assign write_ready = ~full;
assign read_ready  = out_of_order_buffer.valid[read_index];
// Cannot use read_error for read_ready because it is combinatorial with read_enable

endmodule