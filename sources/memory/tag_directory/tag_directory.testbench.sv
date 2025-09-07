// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        tag_directory.testbench.sv                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the tag directory.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module tag_directory__testbench ();

// Device parameters
localparam int WIDTH = 8;
localparam int DEPTH = 16;

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH_POW2   = 2**WIDTH;
localparam int  INDEX_WIDTH  = $clog2(DEPTH);

// Check parameters
localparam int  SIMULTANEOUS_CHECK_DURATION    = 100;
localparam int  RANDOM_CHECK_DURATION          = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic                   clock;
logic                   resetn;
logic                   full;
logic                   empty;
logic                   allocate_enable;
logic       [WIDTH-1:0] allocate_tag;
logic [INDEX_WIDTH-1:0] allocate_index;
logic       [WIDTH-1:0] search_tag;
logic [INDEX_WIDTH-1:0] search_index;
logic                   search_hit;
logic                   evict_enable;
logic [INDEX_WIDTH-1:0] evict_index;

// Test variables
logic [INDEX_WIDTH-1:0] last_index;
logic       [DEPTH-1:0] model_valid;
logic       [WIDTH-1:0] model_tags [DEPTH-1:0];
logic                   expected_hit;
logic [INDEX_WIDTH-1:0] expected_index;

// Allocate
task automatic allocate;
  allocate_enable = 1;
  allocate_tag    = $urandom_range(WIDTH_POW2);
  last_index      = allocate_index;
  @(posedge clock);
  model_valid [last_index] = 1;
  model_tags  [last_index] = allocate_tag;
  @(negedge clock);
  allocate_enable = 0;
  allocate_tag    = 0;
endtask

// Evict
task automatic evict(input [INDEX_WIDTH-1:0] index_to_evict);
  evict_enable = 1;
  evict_index  = index_to_evict;
  @(posedge clock);
  model_valid [evict_index] = 0;
  model_tags  [evict_index] = 'x;
  @(negedge clock);
  evict_enable = 0;
endtask

// Update the expected search results based on the model
task automatic search_for_tag(input [WIDTH-1:0] tag_to_search);
  expected_hit   = 0;
  expected_index = 'x;
`ifndef SIMULATOR_NO_BREAK
  for (int index = 0; index < DEPTH; index++) begin
`else
  for (int index = DEPTH-1; index >= 0; index--) begin
`endif
    if (model_valid[index] && model_tags[index] == tag_to_search) begin
      expected_hit   = 1;
      expected_index = index;
`ifndef SIMULATOR_NO_BREAK
      break;
`endif
    end
  end
endtask

// Search all tags and compare with the model
task automatic search_all;
  for (int tag = 0; tag < WIDTH_POW2; tag++) begin
    // Search
    @(negedge clock);
    search_tag = tag;
    search_for_tag(search_tag);
    @(posedge clock);
    // Check DUT
    if (expected_hit) begin
      assert (search_hit) else $error("[%0tns] Search miss for allocated tag '0x%0h'.", $time, search_tag);
      assert (search_index == expected_index) else $error("[%0tns] Index of searched tag is incorrect (expected '0x%0d', got '0x%0d').", $time, expected_index, search_index);
    end else begin
      assert (!search_hit) else $error("[%0tns] Search hit on unallocated tag '0x%0h' at index '%0d'.", $time, search_tag, search_index);
    end
  end
endtask

// Task to check the status flags
task automatic check_flags;
  input logic  expect_full;
  input logic  expect_empty;
  input string context_string;
  if ( expect_full ) assert ( full ) else $error("[%0tns] Full flag is not asserted%s.",  $time, context_string);
  if ( expect_empty) assert ( empty) else $error("[%0tns] Empty flag is not asserted%s.", $time, context_string);
  if (!expect_full ) assert (!full ) else $error("[%0tns] Full flag is asserted%s.",      $time, context_string);
  if (!expect_empty) assert (!empty) else $error("[%0tns] Empty flag is asserted%s.",     $time, context_string);
endtask

// Device under test
tag_directory #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) tag_directory_dut (
  .clock           ( clock           ),
  .resetn          ( resetn          ),
  .full            ( full            ),
  .empty           ( empty           ),
  .allocate_enable ( allocate_enable ),
  .allocate_tag    ( allocate_tag    ),
  .allocate_index  ( allocate_index  ),
  .search_tag      ( search_tag      ),
  .search_index    ( search_index    ),
  .search_hit      ( search_hit      ),
  .evict_enable    ( evict_enable    ),
  .evict_index     ( evict_index     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("tag_directory.testbench.vcd");
  $dumpvars(0,tag_directory__testbench);

  // Initialization
  allocate_enable = 0;
  allocate_tag    = 0;
  search_tag      = 0;
  evict_enable    = 0;
  evict_index     = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Allocate once
  $display("CHECK 1 : Allocate once.");
  // Initial state
  check_flags(false, true, " after reset");
  // Allocate
  @(negedge clock);
  allocate();
  // Final state
  check_flags(false, false, " after allocating once. The directory should have one entry.");
  // Search all
  search_all();

  repeat(10) @(posedge clock);

  // Check 2 : Evict once
  $display("CHECK 2 : Evict once.");
  // Evict
  @(negedge clock);
  evict(last_index);
  // Final state
  check_flags(false, true, " after eviction. The directory should be empty.");
  // Search all
  search_all();

  repeat(10) @(posedge clock);

  // Check 3 : Allocate all
  $display("CHECK 3 : Allocate all.");
  repeat (DEPTH) begin
    // Allocate
    @(negedge clock);
    allocate();
  end
  // Final state
  check_flags(true, false, " after allocating all. The directory should be full.");
  // Search all
  search_all();

  repeat(10) @(posedge clock);

  // Check 4 : Evict all
  $display("CHECK 4 : Evict all.");
  for (int index = 0; index < DEPTH; index++) begin
    // Evict
    evict(index);
  end
  // Final state
  check_flags(false, true, " after evicting all. The directory should be empty.");
  // Search all
  search_all();

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
