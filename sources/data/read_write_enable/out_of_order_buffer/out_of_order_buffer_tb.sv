// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        out_of_order_buffer_tb.sv                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the out-of-order buffer.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module out_of_order_buffer_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 8;
localparam integer WIDTH_POW2   = 2**WIDTH;
localparam integer DEPTH        = 8;
localparam integer INDEX_WIDTH  = $clog2(DEPTH);

// Check parameters
localparam integer CONTINUOUS_CHECK_DURATION      = 100;
localparam integer RANDOM_CHECK_DURATION          = 100;
localparam real    RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real    RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam real    RANDOM_CHECK_CLEAR_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic                    clock;
logic                    resetn;
logic                    write_enable;
logic [WIDTH-1:0]        write_data;
logic [INDEX_WIDTH-1:0]  write_index;
logic                    full;
logic                    read_enable;
logic                    read_clear;
logic [INDEX_WIDTH-1:0]  read_index;
logic [WIDTH-1:0]        read_data;
logic                    read_error;
logic                    empty;

// Test variables
logic [WIDTH-1:0] memory_model [DEPTH-1:0];
logic             valid_model  [DEPTH-1:0];
integer           valid_entries_count;
integer           timeout_countdown;
logic [INDEX_WIDTH-1:0] last_written_index;
logic [INDEX_WIDTH-1:0] temp_index;
integer           operation_count;

