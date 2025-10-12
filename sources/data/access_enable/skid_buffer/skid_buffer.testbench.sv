// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        skid_buffer.testbench.sv                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the skid buffer.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module skid_buffer__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;

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
int timeout_countdown;

// Device under test
skid_buffer #(
  .WIDTH ( WIDTH )
) skid_buffer_dut (
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
  end else begin
    $error("[%t] Read enabled while buffer should be empty.", $realtime);
  end
  @(negedge clock);
  read_enable = 0;
endtask

// Check flags task
task automatic check_flags;
  input int expected_count;
  if (expected_count == 0) begin
    assert (empty) else $error("[%t] Empty flag is deasserted. The buffer should have %0d entries in it.", $realtime, expected_count);
  end else begin
    assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should have %0d entries in it.", $realtime, expected_count);
  end
  if (expected_count == 2) begin
    assert (full) else $error("[%t] Full flag is deasserted. The buffer should have %0d entries in it.", $realtime, expected_count);
  end else begin
    assert (!full) else $error("[%t] Full flag is asserted. The buffer should have %0d entries in it.", $realtime, expected_count);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("skid_buffer.testbench.vcd");
  $dumpvars(0,skid_buffer__testbench);
  $timeformat(-9, 0, " ns", 0);

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
  assert (empty) else $error("[%t] Empty flag is deasserted after reset with data '%0h'. The buffer should be empty.", $realtime, read_data);
  assert (!full) else $error("[%t] Full flag is asserted after reset. The buffer should be empty.", $realtime);
  // First write
  @(negedge clock); write_enable = 1; write_data = 8'b10101010; data_expected.push_back(write_data);
  @(negedge clock); write_enable = 0; write_data = 0;
  assert (!empty) else $error("[%t] Empty flag is asserted after the first write. The buffer should contain the first transfer.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after the first write. The buffer should still have one free slot.", $realtime);
  // Second write
  @(negedge clock); write_enable = 1; write_data = 8'b01010101; data_expected.push_back(write_data);
  @(negedge clock); write_enable = 0; write_data = 0;
  assert (!empty) else $error("[%t] Empty flag is asserted after the second write. The buffer should contain the first transfer.", $realtime);
  assert (full) else $error("[%t] Full flag is deasserted after the second write. The buffer should be full.", $realtime);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // First read
  @(negedge clock); read_enable = 1;
  if (data_expected.size() != 0) begin
    assert (read_data === data_expected[0]) else $error("[%t] First read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
  end else begin
    $error("[%t] Read enabled while FIFO should be empty.", $realtime);
  end
  @(negedge clock); read_enable = 0; pop_trash = data_expected.pop_front();
  assert (!empty) else $error("[%t] Empty flag is asserted after the first read. The buffer should contain the second transfer.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after the first read. The buffer should have one free slot.", $realtime);
  // Second read
  @(negedge clock); read_enable = 1;
  if (data_expected.size() != 0) begin
    assert (read_data === data_expected[0]) else $error("[%t] Second read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
  end else begin
    $error("[%t] Read enabled while FIFO should be empty.", $realtime);
  end
  @(negedge clock); read_enable = 0; pop_trash = data_expected.pop_front();
  assert (empty) else $error("[%t] Empty flag is deasserted after the second read with data '%0h'. The buffer should be empty.", $realtime, read_data);
  assert (!full) else $error("[%t] Full flag is asserted after the second read. The buffer should be empty.", $realtime);

  repeat(10) @(posedge clock);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_enable = 1;
  write_data   = 0;
  for (int iteration = 1; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
    data_expected.push_back(write_data);
    @(negedge clock);
    assert (!empty) else $error("[%t] Empty flag is asserted. The buffer should be sending transfers.", $realtime);
    assert (!full) else $error("[%t] Full flag is asserted. The buffer should be accepting tranfers.", $realtime);
    // Read when not empty
    if (!empty) begin
      read_enable = 1;
      if (data_expected.size() != 0) begin
        assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
      end else begin
        $error("[%t] Read enabled while FIFO should be empty.", $realtime);
      end
      pop_trash = data_expected.pop_front();
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
  assert (empty) else $error("[%t] Empty flag is deasserted after check 3. The buffer should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after check 3. The buffer should be empty.", $realtime);

  repeat(10) @(posedge clock);

  // Check 4 : Random stimulus
  $display("CHECK 4 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
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
            assert (read_data === data_expected[0]) else $error("[%t] Read data '%0h' is not as expected '%0h'.", $realtime, read_data, data_expected[0]);
            pop_trash = data_expected.pop_front();
          end else begin
            $error("[%t] Read enabled while FIFO should be empty.", $realtime);
          end
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
  // Final state
  assert (empty) else $error("[%t] Empty flag is deasserted after check 4. The buffer should be empty.", $realtime);
  assert (!full) else $error("[%t] Full flag is asserted after check 4. The buffer should be empty.", $realtime);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
