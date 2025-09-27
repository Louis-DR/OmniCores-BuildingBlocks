// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_simple_dual_port_ram.testbench.sv               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the asynchronous simple dual-port RAM.         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "random.svh"
`include "boolean.svh"



module asynchronous_simple_dual_port_ram__testbench ();

// Device parameters
localparam int  WIDTH           = 8;
localparam int  DEPTH           = 16;
localparam bit  REGISTERED_READ = 1;

// Derived parameters
localparam int  ADDRESS_WIDTH   = $clog2(DEPTH);
localparam int  WIDTH_POW2      = 2**WIDTH;

// Test parameters
localparam real WRITE_CLOCK_PERIOD        = 10;
localparam real READ_CLOCK_PERIOD         = WRITE_CLOCK_PERIOD / 3.14159265359;
localparam int  CONCURRENT_CHECK_DURATION = 1000;
localparam int  CONCURRENT_CHECK_TIMEOUT  = 10000;
localparam int  RANDOM_CHECK_DURATION     = 1000;
localparam int  RANDOM_CHECK_TIMEOUT      = 10000;
localparam real RANDOM_WRITE_PROBABILITY  = 0.5;
localparam real RANDOM_READ_PROBABILITY   = 0.5;

// Device ports
logic                     write_clock;
logic                     read_clock;
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

// Write task
task automatic write_once;
  input [ADDRESS_WIDTH-1:0] address;
  input         [WIDTH-1:0] data;
  write_enable  = 1;
  write_address = address;
  write_data    = data;
  @(posedge write_clock);
  // $display("[%0tns] Write data '0x%0h' at address '0x%0h'.", $time, data, address);
  memory_model[address] = data;
  @(negedge write_clock);
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
  if (REGISTERED_READ) @(posedge read_clock);
  expected_data = memory_model[address];
  #(1fs);
  assert (read_data === expected_data)
    else $error("[%0tns] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, read_data, address, expected_data);
  @(negedge read_clock);
  read_enable = 0;
endtask

// Read all task
task automatic read_all;
  for (int index = 0; index < DEPTH; index++) begin
    read_once(index);
  end
endtask

// Device under test
asynchronous_simple_dual_port_ram #(
  .WIDTH           ( WIDTH           ),
  .DEPTH           ( DEPTH           ),
  .REGISTERED_READ ( REGISTERED_READ )
) asynchronous_simple_dual_port_ram_dut (
  .write_clock   ( write_clock   ),
  .write_enable  ( write_enable  ),
  .write_address ( write_address ),
  .write_data    ( write_data    ),
  .read_clock    ( read_clock    ),
  .read_enable   ( read_enable   ),
  .read_address  ( read_address  ),
  .read_data     ( read_data     )
);

// Clock generators
initial begin
  write_clock = 1;
  forever #(WRITE_CLOCK_PERIOD/2) write_clock = ~write_clock;
end

initial begin
  read_clock = 1;
  forever #(READ_CLOCK_PERIOD/2) read_clock = ~read_clock;
end

// Main block
initial begin
  $dumpfile("asynchronous_simple_dual_port_ram.testbench.vcd");
  $dumpvars(0, asynchronous_simple_dual_port_ram__testbench);

  // Initialization
  write_enable  =  0;
  write_address = 'x;
  write_data    = 'x;
  read_enable   =  0;
  read_address  = 'x;

  // Wait for clocks to stabilize
  repeat(5) @(posedge write_clock);

  // Check 1 : All zero
  $display("CHECK 1 : All zero."); check = 1;
  write_all('0);
  read_all();

  repeat(10) @(posedge write_clock);

  // Check 2 : Address walking ones
  $display("CHECK 2 : Address walking ones."); check = 2;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '1);
    read_all();
    write_once(address_index, '0);
  end

  repeat(10) @(posedge write_clock);

  // Check 3 : Address walking zeros
  $display("CHECK 3 : Address walking zeros."); check = 3;
  write_all('1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '0);
    read_all();
    write_once(address_index, '1);
  end

  repeat(10) @(posedge write_clock);

  // Check 4 : Data walking one
  $display("CHECK 4 : Data walking one."); check = 4;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(address_index, 1 << bit_index);
      read_once(address_index);
    end
  end

  repeat(10) @(posedge write_clock);

  // Check 5 : Data walking zero
  $display("CHECK 5 : Data walking zero."); check = 5;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(address_index, ~(1 << bit_index));
      read_once(address_index);
    end
  end

  repeat(10) @(posedge write_clock);

  // Check 6 : Concurrent reads and writes
  $display("CHECK 6 : Concurrent reads and writes."); check = 6;
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
        @(negedge write_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge write_clock);

  // Check 7 : Random stimulus
  $display("CHECK 7 : Random stimulus."); check = 7;
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge write_clock);
        if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
          write_enable  = 1;
          write_address = $urandom_range(DEPTH);
          write_data    = $urandom_range(WIDTH_POW2);
          @(posedge write_clock);
          memory_model[write_address] = write_data;
          transfer_count++;
        end else begin
          write_enable = 0;
        end
      end
      write_enable = 0;
    end
    // Reading
    begin
      forever begin
        @(negedge read_clock);
        if (random_boolean(RANDOM_READ_PROBABILITY)) begin
          read_enable   = 1;
          read_address  = $urandom_range(DEPTH);
          if (REGISTERED_READ) @(posedge read_clock);
          expected_data = memory_model[read_address];
          @(posedge read_clock);
          assert (read_data === expected_data)
            else $error("[%0tns] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, read_data, read_address, expected_data);
        end else begin
          read_enable = 0;
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge write_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge write_clock);

  $finish;
end

endmodule
