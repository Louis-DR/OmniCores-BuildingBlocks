// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_true_dual_port_ram.testbench.sv                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the asynchronous true dual-port RAM.           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs
`include "random.svh"
`include "boolean.svh"



module asynchronous_true_dual_port_ram__testbench ();

// Device parameters
localparam int  WIDTH           = 8;
localparam int  DEPTH           = 16;
localparam bit  REGISTERED_READ = 1;

// Derived parameters
localparam int  ADDRESS_WIDTH   = $clog2(DEPTH);
localparam int  WIDTH_POW2      = 2**WIDTH;

// Test parameters
localparam real PORT_0_CLOCK_PERIOD       = 10;
localparam real PORT_1_CLOCK_PERIOD       = PORT_0_CLOCK_PERIOD / 3.14159265359;
localparam int  CONCURRENT_CHECK_DURATION = 1000;
localparam int  CONCURRENT_CHECK_TIMEOUT  = 10000;
localparam int  RANDOM_CHECK_DURATION     = 1000;
localparam int  RANDOM_CHECK_TIMEOUT      = 10000;
localparam real RANDOM_ACCESS_PROBABILITY = 0.5;
localparam real RANDOM_WRITE_PROBABILITY  = 0.5;

// Device ports
logic                     port_0_clock;
logic                     port_0_access_enable;
logic                     port_0_write;
logic [ADDRESS_WIDTH-1:0] port_0_address;
logic         [WIDTH-1:0] port_0_write_data;
logic         [WIDTH-1:0] port_0_read_data;
logic                     port_1_clock;
logic                     port_1_access_enable;
logic                     port_1_write;
logic [ADDRESS_WIDTH-1:0] port_1_address;
logic         [WIDTH-1:0] port_1_write_data;
logic         [WIDTH-1:0] port_1_read_data;

// Test variables
int               check;
logic [WIDTH-1:0] memory_model [DEPTH];
int               transfer_count;
int               timeout_countdown;

// Device under test
asynchronous_true_dual_port_ram #(
  .WIDTH           ( WIDTH           ),
  .DEPTH           ( DEPTH           ),
  .REGISTERED_READ ( REGISTERED_READ )
) asynchronous_true_dual_port_ram_dut (
  .port_0_clock         ( port_0_clock         ),
  .port_0_access_enable ( port_0_access_enable ),
  .port_0_write         ( port_0_write         ),
  .port_0_address       ( port_0_address       ),
  .port_0_write_data    ( port_0_write_data    ),
  .port_0_read_data     ( port_0_read_data     ),
  .port_1_clock         ( port_1_clock         ),
  .port_1_access_enable ( port_1_access_enable ),
  .port_1_write         ( port_1_write         ),
  .port_1_address       ( port_1_address       ),
  .port_1_write_data    ( port_1_write_data    ),
  .port_1_read_data     ( port_1_read_data     )
);

// Clock generators
initial begin
  port_0_clock = 1;
  forever #(PORT_0_CLOCK_PERIOD/2) port_0_clock = ~port_0_clock;
end

initial begin
  port_1_clock = 1;
  forever #(PORT_1_CLOCK_PERIOD/2) port_1_clock = ~port_1_clock;
end

// Write task
task automatic write_once;
  input int                 port_index;
  input [ADDRESS_WIDTH-1:0] address;
  input         [WIDTH-1:0] data;
  if (port_index == 0) begin
    port_0_access_enable = 1;
    port_0_write         = 1;
    port_0_address       = address;
    port_0_write_data    = data;
    @(posedge port_0_clock);
    memory_model[address] = data;
    @(negedge port_0_clock);
    port_0_access_enable = 0;
    port_0_write         = 0;
  end else begin
    port_1_access_enable = 1;
    port_1_write         = 1;
    port_1_address       = address;
    port_1_write_data    = data;
    @(posedge port_1_clock);
    memory_model[address] = data;
    @(negedge port_1_clock);
    port_1_access_enable = 0;
    port_1_write         = 0;
  end
endtask

