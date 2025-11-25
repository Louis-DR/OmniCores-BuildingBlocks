// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        simple_dual_port_ram.testbench.sv                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the simple dual-port RAM.                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module simple_dual_port_ram__testbench ();

// Device parameters
localparam int  WIDTH         = 8;
localparam int  DEPTH         = 16;
localparam bit  WRITE_THROUGH = 0;
localparam bit  READ_LATENCY  = 1;

// Derived parameters
localparam int  ADDRESS_WIDTH   = $clog2(DEPTH);
localparam int  WIDTH_POW2      = 2**WIDTH;

// Test parameters
localparam real CLOCK_PERIOD              = 10;
localparam int  CONCURRENT_CHECK_DURATION = 1000;
localparam int  CONCURRENT_CHECK_TIMEOUT  = 10000;
localparam int  RANDOM_CHECK_DURATION     = 1000;
localparam int  RANDOM_CHECK_TIMEOUT      = 10000;
localparam real RANDOM_WRITE_PROBABILITY  = 0.5;
localparam real RANDOM_READ_PROBABILITY   = 0.5;

// Device ports
logic                     clock;
logic                     write_enable;
logic [ADDRESS_WIDTH-1:0] write_address;
logic         [WIDTH-1:0] write_data;
logic                     read_enable;
logic [ADDRESS_WIDTH-1:0] read_address;
logic         [WIDTH-1:0] read_data;

// Test variables
int               check;
logic [WIDTH-1:0] memory_model [DEPTH];
logic [WIDTH-1:0] expected_data;
int               transfer_count;
int               timeout_countdown;

// Device under test
simple_dual_port_ram #(
  .WIDTH         ( WIDTH         ),
  .DEPTH         ( DEPTH         ),
  .WRITE_THROUGH ( WRITE_THROUGH ),
  .READ_LATENCY  ( READ_LATENCY  )
) simple_dual_port_ram_dut (
  .clock         ( clock         ),
  .write_enable  ( write_enable  ),
  .write_address ( write_address ),
  .write_data    ( write_data    ),
  .read_enable   ( read_enable   ),
  .read_address  ( read_address  ),
  .read_data     ( read_data     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Write task
task automatic write_once;
  input [ADDRESS_WIDTH-1:0] address;
  input         [WIDTH-1:0] data;
  write_enable  = 1;
  write_address = address;
  write_data    = data;
  @(posedge clock);
  memory_model[address] = data;
  @(negedge clock);
  write_enable = 0;
endtask

// Write all task
task automatic write_all;
  input [WIDTH-1:0] data;
  for (int index = 0; index < DEPTH; index++) begin
    write_once(index, data);
  end
endtask

// Read task
task automatic read_once;
  input [ADDRESS_WIDTH-1:0] address;
  read_enable   = 1;
  read_address  = address;
  if (WRITE_THROUGH) begin
    #(1);
    expected_data = (write_enable && write_address == address) ? write_data : memory_model[address];
  end else begin
    expected_data = memory_model[address];
  end
  if (READ_LATENCY) @(posedge clock);
  #(1);
  assert (read_data === expected_data)
    else $error("[%t] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $realtime, read_data, address, expected_data);
  @(negedge clock);
  read_enable = 0;
endtask

// Read all task
task automatic read_all;
  for (int index = 0; index < DEPTH; index++) begin
    read_once(index);
  end
endtask

// Main block
initial begin
  $dumpfile("simple_dual_port_ram.testbench.vcd");
  $dumpvars(0, simple_dual_port_ram__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  write_enable  =  0;
  write_address = 'x;
  write_data    = 'x;
  read_enable   =  0;
  read_address  = 'x;

  // Check 1 : All zero
  $display("CHECK 1 : All zero."); check = 1;
  @(negedge clock);
  write_all('0);
  read_all();

  repeat(10) @(posedge clock);

  // Check 2 : Address walking ones
  $display("CHECK 2 : Address walking ones."); check = 2;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '1);
    read_all();
    write_once(address_index, '0);
  end

  repeat(10) @(posedge clock);

  // Check 3 : Address walking zeros
  $display("CHECK 3 : Address walking zeros."); check = 3;
  @(negedge clock);
  write_all('1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '0);
    read_all();
    write_once(address_index, '1);
  end

  repeat(10) @(posedge clock);

  // Check 4 : Data walking one
  $display("CHECK 4 : Data walking one."); check = 4;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(address_index, 1 << bit_index);
      read_once(address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 5 : Data walking zero
  $display("CHECK 5 : Data walking zero."); check = 5;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(address_index, ~(1 << bit_index));
      read_once(address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 6 : Concurrent reads and writes
  $display("CHECK 6 : Concurrent reads and writes."); check = 6;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = CONCURRENT_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      while (transfer_count < CONCURRENT_CHECK_DURATION) begin
        write_once($urandom_range(DEPTH), $urandom_range(WIDTH_POW2));
        transfer_count++;
      end
    end
    // Reading
    begin
      while (transfer_count < CONCURRENT_CHECK_DURATION) begin
        read_once($urandom_range(DEPTH));
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

  repeat(10) @(posedge clock);

  // Check 7 : Random stimulus
  $display("CHECK 7 : Random stimulus."); check = 7;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
        if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
          write_enable  = 1;
          write_address = $urandom_range(DEPTH);
          write_data    = $urandom_range(WIDTH_POW2);
          @(posedge clock);
          memory_model[write_address] = write_data;
          transfer_count++;
        end else begin
          write_enable = 0;
          @(posedge clock);
        end
      end
      write_enable = 0;
    end
    // Reading
    begin
      forever begin
        @(negedge clock);
        if (random_boolean(RANDOM_READ_PROBABILITY)) begin
          read_enable   = 1;
          read_address  = $urandom_range(DEPTH);
          expected_data = memory_model[read_address];
          if (WRITE_THROUGH) begin
            #(1);
            expected_data = (write_enable && write_address == read_address) ? write_data : memory_model[read_address];
          end else begin
            expected_data = memory_model[read_address];
          end
          if (READ_LATENCY) @(posedge clock);
          #(1);
          assert (read_data === expected_data)
            else $error("[%t] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $realtime, read_data, read_address, expected_data);
        end else begin
          read_enable = 0;
        end
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

  repeat(10) @(posedge clock);

  $finish;
end

endmodule
