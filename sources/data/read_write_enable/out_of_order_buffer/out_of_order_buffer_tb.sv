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
localparam integer CONTINUOUS_CHECK_DURATION      = DEPTH * 2; // Number of write/clear cycles
localparam integer RANDOM_CHECK_DURATION          = 200; // Number of random operations
localparam real    RANDOM_CHECK_WRITE_PROBABILITY  = 0.4; // Probability of a write attempt
localparam real    RANDOM_CHECK_READ_PROBABILITY   = 0.4; // Probability of a read (no clear) attempt
// Probability of read with clear is 1.0 - write_prob - read_prob = 0.2
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
  if (write_index >= DEPTH) $error("[%0tns] Write index %0d out of bounds.", $time, write_index);
  if (valid_model[write_index]) $error("[%0tns] Write index %0d was already valid in model.", $time, write_index);
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
  if (read_error) $error("[%0tns] Read error asserted for valid index %0d.", $time, read_index);
  if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index %0d differs from model '%0h'.", $time, read_data, read_index, memory_model[read_index]);
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
  if (read_error) $error("[%0tns] Read error asserted for valid index %0d during clear.", $time, read_index);
  if (read_data !== memory_model[read_index]) $error("[%0tns] Read data '%0h' at index %0d differs from model '%0h' during clear.", $time, read_data, read_index, memory_model[read_index]);
  // Update model
  valid_model[read_index] = 1'b0;
  valid_entries_count--;
  memory_model[read_index] = 'x; // Invalidate model data
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
    if (write_index >= DEPTH) $error("[%0tns] Check 4 Error: Write index %0d out of bounds during fill.", $time, write_index);
    if (valid_model[write_index]) $error("[%0tns] Check 4 Error: Write index %0d was already valid in model during fill.", $time, write_index);
    memory_model[write_index] = write_data;
    valid_model[write_index]  = 1'b1;
    valid_entries_count++;
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    if (!full && valid_entries_count == DEPTH) $error("[%0tns] Check 4 Error: Full flag not asserted when model is full (%0d/%0d).", $time, valid_entries_count, DEPTH);
    if (full && valid_entries_count < DEPTH) $error("[%0tns] Check 4 Error: Full flag asserted prematurely (%0d/%0d).", $time, valid_entries_count, DEPTH);
  end
  // Final state check (should be full)
  if ( empty) $error("[%0tns] Check 4 Error: Empty flag is asserted after filling. Should be full.", $time);
  if (!full ) $error("[%0tns] Check 4 Error: Full flag is deasserted after filling. Should be full.", $time);
  if (valid_entries_count != DEPTH) $error("[%0tns] Check 4 Error: Model count (%0d) is not DEPTH after filling.", $time, valid_entries_count);
  // Attempt to write when full
  @(negedge clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock); // Write should be ignored
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  if (!full) $error("[%0tns] Check 4 Error: Full flag deasserted after write attempt when full.", $time);

  repeat(10) @(posedge clock);

  // Check 6 : Clearing to empty
  $display("CHECK 6 : Clearing to empty.");
  // Clear all entries
  for (integer clear_count = 0; clear_count < DEPTH; clear_count++) begin
    // Find a valid index to clear
    temp_index = 'x;
    for (integer i = 0; i < DEPTH; i++) begin
      if (valid_model[i]) begin
        temp_index = i;
`ifndef SIMUMLATOR_NO_BREAK_SUPPORT
        break;
`endif
      end
    end
    if (temp_index === 'x) $error("[%0tns] Check 5 Error: Could not find a valid index in model to clear (iteration %0d).", $time, clear_count);

    @(negedge clock);
    read_enable = 1;
    read_clear  = 1;
    read_index  = temp_index;
    @(posedge clock);
    if (read_error) $error("[%0tns] Check 5 Error: Read error asserted for valid index %0d during clear.", $time, read_index);
    if (read_data !== memory_model[read_index]) $error("[%0tns] Check 5 Error: Read data '%0h' at index %0d differs from model '%0h' during clear.", $time, read_data, read_index, memory_model[read_index]);
    // Update model
    valid_model[read_index] = 1'b0;
    valid_entries_count--;
    memory_model[read_index] = 'x;
    @(negedge clock);
    read_enable = 0;
    read_clear  = 0;
    read_index  = 0;
    if (!empty && valid_entries_count == 0) $error("[%0tns] Check 5 Error: Empty flag not asserted when model is empty (%0d/%0d).", $time, valid_entries_count, DEPTH);
    if (empty && valid_entries_count > 0) $error("[%0tns] Check 5 Error: Empty flag asserted prematurely (%0d/%0d).", $time, valid_entries_count, DEPTH);
  end
  // Final state check (should be empty)
  if (!empty) $error("[%0tns] Check 5 Error: Empty flag is deasserted after clearing all. Should be empty.", $time);
  if ( full ) $error("[%0tns] Check 5 Error: Full flag is asserted after clearing all. Should be empty.", $time);
  if (valid_entries_count != 0) $error("[%0tns] Check 5 Error: Model count (%0d) is not 0 after clearing all.", $time, valid_entries_count);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
