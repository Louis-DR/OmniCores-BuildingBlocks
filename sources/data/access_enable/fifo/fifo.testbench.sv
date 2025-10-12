// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo.testbench.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the FIFO queue.                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module fifo__testbench ();

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
fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) fifo_dut (
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

// Write task
task automatic write;
  input logic [WIDTH-1:0] data;
  write_enable = 1;
  write_data   = data;
  @(posedge clock);
  data_expected.push_back(data);
  outstanding_count++;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
endtask

// Read task
task automatic read;
  read_enable = 1;
  @(posedge clock);
  if (data_expected.size() != 0) begin
    assert (read_data === data_expected[0])
      else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
    pop_trash = data_expected.pop_front();
    outstanding_count--;
  end else begin
    $error("[%t] Read enabled while FIFO should be empty.", $realtime);
  end
  @(negedge clock);
  read_enable = 0;
endtask

// Check flags task
task automatic check_flags;
  if (outstanding_count == 0) begin
    assert ( empty) else $error("[%t] Empty flag is deasserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert (!full)  else $error("[%t] Full flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end else if (outstanding_count == DEPTH) begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert ( full)  else $error("[%t] Full flag is deasserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end else begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
    assert (!full)  else $error("[%t] Full flag is asserted. The FIFO should have %0d entries in it.", $realtime, outstanding_count);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("fifo.testbench.vcd");
  $dumpvars(0,fifo__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  write_data        = 0;
  write_enable      = 0;
  read_enable       = 0;
  outstanding_count = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  // Initial state
  check_flags();
  // Writing
  for (int write_count = 1; write_count <= DEPTH; write_count++) begin
    @(negedge clock);
    write($urandom_range(WIDTH_POW2));
  end
  // Final state
  check_flags();

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Reading
  for (int read_count = 1; read_count <= DEPTH; read_count++) begin
    @(negedge clock);
    read();
  end
  // Final state
  check_flags();

  repeat(10) @(posedge clock);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  // First write
  @(negedge clock);
  write(0);
  // Simultaneous write and read
  for (int iteration = 1; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    write_enable = 1;
    write_data   = iteration;
    read_enable  = 1;
    @(posedge clock);
    // Check read
    if (data_expected.size() != 0) begin
      assert (read_data === data_expected[0])
        else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
      pop_trash = data_expected.pop_front();
    end else begin
      $error("[%t] Read enabled while FIFO should be empty.", $realtime);
    end
    // Update model for write
    data_expected.push_back(write_data);
    @(negedge clock);
    write_enable = 0;
    write_data   = 0;
    read_enable  = 0;
  end
  // Last read
  @(negedge clock);
  read();
  // Final state
  check_flags();

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
        @(negedge clock);
        if (!full && random_boolean(RANDOM_CHECK_WRITE_PROBABILITY) && transfer_count < RANDOM_CHECK_DURATION) begin
          write($urandom_range(WIDTH_POW2));
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        @(negedge clock);
        if (!empty && random_boolean(RANDOM_CHECK_READ_PROBABILITY)) begin
          read();
        end
      end
    end
    // Status check
    begin
      forever begin
        @(negedge clock);
        check_flags();
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
  // Final state
  check_flags();

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
