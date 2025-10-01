// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_advanced_fifo.testbench.sv                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the FIFO queue.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module asynchronous_advanced_fifo__testbench ();

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
logic                write_enable;
logic    [WIDTH-1:0] write_data;
logic                write_miss;
logic                write_clear_miss;
logic                write_empty;
logic                write_not_empty;
logic                write_almost_empty;
logic                write_full;
logic                write_not_full;
logic                write_almost_full;
logic [DEPTH_LOG2:0] write_level;
logic [DEPTH_LOG2:0] write_lower_threshold_level;
logic                write_lower_threshold_status;
logic [DEPTH_LOG2:0] write_upper_threshold_level;
logic                write_upper_threshold_status;
logic                read_clock;
logic                read_resetn;
logic                read_flush;
logic                read_enable;
logic    [WIDTH-1:0] read_data;
logic                read_error;
logic                read_clear_error;
logic                read_empty;
logic                read_not_empty;
logic                read_almost_empty;
logic                read_full;
logic                read_not_full;
logic                read_almost_full;
logic [DEPTH_LOG2:0] read_level;
logic [DEPTH_LOG2:0] read_lower_threshold_level;
logic                read_lower_threshold_status;
logic [DEPTH_LOG2:0] read_upper_threshold_level;
logic                read_upper_threshold_status;

// Test variables
int check;
int data_expected[$];
int pop_trash;
int transfer_count;
int outstanding_count;
int timeout_countdown;
int threshold_change_countdown;

