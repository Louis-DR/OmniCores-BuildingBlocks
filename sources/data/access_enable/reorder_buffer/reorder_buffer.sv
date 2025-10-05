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
  // Read interface
  input                    read_enable,
  output       [WIDTH-1:0] read_data
);

// Memory array
logic [WIDTH-1:0] memory [DEPTH-1:0];

// Reserved entries
logic [DEPTH-1:0] reserved;
logic [DEPTH-1:0] reserved_next;

// Valid entries
logic [DEPTH-1:0] valid;
logic [DEPTH-1:0] valid_next;

// Reservation and read pointers with wrap bits
logic [INDEX_WIDTH:0] reserve_pointer;
logic [INDEX_WIDTH:0] reserve_pointer_next;
logic [INDEX_WIDTH:0] read_pointer;
logic [INDEX_WIDTH:0] read_pointer_next;

// Reservation full and empty flags
logic  reserve_full_next;
assign reserve_full_next =  reserve_pointer_next[INDEX_WIDTH-1:0] == read_pointer_next[INDEX_WIDTH-1:0]
                         && reserve_pointer_next[INDEX_WIDTH]     != read_pointer_next[INDEX_WIDTH];
logic  reserve_empty_next;
assign reserve_empty_next =  reserve_pointer_next[INDEX_WIDTH-1:0] == read_pointer_next[INDEX_WIDTH-1:0]
                          && reserve_pointer_next[INDEX_WIDTH]     == read_pointer_next[INDEX_WIDTH];

// Data full and empty flags
logic  data_full_next;
assign data_full_next = &valid_next;
logic  data_empty_next;
assign data_empty_next = ~|valid_next;

// Reservation, write, and read logic
always_comb begin
  // Default assignments
  reserve_pointer_next = reserve_pointer;
  read_pointer_next    = read_pointer;
  reserved_next        = reserved;
  valid_next           = valid;
  // Reservation operation
  if (reserve_enable) begin
    reserved_next [reserve_pointer[INDEX_WIDTH-1:0]] = 1'b1;
    reserve_pointer_next = reserve_pointer + 1;
  end
  // Write operation
  if (write_enable) begin
    valid_next  [write_index] = 1'b1;
  end
  // Read operation
  if (read_enable) begin
    valid_next    [read_pointer[INDEX_WIDTH-1:0]] = 1'b0;
    reserved_next [read_pointer[INDEX_WIDTH-1:0]] = 1'b0;
    read_pointer_next = read_pointer + 1;
  end
end

// Reservation logic
assign reserve_index = reserve_pointer[INDEX_WIDTH-1:0];

// Read logic
assign read_data = memory[read_pointer[INDEX_WIDTH-1:0]];

// Reset and sequential logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    reserve_full    <= 0;
    reserve_empty   <= 1;
    data_full       <= 0;
    data_empty      <= 1;
    reserve_pointer <= 0;
    read_pointer    <= 0;
    reserved        <= 0;
    valid           <= 0;
  end
  // Operation
  else begin
    reserve_full    <= reserve_full_next;
    reserve_empty   <= reserve_empty_next;
    data_full       <= data_full_next;
    data_empty      <= data_empty_next;
    reserve_pointer <= reserve_pointer_next;
    read_pointer    <= read_pointer_next;
    reserved        <= reserved_next;
    valid           <= valid_next;
  end
end

// Write to memory without reset
always @(posedge clock) begin
  if (write_enable) begin
    memory[write_index] <= write_data;
  end
end

endmodule