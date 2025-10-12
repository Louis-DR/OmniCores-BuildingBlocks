// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_out_of_order_buffer.testbench.sv                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the out-of-order buffer.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module valid_ready_out_of_order_buffer__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;
localparam int  DEPTH        = 8;
localparam int  INDEX_WIDTH  = $clog2(DEPTH);

// Check parameters
localparam int  CONTINUOUS_CHECK_DURATION      = 100;
localparam int  RANDOM_CHECK_DURATION          = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam real RANDOM_CHECK_CLEAR_PROBABILITY = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic                    clock;
logic                    resetn;
logic                    write_valid;
logic [WIDTH-1:0]        write_data;
logic [INDEX_WIDTH-1:0]  write_index;
logic                    write_ready;
logic                    full;
logic                    read_valid;
logic                    read_clear;
logic [INDEX_WIDTH-1:0]  read_index;
logic [WIDTH-1:0]        read_data;
logic                    read_ready;
logic                    read_error;
logic                    empty;

// Test variables
logic [WIDTH-1:0] memory_model [DEPTH-1:0];
logic             valid_model  [DEPTH-1:0];
int               valid_entries_count;
int               last_written_index;
int               timeout_countdown;
int               transfer_count;

// Device under test
valid_ready_out_of_order_buffer #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) valid_ready_out_of_order_buffer_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .empty        ( empty        ),
  .write_valid  ( write_valid  ),
  .write_data   ( write_data   ),
  .write_index  ( write_index  ),
  .write_ready  ( write_ready  ),
  .read_valid   ( read_valid   ),
  .read_clear   ( read_clear   ),
  .read_index   ( read_index   ),
  .read_data    ( read_data    ),
  .read_ready   ( read_ready   )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Write task
task automatic write;
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  if (write_ready) begin
    assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds.", $realtime, write_index);
    assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model.", $realtime, write_index);
    memory_model[write_index] = write_data;
    valid_model[write_index]  = 1;
    valid_entries_count++;
    last_written_index = write_index;
  end
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;
endtask

// Read task (without clear)
task automatic read;
  input logic [INDEX_WIDTH-1:0] index;
  read_valid = 1;
  read_clear = 0;
  read_index = index;
  @(posedge clock);
  if (read_ready) begin
    assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h'.", $realtime, read_data, read_index, memory_model[read_index]);
  end
  @(negedge clock);
  read_valid = 0;
  read_index = 0;
endtask

// Read and clear task
task automatic read_and_clear;
  input logic [INDEX_WIDTH-1:0] index;
  read_valid = 1;
  read_clear = 1;
  read_index = index;
  @(posedge clock);
  if (read_ready) begin
    assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h'.", $realtime, read_data, read_index, memory_model[read_index]);
    valid_model[read_index] = 0;
    valid_entries_count--;
  end
  @(negedge clock);
  read_valid = 0;
  read_clear = 0;
  read_index = 0;
endtask

