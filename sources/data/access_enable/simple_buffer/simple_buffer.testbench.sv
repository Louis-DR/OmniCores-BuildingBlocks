// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        simple_buffer.testbench.sv                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the simple buffer.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"



module simple_buffer__testbench ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam int  WIDTH        = 8;
localparam int  WIDTH_POW2   = 2**WIDTH;

// Check parameters
localparam int  THROUGHPUT_CHECK_DURATION          = 100;
localparam int  RANDOM_CHECK_DURATION              = 100;
localparam real RANDOM_CHECK_INJECTION_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_RECEPTION_PROBABILITY = 0.5;
localparam int  RANDOM_CHECK_TIMEOUT               = 1000;

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
int data_expected;
int transfer_count;
int timeout_countdown;

// Device under test
simple_buffer #(
  .WIDTH ( WIDTH )
) simple_buffer_dut (
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
  data_expected = data;
  @(negedge clock);
  write_enable = 0;
  write_data   = 0;
endtask

// Read task
task automatic read;
  read_enable = 1;
  if (read_data !== data_expected) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
  @(posedge clock);
  data_expected = 'x;
  @(negedge clock);
  read_enable = 0;
endtask

// Check flags task
task automatic check_flags;
  input logic expected_empty;
  input logic expected_full;
  if (empty !== expected_empty) begin
    if (expected_empty) $error("[%0tns] Empty flag is deasserted. The buffer should be empty.", $time);
    else $error("[%0tns] Empty flag is asserted. The buffer should be full.", $time);
  end
  if (full !== expected_full) begin
    if (expected_full) $error("[%0tns] Full flag is deasserted. The buffer should be full.", $time);
    else $error("[%0tns] Full flag is asserted. The buffer should be empty.", $time);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("simple_buffer.testbench.vcd");
  $dumpvars(0,simple_buffer__testbench);

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
  check_flags(1, 0);
  // Write
  @(negedge clock);
  write(8'b10101010);
  check_flags(0, 1);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // Read
  @(negedge clock);
  read();
  check_flags(1, 0);

  repeat(10) @(posedge clock);

  // Check 3 : Successive transfers
  $display("CHECK 3 : Successive transfers.");
  for (int iteration = 0; iteration < THROUGHPUT_CHECK_DURATION; iteration++) begin
    @(negedge clock);
    check_flags(1, 0);
    write(iteration);
    @(negedge clock);
    check_flags(0, 1);
    read();
  end
  // Final state
  check_flags(1, 0);

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
        @(negedge clock);
        if (!full && random_boolean(RANDOM_CHECK_INJECTION_PROBABILITY)) begin
          write($urandom_range(WIDTH_POW2));
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        @(negedge clock);
        if (!empty && random_boolean(RANDOM_CHECK_RECEPTION_PROBABILITY)) begin
          read();
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
  check_flags(1, 0);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
