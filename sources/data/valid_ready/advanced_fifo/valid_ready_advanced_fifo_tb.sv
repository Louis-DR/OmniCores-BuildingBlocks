// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_advanced_fifo_tb.sv                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the advanced FIFO queue.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "common.svh"



module valid_ready_advanced_fifo_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 8;
localparam integer WIDTH_POW2   = 2**WIDTH;
localparam integer DEPTH        = 4;
localparam integer DEPTH_LOG2   = `CLOG2(DEPTH);

// Check parameters
localparam integer THROUGHPUT_CHECK_DURATION      = 100;
localparam integer RANDOM_CHECK_DURATION          = 500;
localparam integer RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam integer RANDOM_CHECK_TIMEOUT           = 5000;
localparam integer RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD = 25;

// Device ports
logic                clock;
logic                resetn;
logic    [WIDTH-1:0] write_data;
logic                write_valid;
logic                write_ready;
logic    [WIDTH-1:0] read_data;
logic                read_valid;
logic                read_ready;
logic                full;
logic                empty;
logic [DEPTH_LOG2:0] level;
logic [DEPTH_LOG2:0] lower_threshold_level;
logic                lower_threshold_status;
logic [DEPTH_LOG2:0] upper_threshold_level;
logic                upper_threshold_status;

// Test variables
integer data_expected[$];
integer pop_trash;
integer transfer_count;
integer outstanding_count;
integer timeout_countdown;
integer threshold_change_countdown;
bool    write_outstanding;

// Device under test
valid_ready_advanced_fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) valid_ready_advanced_fifo_dut (
  .clock                  ( clock                  ),
  .resetn                 ( resetn                 ),
  .write_data             ( write_data             ),
  .write_valid            ( write_valid            ),
  .write_ready            ( write_ready            ),
  .read_data              ( read_data              ),
  .read_valid             ( read_valid             ),
  .read_ready             ( read_ready             ),
  .full                   ( full                   ),
  .empty                  ( empty                  ),
  .level                  ( level                  ),
  .lower_threshold_level  ( lower_threshold_level  ),
  .lower_threshold_status ( lower_threshold_status ),
  .upper_threshold_level  ( upper_threshold_level  ),
  .upper_threshold_status ( upper_threshold_status )
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
  $dumpfile("valid_ready_advanced_fifo_tb.vcd");
  $dumpvars(0,valid_ready_advanced_fifo_tb);

  // Initialization
  write_data   = 0;
  write_valid  = 0;
  read_ready   = 0;
  lower_threshold_level = 0;
  upper_threshold_level = DEPTH;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  outstanding_count = 0;
  // Initial state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after reset. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after reset. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after reset. The FIFO should be empty.", $time, level);
  // Writing
  for (integer write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge clock);
    write_valid = 1;
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (level != outstanding_count) $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
    data_expected.push_back(write_data);
    outstanding_count++;
    @(negedge clock);
    write_valid = 0;
    write_data  = 0;
    if (write_count != DEPTH) begin
      if (!read_valid ) $error("[%0tns] Read valid is deasserted after %0d writes.", $time, write_count);
      if (!write_ready) $error("[%0tns] Write ready is deasserted after %0d writes.", $time, write_count);
      if ( empty      ) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
      if ( full       ) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after writing to full. The FIFO should be full.", $time);
  if ( write_ready) $error("[%0tns] Write ready is asserted after writing to full. The FIFO should be full.", $time);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after writing to full. The FIFO should be full.", $time);
  if (!full       ) $error("[%0tns] Full flag is deasserted after writing to full. The FIFO should be full.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $time, level, DEPTH);

  repeat(10) @(posedge clock);

  // Check 2 : Write valid while full
  $display("CHECK 2 : Write valid while full.");
  // Write
  @(negedge clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after writing while full. The FIFO should be full.", $time);
  if ( write_ready) $error("[%0tns] Write ready is asserted after writing while full. The FIFO should be full.", $time);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after writing while full. The FIFO should be full.", $time);
  if (!full       ) $error("[%0tns] Full flag is deasserted after writing while full. The FIFO should be full.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' after writing while full. The FIFO should be full.", $time, level, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty.");
  // Reading
  for (integer read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge clock);
    read_ready = 1;
    @(posedge clock);
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    end else begin
      $error("[%0tns] Read valid while FIFO should be empty.", $time);
    end
    if (level != outstanding_count) $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
    pop_trash = data_expected.pop_front();
    outstanding_count--;
    @(negedge clock);
    read_ready = 0;
    if (read_count != DEPTH) begin
      if (!read_valid ) $error("[%0tns] Read valid is deasserted after %0d reads.", $time, read_count);
      if (!write_ready) $error("[%0tns] Write ready is deasserted after %0d reads.", $time, read_count);
      if ( empty      ) $error("[%0tns] Empty flag is asserted after %0d reads.", $time, read_count);
      if ( full       ) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if ( full       ) $error("[%0tns] Full flag is asserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after reading to empty. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 4 : Read ready while empty
  $display("CHECK 4 : Read ready while empty.");
  // Read
  @(negedge clock);
  read_ready = 1;
  @(negedge clock);
  read_ready = 0;
  if ( read_valid ) $error("[%0tns] Read valid is asserted after asserting read valid while empty. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after asserting read valid while empty. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after asserting read valid while empty. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after asserting read valid while empty. The FIFO should be empty.", $time);
  if (level != 0)  $error("[%0tns] Level '%0d' is not zero after asserting read valid while empty. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 5 : Back-to-back transfers for full throughput
  $display("CHECK 5 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_valid = 1;
  write_data  = 0;
  for (integer iteration = 0; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    if (!read_valid ) $error("[%0tns] Read valid is deasserted.", $time);
    if (!write_ready) $error("[%0tns] Write ready is deasserted.", $time);
    if ( empty      ) $error("[%0tns] Empty flag is asserted.", $time);
    if ( full       ) $error("[%0tns] Full flag is asserted.", $time);
    // Read
    read_ready = 1;
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
    end else begin
      $error("[%0tns] Read valid while FIFO should be empty.", $time);
    end
    // Increment write data
    write_data = write_data+1;
  end
  write_valid = 0;
  write_data  = 0;
  // Last read
  @(negedge clock);
  read_ready = 0;
  // Safety
  write_valid = 0;
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 5. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 5. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 5. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 5. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after check 5. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 6 : Random stimulus
  $display("CHECK 6 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  outstanding_count = 0;
  data_expected     = {};
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  threshold_change_countdown = RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD;
  fork
    // Writing
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (!write_outstanding) begin
          if ($random < RANDOM_CHECK_WRITE_PROBABILITY) begin
            write_outstanding = 1;
            write_valid = 1;
            write_data  = $urandom_range(WIDTH_POW2);
          end else begin
            write_valid = 0;
            write_data  = 0;
          end
        end
        // Check
        @(posedge clock);
        if (write_valid && write_ready) begin
          data_expected.push_back(write_data);
          transfer_count++;
          outstanding_count++;
          write_outstanding = 0;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if ($random < RANDOM_CHECK_READ_PROBABILITY) begin
          read_ready = 1;
        end else begin
          read_ready = 0;
        end
        // Check
        @(posedge clock);
        if (read_valid && read_ready) begin
          if (data_expected.size() != 0) begin
            if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
            pop_trash = data_expected.pop_front();
            outstanding_count--;
          end else begin
            $error("[%0tns] Read valid while FIFO should be empty.", $time);
          end
        end
      end
    end
    // Thresholds change
    begin
      forever begin
        @(negedge clock);
        if (threshold_change_countdown == 0) begin
          threshold_change_countdown = RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD;
          lower_threshold_level = $urandom_range(DEPTH);
          upper_threshold_level = $urandom_range(DEPTH);
        end else begin
          threshold_change_countdown--;
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
        if (level != outstanding_count) $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
        if (outstanding_count == 0) begin
          if ( read_valid ) $error("[%0tns] Read valid is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if (!write_ready) $error("[%0tns] Write ready is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if (!empty      ) $error("[%0tns] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( full       ) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end else if (outstanding_count == DEPTH) begin
          if (!read_valid ) $error("[%0tns] Read valid is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( write_ready) $error("[%0tns] Write ready is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( empty      ) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if (!full       ) $error("[%0tns] Full flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end else begin
          if (!read_valid ) $error("[%0tns] Read valid is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if (!write_ready) $error("[%0tns] Write ready is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( empty      ) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( full       ) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end
        if (lower_threshold_status !== level <= lower_threshold_level) begin
          $error("[%0tns] Lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $time, lower_threshold_status, lower_threshold_level, level);
        end
        if (upper_threshold_status !== level >= upper_threshold_level) begin
          $error("[%0tns] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $time, upper_threshold_status, upper_threshold_level, level);
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
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  // Safety
  write_valid = 0;
  read_ready  = 0;
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 6. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 6. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 6. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 6. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after check 6. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
