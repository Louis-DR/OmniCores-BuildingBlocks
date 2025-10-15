// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_asynchronous_advanced_fifo.testbench.sv          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the FIFO queue.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "random.svh"



module valid_ready_asynchronous_advanced_fifo__testbench ();

// Test parameters
localparam real CLOCK_SLOW_PERIOD = 10;
localparam real CLOCK_FAST_PERIOD = CLOCK_SLOW_PERIOD/3.14159265359;
localparam real CLOCK_PHASE_SHIFT = CLOCK_FAST_PERIOD*3/2;
localparam int  WIDTH             = 8;
localparam int  WIDTH_POW2        = 2**WIDTH;
localparam int  DEPTH             = 4;
localparam int  DEPTH_LOG2        = $clog2(DEPTH);
localparam int  STAGES_WRITE      = 2;
localparam int  STAGES_READ       = 2;

// Check parameters
localparam int  THROUGHPUT_CHECK_DURATION      = 100;
localparam int  THROUGHPUT_CHECK_TIMEOUT       = 1000;
localparam int  RANDOM_CHECK_DURATION          = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 1000;
localparam int  RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD = 25;

// Variable frequency test clocks
real WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
real READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;

// Device ports
logic                write_clock;
logic                write_resetn;
logic                write_flush;
logic    [WIDTH-1:0] write_data;
logic                write_valid;
logic                write_ready;
logic                write_empty;
logic                write_almost_empty;
logic                write_half_empty;
logic                write_not_empty;
logic                write_not_full;
logic                write_half_full;
logic                write_almost_full;
logic                write_full;
logic [DEPTH_LOG2:0] write_level;
logic [DEPTH_LOG2:0] write_space;
logic [DEPTH_LOG2:0] write_lower_threshold_level;
logic                write_lower_threshold_status;
logic [DEPTH_LOG2:0] write_upper_threshold_level;
logic                write_upper_threshold_status;
logic                read_clock;
logic                read_resetn;
logic                read_flush;
logic    [WIDTH-1:0] read_data;
logic                read_valid;
logic                read_ready;
logic                read_empty;
logic                read_almost_empty;
logic                read_half_empty;
logic                read_not_empty;
logic                read_not_full;
logic                read_half_full;
logic                read_almost_full;
logic                read_full;
logic [DEPTH_LOG2:0] read_level;
logic [DEPTH_LOG2:0] read_space;
logic [DEPTH_LOG2:0] read_lower_threshold_level;
logic                read_lower_threshold_status;
logic [DEPTH_LOG2:0] read_upper_threshold_level;
logic                read_upper_threshold_status;

// Test variables
int data_expected[$];
int pop_trash;
int transfer_count;
int outstanding_count;
int timeout_countdown;
int threshold_change_countdown;

