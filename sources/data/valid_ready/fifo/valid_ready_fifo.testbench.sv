// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_fifo.testbench.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the FIFO queue.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module valid_ready_fifo__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;
localparam int  DEPTH        = 4;

// Check parameters
localparam int  THROUGHPUT_CHECK_DURATION      = 100;
localparam int  RANDOM_CHECK_DURATION          = 100;
localparam real RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic             clock;
logic             resetn;
logic [WIDTH-1:0] write_data;
logic             write_valid;
logic             write_ready;
logic             full;
logic [WIDTH-1:0] read_data;
logic             read_valid;
logic             read_ready;
logic             empty;

// Test variables
int data_expected[$];
int pop_trash;
int transfer_count;
int outstanding_count;
int timeout_countdown;

// Device under test
valid_ready_fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) valid_ready_fifo_dut (
  .clock       ( clock       ),
  .resetn      ( resetn      ),
  .full        ( full        ),
  .empty       ( empty       ),
  .write_data  ( write_data  ),
  .write_valid ( write_valid ),
  .write_ready ( write_ready ),
  .read_data   ( read_data   ),
  .read_valid  ( read_valid  ),
  .read_ready  ( read_ready  )
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
  $dumpfile("valid_ready_fifo.testbench.vcd");
  $dumpvars(0,valid_ready_fifo__testbench);

  // Initialization
  write_data  = 0;
  write_valid = 0;
  read_ready  = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  // Initial state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after reset. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after reset. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after reset. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after reset. The FIFO should be empty.", $time);
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge clock);
    write_valid = 1;
    write_data  = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    data_expected.push_back(write_data);
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
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after %0d writes. The FIFO should be full.", $time, DEPTH);
  if ( write_ready) $error("[%0tns] Write ready is asserted after %0d writes. The FIFO should be full.", $time, DEPTH);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after %0d writes. The FIFO should be full.", $time, DEPTH);
  if (!full       ) $error("[%0tns] Full flag is deasserted after %0d writes. The FIFO should be full.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge clock);
    read_ready = 1;
    @(posedge clock);
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
    end else begin
      $error("[%0tns] Read valid while FIFO should be empty.", $time);
    end
    pop_trash = data_expected.pop_front();
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
  if ( read_valid ) $error("[%0tns] Read valid is asserted after %0d reads. The FIFO should be empty.", $time, DEPTH);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after %0d reads. The FIFO should be empty.", $time, DEPTH);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after %0d reads. The FIFO should be empty.", $time, DEPTH);
  if ( full       ) $error("[%0tns] Full flag is asserted after %0d reads. The FIFO should be empty.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_valid = 1;
  write_data  = 0;
  for (int iteration = 0; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
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
    end else begin
      $error("[%0tns] Read valid while FIFO should be empty.", $time);
    end
    pop_trash = data_expected.pop_front();
    // Increment write data
    write_data = write_data+1;
  end
  write_valid = 0;
  write_data  = 0;
  // Last read
  @(negedge clock);
  read_ready = 0;
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 3. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 3. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 3. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 3. The FIFO should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Random stimulus
  $display("CHECK 4 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  outstanding_count = 0;
  data_expected     = {};
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
            if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
            pop_trash = data_expected.pop_front();
            outstanding_count--;
          end else begin
            $error("[%0tns] Read valid while FIFO should be empty.", $time);
          end
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
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
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 4. The FIFO should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 4. The FIFO should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 4. The FIFO should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 4. The FIFO should be empty.", $time);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
