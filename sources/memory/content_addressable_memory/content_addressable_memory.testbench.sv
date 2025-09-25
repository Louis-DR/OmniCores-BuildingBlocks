// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        content_addressable_memory.testbench.sv                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the content-addressable memory.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module content_addressable_memory__testbench ();

// Device parameters
localparam int TAG_WIDTH  = 8;
localparam int DATA_WIDTH = 8;
localparam int DEPTH      = 16;

// Test parameters
localparam real CLOCK_PERIOD    = 10;
localparam int  TAG_WIDTH_POW2  = 2**TAG_WIDTH;
localparam int  DATA_WIDTH_POW2 = 2**DATA_WIDTH;
localparam int  INDEX_WIDTH     = $clog2(DEPTH);

// Check parameters
localparam int  SIMULTANEOUS_CHECK_DURATION     = 100;
localparam int  SIMULTANEOUS_CHECK_TIMEOUT      = 1000;
localparam int  RANDOM_CHECK_DURATION           = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY  = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY   = 0.5;
localparam real RANDOM_CHECK_DELETE_PROBABILITY = 0.3;
localparam int  RANDOM_CHECK_TIMEOUT            = 1000;

// Device ports
logic                  clock;
logic                  resetn;
logic                  full;
logic                  empty;
logic                  write_enable;
logic  [TAG_WIDTH-1:0] write_tag;
logic [DATA_WIDTH-1:0] write_data;
logic                  read_enable;
logic  [TAG_WIDTH-1:0] read_tag;
logic [DATA_WIDTH-1:0] read_data;
logic                  read_hit;
logic                  delete_enable;
logic  [TAG_WIDTH-1:0] delete_tag;
logic                  delete_hit;

// Test variables
int                    check;
logic [DATA_WIDTH-1:0] model_memory [logic [TAG_WIDTH-1:0]];
logic  [TAG_WIDTH-1:0] last_write_tag;
logic  [TAG_WIDTH-1:0] read_random_tag;
logic  [TAG_WIDTH-1:0] delete_random_tag;
int                    number_entries;
int                    transfer_count;
int                    timeout_countdown;

// Write
task automatic write;
  input logic  [TAG_WIDTH-1:0] tag_to_write;
  input logic [DATA_WIDTH-1:0] data_to_write;
  write_enable = 1;
  write_tag    = tag_to_write;
  write_data   = data_to_write;
  @(posedge clock);
  number_entries++;
  model_memory[write_tag] = write_data;
  last_write_tag = write_tag;
  @(negedge clock);
  write_enable = 0;
  write_tag    = 0;
  write_data   = 0;
endtask

// Write random tag and data
task automatic write_random;
  write($urandom_range(TAG_WIDTH_POW2), $urandom_range(DATA_WIDTH_POW2));
endtask

// Read
task automatic read;
  input logic [TAG_WIDTH-1:0] tag_to_read;
  read_enable = 1;
  read_tag    = tag_to_read;
  @(posedge clock);
  if (delete_enable) begin
    assert (!read_hit) else $error("[%0tns] Read search hit while reading and deleting at the same time.", $time);
  end else begin
    assert (!delete_hit) else $error("[%0tns] Delete hit during reading without deleting.", $time);
    if (model_memory.exists(tag_to_read)) begin
      assert (read_hit) else $error("[%0tns] Read search incorrect miss for tag '0x%0h'.", $time, tag_to_read);
      assert (read_data === model_memory[tag_to_read])
        else $error("[%0tns] Read data '0x%0h' doesn't match expected value '0x%0h' from the model for tag '0x%0h'.", $time, read_data, model_memory[tag_to_read], tag_to_read);
    end else begin
      assert (!read_hit) else $error("[%0tns] Read search incorrect hit for tag '0x%0h'.", $time, tag_to_read);
    end
  end
  @(negedge clock);
  read_enable = 0;
endtask

// Read all tags and compare with the model
task automatic read_all;
  for (int tag = 0; tag < TAG_WIDTH_POW2; tag++) begin
    // Read
    @(negedge clock);
    read(tag);
  end
endtask

// Delete all tags
task automatic delete_all;
  for (int tag = 0; tag < TAG_WIDTH_POW2; tag++) begin
    // Delete
    @(negedge clock);
    delete(tag);
  end
endtask

// Delete
task automatic delete;
  input logic [TAG_WIDTH-1:0] tag_to_delete;
  delete_enable = 1;
  delete_tag    = tag_to_delete;
  @(posedge clock);
  assert (!read_hit) else $error("[%0tns] Read hit during deletion.", $time);
  if (model_memory.exists(tag_to_delete)) begin
    assert (delete_hit) else $error("[%0tns] Delete search incorrect miss for tag '0x%0h'.", $time, tag_to_delete);
    number_entries--;
    model_memory.delete(tag_to_delete);
  end else begin
    assert (!delete_hit) else $error("[%0tns] Delete search incorrect hit for tag '0x%0h'.", $time, tag_to_delete);
  end
  @(negedge clock);
  delete_enable = 0;
