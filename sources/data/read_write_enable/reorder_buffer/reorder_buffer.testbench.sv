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
localparam int  SUCCESSIVE_CHECK_DURATION      = 100;
localparam int  CONCURRENT_CHECK_DURATION      = 100;
localparam int  RANDOM_CHECK_DURATION          = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam real RANDOM_CHECK_CLEAR_PROBABILITY = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic                   clock;
logic                   resetn;
logic                   reserve_full;
logic                   reserve_empty;
logic                   data_full;
logic                   data_empty;
logic                   reserve_enable;
logic [INDEX_WIDTH-1:0] reserve_index;
logic                   reserve_error;
logic                   write_enable;
logic [INDEX_WIDTH-1:0] write_index;
logic       [WIDTH-1:0] write_data;
logic                   write_error;
logic                   read_enable;
logic                   read_valid;
logic       [WIDTH-1:0] read_data;
logic                   read_error;

// Test variables
logic [INDEX_WIDTH-1:0] read_index;
logic       [WIDTH-1:0] memory_model   [DEPTH-1:0];
logic                   reserved_model [DEPTH-1:0];
logic                   valid_model    [DEPTH-1:0];
int                     reserved_indices_for_write [$];
int                     reserved_indices_for_read  [$];
int                     reserved_entries_count;
int                     valid_entries_count;
int                     timeout_countdown;
int                     transfer_count;

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
  .reserve_error  ( reserve_error  ),
  .write_enable   ( write_enable   ),
  .write_data     ( write_data     ),
  .write_index    ( write_index    ),
  .write_error    ( write_error    ),
  .read_enable    ( read_enable    ),
  .read_valid     ( read_valid     ),
  .read_data      ( read_data      ),
  .read_error     ( read_error     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Task to check the status flags
task automatic check_flags;
  input logic  expect_reserve_full;
  input logic  expect_reserve_empty;
  input logic  expect_data_full;
  input logic  expect_data_empty;
  input string context_string;
  if ( expect_reserve_full  && !reserve_full  ) $error("[%0tns] Reserve full flag is not asserted%s.",  $time, context_string);
  if ( expect_reserve_empty && !reserve_empty ) $error("[%0tns] Reserve empty flag is not asserted%s.", $time, context_string);
  if ( expect_data_full     && !data_full     ) $error("[%0tns] Data full flag is not asserted%s.",     $time, context_string);
  if ( expect_data_empty    && !data_empty    ) $error("[%0tns] Data empty flag is not asserted%s.",    $time, context_string);
  if (!expect_reserve_full  &&  reserve_full  ) $error("[%0tns] Reserve full flag is asserted%s.",      $time, context_string);
  if (!expect_reserve_empty &&  reserve_empty ) $error("[%0tns] Reserve empty flag is asserted%s.",     $time, context_string);
  if (!expect_data_full     &&  data_full     ) $error("[%0tns] Data full flag is asserted%s.",         $time, context_string);
  if (!expect_data_empty    &&  data_empty    ) $error("[%0tns] Data empty flag is asserted%s.",        $time, context_string);
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("reorder_buffer.testbench.vcd");
  $dumpvars(0,reorder_buffer__testbench);

  // Initialization
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

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
  @(negedge clock);
  reserve_enable = 1;
  @(posedge clock);
  if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
  if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
  reserved_entries_count++;
  reserved_indices_for_write.push_back(reserve_index);
  reserved_indices_for_read.push_back(reserve_index);
  reserved_model [reserve_index] = 1;
  memory_model   [reserve_index] = 'x;
  @(negedge clock);
  reserve_enable = 0;
  // Final state
  check_flags(false, false, false, true, " after one reservation");

  repeat(10) @(posedge clock);

  // Check 2 : Write once
  $display("CHECK 2 : Write once.");
  // Write operation
  @(negedge clock);
  write_enable = 1;
  write_index  = reserved_indices_for_write.pop_front();
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if (write_error) $error("[%0tns] Write error when writing to reserved index '%0d'.", $time, write_index);
  valid_entries_count++;
  valid_model  [write_index] = 1;
  memory_model [write_index] = write_data;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Final state
  check_flags(false, false, false, false, " after one write");

  repeat(10) @(posedge clock);

  // Check 3 : Read once
  $display("CHECK 3 : Read once.");
  // Read operation
  @(negedge clock);
  read_enable = 1;
  @(posedge clock);
  read_index = reserved_indices_for_read.pop_front();
  if (!read_valid) $error("[%0tns] Read valid is deasserted after writing.", $time);
  if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index 0 differs from model '%0h'.", $time, read_data, memory_model[0]);
  reserved_model [read_index] = 0;
  valid_model    [read_index] = 0;
  reserved_entries_count--;
  valid_entries_count--;
  @(negedge clock);
  read_enable = 0;
  // Final state
  check_flags(false, true, false, true, " after reading the only entry");

  repeat(10) @(posedge clock);

  // Check 4 : Reserve all
  $display("CHECK 4 : Reserve all.");
  // Reserve all
  @(negedge clock);
  reserve_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
    if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
    reserved_entries_count++;
    reserved_indices_for_write.push_back(reserve_index);
    reserved_indices_for_read.push_back(reserve_index);
    reserved_model [reserve_index] = 1;
    memory_model   [reserve_index] = 'x;
  end
  @(negedge clock);
  reserve_enable = 0;
  // Final state
  check_flags(true, false, false, true, " after reserving all slots");

  repeat(10) @(posedge clock);

  // Check 5 : Write in-order
  $display("CHECK 5 : Write in-order.");
  // Write all
  @(negedge clock);
  write_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    write_index = reserved_indices_for_write.pop_front();
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (write_error) $error("[%0tns] Write error when writing to reserved index '%0d'.", $time, write_index);
    valid_entries_count++;
    valid_model  [write_index] = 1;
    memory_model [write_index] = write_data;
  end
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Final state
  check_flags(true, false, true, false, " after writing all reserved slots in-order");

  repeat(10) @(posedge clock);

  // Check 6 : Read in-order
  $display("CHECK 6 : Read in-order.");
  // Read all
  @(negedge clock);
  read_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    read_index = reserved_indices_for_read.pop_front();
    if (!read_valid) $error("[%0tns] Read valid is deasserted after writing.", $time);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index 0 differs from model '%0h'.", $time, read_data, memory_model[0]);
    reserved_model [read_index] = 0;
    valid_model    [read_index] = 0;
    reserved_entries_count--;
    valid_entries_count--;
  end
  @(negedge clock);
  read_enable = 0;
  // Final state
  check_flags(false, true, false, true, " after reading the whole buffer");

  repeat(10) @(posedge clock);

  // Check 7 : Reserve all again
  $display("CHECK 7 : Reserve all again.");
  // Reserve all
  @(negedge clock);
  reserve_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
    if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
    reserved_entries_count++;
    reserved_indices_for_write.push_back(reserve_index);
    reserved_indices_for_read.push_back(reserve_index);
    reserved_model [reserve_index] = 1;
    memory_model   [reserve_index] = 'x;
  end
  @(negedge clock);
  reserve_enable = 0;
  // Final state
  check_flags(true, false, false, true, " after reserving all slots again");

  repeat(10) @(posedge clock);

  // Check 8 : Write reverse-order
  $display("CHECK 8 : Write reverse-order.");
  // Write all
  @(negedge clock);
  write_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    write_index = reserved_indices_for_write.pop_back();
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (write_error) $error("[%0tns] Write error when writing to reserved index '%0d'.", $time, write_index);
    valid_entries_count++;
    valid_model  [write_index] = 1;
    memory_model [write_index] = write_data;
  end
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Final state
  check_flags(true, false, true, false, " after writing all reserved slots in reverse order");

  repeat(10) @(posedge clock);

  // Check 9 : Read in-order again
  $display("CHECK 9 : Read in-order again.");
  // Read all
  @(negedge clock);
  read_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    read_index = reserved_indices_for_read.pop_front();
    if (!read_valid) $error("[%0tns] Read valid is deasserted after writing.", $time);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index 0 differs from model '%0h'.", $time, read_data, memory_model[0]);
    reserved_model [read_index] = 0;
    valid_model    [read_index] = 0;
    reserved_entries_count--;
    valid_entries_count--;
  end
  @(negedge clock);
  read_enable = 0;
  // Final state
  check_flags(false, true, false, true, " after reading the whole buffer again");

  repeat(10) @(posedge clock);

  // Check 10 : Write overwrite
  $display("CHECK 10 : Write overwrite.");
  // Reserve operation
  @(negedge clock);
  reserve_enable = 1;
  @(posedge clock);
  reserved_entries_count++;
  reserved_indices_for_write.push_back(reserve_index);
  reserved_indices_for_read.push_back(reserve_index);
  reserved_model [reserve_index] = 1;
  memory_model   [reserve_index] = 'x;
  @(negedge clock);
  reserve_enable = 0;
  // Write operation
  @(negedge clock);
  write_enable = 1;
  write_index  = reserved_indices_for_write[0];
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  valid_entries_count++;
  valid_model  [write_index] = 1;
  memory_model [write_index] = write_data;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Write operation
  @(negedge clock);
  write_enable = 1;
  write_index  = reserved_indices_for_write.pop_front();
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if (!write_error) $error("[%0tns] No write error when overwriting at index '%0d'.", $time, write_index);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after overwriting");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

  repeat(10) @(posedge clock);

  // Check 11 : Write at unreserved
  $display("CHECK 11 : Write at unreserved.");
  // Write operation
  @(negedge clock);
  write_enable = 1;
  write_index  = 0;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if (!write_error) $error("[%0tns] No write error when writing at unreserved index '%0d'.", $time, write_index);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after writing at unreserved");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

  repeat(10) @(posedge clock);

  // Check 12 : Read at unreserved
  $display("CHECK 12 : Read at unreserved.");
  // Read operation
  @(negedge clock);
  read_enable = 1;
  @(posedge clock);
  if (!read_error) $error("[%0tns] No read error when reading at unreserved buffer.", $time);
  @(negedge clock);
  read_enable = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after reading at unreserved");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

  repeat(10) @(posedge clock);

  // Check 13 : Read before write
  $display("CHECK 13 : Read before write.");
  // Reserve operation
  @(negedge clock);
  reserve_enable = 1;
  @(posedge clock);
  reserved_entries_count++;
  reserved_indices_for_write.push_back(reserve_index);
  reserved_indices_for_read.push_back(reserve_index);
  reserved_model [reserve_index] = 1;
  memory_model   [reserve_index] = 'x;
  @(negedge clock);
  reserve_enable = 0;
  // Read operation
  @(negedge clock);
  read_enable = 1;
  @(posedge clock);
  if (!read_error) $error("[%0tns] No read error when reading before write.", $time);
  @(negedge clock);
  read_enable = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after reading before write");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

  repeat(10) @(posedge clock);

  // Check 14 : Reserve when fully reserved
  $display("CHECK 14 : Reserve when fully reserved.");
  // Reserve all
  @(negedge clock);
  reserve_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
    if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
    reserved_entries_count++;
    reserved_indices_for_write.push_back(reserve_index);
    reserved_indices_for_read.push_back(reserve_index);
    reserved_model [reserve_index] = 1;
    memory_model   [reserve_index] = 'x;
  end
  @(negedge clock);
  reserve_enable = 0;
  // Reserve operation
  @(negedge clock);
  reserve_enable = 1;
  @(posedge clock);
  if (!reserve_error) $error("[%0tns] No reserve error when reserving when buffer fully reserved.", $time);
  @(negedge clock);
  reserve_enable = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after reserving when fullly reserved");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end
  reserved_indices_for_write = {};
  reserved_indices_for_read  = {};

  repeat(10) @(posedge clock);

  // Check 15 : Reserve when fully written
  $display("CHECK 15 : Reserve when fully written.");
  // Reserve all
  @(negedge clock);
  reserve_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    @(posedge clock);
    if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
    if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
    reserved_entries_count++;
    reserved_indices_for_write.push_back(reserve_index);
    reserved_indices_for_read.push_back(reserve_index);
    reserved_model [reserve_index] = 1;
    memory_model   [reserve_index] = 'x;
  end
  @(negedge clock);
  reserve_enable = 0;
  // Write all
  @(negedge clock);
  write_enable = 1;
  for (int reserve_count = 0; reserve_count < DEPTH; reserve_count++) begin
    write_index = reserved_indices_for_write.pop_front();
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (write_error) $error("[%0tns] Write error when writing to reserved index '%0d'.", $time, write_index);
    valid_entries_count++;
    valid_model  [write_index] = 1;
    memory_model [write_index] = write_data;
    @(negedge clock);
  end
  write_enable = 0;
  write_data   = 0;
  // Reserve operation
  @(negedge clock);
  reserve_enable = 1;
  @(posedge clock);
  if (!reserve_error) $error("[%0tns] No reserve error when reserving when buffer fully written.", $time);
  @(negedge clock);
  reserve_enable = 0;
  // Reset from broken state
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);
  // Final state
  check_flags(false, true, false, true, " after resetting after reserving when fullly written");
  // Clear the test variables
  reserve_enable = 0;
  write_enable   = 0;
  write_index    = 0;
  write_data     = 0;
  read_enable    = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end

  repeat(10) @(posedge clock);

  // Check 16 : Successive operations
  $display("CHECK 16 : Successive operations.");
  repeat (SUCCESSIVE_CHECK_DURATION) begin
    // Reserve operation
    @(negedge clock);
    reserve_enable = 1;
    @(posedge clock);
    if (reserve_index >= DEPTH) $error("[%0tns] Reserve index '%0d' out of bounds.", $time, reserve_index);
    if (valid_model[reserve_index]) $error("[%0tns] Reserve index '%0d' was already valid in model.", $time, reserve_index);
    reserved_entries_count++;
    reserved_indices_for_write.push_back(reserve_index);
    reserved_indices_for_read.push_back(reserve_index);
    reserved_model [reserve_index] = 1;
    memory_model   [reserve_index] = 'x;
    @(negedge clock);
    reserve_enable = 0;
    // Write operation
    @(negedge clock);
    write_enable = 1;
    write_index  = reserved_indices_for_write.pop_front();
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (write_error) $error("[%0tns] Write error when writing to reserved index '%0d'.", $time, write_index);
    valid_entries_count++;
    valid_model  [write_index] = 1;
    memory_model [write_index] = write_data;
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    // Read operation
    @(negedge clock);
    read_enable = 1;
    @(posedge clock);
    read_index = reserved_indices_for_read.pop_front();
    if (!read_valid) $error("[%0tns] Read valid is deasserted after writing.", $time);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index 0 differs from model '%0h'.", $time, read_data, memory_model[0]);
    reserved_model [read_index] = 0;
    valid_model    [read_index] = 0;
    reserved_entries_count--;
    valid_entries_count--;
    @(negedge clock);
    read_enable = 0;
  end
  // Final state
  check_flags(false, true, false, true, " after successive operations check");

  repeat(10) @(posedge clock);

  // // Check 12 : Random stimulus
  // $display("CHECK 12 : Random stimulus.");
  // @(negedge clock);
  // transfer_count    = 0;
  // timeout_countdown = RANDOM_CHECK_TIMEOUT;
  // fork
  //   // Writing
  //   begin
  //     forever begin
  //       // Stimulus
  //       @(negedge clock);
  //       if (!full && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
  //         write_enable = 1;
  //         write_data   = $urandom_range(WIDTH_POW2);
  //       end else begin
  //         write_enable = 0;
  //         write_data   = 0;
  //       end
  //       // Check
  //       @(posedge clock);
  //       if (write_enable) begin
  //         if (write_index >= DEPTH) $error("[%0tns] Write index '%0d' out of bounds.", $time, write_index);
  //         if (valid_model[write_index]) $error("[%0tns] Write index '%0d' was already valid in model.", $time, write_index);
  //         memory_model[write_index] = write_data;
  //         valid_model[write_index]  = 1'b1;
  //         valid_entries_count++;
  //         transfer_count++;
  //       end
  //     end
  //   end
  //   // Reading
  //   begin
  //     forever begin
  //       // Stimulus
  //       @(negedge clock);
  //       if (!empty && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
  //         foreach (valid_model[index]) begin
  //           if (valid_model[index]) begin
  //             read_index = index;
  //             // break;
  //           end
  //         end
  //         read_enable = 1;
  //         if (random_boolean(RANDOM_CHECK_CLEAR_PROBABILITY)) begin
  //           read_clear = 1;
  //         end else begin
  //           read_clear = 0;
  //         end
  //       end else begin
  //         read_enable = 0;
  //         read_clear  = 0;
  //       end
  //       // Check
  //       @(posedge clock);
  //       if (read_enable) begin
  //         if (read_error) $error("[%0tns] Read error asserted for valid index '%0d'.", $time, read_index);
  //         if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h'.", $time, read_data, read_index, memory_model[read_index]);
  //         if (read_clear) begin
  //           memory_model[read_index] = 'x;
  //           valid_model[read_index]  = 1'b0;
  //           valid_entries_count--;
  //         end
  //       end
  //     end
  //   end
  //   // Status check
  //   begin
  //     forever begin
  //       @(negedge clock);
  //       if (valid_entries_count == 0) begin
  //         if (!empty) $error("[%0tns] Empty flag is deasserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //         if ( full ) $error("[%0tns] Full flag is asserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //       end else if (valid_entries_count == DEPTH) begin
  //         if ( empty) $error("[%0tns] Empty flag is asserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //         if (!full ) $error("[%0tns] Full flag is deasserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //       end else begin
  //         if ( empty) $error("[%0tns] Empty flag is asserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //         if ( full ) $error("[%0tns] Full flag is asserted. The buffer should be have %0d entries in it.", $time, valid_entries_count);
  //       end
  //     end
  //   end
  //   // Stop condition
  //   begin
  //     // Transfer count
  //     while (transfer_count < RANDOM_CHECK_DURATION) begin
  //       @(negedge clock);
  //     end
  //     // Read until empty
  //     while (!empty) begin
  //       @(negedge clock);
  //     end
  //   end
  //   // Timeout
  //   begin
  //     while (timeout_countdown > 0) begin
  //       @(negedge clock);
  //       timeout_countdown--;
  //     end
  //     $error("[%0tns] Timeout.", $time);
  //   end
  // join_any
  // disable fork;
  // // Final state
  // if (!empty) $error("[%0tns] Final state not empty (%0d entries).", $time, valid_entries_count);
  // if ( full ) $error("[%0tns] Final state is full.", $time);
  // if (valid_entries_count != 0) $error("[%0tns] Model count (%0d) is not 0.", $time, valid_entries_count);

  // repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