// Device under test
valid_ready_asynchronous_advanced_fifo #(
  .WIDTH        ( WIDTH        ),
  .DEPTH        ( DEPTH        ),
  .STAGES_WRITE ( STAGES_WRITE ),
  .STAGES_READ  ( STAGES_READ  )
) valid_ready_asynchronous_advanced_fifo_dut (
  .write_clock                  ( write_clock                  ),
  .write_resetn                 ( write_resetn                 ),
  .write_flush                  ( write_flush                  ),
  .write_data                   ( write_data                   ),
  .write_valid                  ( write_valid                  ),
  .write_ready                  ( write_ready                  ),
  .write_empty                  ( write_empty                  ),
  .write_almost_empty           ( write_almost_empty           ),
  .write_half_empty             ( write_half_empty             ),
  .write_not_empty              ( write_not_empty              ),
  .write_not_full               ( write_not_full               ),
  .write_half_full              ( write_half_full              ),
  .write_almost_full            ( write_almost_full            ),
  .write_full                   ( write_full                   ),
  .write_level                  ( write_level                  ),
  .write_space                  ( write_space                  ),
  .write_lower_threshold_level  ( write_lower_threshold_level  ),
  .write_lower_threshold_status ( write_lower_threshold_status ),
  .write_upper_threshold_level  ( write_upper_threshold_level  ),
  .write_upper_threshold_status ( write_upper_threshold_status ),
  .read_clock                   ( read_clock                   ),
  .read_resetn                  ( read_resetn                  ),
  .read_flush                   ( read_flush                   ),
  .read_data                    ( read_data                    ),
  .read_valid                   ( read_valid                   ),
  .read_ready                   ( read_ready                   ),
  .read_empty                   ( read_empty                   ),
  .read_almost_empty            ( read_almost_empty            ),
  .read_half_empty              ( read_half_empty              ),
  .read_not_empty               ( read_not_empty               ),
  .read_not_full                ( read_not_full                ),
  .read_half_full               ( read_half_full               ),
  .read_almost_full             ( read_almost_full             ),
  .read_full                    ( read_full                    ),
  .read_level                   ( read_level                   ),
  .read_space                   ( read_space                   ),
  .read_lower_threshold_level   ( read_lower_threshold_level   ),
  .read_lower_threshold_status  ( read_lower_threshold_status  ),
  .read_upper_threshold_level   ( read_upper_threshold_level   ),
  .read_upper_threshold_status  ( read_upper_threshold_status  )
);

// Write clock generation
initial begin
  write_clock = 1;
  if (CLOCK_PHASE_SHIFT < 0) #(-CLOCK_PHASE_SHIFT);
  forever begin
    #(WRITE_CLOCK_PERIOD/2) write_clock = ~write_clock;
  end
end

// Read clock generation
initial begin
  read_clock = 1;
  if (CLOCK_PHASE_SHIFT > 0) #(CLOCK_PHASE_SHIFT);
  forever begin
    #(READ_CLOCK_PERIOD/2) read_clock = ~read_clock;
  end
end

// Write task
task automatic write;
  input logic [WIDTH-1:0] data;
  write_valid = 1;
  write_data  = data;
  @(posedge write_clock);
  if (write_ready) begin
    data_expected.push_back(data);
    outstanding_count++;
  end
  @(negedge write_clock);
  write_valid = 0;
  write_data  = 0;
endtask