// Write random task
task automatic write_random;
  input int port_index;
  logic [ADDRESS_WIDTH-1:0] random_address;
  logic         [WIDTH-1:0] random_data;
  random_address = $urandom_range(DEPTH);
  random_data    = $urandom_range(WIDTH_POW2);
  if (port_index == 0) begin
    if (port_1_access_enable) begin
      while (random_address === port_1_address) begin
        random_address = $urandom_range(DEPTH);
      end
    end
  end else begin
    if (port_0_access_enable) begin
      while (random_address === port_0_address) begin
        random_address = $urandom_range(DEPTH);
      end
    end
  end
  write_once(port_index, random_address, random_data);
endtask

// Write all task
task automatic write_all;
  input int         port_index;
  input [WIDTH-1:0] data;
  for (int index = 0; index < DEPTH; index++) begin
    write_once(port_index, index, data);
  end
endtask

// Read task
task automatic read_once;
  input int                 port_index;
  input [ADDRESS_WIDTH-1:0] address;
  logic [WIDTH-1:0]         expected_data;
  if (port_index == 0) begin
    port_0_access_enable = 1;
    port_0_write         = 0;
    port_0_address       = address;
    if (REGISTERED_READ) @(posedge port_0_clock);
    expected_data = memory_model[address];
    #(1fs);
    assert (port_0_read_data === expected_data)
      else $error("[%0tns] Port 0: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_0_read_data, address, expected_data);
    @(negedge port_0_clock);
    port_0_access_enable = 0;
  end else begin
    port_1_access_enable = 1;
    port_1_write         = 0;
    port_1_address       = address;
    if (REGISTERED_READ) @(posedge port_1_clock);
    expected_data = memory_model[address];
    #(1fs);
    assert (port_1_read_data === expected_data)
      else $error("[%0tns] Port 1: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_1_read_data, address, expected_data);
    @(negedge port_1_clock);
    port_1_access_enable = 0;
  end
endtask

// Read random task
task automatic read_random;
  input int port_index;
  logic [ADDRESS_WIDTH-1:0] random_address;
  random_address = $urandom_range(DEPTH);
  if (port_index == 0) begin
    if (port_1_access_enable) begin
      while (random_address === port_1_address) begin
        random_address = $urandom_range(DEPTH);
      end
    end
  end else begin
    if (port_0_access_enable) begin
      while (random_address === port_0_address) begin
        random_address = $urandom_range(DEPTH);
      end
    end
  end
  read_once(port_index, random_address);
endtask

// Read all task
task automatic read_all;
  input int port_index;
  for (int index = 0; index < DEPTH; index++) begin
    read_once(port_index, index);
  end
endtask

// Main block
initial begin
  $dumpfile("asynchronous_true_dual_port_ram.testbench.vcd");
  $dumpvars(0, asynchronous_true_dual_port_ram__testbench);

  // Initialization
  port_0_access_enable = 0;
  port_0_write         = 0;
  port_0_address       = 'x;
  port_0_write_data    = 'x;
  port_1_access_enable = 0;
  port_1_write         = 0;
  port_1_address       = 'x;
  port_1_write_data    = 'x;

  // Wait for clocks to stabilize
  repeat(5) @(posedge port_0_clock);

  // Check 1 : All zero (port 0 write, port 1 read)
  $display("CHECK 1 : All zero (port 0 write, port 1 read)."); check = 1;
  write_all(0, '0);
  read_all(1);

  repeat(10) @(posedge port_0_clock);

  // Check 2 : All zero (port 1 write, port 0 read)
  $display("CHECK 2 : All zero (port 1 write, port 0 read)."); check = 2;
  write_all(1, '0);
  read_all(0);

  repeat(10) @(posedge port_0_clock);

  // Check 3 : Address walking ones (port 0 write, port 1 read)
  $display("CHECK 3 : Address walking ones (port 0 write, port 1 read)."); check = 3;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(0, address_index, '1);
    read_all(1);
    write_once(0, address_index, '0);
  end

  repeat(10) @(posedge port_0_clock);

  // Check 4 : Address walking ones (port 1 write, port 0 read)
  $display("CHECK 4 : Address walking ones (port 1 write, port 0 read)."); check = 4;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(1, address_index, '1);
    read_all(0);
    write_once(1, address_index, '0);
  end

  repeat(10) @(posedge port_0_clock);

  // Check 5 : Address walking zeros (port 0 write, port 1 read)
  $display("CHECK 5 : Address walking zeros (port 0 write, port 1 read)."); check = 5;
  write_all(0, '1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(0, address_index, '0);
    read_all(1);
    write_once(0, address_index, '1);
  end

  repeat(10) @(posedge port_0_clock);

  // Check 6 : Address walking zeros (port 1 write, port 0 read)
  $display("CHECK 6 : Address walking zeros (port 1 write, port 0 read)."); check = 6;
  write_all(1, '1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(1, address_index, '0);
    read_all(0);
    write_once(1, address_index, '1);
  end

  repeat(10) @(posedge port_0_clock);

  // Check 7 : Data walking one (port 0 write, port 1 read)
  $display("CHECK 7 : Data walking one (port 0 write, port 1 read)."); check = 7;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(0, address_index, 1 << bit_index);
      read_once(1, address_index);
    end
  end

  repeat(10) @(posedge port_0_clock);

  // Check 8 : Data walking one (port 1 write, port 0 read)
  $display("CHECK 8 : Data walking one (port 1 write, port 0 read)."); check = 8;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(1, address_index, 1 << bit_index);
      read_once(0, address_index);
    end
  end

  repeat(10) @(posedge port_0_clock);

  // Check 9 : Data walking zero (port 0 write, port 1 read)
  $display("CHECK 9 : Data walking zero (port 0 write, port 1 read)."); check = 9;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(0, address_index, ~(1 << bit_index));
      read_once(1, address_index);
    end
  end

  repeat(10) @(posedge port_0_clock);

  // Check 10 : Data walking zero (port 1 write, port 0 read)
  $display("CHECK 10 : Data walking zero (port 1 write, port 0 read)."); check = 10;
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(1, address_index, ~(1 << bit_index));
      read_once(0, address_index);
    end
  end

  repeat(10) @(posedge port_0_clock);

  // Check 11 : Concurrent writes (port 0 and port 1)
  $display("CHECK 11 : Concurrent writes (port 0 and port 1)."); check = 11;
  timeout_countdown = CONCURRENT_CHECK_TIMEOUT;
  fork
    // Port 0 writing
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        write_random(0);
      end
    end
    // Port 1 writing
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        write_random(1);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge port_0_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  read_all(0);
  read_all(1);

  repeat(10) @(posedge port_0_clock);

  // Check 12 : Concurrent reads (port 0 and port 1)
  $display("CHECK 12 : Concurrent reads (port 0 and port 1)."); check = 12;
  timeout_countdown = CONCURRENT_CHECK_TIMEOUT;
  fork
    // Port 0 reading
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        read_random(0);
      end
    end
    // Port 1 reading
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        read_random(1);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge port_0_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge port_0_clock);

  // Check 13 : Concurrent read/write (port 0 read, port 1 write)
  $display("CHECK 13 : Concurrent read/write (port 0 read, port 1 write)."); check = 13;
  timeout_countdown = CONCURRENT_CHECK_TIMEOUT;
  fork
    // Port 0 reading
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        read_random(0);
      end
    end
    // Port 1 writing
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        write_random(1);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge port_0_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge port_0_clock);

  // Check 14 : Concurrent read/write (port 0 write, port 1 read)
  $display("CHECK 14 : Concurrent read/write (port 0 write, port 1 read)."); check = 14;
  transfer_count    = 0;
  timeout_countdown = CONCURRENT_CHECK_TIMEOUT;
  fork
    // Port 0 writing
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        write_random(0);
      end
    end
    // Port 1 reading
    begin
      repeat (CONCURRENT_CHECK_DURATION) begin
        read_random(1);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge port_0_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge port_0_clock);

  // Check 15 : Random stimulus
  $display("CHECK 15 : Random stimulus."); check = 15;
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Port 0 stimulus
    begin
      forever begin
        @(negedge port_0_clock);
        if (random_boolean(RANDOM_ACCESS_PROBABILITY)) begin
          if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
            write_random(0);
          end else begin
            read_random(0);
          end
        end
      end
    end
    // Port 1 stimulus
    begin
      while(transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge port_1_clock);
        if (random_boolean(RANDOM_ACCESS_PROBABILITY)) begin
          if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
            write_random(1);
          end else begin
            read_random(1);
          end
          transfer_count++;
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge port_0_clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge port_0_clock);

  $finish;
end

endmodule
