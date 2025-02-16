// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_fifo_tb.sv                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the FIFO queue.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module asynchronous_fifo_tb ();

// Test parameters
localparam real    CLOCK_SLOW_PERIOD = 10;
localparam real    CLOCK_FAST_PERIOD = CLOCK_SLOW_PERIOD/3.14159265359;
localparam real    CLOCK_PHASE_SHIFT = CLOCK_FAST_PERIOD*3/2;
localparam integer WIDTH             = 8;
localparam integer WIDTH_POW2        = 2**WIDTH;
localparam integer DEPTH             = 4;
localparam integer STAGES            = 2;

// Check parameters
localparam integer THROUGHPUT_CHECK_DURATION      = 100;
localparam integer THROUGHPUT_CHECK_TIMEOUT       = 1000;
localparam integer RANDOM_CHECK_DURATION          = 100;
localparam integer RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam integer RANDOM_CHECK_TIMEOUT           = 1000;

// Variable frequency test clocks
real WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
real READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;

// Device ports
logic             write_clock;
logic             write_resetn;
logic             write_enable;
logic [WIDTH-1:0] write_data;
logic             write_full;
logic             read_clock;
logic             read_resetn;
logic             read_enable;
logic [WIDTH-1:0] read_data;
logic             read_empty;

// Test variables
integer data_expected[$];
integer pop_trash;
integer transfer_count;
integer outstanding_count;
integer timeout_countdown;

// Device under test
asynchronous_fifo #(
  .WIDTH  ( WIDTH  ),
  .DEPTH  ( DEPTH  ),
  .STAGES ( STAGES )
) asynchronous_fifo_dut (
  .write_clock  ( write_clock  ),
  .write_resetn ( write_resetn ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .write_full   ( write_full   ),
  .read_clock   ( read_clock   ),
  .read_resetn  ( read_resetn  ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .read_empty   ( read_empty   )
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
  $dumpfile("asynchronous_fifo_tb.vcd");
  $dumpvars(0,asynchronous_fifo_tb);

  // Initialization
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;

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
  // Initial state
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( write_full) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  // Writing
  for (integer write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge write_clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge write_clock);
    data_expected.push_back(write_data);
    @(negedge write_clock);
    write_enable = 0;
    write_data   = 0;
    if (write_count != DEPTH) begin
      if ( write_full) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
    repeat(STAGES) @(posedge read_clock); @(negedge read_clock);
    if (write_count != DEPTH) begin
      if ( read_empty) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if ( read_empty) $error("[%0tns] Empty flag is asserted after %0d writes. The FIFO should be full.", $time, DEPTH);
  if (!write_full) $error("[%0tns] Full flag is deasserted after %0d writes. The FIFO should be full.", $time, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Reading
  for (integer read_count = 1; read_count <= DEPTH; read_count++) begin
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
    repeat(STAGES) @(posedge write_clock); @(negedge write_clock);
    if (read_count != DEPTH) begin
      if ( write_full) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if (!read_empty) $error("[%0tns] Empty flag is deasserted after %0d reads. The FIFO should be empty.", $time, DEPTH);
  if ( write_full) $error("[%0tns] Full flag is asserted after %0d reads. The FIFO should be empty.", $time, DEPTH);

  repeat(5) @(posedge write_clock);
  repeat(5) @(posedge read_clock);

  // Checks 3-5 : Maximal throughput
  for (integer check = 3; check <= 5; check++) begin
    case (check)
      3: begin
        $display("CHECK 3 : Maximal throughput with same frequencies.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      4: begin
        $display("CHECK 4 : Maximal throughput with fast write and slow read.");
        WRITE_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      5: begin
        $display("CHECK 5 : Maximal throughput with slow write and fast read.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_FAST_PERIOD;
      end
    endcase

    transfer_count    = 0;
    outstanding_count = 0;
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
        repeat(DEPTH) @(negedge write_clock);
        repeat(DEPTH) @(negedge read_clock);
        // Read until empty
        while (!read_empty) begin
          @(negedge read_clock);
        end
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

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // Checks 6-8 : Random stimulus
  for (integer check = 6; check <= 8; check++) begin
    case (check)
      6: begin
        $display("CHECK 6 : Random stimulus with same frequencies.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      7: begin
        $display("CHECK 7 : Random stimulus with fast write and slow read.");
        WRITE_CLOCK_PERIOD = CLOCK_FAST_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_SLOW_PERIOD;
      end
      8: begin
        $display("CHECK 8 : Random stimulus with slow write and fast read.");
        WRITE_CLOCK_PERIOD = CLOCK_SLOW_PERIOD;
        READ_CLOCK_PERIOD  = CLOCK_FAST_PERIOD;
      end
    endcase

    transfer_count    = 0;
    outstanding_count = 0;
    timeout_countdown = RANDOM_CHECK_TIMEOUT;
    fork
      // Writing
      begin
        forever begin
          // Stimulus
          @(negedge write_clock);
          if (!write_full && $random < RANDOM_CHECK_WRITE_PROBABILITY && transfer_count < RANDOM_CHECK_DURATION) begin
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
          if (!read_empty && $random < RANDOM_CHECK_READ_PROBABILITY) begin
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
      // // Write status check
      // begin
      //   forever begin
      //     @(negedge write_clock);
      //     if (outstanding_count == 0) begin
      //       if ( write_full) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end else if (outstanding_count == DEPTH) begin
      //       if (!write_full) $error("[%0tns] Full flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end else begin
      //       if ( write_full) $error("[%0tns] Full flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end
      //   end
      // end
      // // Read status check
      // begin
      //   forever begin
      //     @(negedge read_clock);
      //     if (outstanding_count == 0) begin
      //       if (!read_empty) $error("[%0tns] Empty flag is deasserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end else if (outstanding_count == DEPTH) begin
      //       if ( read_empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end else begin
      //       if ( read_empty) $error("[%0tns] Empty flag is asserted. The FIFO should be have %0d entries in it.", $time, outstanding_count);
      //     end
      //   end
      // end
      // Stop condition
      begin
        // Transfer count
        while (transfer_count < RANDOM_CHECK_DURATION) begin
          @(negedge write_clock);
        end
        // Read until empty
        while (!read_empty) begin
          @(negedge read_clock);
        end
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

    repeat(5) @(posedge write_clock);
    repeat(5) @(posedge read_clock);

  end

  // End of test
  $finish;
end

endmodule
