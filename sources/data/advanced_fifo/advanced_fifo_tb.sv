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
logic                write_enable;
logic    [WIDTH-1:0] write_data;
logic                full;
logic                read_enable;
logic    [WIDTH-1:0] read_data;
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
  .write_enable           ( write_enable           ),
  .write_data             ( write_data             ),
  .full                   ( full                   ),
  .read_enable            ( read_enable            ),
  .read_data              ( read_data              ),
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
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;
  lower_threshold_level = 0;
  upper_threshold_level = DEPTH;

  // Reset
  resetn = 0;
  #(CLOCK_PERIOD);
  resetn = 1;
  #(CLOCK_PERIOD);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  outstanding_count = 0;
  // Initial state
  if (!empty) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  // Writing
  for (integer write_count=0 ; write_count<DEPTH ; write_count++) begin
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
    if (write_count != DEPTH-1) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if ( empty) $error("[%0tns] Empty flag is asserted after %0d writes. The FIFO should be full.", $time, DEPTH);
  if (!full ) $error("[%0tns] Full flag is deasserted after %0d writes. The FIFO should be full.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Reading
  for (integer read_count=0 ; read_count<DEPTH ; read_count++) begin
    @(negedge clock);
    read_enable = 1;
    @(posedge clock);
    if (read_data != data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    if (level != outstanding_count)    $error("[%0tns] Level '%0d' is not as expected '%0d'.", $time, level, outstanding_count);
    pop_trash = data_expected.pop_front();
    outstanding_count--;
    @(negedge clock);
    read_enable = 0;
    if (read_count != DEPTH-1) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d reads.", $time, read_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if (!empty) $error("[%0tns] Empty flag is asserted after %0d reads. The FIFO should be empty.", $time, DEPTH);
  if ( full ) $error("[%0tns] Full flag is deasserted after %0d reads. The FIFO should be empty.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_enable = 1;
  write_data   = 0;
  for (integer iteration=1 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    if ( empty) $error("[%0tns] Empty flag is asserted.", $time);
    if ( full ) $error("[%0tns] Full flag is asserted.", $time);
    // Read
    read_enable = 1;
    if (read_data != data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    pop_trash = data_expected.pop_front();
    // Increment write data
    write_data = write_data+1;
  end
  write_enable = 0;
  write_data   = 0;
  // Last read
  @(negedge clock);
  read_enable = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 3. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 3. The FIFO should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Random stimulus
  $display("CHECK 4 : Random stimulus.");
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
          if (read_data != data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
          pop_trash = data_expected.pop_front();
          outstanding_count--;
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
    end
  join_any
  disable fork;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 4. The FIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 4. The FIFO should be empty.", $time);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
