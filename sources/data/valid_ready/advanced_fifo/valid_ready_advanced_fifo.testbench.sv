// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_advanced_fifo.testbench.sv                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the advanced FIFO queue.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "boolean.svh"
`include "random.svh"



module valid_ready_advanced_fifo__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;
localparam int  DEPTH        = 4;
localparam int  DEPTH_LOG2   = $clog2(DEPTH);

// Check parameters
localparam int  THROUGHPUT_CHECK_DURATION      = 100;
localparam int  RANDOM_CHECK_DURATION          = 500;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 5000;
localparam int  RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD = 25;

// Device ports
logic                clock;
logic                resetn;
logic                flush;
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
int  data_expected[$];
int  pop_trash;
int  transfer_count;
int  outstanding_count;
int  timeout_countdown;
int  threshold_change_countdown;
bool write_outstanding;

// Device under test
valid_ready_advanced_fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) valid_ready_advanced_fifo_dut (
  .clock                  ( clock                  ),
  .resetn                 ( resetn                 ),
  .flush                  ( flush                  ),
  .full                   ( full                   ),
  .empty                  ( empty                  ),
  .write_data             ( write_data             ),
  .write_valid            ( write_valid            ),
  .write_ready            ( write_ready            ),
  .read_data              ( read_data              ),
  .read_valid             ( read_valid             ),
  .read_ready             ( read_ready             ),
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

// Write task
task automatic write;
  input logic [WIDTH-1:0] data;
  write_valid = 1;
  write_data  = data;
  @(posedge clock);
  if (write_ready) begin
    data_expected.push_back(data);
    outstanding_count++;
  end
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;
endtask

// Read task
task automatic read;
  read_ready = 1;
  @(posedge clock);
  if (read_valid) begin
    if (data_expected.size() != 0) begin
      assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
      outstanding_count--;
    end else begin
      $error("[%t] Read valid while FIFO should be empty.", $realtime);
    end
  end
  @(negedge clock);
  read_ready = 0;
endtask

// Check flags task
task automatic check_flags;
  if (outstanding_count == 0) begin
    assert (empty) else $error("[%t] Empty flag is deasserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert (!full) else $error("[%t] Full flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end else if (outstanding_count == DEPTH) begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert (full) else $error("[%t] Full flag is deasserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end else begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert (!full) else $error("[%t] Full flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("valid_ready_advanced_fifo.testbench.vcd");
  $dumpvars(0,valid_ready_advanced_fifo__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  flush        = 0;
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
  assert (!read_valid) else $error("[%t] Read valid is asserted after reset. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after reset. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after reset. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after reset. The FIFO should be empty.", $realtime);
  assert ( level == 0 ) else $error("[%t] Level '%0d' is not zero after reset. The FIFO should be empty.", $realtime, level);
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge clock);
    write_valid = 1;
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    assert (level == outstanding_count) else $error("[%t] Level '%0d' is not as expected '%0d'.", $realtime, level, outstanding_count);
    data_expected.push_back(write_data);
    outstanding_count++;
    @(negedge clock);
    write_valid = 0;
    write_data  = 0;
    if (write_count != DEPTH) begin
      assert (read_valid) else $error("[%t] Read valid is deasserted after %0d writes.", $realtime, write_count);
      assert (write_ready) else $error("[%t] Write ready is deasserted after %0d writes.", $realtime, write_count);
      assert (!empty) else $error("[%t] Empty flag is asserted after %0d writes.", $realtime, write_count);
      assert (!full) else $error("[%t] Full flag is asserted after %0d writes.", $realtime, write_count);
    end
  end
  // Final state
  assert (read_valid) else $error("[%t] Read valid is deasserted after writing to full. The FIFO should be full.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after writing to full. The FIFO should be full.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after writing to full. The FIFO should be full.", $realtime);
  assert (full) else $error("[%t] Full flag is deasserted after writing to full. The FIFO should be full.", $realtime);
  assert (level == DEPTH) else $error("[%t] Level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $realtime, level, DEPTH);

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
  assert (read_valid) else $error("[%t] Read valid is deasserted after writing while full. The FIFO should be full.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after writing while full. The FIFO should be full.", $realtime);
  assert (!empty) else $error("[%t] Empty flag is asserted after writing while full. The FIFO should be full.", $realtime);
  assert (full) else $error("[%t] Full flag is deasserted after writing while full. The FIFO should be full.", $realtime);
  assert (level == DEPTH) else $error("[%t] Level '%0d' is not equal to DEPTH='%0d' after writing while full. The FIFO should be full.", $realtime, level, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty.");
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge clock);
    read_ready = 1;
    @(posedge clock);
    if (data_expected.size() != 0) begin
      assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
    end else begin
      $error("[%t] Read valid while FIFO should be empty.", $realtime);
    end
    assert (level == outstanding_count) else $error("[%t] Level '%0d' is not as expected '%0d'.", $realtime, level, outstanding_count);
    pop_trash = data_expected.pop_front();
    outstanding_count--;
    @(negedge clock);
    read_ready = 0;
    if (read_count != DEPTH) begin
      assert (read_valid) else $error("[%t] Read valid is deasserted after %0d reads.", $realtime, read_count);
      assert (write_ready) else $error("[%t] Write ready is deasserted after %0d reads.", $realtime, read_count);
      assert (!empty) else $error("[%t] Empty flag is asserted after %0d reads.", $realtime, read_count);
      assert (!full) else $error("[%t] Full flag is asserted after %0d reads.", $realtime, read_count);
    end
  end
  // Final state
  assert (!read_valid) else $error("[%t] Read valid is asserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after reading to empty. The FIFO should be empty.", $realtime);
  assert ( level == 0 ) else $error("[%t] Level '%0d' is not zero after reading to empty. The FIFO should be empty.", $realtime, level);

  repeat(10) @(posedge clock);

  // Check 4 : Read ready while empty
  $display("CHECK 4 : Read ready while empty.");
  // Read
  @(negedge clock);
  read_ready = 1;
  @(negedge clock);
  read_ready = 0;
  assert (!read_valid) else $error("[%t] Read valid is asserted after asserting read valid while empty. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after asserting read valid while empty. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after asserting read valid while empty. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after asserting read valid while empty. The FIFO should be empty.", $realtime);
  if ( level != 0 )  $error("[%t] Level '%0d' is not zero after asserting read valid while empty. The FIFO should be empty.", $realtime, level);

  repeat(10) @(posedge clock);

  // Check 5 : Flushing
  $display("CHECK 5 : Flushing.");
  // Write
  @(negedge clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(negedge clock);
  write_valid = 0;
  write_data  = 0;
  // Flush
  @(negedge clock);
  flush = 1;
  @(negedge clock);
  flush = 0;
  assert (!read_valid) else $error("[%t] Read valid is asserted after flushing. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after flushing. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after flushing. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after flushing. The FIFO should be empty.", $realtime);
  assert ( level == 0 ) else $error("[%t] Level '%0d' is not zero after flushing. The FIFO should be empty.", $realtime, level);

  repeat(10) @(posedge clock);

  // Check 6 : Back-to-back transfers for full throughput
  $display("CHECK 6 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_valid = 1;
  write_data  = 0;
  for (int iteration = 0; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    assert (read_valid) else $error("[%t] Read valid is deasserted.", $realtime);
    assert (write_ready) else $error("[%t] Write ready is deasserted.", $realtime);
    assert (!empty) else $error("[%t] Empty flag is asserted.", $realtime);
    assert (!full) else $error("[%t] Full flag is asserted.", $realtime);
    // Read
    read_ready = 1;
    if (data_expected.size() != 0) begin
      assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
    end else begin
      $error("[%t] Read valid while FIFO should be empty.", $realtime);
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
  assert (!read_valid) else $error("[%t] Read valid is asserted after check 6. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after check 6. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after check 6. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after check 6. The FIFO should be empty.", $realtime);
  assert ( level == 0 ) else $error("[%t] Level '%0d' is not zero after check 6. The FIFO should be empty.", $realtime, level);

  repeat(10) @(posedge clock);

  // Check 7 : Random stimulus
  $display("CHECK 7 : Random stimulus.");
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
          if (random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
            write_outstanding = true;
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
          write_outstanding = false;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          read_ready = 1;
        end else begin
          read_ready = 0;
        end
        // Check
        @(posedge clock);
        if (read_valid && read_ready) begin
          if (data_expected.size() != 0) begin
            assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
            pop_trash = data_expected.pop_front();
            outstanding_count--;
          end else begin
            $error("[%t] Read valid while FIFO should be empty.", $realtime);
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
        @(negedge clock); #1;
        assert (level == outstanding_count) else $error("[%t] Level '%0d' is not as expected '%0d'.", $realtime, level, outstanding_count);
        if (outstanding_count == 0) begin
          assert (!read_valid) else $error("[%t] Read valid is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (write_ready) else $error("[%t] Write ready is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (empty) else $error("[%t] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (!full) else $error("[%t] Full flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
        end else if (outstanding_count == DEPTH) begin
          assert (read_valid) else $error("[%t] Read valid is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (!write_ready) else $error("[%t] Write ready is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (full) else $error("[%t] Full flag is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
        end else begin
          assert (read_valid) else $error("[%t] Read valid is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (write_ready) else $error("[%t] Write ready is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          assert (!full) else $error("[%t] Full flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
        end
        if (lower_threshold_status !== level <= lower_threshold_level) begin
          $error("[%t] Lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $realtime, lower_threshold_status, lower_threshold_level, level);
        end
        if (upper_threshold_status !== level >= upper_threshold_level) begin
          $error("[%t] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $realtime, upper_threshold_status, upper_threshold_level, level);
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
  // Safety
  write_valid = 0;
  read_ready  = 0;
  // Final state
  assert (!read_valid) else $error("[%t] Read valid is asserted after check 7. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after check 7. The FIFO should be empty.", $realtime);
  assert (empty) else $error("[%t] Empty flag is deasserted after check 7. The FIFO should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after check 7. The FIFO should be empty.", $realtime);
  assert ( level == 0 ) else $error("[%t] Level '%0d' is not zero after check 7. The FIFO should be empty.", $realtime, level);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