// Check flags task
task automatic check_flags;
  if (valid_entries_count == 0) begin
    assert (empty) else $error("[%t] Empty flag is deasserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
    assert (!full) else $error("[%t] Full flag is asserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
  end else if (valid_entries_count == DEPTH) begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
    assert (full) else $error("[%t] Full flag is deasserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
  end else begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
    assert (!full) else $error("[%t] Full flag is asserted. The buffer should have %0d valid entries.", $realtime, valid_entries_count);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("valid_ready_out_of_order_buffer.testbench.vcd");
  $dumpvars(0,valid_ready_out_of_order_buffer__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  write_data   = 0;
  write_valid  = 0;
  read_valid   = 0;
  read_clear   = 0;
  read_index   = 0;
  valid_entries_count = 0;
  for (int index = 0; index < DEPTH; index++) begin
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
  $display("[%t] After reset: full=%b empty=%b write_ready=%b read_ready=%b", $realtime, full, empty, write_ready, read_ready);
  $display("[%t] Controller valid bits: %b", $realtime, valid_ready_out_of_order_buffer_dut.controller.valid);
  $display("[%t] Controller outputs: full=%b empty=%b", $realtime, valid_ready_out_of_order_buffer_dut.controller.full, valid_ready_out_of_order_buffer_dut.controller.empty);
  assert (read_ready) else $error("[%t] Read ready should always be asserted for indexed reads.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after reset.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after reset.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after reset.", $realtime);
  // Write operation
  @(negedge clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds.", $realtime, write_index);
  assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model.", $realtime, write_index);
  memory_model[write_index] = write_data;
  valid_model[write_index]  = 1'b1;
  valid_entries_count++;
  last_written_index = write_index;
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;
  // Final state
  assert (read_ready) else $error("[%t] Read ready is deasserted after one write.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after one write.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after one write.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after only one write.", $realtime);

  repeat(10) @(posedge clock);

  // Check 2 : Read once without clearing
  $display("CHECK 2 : Read once without clearing.");
  @(negedge clock);
  read_valid = 1;
  read_clear = 0;
  read_index = last_written_index;
  @(posedge clock);
  assert (read_ready) else $error("[%t] Read ready not asserted for valid index '%0d'.", $realtime, read_index);
  assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h'.", $realtime, read_data, read_index, memory_model[read_index]);
  @(negedge clock);
  read_valid = 0;
  read_index = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Read once and clear
  $display("CHECK 3 : Read once and clear.");
  // Clear signal high without reading
  @(negedge clock);
  read_valid = 0;
  read_clear = 1;
  read_index = last_written_index;
  // Actual read operation
  @(negedge clock);
  read_valid = 1;
  read_clear = 1;
  read_index = last_written_index;
  @(posedge clock);
  assert (read_ready) else $error("[%t] Read ready not asserted for valid index '%0d' during clear.", $realtime, read_index);
  assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h' during clear.", $realtime, read_data, read_index, memory_model[read_index]);
  memory_model[read_index] = 'x;
  valid_model[read_index]  = 1'b0;
  valid_entries_count--;
  @(negedge clock);
  read_valid = 0;
  read_clear = 0;
  read_index = 0;
  // Final state
  assert (read_ready) else $error("[%t] Read ready should always be asserted for indexed reads.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after clearing the only valid entry.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after clearing the only valid entry.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after clearing the only valid entry.", $realtime);

  repeat(10) @(posedge clock);

  // Check 4 : Read while empty
  $display("CHECK 4 : Read while empty.");
  // Try reading the cleared index again
  @(negedge clock);
  read_valid = 1;
  read_index = last_written_index;
  @(posedge clock);
  assert (read_ready) else $error("[%t] Read ready should always be asserted for indexed reads.", $realtime);
  // Check that read_error is asserted for invalid index
  assert (read_error) else $error("[%t] Read error not asserted for cleared index %0d.", $realtime, read_index);
  @(negedge clock);
  read_valid = 0;
  read_index = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Writing to full
  $display("CHECK 5 : Writing to full.");
  // Fill the memory
  for (int write_count = valid_entries_count; write_count < DEPTH; write_count++) begin
    @(negedge clock);
    write_valid = 1;
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds during fill.", $realtime, write_index);
    assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model during fill.", $realtime, write_index);
    memory_model[write_index] = write_data;
    valid_model[write_index]  = 1'b1;
    valid_entries_count++;
    @(negedge clock);
    write_valid = 0;
    write_data  = 0;
    assert (full || valid_entries_count != DEPTH) else $error("[%t] Full flag not asserted when model is full (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
    assert (!full || valid_entries_count >= DEPTH) else $error("[%t] Full flag asserted when model is not full (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
  end
  // Final state
  assert (read_ready) else $error("[%t] Read ready is deasserted after filling.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after filling.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after filling. Should be full.", $realtime);
  assert (full) else $error("[%t] Full flag is deasserted after filling. Should be full.", $realtime);
  assert (valid_entries_count == DEPTH) else $error("[%t] Model count '%0d' is not equal to DEPTH '%0d' after filling.", $realtime, valid_entries_count, DEPTH);

  repeat(10) @(posedge clock);

  // Check 6 : Writing when full
  $display("CHECK 6 : Writing when full.");
  // Attempt to write when full
  @(negedge clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  assert (read_ready) else $error("[%t] Read ready is deasserted after write attempt when full.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after write attempt when full.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after write attempt when full", $realtime);
  assert (full) else $error("[%t] Full flag deasserted after write attempt when full.", $realtime);
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;

  repeat(10) @(posedge clock);

  // Check 7 : Read all without clearing
  $display("CHECK 7 : Read all without clearing.");
  read_clear = 0;
  for (int read_count = 0; read_count < DEPTH; read_count++) begin
    @(negedge clock);
    read_valid = 1;
    read_index = read_count;
    @(posedge clock);
    assert (read_ready) else $error("[%t] Read ready not asserted for valid index '%0d' during read.", $realtime, read_index);
    assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h' during read.", $realtime, read_data, read_index, memory_model[read_index]);
    @(negedge clock);
    read_valid = 0;
    read_index = 0;
    assert (empty || valid_entries_count != 0) else $error("[%t] Empty flag not asserted when model is empty (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
    assert (!empty || valid_entries_count == 0) else $error("[%t] Empty flag asserted when model is not empty (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
  end
  // Final state
  assert (read_ready) else $error("[%t] Read ready is deasserted after reading without clearing.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after reading without clearing.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after reading without clearing. Should be full.", $realtime);
  assert (full) else $error("[%t] Full flag is deasserted after reading without clearing. Should be full.", $realtime);
  assert (valid_entries_count == DEPTH) else $error("[%t] Model count '%0d' is not equal to DEPTH '%0d' after reading without clearing.", $realtime, valid_entries_count, DEPTH);
  read_clear = 0;

  repeat(10) @(posedge clock);

  // Check 8 : Read and clear to empty
  $display("CHECK 8 : Read and clear to empty.");
  read_clear = 1;
  for (int clear_count = 0; clear_count < DEPTH; clear_count++) begin
    @(negedge clock);
    read_valid = 1;
    read_index = clear_count;
    @(posedge clock);
    assert (read_ready) else $error("[%t] Read ready not asserted for valid index '%0d' during clear.", $realtime, read_index);
    assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h' during clear.", $realtime, read_data, read_index, memory_model[read_index]);
    memory_model[read_index] = 'x;
    valid_model[read_index]  = 1'b0;
    valid_entries_count--;
    @(negedge clock);
    read_valid = 0;
    read_index = 0;
    assert (empty || valid_entries_count != 0) else $error("[%t] Empty flag not asserted when model is empty (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
    assert (!empty || valid_entries_count == 0) else $error("[%t] Empty flag asserted when model is not empty (%0d/%0d).", $realtime, valid_entries_count, DEPTH);
  end
  // Final state check (should be empty)
  assert (read_ready) else $error("[%t] Read ready should always be asserted for indexed reads.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after clearing all.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after clearing all. Should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after clearing all. Should be empty.", $realtime);
  assert (valid_entries_count == 0) else $error("[%t] Model count (%0d) is not 0 after clearing all.", $realtime, valid_entries_count);
  read_clear = 0;

  repeat(10) @(posedge clock);

  // Check 9 : Continuous write & clear almost empty
  $display("CHECK 9 : Continuous write & clear almost empty.");
  assert (empty) else $error("[%t] Buffer is not empty.", $realtime);
  last_written_index = 'x;
  for (int iteration = 0; iteration < CONTINUOUS_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    // Read except for the first iteration
    if (iteration > 0) begin
      read_valid = 1;
      read_clear = 1;
      read_index = last_written_index;
      #0;
      assert (read_ready) else $error("[%t] Read ready not asserted for index '%0d' during clear at iteration %0d.", $realtime, read_index, iteration);
      assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' differs from model '%0h' at index '%0d' during clear at iteration %0d.", $realtime, read_data, memory_model[read_index], read_index, iteration);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
    end else begin
      read_valid = 0;
      read_clear = 0;
      read_index = 0;
    end
    // Write except for the last iteration
    if (iteration < CONTINUOUS_CHECK_DURATION-1) begin
      write_valid = 1;
      write_data  = $urandom_range(WIDTH_POW2);
      last_written_index = write_index;
      #0;
      assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds at iteration %0d.", $realtime, write_index, iteration);
      assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model at iteration %0d.", $realtime, write_index, iteration);
      memory_model[write_index] = write_data;
      valid_model[write_index]  = 1'b1;
      valid_entries_count++;
    end else begin
      write_valid = 0;
      write_data  = 0;
      last_written_index = 'x;
    end
  end
  // Deassert all signals
  @(negedge clock);
  write_valid = 0;
  read_valid  = 0;
  read_clear  = 0;
  read_index  = 0;
  @(posedge clock);
  // Final state
  assert (empty) else $error("[%t] Final state not empty (%0d entries).", $realtime, valid_entries_count);
  assert (!full) else $error("[%t] Final state is full.", $realtime);
  assert (valid_entries_count == 0) else $error("[%t] Model count (%0d) is not 0.", $realtime, valid_entries_count);

  repeat(10) @(posedge clock);

  // Check 10 : Continuous write & clear almost full
  $display("CHECK 10 : Continuous write & clear almost full.");
  assert (empty) else $error("[%t] Buffer is not empty.", $realtime);
  last_written_index = 'x;
  for (int iteration = 0; iteration < CONTINUOUS_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    // Read except for the first few iterations to fill the buffer
    if (iteration > DEPTH-2) begin
      read_valid = 1;
      read_clear = 1;
      read_index = last_written_index;
      #0;
      assert (read_ready) else $error("[%t] Read ready not asserted for index '%0d' during clear at iteration %0d.", $realtime, read_index, iteration);
      assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' differs from model '%0h' at index '%0d' during clear at iteration %0d.", $realtime, read_data, memory_model[read_index], read_index, iteration);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
    end else begin
      read_valid = 0;
      read_clear = 0;
      read_index = 0;
    end
    // Write except for the last few iterations to empty the buffer
    if (iteration < CONTINUOUS_CHECK_DURATION-1) begin
      write_valid = 1;
      write_data  = $urandom_range(WIDTH_POW2);
      last_written_index = write_index;
      #0;
      assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds at iteration %0d.", $realtime, write_index, iteration);
      assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model at iteration %0d.", $realtime, write_index, iteration);
      memory_model[write_index] = write_data;
      valid_model[write_index]  = 1'b1;
      valid_entries_count++;
    end else begin
      write_valid = 0;
      write_data  = 0;
      last_written_index = 'x;
    end
  end
  // Read and clear remaining valid entries
  for (int index = 0; index < DEPTH; index++) begin
    if (valid_model[index]) begin
      @(negedge clock);
      read_valid = 1;
      read_clear = 1;
      read_index = index;
      #0;
      assert (read_ready) else $error("[%t] Read ready not asserted for valid index '%0d' during final read pass.", $realtime, read_index);
      assert (read_data === memory_model[index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h' during final read pass.", $realtime, read_data, read_index, memory_model[index]);
      memory_model[read_index] = 'x;
      valid_model[read_index]  = 1'b0;
      valid_entries_count--;
      @(posedge clock);
    end else begin
      @(negedge clock);
      read_valid = 0;
      read_clear = 0;
      read_index = index;
      @(posedge clock);
    end
  end
  // Deassert all signals
  @(negedge clock);
  write_valid = 0;
  read_valid  = 0;
  read_clear  = 0;
  read_index  = 0;
  @(posedge clock);
  // Final state
  assert (empty) else $error("[%t] Final state not empty (%0d entries).", $realtime, valid_entries_count);
  assert (!full) else $error("[%t] Final state is full.", $realtime);
  assert (valid_entries_count == 0) else $error("[%t] Model count (%0d) is not 0.", $realtime, valid_entries_count);

  repeat(10) @(posedge clock);

  // Check 11 : Random stimulus
  $display("CHECK 11 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
          write_valid = 1;
          write_data  = $urandom_range(WIDTH_POW2);
        end else begin
          write_valid = 0;
          write_data  = 0;
        end
        // Check
        @(posedge clock);
        if (write_valid && write_ready) begin
          assert (write_index < DEPTH) else $error("[%t] Write index '%0d' out of bounds.", $realtime, write_index);
          assert (!valid_model[write_index]) else $error("[%t] Write index '%0d' was already valid in model.", $realtime, write_index);
          memory_model[write_index] = write_data;
          valid_model[write_index]  = 1'b1;
          valid_entries_count++;
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          // Find a valid entry to read
          logic found_valid;
          found_valid = 0;
          foreach (valid_model[index]) begin
            if (valid_model[index]) begin
              read_index  = index;
              found_valid = 1;
              // break;
            end
          end
          // Only set read_valid if we found a valid entry
          if (found_valid) begin
            read_valid = 1;
            if (random_boolean(RANDOM_CHECK_CLEAR_PROBABILITY)) begin
              read_clear = 1;
            end else begin
              read_clear = 0;
            end
          end else begin
            read_valid = 0;
            read_clear = 0;
          end
        end else begin
          read_valid = 0;
          read_clear = 0;
        end
        // Check
        @(posedge clock);
        if (read_valid && read_ready) begin
          assert (valid_model[read_index]) else $error("[%t] Read from invalid index '%0d'.", $realtime, read_index);
          assert (read_data === memory_model[read_index]) else $error("[%t] Read data '%0h' at index '%0d' differs from model '%0h'.", $realtime, read_data, read_index, memory_model[read_index]);
          // Check read_error signal
          assert (!read_error) else $error("[%t] Read error asserted for valid read at index '%0d'.", $realtime, read_index);
          if (read_clear) begin
            memory_model[read_index] = 'x;
            valid_model[read_index]  = 1'b0;
            valid_entries_count--;
          end
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
        // Read ready is always asserted for indexed reads
        assert (read_ready) else $error("[%t] Read ready should always be asserted for indexed reads.", $realtime);
        if (valid_entries_count == 0) begin
          assert (write_ready) else $error("[%t] Write ready is deasserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (empty) else $error("[%t] Empty flag is deasserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (!full) else $error("[%t] Full flag is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
        end else if (valid_entries_count == DEPTH) begin
          assert (!write_ready) else $error("[%t] Write ready is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (full) else $error("[%t] Full flag is deasserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
        end else begin
          assert (write_ready) else $error("[%t] Write ready is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
          assert (!full) else $error("[%t] Full flag is asserted. The buffer should be have %0d entries in it.", $realtime, valid_entries_count);
        end
      end
    end
    // Stop condition
    begin
      // Transfer count
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
      end
      // Read until empty
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
      $error("[%t] Timeout.", $realtime);
    end
  join_any
  disable fork;
  // Final state
  assert (empty) else $error("[%t] Final state not empty (%0d entries).", $realtime, valid_entries_count);
  assert (!full) else $error("[%t] Final state is full.", $realtime);
  assert (valid_entries_count == 0) else $error("[%t] Model count (%0d) is not 0.", $realtime, valid_entries_count);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
