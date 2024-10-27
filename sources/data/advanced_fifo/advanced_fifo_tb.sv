// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_fifo_tb.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the advanced FIFO queue.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module advanced_fifo_tb ();

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
logic                clear_flags;
logic                write_enable;
logic    [WIDTH-1:0] write_data;
logic                write_miss;
logic                full;
logic                read_enable;
logic    [WIDTH-1:0] read_data;
logic                read_error;
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
advanced_fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) advanced_fifo_dut (
  .clock                  ( clock                  ),
  .resetn                 ( resetn                 ),
  .clear_flags            ( clear_flags            ),
  .write_enable           ( write_enable           ),
  .write_data             ( write_data             ),
  .write_miss             ( write_miss             ),
  .full                   ( full                   ),
  .read_enable            ( read_enable            ),
  .read_data              ( read_data              ),
  .read_error             ( read_error             ),
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
  $dumpfile("advanced_fifo_tb.vcd");
  $dumpvars(0,advanced_fifo_tb);

  // Initialization
  clear_flags  = 0;
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;
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
  if (!empty) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after reset. The FIFO should be empty.", $time, level);
  // Writing
  for (integer write_count=1 ; write_count<=DEPTH ; write_count++) begin
    @(negedge clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    if (level != outstanding_count) $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
    data_expected.push_back(write_data);
    outstanding_count++;
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    if (write_count != DEPTH) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if ( empty) $error("[%0tns] Empty flag is asserted after writing to full. The FIFO should be full.", $time);
  if (!full ) $error("[%0tns] Full flag is deasserted after writing to full. The FIFO should be full.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' after writing to full. The FIFO should be full.", $time, level, DEPTH);

  repeat(10) @(posedge clock);

  // Check 2 : Write miss
  $display("CHECK 2 : Write miss.");
  // Initial state
  if ( empty     ) $error("[%0tns] Empty flag is asserted before the write miss check. The FIFO should be full.", $time);
  if (!full      ) $error("[%0tns] Full flag is deasserted before the write miss check. The FIFO should be full.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted before the write miss check.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted before the write miss check.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' before the write miss check. The FIFO should be full.", $time, level, DEPTH);
  // Write
  @(negedge clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  if ( empty     ) $error("[%0tns] Empty flag is asserted after a write while full. The FIFO should be full.", $time);
  if (!full      ) $error("[%0tns] Full flag is deasserted after a write while full. The FIFO should be full.", $time);
  if (!write_miss) $error("[%0tns] Write miss flag is deasserted after a write while full.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after a write while full.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' after a write while full. The FIFO should be full.", $time, level, DEPTH);
  // Clear flags
  @(negedge clock);
  clear_flags  = 1;
  @(negedge clock);
  clear_flags  = 0;
  if ( empty     ) $error("[%0tns] Empty flag is asserted after clearing the flags. The FIFO should be full.", $time);
  if (!full      ) $error("[%0tns] Full flag is deasserted after clearing the flags. The FIFO should be full.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after clearing the flags.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after clearing the flags.", $time);
  if (level != DEPTH) $error("[%0tns] Level '%0d' is not equal to DEPTH='%0d' after clearing the flags. The FIFO should be full.", $time, level, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty.");
  // Reading
  for (integer read_count=1 ; read_count<=DEPTH ; read_count++) begin
    @(negedge clock);
    read_enable = 1;
    @(posedge clock);
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    end else begin
      $error("[%0tns] Read enabled while FIFO should be empty.", $time);
    end
    if (level != outstanding_count) $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
    pop_trash = data_expected.pop_front();
    outstanding_count--;
    @(negedge clock);
    read_enable = 0;
    if (read_count != DEPTH) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d reads.", $time, read_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if (!empty) $error("[%0tns] Empty flag is asserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if ( full ) $error("[%0tns] Full flag is deasserted after reading to empty. The FIFO should be empty.", $time, DEPTH);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after reading to empty. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 4 : Read error
  $display("CHECK 4 : Read error.");
  // Initial state
  if (!empty     ) $error("[%0tns] Empty flag is deasserted before the read error check. The FIFO should be empty.", $time);
  if ( full      ) $error("[%0tns] Full flag is asserted before the read error check. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted before the read error check.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted before the read error check.", $time);
  if (level != 0)  $error("[%0tns] Level '%0d' is not zero before the read error check. The FIFO should be empty.", $time, level);
  // Write
  @(negedge clock);
  read_enable = 1;
  @(negedge clock);
  read_enable = 0;
  if (!empty     ) $error("[%0tns] Empty flag is deasserted after a read while empty. The FIFO should be empty.", $time);
  if ( full      ) $error("[%0tns] Full flag is asserted after a read while empty. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after a read while empty.", $time);
  if (!read_error) $error("[%0tns] Read error flag is deasserted after a read while empty.", $time);
  if (level != 0)  $error("[%0tns] Level '%0d' is not zero after a read while empty. The FIFO should be empty.", $time, level);
  // Clear flags
  @(negedge clock);
  clear_flags = 1;
  @(negedge clock);
  clear_flags = 0;
  if (!empty     ) $error("[%0tns] Empty flag is deasserted after clearing the flags. The FIFO should be empty.", $time);
  if ( full      ) $error("[%0tns] Full flag is asserted after clearing the flags. The FIFO should be empty.", $time);
  if ( write_miss) $error("[%0tns] Write miss flag is asserted after clearing the flags.", $time);
  if ( read_error) $error("[%0tns] Read error flag is asserted after clearing the flags.", $time);
  if (level != 0)  $error("[%0tns] Level '%0d' is not zero after clearing the flags. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 5 : Back-to-back transfers for full throughput
  $display("CHECK 5 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_enable = 1;
  write_data   = 0;
  for (integer iteration=0 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    if ( empty) $error("[%0tns] Empty flag is asserted.", $time);
    if ( full ) $error("[%0tns] Full flag is asserted.", $time);
    // Read
    read_enable = 1;
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
    end else begin
      $error("[%0tns] Read enabled while FIFO should be empty.", $time);
    end
    // Increment write data
    write_data = write_data+1;
  end
  write_enable = 0;
  write_data   = 0;
  // Last read
  @(negedge clock);
  read_enable = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 5. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 5. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after check 5. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // Check 6 : Random stimulus
  $display("CHECK 6 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  outstanding_count = 0;
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
            write_enable = 1;
            write_data   = $urandom_range(WIDTH_POW2);
          end else begin
            write_enable = 0;
            write_data   = 0;
          end
        end
        // Check
        @(posedge clock);
        if (write_enable && !full) begin
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
        if (!empty && $random < RANDOM_CHECK_READ_PROBABILITY) begin
          read_enable = 1;
        end else begin
          read_enable = 0;
        end
        // Check
        @(posedge clock);
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
          if (!empty) $error("[%0tns] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( full ) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end else if (outstanding_count == DEPTH) begin
          if ( empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if (!full ) $error("[%0tns] Full flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end else begin
          if ( empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
          if ( full ) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
        end
        if (lower_threshold_status != level <= lower_threshold_level) begin
          $error("[%0tns] Lower threshold flag '%0b' doesn't match given the threshold value of '%0d' and the FIFO level of '%0d'.", $time, lower_threshold_status, lower_threshold_level, level);
        end
        if (upper_threshold_status != level >= upper_threshold_level) begin
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
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 6. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 6. The FIFO should be empty.", $time);
  if (level != 0) $error("[%0tns] Level '%0d' is not zero after check 6. The FIFO should be empty.", $time, level);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