// Device under test
asynchronous_advanced_fifo #(
  .WIDTH        ( WIDTH        ),
  .DEPTH        ( DEPTH        ),
  .STAGES_WRITE ( STAGES_WRITE ),
  .STAGES_READ  ( STAGES_READ  )
) asynchronous_advanced_fifo_dut (
  .write_clock                  ( write_clock                  ),
  .write_resetn                 ( write_resetn                 ),
  .write_flush                  ( write_flush                  ),
  .write_enable                 ( write_enable                 ),
  .write_data                   ( write_data                   ),
  .write_miss                   ( write_miss                   ),
  .write_clear_miss             ( write_clear_miss             ),
  .write_empty                  ( write_empty                  ),
  .write_not_empty              ( write_not_empty              ),
  .write_almost_empty           ( write_almost_empty           ),
  .write_full                   ( write_full                   ),
  .write_not_full               ( write_not_full               ),
  .write_almost_full            ( write_almost_full            ),
  .write_level                  ( write_level                  ),
  .write_lower_threshold_level  ( write_lower_threshold_level  ),
  .write_lower_threshold_status ( write_lower_threshold_status ),
  .write_upper_threshold_level  ( write_upper_threshold_level  ),
  .write_upper_threshold_status ( write_upper_threshold_status ),
  .read_clock                   ( read_clock                   ),
  .read_resetn                  ( read_resetn                  ),
  .read_flush                   ( read_flush                   ),
  .read_enable                  ( read_enable                  ),
  .read_data                    ( read_data                    ),
  .read_error                   ( read_error                   ),
  .read_clear_error             ( read_clear_error             ),
  .read_empty                   ( read_empty                   ),
  .read_not_empty               ( read_not_empty               ),
  .read_almost_empty            ( read_almost_empty            ),
  .read_full                    ( read_full                    ),
  .read_not_full                ( read_not_full                ),
  .read_almost_full             ( read_almost_full             ),
  .read_level                   ( read_level                   ),
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

// Main block
initial begin
  // Log waves
  $dumpfile("asynchronous_advanced_fifo.testbench.vcd");
  $dumpvars(0,asynchronous_advanced_fifo__testbench);

  // Initialization
  write_data       = 0;
  write_enable     = 0;
  read_enable      = 0;
  write_flush      = 0;
  read_flush       = 0;
  write_clear_miss = 0;
  read_clear_error = 0;
  write_lower_threshold_level = 0;
  write_upper_threshold_level = DEPTH;
  read_lower_threshold_level  = 0;
  read_upper_threshold_level  = DEPTH;

  // Reset
  @(posedge write_clock);
  @(posedge read_clock);
  write_resetn = 0;
  read_resetn  = 0;
  @(posedge write_clock);
  @(posedge read_clock);
  write_resetn = 1;
  read_resetn  = 1;
  repeat (5) @(posedge write_clock);
  repeat (5) @(posedge read_clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full."); check = 1;
  outstanding_count = 0;
  // Initial state
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after reset. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after reset. The FIFO should be empty.", $time, read_level);
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge write_clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge write_clock);
    if (write_level != outstanding_count) $error("[%0tns] Write level '%0d' is not as expected '%0d'.", $time, write_level, outstanding_count);
    data_expected.push_back(write_data);
    outstanding_count++;
    @(negedge write_clock);
    write_enable = 0;
    write_data   = 0;
    if (write_count != DEPTH) begin
      if ( write_full) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
    repeat (STAGES_READ) @(posedge read_clock); @(negedge read_clock);
    if (write_count != DEPTH) begin
      if ( read_empty) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if ( read_empty) $error("[%0tns] Empty flag is asserted after writing to full. The FIFO should be full.", $time);
  if (!write_full) $error("[%0tns] Full flag is deasserted after writing to full. The FIFO should be full.", $time);
  if (write_level != DEPTH) $error("[%0tns] Write level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $time, write_level, DEPTH);
  if (read_level  != DEPTH) $error("[%0tns] Read level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $time, read_level, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 2 : Write miss
  $display("CHECK 2 : Write miss."); check = 2;
  // Initial state
  if ( read_empty) $error("[%0tns] Empty flag is asserted before the write miss check. The FIFO should be full.", $time);
  if (!write_full) $error("[%0tns] Full flag is deasserted before the write miss check. The FIFO should be full.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted before the write miss check.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted before the write miss check.", $time);
  if (write_level != DEPTH) $error("[%0tns] Write level '%0d' is not equal to DEPTH='%0d' before the write miss check. The FIFO should be full.", $time, write_level, DEPTH);
  if (read_level  != DEPTH) $error("[%0tns] Read level '%0d' is not equal to DEPTH='%0d' before the write miss check. The FIFO should be full.", $time, read_level, DEPTH);
  // Write
  @(negedge write_clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(negedge write_clock);
  write_enable = 0;
  write_data   = 0;
  if ( read_empty) $error("[%0tns] Empty flag is asserted after a write while full. The FIFO should be full.", $time);
  if (!write_full) $error("[%0tns] Full flag is deasserted after a write while full. The FIFO should be full.", $time);
  if (!write_miss) $error("[%0tns] Write miss flag is deasserted after a write while full.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after a write while full.", $time);
  if (write_level != DEPTH) $error("[%0tns] Write level '%0d' is not equal to DEPTH='%0d' after a write while full. The FIFO should be full.", $time, write_level, DEPTH);
  if (read_level  != DEPTH) $error("[%0tns] Read level '%0d' is not equal to DEPTH='%0d' after a write while full. The FIFO should be full.", $time, read_level, DEPTH);
  // Clear flags
  @(negedge write_clock);
  write_clear_miss = 1;
  @(negedge write_clock);
  write_clear_miss = 0;
  if ( read_empty) $error("[%0tns] Empty flag is asserted after clearing the flags. The FIFO should be full.", $time);
  if (!write_full) $error("[%0tns] Full flag is deasserted after clearing the flags. The FIFO should be full.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after clearing the flags.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after clearing the flags.", $time);
  if (write_level != DEPTH) $error("[%0tns] Write level '%0d' is not equal to DEPTH='%0d' after clearing the flags. The FIFO should be full.", $time, write_level, DEPTH);
  if (read_level  != DEPTH) $error("[%0tns] Read level '%0d' is not equal to DEPTH='%0d' after clearing the flags. The FIFO should be full.", $time, read_level, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty."); check = 3;
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge read_clock);
    read_enable = 1;
    @(posedge read_clock);
    if (data_expected.size() != 0) if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    pop_trash = data_expected.pop_front();
    @(negedge read_clock);
    read_enable = 0;
    if (read_count != DEPTH) begin
      if ( read_empty) $error("[%0tns] Empty flag is asserted after %0d reads.", $time, read_count);
    end
    repeat (STAGES_WRITE) @(posedge write_clock); @(negedge write_clock);
    if (read_count != DEPTH) begin
      if ( write_full) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if ( write_full) $error("[%0tns] Full flag is asserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after reading to empty. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after reading to empty. The FIFO should be empty.", $time, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 4 : Read error
  $display("CHECK 4 : Read error."); check = 4;
  // Initial state
  if (!read_empty) $error("[%0tns] Empty flag is deasserted before the read error check. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted before the read error check. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted before the read error check.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted before the read error check.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero before the read error check. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero before the read error check. The FIFO should be empty.", $time, read_level);
  // Read
  @(negedge read_clock);
  read_enable = 1;
  @(negedge read_clock);
  read_enable = 0;
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after a read while empty. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after a read while empty. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after a read while empty.", $time);
  if (!read_error) $error("[%0tns] Read error flag is deasserted after a read while empty.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after a read while empty. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after a read while empty. The FIFO should be empty.", $time, read_level);
  // Clear flags
  @(negedge read_clock);
  read_clear_error = 1;
  @(negedge read_clock);
  read_clear_error = 0;
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after clearing the flags. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after clearing the flags. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after clearing the flags.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after clearing the flags.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after clearing the flags. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after clearing the flags. The FIFO should be empty.", $time, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 5 : Flushing from write port
  $display("CHECK 5 : Flushing from write port."); check = 5;
  // Writing once
  @(negedge write_clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge write_clock);
  data_expected.push_back(write_data);
  outstanding_count++;
  @(negedge write_clock);
  write_enable = 0;
  write_data   = 0;
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
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after flushing from write port. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after flushing from write port. The FIFO should be empty.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after flushing from write port. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after flushing from write port. The FIFO should be empty.", $time, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 6 : Flushing from read port
  $display("CHECK 6 : Flushing from read port."); check = 6;
  // Writing once
  @(negedge write_clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge write_clock);
  data_expected.push_back(write_data);
  outstanding_count++;
  @(negedge write_clock);
  write_enable = 0;
  write_data   = 0;
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
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after flushing from read port. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after flushing from read port. The FIFO should be empty.", $time);
  if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after flushing from read port. The FIFO should be empty.", $time, write_level);
  if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after flushing from read port. The FIFO should be empty.", $time, read_level);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Checks 7-9 : Maximal throughput
  for (check = 7; check <= 9; check++) begin
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
          if (!write_full && transfer_count < THROUGHPUT_CHECK_DURATION) begin
            write_enable = 1;
            write_data   = $urandom_range(WIDTH_POW2);
          end else begin
            write_enable = 0;
            write_data   = 0;
          end
          // Check
          @(posedge write_clock);
          if (write_enable) begin
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
          if (!read_empty) begin
            read_enable = 1;
          end else begin
            read_enable = 0;
          end
          // Check
          @(posedge read_clock);
          if (read_enable) begin
            if (data_expected.size() != 0) begin
              if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
              pop_trash = data_expected.pop_front();
              outstanding_count--;
            end else begin
              $error("[%0tns] Read enabled while FIFO should be empty.", $time);
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
        $error("[%0tns] Timeout.", $time);
      end
    join_any
    disable fork;
    // Final state
    if (!read_empty) $error("[%0tns] Empty flag is deasserted after the maximal throughput check. The FIFO should be empty.", $time);
    if ( write_full) $error("[%0tns] Full flag is asserted after the maximal throughput check. The FIFO should be empty.", $time);
    if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after the maximal throughput check. The FIFO should be empty.", $time, write_level);
    if (read_level  != 0) $error("[%0tns] Read level '%0d' is not zero after the maximal throughput check. The FIFO should be empty.", $time, read_level);

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // Checks 10-12 : Random stimulus
  for (check = 10; check <= 12; check++) begin
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
            write_enable = 1;
            write_data   = $urandom_range(WIDTH_POW2);
          end else begin
            write_enable = 0;
            write_data   = 0;
          end
          // Check
          @(posedge write_clock);
          if (write_enable) begin
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
          if (!read_empty && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
            read_enable = 1;
          end else begin
            read_enable = 0;
          end
          // Check
          @(posedge read_clock);
          if (read_enable) begin
            if (data_expected.size() != 0) begin
              if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
              pop_trash = data_expected.pop_front();
              outstanding_count--;
            end else begin
              $error("[%0tns] Read enabled while FIFO should be empty.", $time);
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
          @(negedge write_clock); #1;
          // if (write_level != outstanding_count) $error("[%0tns] Write level '%0d' is not as expected '%0d'.", $time, write_level, outstanding_count);
          // if (outstanding_count == 0) begin
          //   if ( write_full) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end else if (outstanding_count == DEPTH) begin
          //   if (!write_full) $error("[%0tns] Full flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end else begin
          //   if ( write_full) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end
          if (write_lower_threshold_status !== write_level <= write_lower_threshold_level) begin
            $error("[%0tns] Write lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO write level of '%0d'.", $time, write_lower_threshold_status, write_lower_threshold_level, write_level);
          end
          if (write_upper_threshold_status !== write_level >= write_upper_threshold_level) begin
            $error("[%0tns] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $time, write_upper_threshold_status, write_upper_threshold_level, write_level);
          end
        end
      end
      // Read status check
      begin
        forever begin
          @(negedge read_clock); #1;
          // if (read_level != outstanding_count) $error("[%0tns] Read level '%0d' is not as expected '%0d'.", $time, read_level, outstanding_count);
          // if (outstanding_count == 0) begin
          //   if (!read_empty) $error("[%0tns] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end else if (outstanding_count == DEPTH) begin
          //   if ( read_empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end else begin
          //   if ( read_empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          // end
          if (read_lower_threshold_status !== read_level <= read_lower_threshold_level) begin
            $error("[%0tns] Read lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO read level of '%0d'.", $time, read_lower_threshold_status, read_lower_threshold_level, read_level);
          end
          if (read_upper_threshold_status !== read_level >= read_upper_threshold_level) begin
            $error("[%0tns] Upper threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $time, read_upper_threshold_status, read_upper_threshold_level, read_level);
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
        $error("[%0tns] Timeout.", $time);
      end
    join_any
    disable fork;
    // Final state
    if (!read_empty) $error("[%0tns] Empty flag is deasserted after the random stimulus check. The FIFO should be empty.", $time);
    if ( write_full) $error("[%0tns] Full flag is asserted after the random stimulus check. The FIFO should be empty.", $time);
    if (write_level != 0) $error("[%0tns] Write level '%0d' is not zero after the random stimulus check. The FIFO should be empty.", $time, write_level);
    if (read_level != 0) $error("[%0tns] Read level '%0d' is not zero after the random stimulus check. The FIFO should be empty.", $time, read_level);

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // End of test
  $finish;
end

endmodule
