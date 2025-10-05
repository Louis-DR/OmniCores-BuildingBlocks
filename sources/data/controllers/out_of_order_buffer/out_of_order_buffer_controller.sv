// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        out_of_order_buffer_controller.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Controller for out-of-order buffer with indexed access.      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module out_of_order_buffer_controller #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
)(
  input                    clock,
  input                    resetn,
  output                   full,
  output                   empty,
  // Write interface
  input                    write_enable,
  input        [WIDTH-1:0] write_data,
  output [INDEX_WIDTH-1:0] write_index,
  // Read interface
  input                    read_enable,
  input                    read_clear,
  input  [INDEX_WIDTH-1:0] read_index,
  output       [WIDTH-1:0] read_data,
  output logic             read_error,
  // Memory interface
  output logic             memory_write_enable,
  output [INDEX_WIDTH-1:0] memory_write_address,
  output       [WIDTH-1:0] memory_write_data,
  output logic             memory_read_enable,
  output [INDEX_WIDTH-1:0] memory_read_address,
  input        [WIDTH-1:0] memory_read_data
);

// Valid bits for each slot
logic [DEPTH-1:0] valid;
logic [DEPTH-1:0] valid_next;

// Status flags (combinational, based on current valid state)
assign full  = &valid;
assign empty = ~|valid;

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

// Error detection
// Read error: attempting to read from an invalid index
assign read_error = read_enable && !valid[read_index];

// Reset and sequential logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    valid <= 0;
  end
  // Operation
  else begin
    valid <= valid_next;
  end
end

// Memory interface logic
assign memory_write_enable  = write_enable;
assign memory_write_address = first_free_index;
assign memory_write_data    = write_data;
assign memory_read_enable   = read_enable;
assign memory_read_address  = read_index;
assign read_data            = memory_read_data;

endmodule
