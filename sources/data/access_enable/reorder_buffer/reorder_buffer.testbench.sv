// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        reorder_buffer.testbench.sv                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the out-of-order buffer.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module reorder_buffer__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;
localparam int  DEPTH        = 8;
localparam int  INDEX_WIDTH  = $clog2(DEPTH);

// Check parameters
localparam int  SUCCESSIVE_CHECK_DURATION        = 100;
localparam int  CONCURRENT_CHECK_DURATION        = 100;
localparam int  RANDOM_CHECK_DURATION            = 100;
localparam real RANDOM_CHECK_RESERVE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_WRITE_PROBABILITY   = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY    = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT             = 1000;

// Device ports
logic                   clock;
logic                   resetn;
logic                   reserve_full;
logic                   reserve_empty;
logic                   data_full;
logic                   data_empty;
logic                   reserve_enable;
logic [INDEX_WIDTH-1:0] reserve_index;
logic                   write_enable;
logic [INDEX_WIDTH-1:0] write_index;
logic       [WIDTH-1:0] write_data;
logic                   write_error;
logic                   read_enable;
logic       [WIDTH-1:0] read_data;

// Test variables
logic [INDEX_WIDTH-1:0] read_index;
logic [INDEX_WIDTH-1:0] reserved_idx;
logic       [WIDTH-1:0] memory_model [DEPTH-1:0];
logic       [DEPTH-1:0] reserved_model;
logic       [DEPTH-1:0] valid_model;
int                     reserved_indices_for_write [$];
int                     reserved_indices_for_read  [$];
int                     timeout_countdown;
int                     transfer_count;
`ifdef SIMULATOR_NO_QUEUE_SHUFFLE
int                     random_queue_index;
`endif

// Device under test
reorder_buffer #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) reorder_buffer_dut (
  .clock          ( clock          ),
  .resetn         ( resetn         ),
  .reserve_full   ( reserve_full   ),
  .reserve_empty  ( reserve_empty  ),
  .data_full      ( data_full      ),
  .data_empty     ( data_empty     ),
  .reserve_enable ( reserve_enable ),
  .reserve_index  ( reserve_index  ),
  .write_enable   ( write_enable   ),
  .write_data     ( write_data     ),
  .write_index    ( write_index    ),
  .write_error    ( write_error    ),
  .read_enable    ( read_enable    ),
  .read_data      ( read_data      )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Task to reserve a slot
task automatic reserve();
  reserve_enable = 1;
  @(posedge clock);
  assert (reserve_index < DEPTH) else $error("[%t] Reserve index '%0d' out of bounds.", $realtime, reserve_index);
  assert (!valid_model[reserve_index]) else $error("[%t] Reserve index '%0d' was already valid in model.", $realtime, reserve_index);
  reserved_indices_for_write.push_back(reserve_index);
  reserved_indices_for_read.push_back(reserve_index);
  reserved_model [reserve_index] = 1;
  memory_model   [reserve_index] = 'x;
  @(negedge clock);
  reserve_enable = 0;
endtask

// Task to write to a reserved index
task automatic write(input logic [INDEX_WIDTH-1:0] index);
  write_enable = 1;
  write_index  = index;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  valid_model  [write_index] = 1;
  memory_model [write_index] = write_data;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
endtask

// Task to read
task automatic read();
  read_enable = 1;
  read_index  = reserved_indices_for_read.pop_front();
  @(posedge clock);
  assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' differs from model '%0h'.", $realtime, read_data, memory_model[read_index]);
  reserved_model [read_index] = 0;
  valid_model    [read_index] = 0;
  @(negedge clock);
  read_enable = 0;
endtask

task automatic clear_verification_variables();
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};
endtask

