// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        lifo.testbench.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the LIFO stack.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module lifo__testbench ();

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
logic             write_enable;
logic [WIDTH-1:0] write_data;
logic             full;
logic             read_enable;
logic [WIDTH-1:0] read_data;
logic             empty;

// Test variables
int data_expected[$];
int pop_trash;
int transfer_count;
int outstanding_count;
int timeout_countdown;

// Device under test
lifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) lifo_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .full         ( full         ),
  .empty        ( empty        ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    )
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
  $dumpfile("lifo.testbench.vcd");
  $dumpvars(0,lifo__testbench);

  // Initialization
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  // Initial state
  if (!empty) $error("[%0tns] Empty flag is deasserted after reset. The LIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after reset. The LIFO should be empty.", $time);
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    if (write_count != DEPTH) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d writes.", $time, write_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d writes.", $time, write_count);
    end
  end
  // Final state
  if ( empty) $error("[%0tns] Empty flag is asserted after %0d writes. The LIFO should be full.", $time, DEPTH);
  if (!full ) $error("[%0tns] Full flag is deasserted after %0d writes. The LIFO should be full.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge clock);
    read_enable = 1;
    @(posedge clock);
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[$]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[$]);
    end else begin
      $error("[%0tns] Read enabled while LIFO should be empty.", $time);
    end
    pop_trash = data_expected.pop_back();
    @(negedge clock);
    read_enable = 0;
    if (read_count != DEPTH) begin
      if ( empty) $error("[%0tns] Empty flag is asserted after %0d reads.", $time, read_count);
      if ( full ) $error("[%0tns] Full flag is asserted after %0d reads.", $time, read_count);
    end
  end
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after %0d reads. The LIFO should be empty.", $time, DEPTH);
  if ( full ) $error("[%0tns] Full flag is asserted after %0d reads. The LIFO should be empty.", $time, DEPTH);

  repeat(10) @(posedge clock);

  // Check 3 : Successive read and write when almost empty
  $display("CHECK 3 : Successive read and write when almost empty.");
  // Write one item to make it not empty
  @(negedge clock);
  write_enable = 1;
  write_data   = $urandom_range(WIDTH_POW2);
  @(posedge clock);
  data_expected.push_back(write_data);
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
  // Successive read and write operations
  for (int iteration = 0; iteration < 10; iteration++) begin
    @(negedge clock);
    // Simultaneous read and write
    read_enable  = 1;
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    // Check read data (should be top of stack)
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[$]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[$]);
      pop_trash = data_expected.pop_back();
    end else begin
      $error("[%0tns] Read enabled while LIFO should be empty.", $time);
    end
    // Update stack with new write
    data_expected.push_back(write_data);
    @(negedge clock);
    read_enable  = 0;
    write_enable = 0;
    write_data   = 0;
    // Should have exactly one item
    if ( empty) $error("[%0tns] Empty flag is asserted during almost empty test.", $time);
    if ( full ) $error("[%0tns] Full flag is asserted during almost empty test.", $time);
  end
  // Read the last item
  @(negedge clock);
  read_enable = 1;
  @(posedge clock);
  pop_trash = data_expected.pop_back();
  @(negedge clock);
  read_enable = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Successive read and write when almost full
  $display("CHECK 4 : Successive read and write when almost full.");
  // Fill to almost full (DEPTH-1 items)
  for (int write_count = 1; write_count < DEPTH; write_count++) begin
    @(negedge clock);
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    data_expected.push_back(write_data);
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
  end
  // Successive read and write operations when almost full
  for (int iteration = 0; iteration < 10; iteration++) begin
    @(negedge clock);
    // Simultaneous read and write
    read_enable  = 1;
    write_enable = 1;
    write_data   = $urandom_range(WIDTH_POW2);
    @(posedge clock);
    // Check read data (should be top of stack)
    if (data_expected.size() != 0) begin
      if (read_data !== data_expected[$]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[$]);
      pop_trash = data_expected.pop_back();
    end else begin
      $error("[%0tns] Read enabled while LIFO should be empty.", $time);
    end
    // Update stack with new write
    data_expected.push_back(write_data);
    @(negedge clock);
    read_enable  = 0;
    write_enable = 0;
    write_data   = 0;
    // Should have exactly DEPTH-1 items
    if ( empty) $error("[%0tns] Empty flag is asserted during almost full test.", $time);
    if ( full ) $error("[%0tns] Full flag is asserted during almost full test.", $time);
  end
  // Read all items
  while (data_expected.size() > 0) begin
    @(negedge clock);
    read_enable = 1;
    @(posedge clock);
    pop_trash = data_expected.pop_back();
    @(negedge clock);
    read_enable = 0;
  end

  repeat(10) @(posedge clock);

  // Check 5 : Random stimulus
  $display("CHECK 5 : Random stimulus.");
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
        if (!full && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
          write_enable = 1;
          write_data   = $urandom_range(WIDTH_POW2);
        end else begin
          write_enable = 0;
          write_data   = 0;
        end
        // Check
        @(posedge clock);
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
        @(negedge clock);
        if (!empty && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          read_enable = 1;
        end else begin
          read_enable = 0;
        end
        // Check
        @(posedge clock);
        if (read_enable) begin
          if (data_expected.size() != 0) begin
            // LIFO: read the most recently written data (last item in stack)
            if (read_data !== data_expected[$]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[$]);
            pop_trash = data_expected.pop_back();
            outstanding_count--;
          end else begin
            $error("[%0tns] Read enabled while LIFO should be empty.", $time);
          end
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
        if (outstanding_count == 0) begin
          if (!empty) $error("[%0tns] Empty flag is deasserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
          if ( full ) $error("[%0tns] Full flag is asserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
        end else if (outstanding_count == DEPTH) begin
          if ( empty) $error("[%0tns] Empty flag is asserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
          if (!full ) $error("[%0tns] Full flag is deasserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
        end else begin
          if ( empty) $error("[%0tns] Empty flag is asserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
          if ( full ) $error("[%0tns] Full flag is asserted. The LIFO should have %0d entries in it.", $time, outstanding_count);
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
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 5. The LIFO should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 5. The LIFO should be empty.", $time);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