endtask

// Check the status flags
task automatic check_flags;
  input string context_string;
  logic expect_full  = model_memory.size() == DEPTH;
  logic expect_empty = model_memory.size() == 0;
  if ( expect_full ) assert ( full ) else $error("[%0tns] Full flag is not asserted%s.",  $time, context_string);
  if ( expect_empty) assert ( empty) else $error("[%0tns] Empty flag is not asserted%s.", $time, context_string);
  if (!expect_full ) assert (!full ) else $error("[%0tns] Full flag is asserted%s.",      $time, context_string);
  if (!expect_empty) assert (!empty) else $error("[%0tns] Empty flag is asserted%s.",     $time, context_string);
endtask

// Device under test
content_addressable_memory #(
  .TAG_WIDTH  ( TAG_WIDTH  ),
  .DATA_WIDTH ( DATA_WIDTH ),
  .DEPTH      ( DEPTH      )
) content_addressable_memory_dut (
  .clock         ( clock         ),
  .resetn        ( resetn        ),
  .full          ( full          ),
  .empty         ( empty         ),
  .write_enable  ( write_enable  ),
  .write_tag     ( write_tag     ),
  .write_data    ( write_data    ),
  .read_enable   ( read_enable   ),
  .read_tag      ( read_tag      ),
  .read_data     ( read_data     ),
  .read_hit      ( read_hit      ),
  .delete_enable ( delete_enable ),
  .delete_tag    ( delete_tag    ),
  .delete_hit    ( delete_hit    )
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
  $dumpfile("content_addressable_memory.testbench.vcd");
  $dumpvars(0,content_addressable_memory__testbench);

  // Initialization
  write_enable  = 0;
  write_tag     = 0;
  read_enable   = 0;
  read_tag      = 0;
  delete_enable = 0;
  delete_tag    = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Write once
  $display("CHECK 1 : Write once."); check = 1;
  // Initial state
  check_flags(" after reset");
  // Write
  @(negedge clock);
  write_random();
  // Final state
  check_flags(" after allocating once. The memory should have one entry.");
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // Check 2 : Delete once
  $display("CHECK 2 : Delete once."); check = 2;
  // Delete
  @(negedge clock);
  delete(last_write_tag);
  // Final state
  check_flags(" after deletion. The memory should be empty.");
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // Check 3 : Write all
  $display("CHECK 3 : Write all."); check = 3;
  repeat (DEPTH) begin
    // Write
    @(negedge clock);
    write_random();
  end
  // Final state
  check_flags(" after writing all. The memory should be full.");
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // Check 4 : Delete all
  $display("CHECK 4 : Delete all."); check = 4;
  // Delete all
  delete_all();
  // Final state
  check_flags(" after deleting all. The directory should be empty.");
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // Check 5 : Simultaneous operations
  $display("CHECK 5 : Simultaneous operations."); check = 5;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = SIMULTANEOUS_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      forever begin
        @(negedge clock);
        if (!full && transfer_count < SIMULTANEOUS_CHECK_DURATION) begin
          write_random();
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        @(negedge clock);
        if (!empty) begin
          `RANDOM_KEY(model_memory, read_random_tag)
          read(read_random_tag);
        end
      end
    end
    // Deleting
    begin
      forever begin
        @(negedge clock);
        if (!empty) begin
          `RANDOM_KEY(model_memory, delete_random_tag)
          delete(delete_random_tag);
        end
      end
    end
    // Check flags
    begin
      forever begin
        @(posedge clock);
        check_flags("");
      end
    end
    // Correct model for overwrite and delete
    begin
      forever begin
        @(posedge clock);
        if (write_enable && delete_enable && write_tag === delete_tag) begin
          model_memory[write_tag] = write_data;
        end
      end
    end
    // Stop condition
    begin
      // Transfer count
      while (transfer_count < SIMULTANEOUS_CHECK_DURATION) begin
        @(negedge clock);
      end
      // Evict until empty
      while (!empty) begin
        @(negedge clock);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // Check 6 : Random stimulus
  $display("CHECK 6 : Random stimulus."); check = 6;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      forever begin
        @(negedge clock);
        if (!full && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
          write_random();
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        @(negedge clock);
        if (!empty && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          `RANDOM_KEY(model_memory, read_random_tag)
          read(read_random_tag);
        end
      end
    end
    // Deleting
    begin
      forever begin
        @(negedge clock);
        if (!empty && random_boolean(RANDOM_CHECK_DELETE_PROBABILITY)) begin
          `RANDOM_KEY(model_memory, delete_random_tag)
          delete(delete_random_tag);
        end
      end
    end
    // Check flags
    begin
      forever begin
        @(posedge clock);
        check_flags("");
      end
    end
    // Stop condition
    begin
      // Transfer count
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
      end
      // Evict until empty
      while (!empty) begin
        @(negedge clock);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  // Read all
  read_all();

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