// Device under test
out_of_order_buffer #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) out_of_order_buffer_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .empty        ( empty        ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .write_index  ( write_index  ),
  .full         ( full         ),
  .read_enable  ( read_enable  ),
  .read_clear   ( read_clear   ),
  .read_index   ( read_index   ),
  .read_data    ( read_data    ),
  .read_error   ( read_error   )
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
  $dumpfile("out_of_order_buffer_tb.vcd");
  $dumpvars(0,out_of_order_buffer_tb);

  // Initialization
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;
  read_clear   = 0;
  read_index   = 0;
  valid_entries_count = 0;
  for (integer index = 0; index < DEPTH; index++) begin
    memory_model[index] = '0;
    valid_model[index]  = 1'b0;
  end

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Write once
  $display("CHECK 1 : Write once.");
  // Initial state
  if (!empty) $error("[%0tns] Empty flag is deasserted after reset.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after reset.", $time);
  // Write operation
  @(negedge clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if (write_index >= DEPTH) $error("[%0tns] Write index '%0d' out of bounds.", $time, write_index);
  if (valid_model[write_index]) $error("[%0tns] Write index '%0d' was already valid in model.", $time, write_index);
  memory_model[write_index] = write_data;
  valid_model[write_index]  = 1'b1;
  valid_entries_count++;
  last_written_index = write_index;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Final state
  if (empty) $error("[%0tns] Empty flag is asserted after one write.", $time);
  if ( full) $error("[%0tns] Full flag is asserted after only one write.", $time);

  repeat(10) @(posedge clock);

  // Check 2 : Read once without clearing
  $display("CHECK 2 : Read once without clearing.");
  @(negedge clock);
  read_enable = 1;
  read_clear  = 0;
  read_index  = last_written_index;
  @(posedge clock);
  if (read_error) $error("[%0tns] Read error asserted for valid index '%0d'.", $time, read_index);
  if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h'.", $time, read_data, read_index, memory_model[read_index]);
  @(negedge clock);
  read_enable = 0;
  read_index  = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Read once and clear
  $display("CHECK 3 : Read once and clear.");
  @(negedge clock);
  read_enable = 1;
  read_clear  = 1;
  read_index  = last_written_index;
  @(posedge clock);
  if (read_error) $error("[%0tns] Read error asserted for valid index '%0d' during clear.", $time, read_index);
  if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h' during clear.", $time, read_data, read_index, memory_model[read_index]);
  memory_model[read_index] = 'x; // Invalidate model data
  valid_model[read_index]  = 1'b0;
  valid_entries_count--;
  @(negedge clock);
  read_enable = 0;
  read_clear  = 0;
  read_index  = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after clearing the only valid entry.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after clearing the only valid entry.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Read while empty
  $display("CHECK 4 : Read while empty.");
  // Try reading the cleared index again
  @(negedge clock);
  read_enable = 1;
  read_index  = last_written_index;
  @(posedge clock);
  if (!read_error) $error("[%0tns] Read error not asserted for cleared index %0d.", $time, read_index);
  @(negedge clock);
  read_enable = 0;
  read_index  = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Writing to full
  $display("CHECK 5 : Writing to full.");
  // Fill the memory
  for (integer write_count = valid_entries_count; write_count < DEPTH; write_count++) begin
    @(negedge clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (write_index >= DEPTH) $error("[%0tns] Write index '%0d' out of bounds during fill.", $time, write_index);
    if (valid_model[write_index]) $error("[%0tns] Write index '%0d' was already valid in model during fill.", $time, write_index);
    memory_model[write_index] = write_data;
    valid_model[write_index]  = 1'b1;
    valid_entries_count++;
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    if (!full && valid_entries_count == DEPTH) $error("[%0tns] Full flag not asserted when model is full (%0d/%0d).", $time, valid_entries_count, DEPTH);
    if ( full && valid_entries_count  < DEPTH) $error("[%0tns] Full flag asserted when model is not full (%0d/%0d).", $time, valid_entries_count, DEPTH);
  end
  // Final state
  if ( empty) $error("[%0tns] Empty flag is asserted after filling. Should be full.", $time);
  if (!full ) $error("[%0tns] Full flag is deasserted after filling. Should be full.", $time);
  if (valid_entries_count != DEPTH) $error("[%0tns] Model count '%0d' is not equal to DEPTH '%0d' after filling.", $time, valid_entries_count, DEPTH);

  repeat(10) @(posedge clock);

  // Check 6 : Writing when full
  $display("CHECK 6 : Writing when full.");
  // Attempt to write when full
  @(negedge clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if ( empty) $error("[%0tns] Empty flag is asserted after write attempt when full", $time);
  if (!full ) $error("[%0tns] Full flag deasserted after write attempt when full.", $time);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;

  repeat(10) @(posedge clock);

  // Check 7 : Read all without clearing
  $display("CHECK 7 : Read all without clearing.");
  read_clear = 0;
  for (integer read_count = 0; read_count < DEPTH; read_count++) begin
    @(negedge clock);
    read_enable = 1;
    read_index  = read_count;
    @(posedge clock);
    if (read_error) $error("[%0tns] Read error asserted for valid index '%0d' during read.", $time, read_index);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h' during read.", $time, read_data, read_index, memory_model[read_index]);
    @(negedge clock);
    read_enable = 0;
    read_index  = 0;
    if (!empty && valid_entries_count == 0) $error("[%0tns] Empty flag not asserted when model is empty (%0d/%0d).", $time, valid_entries_count, DEPTH);
    if ( empty && valid_entries_count  > 0) $error("[%0tns] Empty flag asserted when model is not empty (%0d/%0d).", $time, valid_entries_count, DEPTH);
  end
  // Final state
  if ( empty) $error("[%0tns] Empty flag is asserted after reading without clearing. Should be full.", $time);
  if (!full ) $error("[%0tns] Full flag is deasserted after reading without clearing. Should be full.", $time);
  if (valid_entries_count != DEPTH) $error("[%0tns] Model count '%0d' is not equal to DEPTH '%0d' after reading without clearing.", $time, valid_entries_count, DEPTH);
  read_clear = 0;

  repeat(10) @(posedge clock);

  // Check 8 : Read and clear to empty
  $display("CHECK 8 : Read and clear to empty.");
  read_clear = 1;
  for (integer clear_count = 0; clear_count < DEPTH; clear_count++) begin
    @(negedge clock);
    read_enable = 1;
    read_index  = clear_count;
    @(posedge clock);
    if (read_error) $error("[%0tns] Read error asserted for valid index '%0d' during clear.", $time, read_index);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h' during clear.", $time, read_data, read_index, memory_model[read_index]);
    memory_model[read_index] = 'x;
    valid_model[read_index]  = 1'b0;
    valid_entries_count--;
    @(negedge clock);
    read_enable = 0;
    read_index  = 0;
    if (!empty && valid_entries_count == 0) $error("[%0tns] Empty flag not asserted when model is empty (%0d/%0d).", $time, valid_entries_count, DEPTH);
    if ( empty && valid_entries_count  > 0) $error("[%0tns] Empty flag asserted when model is not empty (%0d/%0d).", $time, valid_entries_count, DEPTH);
  end
  // Final state check (should be empty)
  if (!empty) $error("[%0tns] Empty flag is deasserted after clearing all. Should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after clearing all. Should be empty.", $time);
  if (valid_entries_count != 0) $error("[%0tns] Model count (%0d) is not 0 after clearing all.", $time, valid_entries_count);
  read_clear = 0;

  repeat(10) @(posedge clock);

  // Check 9 : Continuous write & clear almost empty
  $display("CHECK 9 : Continuous write & clear almost empty.");
  if (!empty) $error("[%0tns] Buffer is not empty.", $time);
  last_written_index = 'x;
  for (integer iteration = 0; iteration < CONTINUOUS_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    // Read except for the first iteration
    if (iteration > 0) begin
      read_enable = 1;
      read_clear  = 1;
      read_index  = last_written_index;
      #0;
      if (read_error) $error("[%0tns] Read error asserted for index '%0d' during clear at iteration %0d.", $time, read_index, iteration);
      if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' differs from model '%0h' at index '%0d' during clear at iteration %0d.", $time, read_data, memory_model[read_index], read_index, iteration);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
    end else begin
      read_enable = 0;
      read_clear  = 0;
      read_index  = 0;
    end
    // Write except for the last iteration
    if (iteration < CONTINUOUS_CHECK_DURATION-1) begin
      write_enable       = 1;
      write_data         = $urandom_range(WIDTH_POW2);
      last_written_index = write_index;
      #0;
      if (write_index >= DEPTH) $error("[%0tns] Write index '%0d' out of bounds at iteration %0d.", $time, write_index, iteration);
      if (valid_model[write_index]) $error("[%0tns] Write index '%0d' was already valid in model at iteration %0d.", $time, write_index, iteration);
      memory_model[write_index] = write_data;
      valid_model[write_index]  = 1'b1;
      valid_entries_count++;
    end else begin
      write_enable       = 0;
      write_data         = 0;
      last_written_index = 'x;
    end
  end
  // Deassert all signals
  @(negedge clock);
  write_enable = 0;
  read_enable  = 0;
  read_clear   = 0;
  read_index   = 0;
  @(posedge clock);
  // Final state
  if (!empty) $error("[%0tns] Final state not empty (%0d entries).", $time, valid_entries_count);
  if ( full ) $error("[%0tns] Final state is full.", $time);
  if (valid_entries_count != 0) $error("[%0tns] Model count (%0d) is not 0.", $time, valid_entries_count);

  repeat(10) @(posedge clock);

  // Check 10 : Continuous write & clear almost full
  $display("CHECK 10 : Continuous write & clear almost full.");
  if (!empty) $error("[%0tns] Buffer is not empty.", $time);
  last_written_index = 'x;
  for (integer iteration = 0; iteration < CONTINUOUS_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    // Read except for the first few iterations to fill the buffer
    if (iteration > DEPTH-2) begin
      read_enable = 1;
      read_clear  = 1;
      read_index  = last_written_index;
      #0;
      if (read_error) $error("[%0tns] Read error asserted for index '%0d' during clear at iteration %0d.", $time, read_index, iteration);
      if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' differs from model '%0h' at index '%0d' during clear at iteration %0d.", $time, read_data, memory_model[read_index], read_index, iteration);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
    end else begin
      read_enable = 0;
      read_clear  = 0;
      read_index  = 0;
    end
    // Write except for the last few iterations to empty the buffer
    if (iteration < CONTINUOUS_CHECK_DURATION-1) begin
      write_enable       = 1;
      write_data         = $urandom_range(WIDTH_POW2);
      last_written_index = write_index;
      #0;
      if (write_index >= DEPTH) $error("[%0tns] Write index '%0d' out of bounds at iteration %0d.", $time, write_index, iteration);
      if (valid_model[write_index]) $error("[%0tns] Write index '%0d' was already valid in model at iteration %0d.", $time, write_index, iteration);
      memory_model[write_index] = write_data;
      valid_model[write_index]  = 1'b1;
      valid_entries_count++;
    end else begin
      write_enable       = 0;
      write_data         = 0;
      last_written_index = 'x;
    end
  end
  // Read and clear remaining valid entries
  for (integer index = 0; index < DEPTH; index++) begin
    if (valid_model[index]) begin
      @(negedge clock);
      read_enable = 1;
      read_clear  = 1;
      read_index  = index;
      #0;
      if (read_error) $error("[%0tns] Read error asserted for valid index '%0d' during final read pass.", $time, read_index);
      if (read_data !== memory_model[index]) $error("[%0tns] Read data '%0h' at index '%0d' differs from model '%0h' during final read pass.", $time, read_data, read_index, memory_model[index]);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
      @(posedge clock);
    end else begin
      @(negedge clock);
      read_enable = 0;
      read_clear  = 0;
      read_index  = index;
      @(posedge clock);
    end
  end
  // Deassert all signals
  @(negedge clock);
  write_enable = 0;
  read_enable  = 0;
  read_clear   = 0;
  read_index   = 0;
  @(posedge clock);
  // Final state
  if (!empty) $error("[%0tns] Final state not empty (%0d entries).", $time, valid_entries_count);
  if ( full ) $error("[%0tns] Final state is full.", $time);
  if (valid_entries_count != 0) $error("[%0tns] Model count (%0d) is not 0.", $time, valid_entries_count);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