// Read task
task automatic read;
  read_ready = 1;
  @(posedge read_clock);
  if (read_valid) begin
    if (data_expected.size() != 0) begin
      assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
      outstanding_count--;
    end else begin
      $error("[%t] Read valid while FIFO should be empty.", $realtime);
    end
  end
  @(negedge read_clock);
  read_ready = 0;
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("valid_ready_asynchronous_advanced_fifo.testbench.vcd");
  $dumpvars(0,valid_ready_asynchronous_advanced_fifo__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  write_flush = 0;
  read_flush  = 0;
  write_data  = 0;
  write_valid = 0;
  read_ready  = 0;
  write_lower_threshold_level = 0;
  write_upper_threshold_level = DEPTH;
  read_lower_threshold_level  = 0;
  read_upper_threshold_level  = DEPTH;

  // Reset
  write_resetn = 0;
  read_resetn  = 0;
  @(posedge write_clock);
  @(posedge read_clock);
  write_resetn = 1;
  read_resetn  = 1;
  @(posedge write_clock);
  @(posedge read_clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  outstanding_count = 0;
  // Initial state
  assert (!read_valid) else $error("[%t] Read valid is asserted after reset. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after reset. The FIFO should be empty.", $realtime);
  assert (read_empty) else $error("[%t] Empty flag is deasserted after reset. The FIFO should be empty.", $realtime);
  assert (!write_full) else $error("[%t] Full flag is asserted after reset. The FIFO should be empty.", $realtime);
  assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after reset. The FIFO should be empty.", $realtime, write_level);
  assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after reset. The FIFO should be empty.", $realtime, read_level);
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge write_clock);
    write_valid = 1;
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge write_clock);
    assert (write_level == outstanding_count) else $error("[%t] Write level '%0d' is not as expected '%0d'.", $realtime, write_level, outstanding_count);
    data_expected.push_back(write_data);
    outstanding_count++;
    @(negedge write_clock);
    write_valid = 0;
    write_data  = 0;
    if (write_count != DEPTH) begin
      assert (write_ready) else $error("[%t] Write ready is asserted after %0d writes.", $realtime, write_count);
      assert (!write_full) else $error("[%t] Full flag is asserted after %0d writes.", $realtime, write_count);
    end
    repeat (STAGES_READ) @(posedge read_clock); @(negedge read_clock);
    if (write_count != DEPTH) begin
      assert (read_valid) else $error("[%t] Read valid is deasserted after %0d writes.", $realtime, write_count);
      assert (!read_empty) else $error("[%t] Empty flag is asserted after %0d writes.", $realtime, write_count);
    end
  end
  // Final state
  assert (read_valid) else $error("[%t] Read valid is deasserted after writing to full. The FIFO should be full.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is asserted after writing to full. The FIFO should be full.", $realtime);
  assert (!read_empty) else $error("[%t] Empty flag is asserted after writing to full. The FIFO should be full.", $realtime);
  assert (write_full) else $error("[%t] Full flag is deasserted after writing to full. The FIFO should be full.", $realtime);
  assert (write_level == DEPTH) else $error("[%t] Write level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $realtime, write_level, DEPTH);
  assert (read_level  == DEPTH) else $error("[%t] Read level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $realtime, read_level, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 2 : Write miss
  $display("CHECK 2 : Write miss.");
  @(negedge write_clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(negedge write_clock);
  write_valid = 0;
  write_data  = 0;
  assert (read_valid) else $error("[%t] Read valid is asserted after a write while full. The FIFO should be full.", $realtime);
  assert (!write_ready) else $error("[%t] Write ready is deasserted after a write while full. The FIFO should be full.", $realtime);
  assert (!read_empty) else $error("[%t] Empty flag is asserted after a write while full. The FIFO should be full.", $realtime);
  assert (write_full) else $error("[%t] Full flag is deasserted after a write while full. The FIFO should be full.", $realtime);
  assert (write_level == DEPTH) else $error("[%t] Write level '%0d' is not equal to DEPTH='%0d' after a write while full. The FIFO should be full.", $realtime, write_level, DEPTH);
  assert (read_level  == DEPTH) else $error("[%t] Read level '%0d' is not equal to DEPTH='%0d' after a write while full. The FIFO should be full.", $realtime, read_level, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty.");
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge read_clock);
    read_ready = 1;
    @(posedge read_clock);
    if (data_expected.size() != 0) assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
    pop_trash = data_expected.pop_front();
    @(negedge read_clock);
    read_ready = 0;
    if (read_count != DEPTH) begin
      assert (read_valid) else $error("[%t] Read valid is asserted after %0d reads.", $realtime, read_count);
      assert (!read_empty) else $error("[%t] Empty flag is asserted after %0d reads.", $realtime, read_count);
    end
    repeat (STAGES_WRITE) @(posedge write_clock); @(negedge write_clock);
    if (read_count != DEPTH) begin
      assert (write_ready) else $error("[%t] Write ready is deasserted after %0d reads.", $realtime, read_count);
      assert (!write_full) else $error("[%t] Full flag is asserted after %0d reads.", $realtime, read_count);
    end
  end
  // Final state
  assert (!read_valid) else $error("[%t] Read valid is asserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (read_empty) else $error("[%t] Empty flag is deasserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (!write_full) else $error("[%t] Full flag is asserted after reading to empty. The FIFO should be empty.", $realtime);
  assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after reading to empty. The FIFO should be empty.", $realtime, write_level);
  assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after reading to empty. The FIFO should be empty.", $realtime, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 4 : Read error
  $display("CHECK 4 : Read error.");
  // Write
  @(negedge read_clock);
  read_ready = 1;
  @(negedge read_clock);
  read_ready = 0;
  assert (!read_valid) else $error("[%t] Read valid is asserted after a read while empty. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after a read while empty. The FIFO should be empty.", $realtime);
  assert (read_empty) else $error("[%t] Empty flag is deasserted after a read while empty. The FIFO should be empty.", $realtime);
  assert (!write_full) else $error("[%t] Full flag is asserted after a read while empty. The FIFO should be empty.", $realtime);
  assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after a read while empty. The FIFO should be empty.", $realtime, write_level);
  assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after a read while empty. The FIFO should be empty.", $realtime, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 5 : Flushing from write port
  $display("CHECK 5 : Flushing from write port.");
  // Writing once
  @(negedge write_clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(posedge write_clock);
  data_expected.push_back(write_data);
  outstanding_count++;
  @(negedge write_clock);
  write_valid = 0;
  write_data  = 0;
  // Waiting for propagation of the write
  repeat (STAGES_READ) @(posedge read_clock); @(negedge read_clock);
  // Flushing from the write port
  @(negedge write_clock);
  write_flush = 1;
  @(posedge write_clock);
  data_expected = {};
  outstanding_count = 0;
  @(negedge write_clock);
  write_flush = 0;
  // Waiting for propagation of the flush and the pointers
  repeat (2*STAGES_READ) @(posedge read_clock); @(negedge read_clock);
  // Final state
  assert (!read_valid) else $error("[%t] Read valid is asserted after flushing from write port. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after flushing from write port. The FIFO should be empty.", $realtime);
  assert (read_empty) else $error("[%t] Empty flag is deasserted after flushing from write port. The FIFO should be empty.", $realtime);
  assert (!write_full) else $error("[%t] Full flag is asserted after flushing from write port. The FIFO should be empty.", $realtime);
  assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after flushing from write port. The FIFO should be empty.", $realtime, write_level);
  assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after flushing from write port. The FIFO should be empty.", $realtime, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 6 : Flushing from read port
  $display("CHECK 6 : Flushing from read port.");
  // Writing once
  @(negedge write_clock);
  write_valid = 1;
  write_data  = $urandom_range(WIDTH_POW2);
  @(posedge write_clock);
  data_expected.push_back(write_data);
  outstanding_count++;
  @(negedge write_clock);
  write_valid = 0;
  write_data  = 0;
  // Waiting for propagation of the write
  repeat (STAGES_READ) @(posedge read_clock); @(negedge read_clock);
  // Flushing from the read port
  @(negedge read_clock);
  read_flush = 1;
  @(posedge read_clock);
  data_expected = {};
  outstanding_count = 0;
  @(negedge read_clock);
  read_flush = 0;
  // Waiting for propagation of the flush and the pointers
  repeat (2*STAGES_WRITE) @(posedge write_clock); @(negedge write_clock);
  // Final state
  assert (!read_valid) else $error("[%t] Read valid is asserted after flushing from read port. The FIFO should be empty.", $realtime);
  assert (write_ready) else $error("[%t] Write ready is deasserted after flushing from read port. The FIFO should be empty.", $realtime);
  assert (read_empty) else $error("[%t] Empty flag is deasserted after flushing from read port. The FIFO should be empty.", $realtime);
  assert (!write_full) else $error("[%t] Full flag is asserted after flushing from read port. The FIFO should be empty.", $realtime);
  assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after flushing from read port. The FIFO should be empty.", $realtime, write_level);
  assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after flushing from read port. The FIFO should be empty.", $realtime, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Checks 7-9 : Maximal throughput
  for (int check = 7; check <= 9; check++) begin
    case (check)
      7: begin
        $display("CHECK 7 : Maximal throughput with same frequencies.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      8: begin
        $display("CHECK 8 : Maximal throughput with fast write and slow read.");
        WRITE_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      9: begin
        $display("CHECK 9 : Maximal throughput with slow write and fast read.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_FAST_PERIOD;
      end
    endcase

    transfer_count    = 0;
    outstanding_count = 0;
    data_expected     = {};
    timeout_countdown = THROUGHPUT_CHECK_TIMEOUT;
    fork
      // Writing
      begin
        forever begin
          // Stimulus
          @(negedge write_clock);
          if (transfer_count < THROUGHPUT_CHECK_DURATION) begin
            write_valid = 1;
            write_data  = $urandom_range(WIDTH_POW2);
          end else begin
            write_valid = 0;
            write_data  = 0;
          end
          // Check
          @(posedge write_clock);
          if (write_valid && write_ready) begin
            data_expected.push_back(write_data);
            transfer_count++;
            outstanding_count++;
          end
        end
      end
      // Reading
      begin
        forever begin
          // Stimulus
          @(negedge read_clock);
          read_ready = 1;
          // Check
          @(posedge read_clock);
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
      // Stop condition
      begin
        // Transfer count
        while (transfer_count < RANDOM_CHECK_DURATION) begin
          @(negedge write_clock);
        end
        // Let the write propagate
        repeat (DEPTH) @(negedge write_clock);
        repeat (DEPTH) @(negedge read_clock);
        // Read until empty
        while (!read_empty) begin
          @(negedge read_clock);
        end
        // Let the status stabilize
        repeat (DEPTH) @(negedge write_clock);
        repeat (DEPTH) @(negedge read_clock);
      end
      // Timeout
      begin
        while (timeout_countdown > 0) begin
          @(negedge write_clock);
          @(negedge read_clock);
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
    assert (!read_valid) else $error("[%t] Read valid is asserted after the maximal throughput check. The FIFO should be empty.", $realtime);
    assert (write_ready) else $error("[%t] Write ready is deasserted after the maximal throughput check. The FIFO should be empty.", $realtime);
    assert (read_empty) else $error("[%t] Empty flag is deasserted after the maximal throughput check. The FIFO should be empty.", $realtime);
    assert (!write_full) else $error("[%t] Full flag is asserted after the maximal throughput check. The FIFO should be empty.", $realtime);
    assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after the maximal throughput check. The FIFO should be empty.", $realtime, write_level);
    assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after the maximal throughput check. The FIFO should be empty.", $realtime, read_level);

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // Checks 10-12 : Random stimulus
  for (int check = 10; check <= 12; check++) begin
    case (check)
      10: begin
        $display("CHECK 10 : Random stimulus with same frequencies.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      11: begin
        $display("CHECK 11 : Random stimulus with fast write and slow read.");
        WRITE_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      12: begin
        $display("CHECK 12 : Random stimulus with slow write and fast read.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_FAST_PERIOD;
      end
    endcase

    transfer_count    = 0;
    outstanding_count = 0;
    data_expected     = {};
    timeout_countdown = RANDOM_CHECK_TIMEOUT;
    // threshold_change_countdown = RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD;
    fork
      // Writing
      begin
        forever begin
          // Stimulus
          @(negedge write_clock);
          if (!write_full && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
            write_valid = 1;
            write_data  = $urandom_range(WIDTH_POW2);
          end else begin
            write_valid = 0;
            write_data  = 0;
          end
          // Check
          @(posedge write_clock);
          if (write_valid && write_ready) begin
            data_expected.push_back(write_data);
            transfer_count++;
            outstanding_count++;
          end
        end
      end
      // Reading
      begin
        forever begin
          // Stimulus
          @(negedge read_clock);
          if (random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
            read_ready = 1;
          end else begin
            read_ready = 0;
          end
          // Check
          @(posedge read_clock);
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
          @(negedge write_clock);
          if (threshold_change_countdown == 0) begin
            threshold_change_countdown = RANDOM_CHECK_THRESHOLD_CHANGE_PERIOD;
            write_lower_threshold_level = $urandom_range(DEPTH);
            write_upper_threshold_level = $urandom_range(DEPTH);
            @(negedge read_clock);
            read_lower_threshold_level  = $urandom_range(DEPTH);
            read_upper_threshold_level  = $urandom_range(DEPTH);
          end else begin
            threshold_change_countdown--;
          end
        end
      end
      // Write status check
      begin
        forever begin
          @(posedge write_clock);
          // assert (write_level == outstanding_count) else $error("[%t] Write level '%0d' is not as expected '%0d'.", $realtime, write_level, outstanding_count);
          // if (outstanding_count == 0) begin
          //   assert (!write_full) else $error("[%t] Full flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end else if (outstanding_count == DEPTH) begin
          //   assert (write_full) else $error("[%t] Full flag is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end else begin
          //   assert (!write_full) else $error("[%t] Full flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end
          if (write_lower_threshold_status !== write_level <= write_lower_threshold_level) begin
            $error("[%t] Write lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO write level of '%0d'.", $realtime, write_lower_threshold_status, write_lower_threshold_level, write_level);
          end
          if (write_upper_threshold_status !== write_level >= write_upper_threshold_level) begin
            $error("[%t] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $realtime, write_upper_threshold_status, write_upper_threshold_level, write_level);
          end
        end
      end
      // Read status check
      begin
        forever begin
          @(posedge read_clock);
          // assert (read_level == outstanding_count) else $error("[%t] Read level '%0d' is not as expected '%0d'.", $realtime, read_level, outstanding_count);
          // if (outstanding_count == 0) begin
          //   assert (read_empty) else $error("[%t] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end else if (outstanding_count == DEPTH) begin
          //   assert (!read_empty) else $error("[%t] Empty flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end else begin
          //   assert (!read_empty) else $error("[%t] Empty flag is asserted. The FIFO should be have %0d entries in it.", $realtime, outstanding_count);
          // end
          if (read_lower_threshold_status !== read_level <= read_lower_threshold_level) begin
            $error("[%t] Read lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO read level of '%0d'.", $realtime, read_lower_threshold_status, read_lower_threshold_level, read_level);
          end
          if (read_upper_threshold_status !== read_level >= read_upper_threshold_level) begin
            $error("[%t] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $realtime, read_upper_threshold_status, read_upper_threshold_level, read_level);
          end
        end
      end
      // Stop condition
      begin
        // Transfer count
        while (transfer_count < RANDOM_CHECK_DURATION) begin
          @(negedge write_clock);
        end
        // Let any remaining write propagate
        repeat (DEPTH) @(negedge write_clock);
        repeat (DEPTH) @(negedge read_clock);
        // Read until empty
        while (!read_empty) begin
          @(negedge read_clock);
        end
        // Let the status stabilize
        repeat (DEPTH) @(negedge write_clock);
        repeat (DEPTH) @(negedge read_clock);
      end
      // Timeout
      begin
        while (timeout_countdown > 0) begin
          @(negedge write_clock);
          @(negedge read_clock);
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
    assert (!read_valid) else $error("[%t] Read valid is asserted after the random stimulus check. The FIFO should be empty.", $realtime);
    assert (write_ready) else $error("[%t] Write ready is deasserted after the random stimulus check. The FIFO should be empty.", $realtime);
    assert (read_empty) else $error("[%t] Empty flag is deasserted after the random stimulus check. The FIFO should be empty.", $realtime);
    assert (!write_full) else $error("[%t] Full flag is asserted after the random stimulus check. The FIFO should be empty.", $realtime);
    assert (write_level == 0) else $error("[%t] Write level '%0d' is not zero after the random stimulus check. The FIFO should be empty.", $realtime, write_level);
    assert (read_level  == 0) else $error("[%t] Read level '%0d' is not zero after the random stimulus check. The FIFO should be empty.", $realtime, read_level);

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // End of test
  $finish;
end

endmodule
