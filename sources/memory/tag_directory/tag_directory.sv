// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        tag_directory.sv                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Directory in which tags can be allocated, searched for, and  ║
// ║              evicted.                                                     ║
// ║                                                                           ║
// ║              When the directory is not full, the allocation interface can ║
// ║              be used to write a tag to the first free slot.               ║
// ║                                                                           ║
// ║              Searching a tag in the directory using the search interface  ║
// ║              can result in a hit or a miss. In case of a hit, the index   ║
// ║              of the tag in the directory is returned.                     ║
// ║                                                                           ║
// ║              The eviction interface is used to manually invalidate and    ║
// ║              free the slot at a specified index.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module tag_directory #(
  parameter WIDTH = 8,
  parameter DEPTH = 16,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                         clock,
  input                         resetn,
  output logic                  full,
  // Allocation interface
  input                         allocate_enable,
  input             [WIDTH-1:0] allocate_tag,
  // Search interface
  input              [WIDTH-1:0] search_tag,
  output logic [INDEX_WIDTH-1:0] search_index,
  output logic                   search_hit,
  // Evict interface
  input                          evict_enable,
  input        [INDEX_WIDTH-1:0] evict_index
);

// Memory array
logic [WIDTH-1:0] buffer      [DEPTH-1:0];
logic [WIDTH-1:0] buffer_next [DEPTH-1:0];
logic [DEPTH-1:0] valid;
logic [DEPTH-1:0] valid_next;

// Full when all entries are valid
logic  full_next;
assign full_next = &valid_next;

// Iteration variable
integer depth_index;

// Index of the first free slot in the memory
logic [INDEX_WIDTH-1:0] first_free_index;
always_comb begin
  first_free_index = 0;
`ifdef SIMUMLATOR_NO_BREAK
  for (depth_index = DEPTH-1; depth_index >= 0; depth_index = depth_index-1) begin
`else
  for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
`endif
    if (!valid[depth_index]) begin
      first_free_index = depth_index;
`ifndef SIMUMLATOR_NO_BREAK
      break;
`endif
    end
  end
end

// Allocation and eviction
always_comb begin
  for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
    buffer_next [depth_index] = buffer [depth_index];
    valid_next  [depth_index] = valid  [depth_index];
  end
  if (!full && allocate_enable) begin
    buffer_next [first_free_index] = allocate_tag;
    valid_next  [first_free_index] = 1;
  end
  if (evict_enable) begin
    valid_next [evict_index] = 0;
  end
end

// Search
always_comb begin
  search_index = 0;
  search_hit   = 0;
`ifdef SIMUMLATOR_NO_BREAK
  for (depth_index = DEPTH-1; depth_index >= 0; depth_index = depth_index-1) begin
`else
  for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
`endif
    if (valid[depth_index] && buffer[depth_index] == search_tag) begin
      search_index = depth_index;
      search_hit   = 1;
`ifndef SIMUMLATOR_NO_BREAK
      break;
`endif
    end
  end
end

// Reset and sequential
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    full <= 0;
    for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      buffer [depth_index] <= 0;
      valid  [depth_index] <= 0;
    end
  end else begin
    full <= full_next;
    for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      buffer [depth_index] <= buffer_next [depth_index];
      valid  [depth_index] <= valid_next  [depth_index];
    end
  end
end

endmodule