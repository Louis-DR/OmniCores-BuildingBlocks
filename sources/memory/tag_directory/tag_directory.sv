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
// ║              be used to write a tag to the first free slot and get the    ║
// ║              corresponding index.                                         ║
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
  parameter WIDTH       = 8,
  parameter DEPTH       = 16,
  parameter INDEX_WIDTH = $clog2(DEPTH)
) (
  input                    clock,
  input                    resetn,
  output                   full,
  output                   empty,
  // Allocation interface
  input                    allocate_enable,
  input        [WIDTH-1:0] allocate_tag,
  output [INDEX_WIDTH-1:0] allocate_index,
  // Search interface
  input        [WIDTH-1:0] search_tag,
  output [INDEX_WIDTH-1:0] search_index,
  output                   search_hit,
  // Evict interface
  input                    evict_enable,
  input  [INDEX_WIDTH-1:0] evict_index
);

// Memory array
logic [WIDTH-1:0] memory [DEPTH-1:0];
logic [DEPTH-1:0] valid;

// Full and valid flags
assign full  =  &valid;
assign empty = ~|valid;

// Index of the first free slot in the memory
logic       [DEPTH-1:0] first_free_onehot;
logic [INDEX_WIDTH-1:0] first_free_index;
assign allocate_index = first_free_index;

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

// Reset and sequential allocation and eviction logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    valid <= '0;
  end
  // Operation
  else begin
    // Allocation
    if (allocate_enable) begin
      valid[first_free_index] <= 1;
    end
    // Eviction
    if (evict_enable) begin
      valid[evict_index] <= 0;
    end
  end
end

// Allocate to memory without reset
always_ff @(posedge clock) begin
  if (allocate_enable) begin
    memory[first_free_index] <= allocate_tag;
  end
end

// Search logic
logic [DEPTH-1:0] search_match_vector;
logic [DEPTH-1:0] search_first_onehot;

// Vector of matching entries
always_comb begin
  for (int depth_index = 0; depth_index < DEPTH; depth_index++) begin
    search_match_vector[depth_index] = valid[depth_index] & (memory[depth_index] == search_tag);
  end
end

// Find the first matching entry
first_one #(
  .WIDTH ( DEPTH )
) search_first_one (
  .data      ( search_match_vector ),
  .first_one ( search_first_onehot )
);

// Convert the one-hot index to a binary index
onehot_to_binary #(
  .WIDTH_ONEHOT ( DEPTH )
) search_onehot_to_index (
  .onehot ( search_first_onehot ),
  .binary ( search_index        )
);

// The search hits if any entry matches
assign search_hit = |search_match_vector;

endmodule