// Task to check the status flags
task automatic check_flags;
  input logic  expect_reserve_full;
  input logic  expect_reserve_empty;
  input logic  expect_data_full;
  input logic  expect_data_empty;
  input string context_string;
  if (expect_reserve_full)  assert (reserve_full)  else $error("[%t] Reserve full flag is not asserted%s.",  $time, context_string);
  if (expect_reserve_empty) assert (reserve_empty) else $error("[%t] Reserve empty flag is not asserted%s.", $realtime, context_string);
  if (expect_data_full)     assert (data_full)     else $error("[%t] Data full flag is not asserted%s.",     $time, context_string);
  if (expect_data_empty)    assert (data_empty)    else $error("[%t] Data empty flag is not asserted%s.",    $time, context_string);
  if (!expect_reserve_full)  assert (!reserve_full)  else $error("[%t] Reserve full flag is asserted%s.",      $time, context_string);
  if (!expect_reserve_empty) assert (!reserve_empty) else $error("[%t] Reserve empty flag is asserted%s.",     $time, context_string);
  if (!expect_data_full)     assert (!data_full)     else $error("[%t] Data full flag is asserted%s.",         $time, context_string);
  if (!expect_data_empty)    assert (!data_empty)    else $error("[%t] Data empty flag is asserted%s.",        $time, context_string);
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("reorder_buffer.testbench.vcd");
  $dumpvars(0,reorder_buffer__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  clear_verification_variables();

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reserve once
  $display("CHECK 1 : Reserve once.");
  // Initial state
  check_flags(false, true, false, true, " after reset");
  // Reserve operation
  reserve();
  // Final state
  check_flags(false, false, false, true, " after one reservation");

  repeat(10) @(posedge clock);

  // Check 2 : Write once
  $display("CHECK 2 : Write once.");
  // Write operation
  @(negedge clock);
  write(reserved_indices_for_write.pop_front());
  // Final state
  check_flags(false, false, false, false, " after one write");

  repeat(10) @(posedge clock);

  // Check 3 : Read once
  $display("CHECK 3 : Read once.");
  // Read operation
  @(negedge clock);
  read();
  // Final state
  check_flags(false, true, false, true, " after reading the only entry");

  repeat(10) @(posedge clock);

  // Check 4 : Reserve all
  $display("CHECK 4 : Reserve all.");
  // Reserve all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    reserve();
  end
  // Final state
  check_flags(true, false, false, true, " after reserving all slots");

  repeat(10) @(posedge clock);

  // Check 5 : Write in-order
  $display("CHECK 5 : Write in-order.");
  // Write all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    write(reserved_indices_for_write.pop_front());
  end
  // Final state
  check_flags(true, false, true, false, " after writing all reserved slots in-order");

  repeat(10) @(posedge clock);

  // Check 6 : Read in-order
  $display("CHECK 6 : Read in-order.");
  // Read all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    read();
  end
  // Final state
  check_flags(false, true, false, true, " after reading the whole buffer");

  repeat(10) @(posedge clock);

  // Check 7 : Reserve all again
  $display("CHECK 7 : Reserve all again.");
  // Reserve all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    reserve();
  end
  // Final state
  check_flags(true, false, false, true, " after reserving all slots again");

  repeat(10) @(posedge clock);

  // Check 8 : Write reverse-order
  $display("CHECK 8 : Write reverse-order.");
  // Write all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    write(reserved_indices_for_write.pop_back());
  end
  // Final state
  check_flags(true, false, true, false, " after writing all reserved slots in reverse order");

  repeat(10) @(posedge clock);

  // Check 9 : Read in-order again
  $display("CHECK 9 : Read in-order again.");
  // Read all
  @(negedge clock);
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    read();
  end
  // Final state
  check_flags(false, true, false, true, " after reading the whole buffer again");

  repeat(10) @(posedge clock);

  // Check 10 : Successive operations
  $display("CHECK 10 : Successive operations.");
  @(negedge clock);
  repeat (SUCCESSIVE_CHECK_DURATION) begin
    // Reserve operation
    reserve();
    // Write operation
    write(reserved_indices_for_write.pop_front());
    // Read operation
    read();
  end
  // Final state
  check_flags(false, true, false, true, " after successive operations check");

  repeat(10) @(posedge clock);

  // Check 11 : Random stimulus
  $display("CHECK 11 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Reserving
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (!reserve_full && random_boolean(RANDOM_CHECK_RESERVE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
          reserve();
          transfer_count++;
        end else begin
          reserve_enable = 0;
        end
      end
    end
    // Writing
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (|(reserved_model & ~valid_model) && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY)) begin
`ifndef SIMULATOR_NO_QUEUE_SHUFFLE
          reserved_indices_for_write.shuffle();
          write(reserved_indices_for_write.pop_front());
`else
          random_queue_index = $urandom_range(reserved_indices_for_write.size()-1);
          write(reserved_indices_for_write[random_queue_index]);
          reserved_indices_for_write.delete(random_queue_index);
`endif
        end else begin
          write_enable = 0;
          write_index  = 0;
          write_data   = 0;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        // Check if the next in-order entry is valid before reading
        if (reserved_indices_for_read.size() > 0 && valid_model[reserved_indices_for_read[0]] && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          read();
        end else begin
          read_enable = 0;
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
        check_flags(&reserved_model, ~|reserved_model, &valid_model, ~|valid_model, " during random check");
      end
    end
    // Stop condition
    begin
      // Transfer count
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
      end
      // Read until all reserved entries are read
      while (reserved_indices_for_read.size() > 0) begin
        @(negedge clock);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%t] Timeout.", $realtime);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // CHECK 12: Write error
  $display("CHECK 12 : Write error on unreserved index.");
  // Reset
  resetn = 0;
  reserve_enable = 0;
  write_enable   = 0;
  write_data     = 0;
  write_index    = 0;
  read_enable    = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = 0;
  end
  reserved_model              = 0;
  valid_model                 = 0;
  reserved_indices_for_write  = {};
  reserved_indices_for_read   = {};
  read_index                  = 0;
  repeat(5) @(negedge clock);
  resetn = 1;
  repeat(5) @(negedge clock);
  // Attempt to write to unreserved index (should error)
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  write_index  = 0;
  @(posedge clock);
  assert (write_error) else $error("[%t] Write error not asserted for unreserved index write.", $realtime);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  write_index  = 0;
  // Reserve and write normally
  reserve();
  write(0);
  // Attempt to write to already-written index 0 (should error)
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  write_index  = 0;
  @(posedge clock);
  assert (write_error) else $error("[%t] Write error not asserted for already-written index write.", $realtime);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  write_index  = 0;

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
