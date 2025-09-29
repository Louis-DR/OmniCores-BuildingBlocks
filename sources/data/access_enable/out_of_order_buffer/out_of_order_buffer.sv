// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        out_of_order_buffer.sv                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Buffer with out-of-order reading.                            ║
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
// ║              cycle. The read operation is fully combinational and         ║
// ║              clearing frees the spot for writing in the next cycle.       ║
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
  output                   read_error
);

// Memory array
logic [WIDTH-1:0] memory [DEPTH-1:0];
logic [DEPTH-1:0] valid;
logic [DEPTH-1:0] valid_next;

// Full when all entries are valid
logic  full_next;
assign full_next = &valid_next;

// Empty when no entries are valid
logic  empty_next;
assign empty_next = ~|valid_next;

// Index of the first free slot in the memory
logic       [DEPTH-1:0] first_free_onehot;
logic [INDEX_WIDTH-1:0] first_free_index;
assign write_index = first_free_index;

// Find the first free slot in the memory
first_one #(
  .WIDTH ( DEPTH )
) first_free_slot (
  .data      ( ~valid            ),
  .first_one ( first_free_onehot )
);

// Convert the one-hot index to a binary index
onehot_to_binary #(
  .WIDTH_ONEHOT ( DEPTH )
) onehot_to_index (
  .onehot ( first_free_onehot ),
  .binary ( first_free_index  )
);

// Allocation and clear logic
always_comb begin
  // Default assignments
  valid_next = valid;
  // Write allocation operation
  if (write_enable) begin
    valid_next[first_free_index] = 1;
  end
  // Read clear operation
  if (read_enable && read_clear) begin
    valid_next[read_index] = 0;
  end
end

// Read logic
assign read_data  = memory[read_index];
assign read_error = read_enable && !valid[read_index];

// Reset and sequential logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    full  <= 0;
    empty <= 1;
    valid <= 0;
  end
  // Operation
  else begin
    full  <= full_next;
    empty <= empty_next;
    valid <= valid_next;
  end
end

// Write to memory without reset
always @(posedge clock) begin
  if (write_enable) begin
    memory[first_free_index] <= write_data;
  end
end

endmodule