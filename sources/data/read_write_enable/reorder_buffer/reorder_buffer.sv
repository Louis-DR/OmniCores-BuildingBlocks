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
// ║              First, the order is declared by reserving a slot which gives ║
// ║              an index. Then, writes are performed out-of-order with the   ║
// ║              reservation index. Finally, the data is read in order of the ║
// ║              indicies when available.                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module reorder_buffer #(
  parameter WIDTH       = 8,
  parameter DEPTH       = 8,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output logic             full,
  output logic             empty,
  output logic             data_full,
  output logic             data_empty,
  // Reservation interface
  input                    reserve_enable,
  output [INDEX_WIDTH-1:0] reserve_index,
  output                   reserve_error,
  // Write interface
  input                    write_enable,
  input  [INDEX_WIDTH-1:0] write_index,
  input        [WIDTH-1:0] write_data,
  output                   write_error,
  // Read interface
  input                    read_enable,
  output                   read_valid,
  output       [WIDTH-1:0] read_data,
  output                   read_error
);

// Memory array
logic [WIDTH-1:0] buffer      [DEPTH-1:0];
logic [WIDTH-1:0] buffer_next [DEPTH-1:0];

// Valid entries
logic [DEPTH-1:0] valid;
logic [DEPTH-1:0] valid_next;

// Reserved entries
logic [DEPTH-1:0] reserved;
logic [DEPTH-1:0] reserved_next;

// Head and tail pointers
logic [INDEX_WIDTH-1:0] reserve_pointer;
logic [INDEX_WIDTH-1:0] reserve_pointer_next;
logic [INDEX_WIDTH-1:0] read_pointer;
logic [INDEX_WIDTH-1:0] read_pointer_next;

// Full and empty flags
logic  full_next;
assign full_next = &reserved_next;
logic  empty_next;
assign empty_next = ~|reserved_next;
logic  data_full_next;
assign data_full_next = &valid_next;
logic  data_empty_next;
assign data_empty_next = ~|valid_next;

// Index of the first free slot in the memory
logic       [DEPTH-1:0] first_free_onehot;
logic [INDEX_WIDTH-1:0] first_free_index;

// Find the first free slot in the memory
first_one #(
  .WIDTH ( DEPTH )
) first_free_slot (
  .data      ( ~reserved         ),
  .first_one ( first_free_onehot )
);

// Convert the one-hot index to a binary index
onehot_to_binary #(
  .WIDTH_ONEHOT ( DEPTH )
) onehot_to_index (
  .onehot ( first_free_onehot ),
  .binary ( first_free_index  )
);

// Reservation, write, and read logic
always_comb begin
  // Default assignments
  read_pointer_next    = read_pointer;
  reserve_pointer_next = reserve_pointer;
  for (integer depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
    buffer_next [depth_index] = buffer [depth_index];
    valid_next  [depth_index] = valid  [depth_index];
  end
  // Reservation operation
  if (reserve_enable) begin
    reserved_next [reserve_index] = 1'b1;
    reserve_pointer_next = reserve_pointer + 1;
  end
  // Write operation
  if (write_enable) begin
    buffer_next [write_index] = write_data;
    valid_next  [write_index] = 1'b1;
  end
  // Read operation
  if (read_enable) begin
    valid_next    [read_index] = 1'b0;
    reserved_next [read_index] = 1'b0;
    read_pointer_next = read_pointer + 1;
  end
end

// Reservation logic
assign reserve_index = first_free_index;
// Reservation error if already reserved
assign reserve_error = reserve_enable && reserved[reserve_index];

// Write error if already valid or not reserved
assign write_error = write_enable && (valid[write_index] || !reserved[write_index]);

// Read logic
assign read_valid = valid[read_index];
assign read_data  = buffer[read_index];
// Read error if not valid
assign read_error = read_enable && !read_valid;

// Reset and sequential logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    full       <= 0;
    empty      <= 1;
    data_full  <= 0;
    data_empty <= 1;
    for (integer depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      buffer [depth_index] <= 0;
      valid  [depth_index] <= 0;
    end
  end
  // Operation
  else begin
    full       <= full_next;
    empty      <= empty_next;
    data_full  <= data_full_next;
    data_empty <= data_empty_next;
    for (integer depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      buffer [depth_index] <= buffer_next [depth_index];
      valid  [depth_index] <= valid_next  [depth_index];
    end
  end
end

endmodule