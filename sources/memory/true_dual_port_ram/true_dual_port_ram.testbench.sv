// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        true_dual_port_ram.testbench.sv                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the true dual-port RAM.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module true_dual_port_ram__testbench ();

// Device parameters
localparam int  WIDTH           = 8;
localparam int  DEPTH           = 16;
localparam bit  WRITE_THROUGH   = 0;
localparam bit  REGISTERED_READ = 1;

// Derived parameters
localparam int  ADDRESS_WIDTH   = $clog2(DEPTH);
localparam int  WIDTH_POW2      = 2**WIDTH;

// Test parameters
localparam real CLOCK_PERIOD              = 10;
localparam int  CONCURRENT_CHECK_DURATION = 1000;
localparam int  CONCURRENT_CHECK_TIMEOUT  = 10000;
localparam int  RANDOM_CHECK_DURATION     = 1000;
localparam int  RANDOM_CHECK_TIMEOUT      = 10000;
localparam real RANDOM_ACCESS_PROBABILITY = 0.5;
localparam real RANDOM_WRITE_PROBABILITY  = 0.5;

// Device ports
logic                     clock;
logic                     port_0_access_enable;
logic                     port_0_write;
logic [ADDRESS_WIDTH-1:0] port_0_address;
logic         [WIDTH-1:0] port_0_write_data;
logic         [WIDTH-1:0] port_0_read_data;
logic                     port_1_access_enable;
logic                     port_1_write;
logic [ADDRESS_WIDTH-1:0] port_1_address;
logic         [WIDTH-1:0] port_1_write_data;
logic         [WIDTH-1:0] port_1_read_data;

// Test variables
int               check;
logic [WIDTH-1:0] memory_model [DEPTH];
logic [WIDTH-1:0] expected_data_port_0;
logic [WIDTH-1:0] expected_data_port_1;
int               transfer_count;
int               timeout_countdown;

// Device under test
true_dual_port_ram #(
  .WIDTH           ( WIDTH           ),
  .DEPTH           ( DEPTH           ),
  .WRITE_THROUGH   ( WRITE_THROUGH   ),
  .REGISTERED_READ ( REGISTERED_READ )
) true_dual_port_ram_dut (
  .clock                ( clock                ),
  .port_0_access_enable ( port_0_access_enable ),
  .port_0_write         ( port_0_write         ),
  .port_0_address       ( port_0_address       ),
  .port_0_write_data    ( port_0_write_data    ),
  .port_0_read_data     ( port_0_read_data     ),
  .port_1_access_enable ( port_1_access_enable ),
  .port_1_write         ( port_1_write         ),
  .port_1_address       ( port_1_address       ),
  .port_1_write_data    ( port_1_write_data    ),
  .port_1_read_data     ( port_1_read_data     )
);

// Clock generator
initial begin
  clock = 1;
  forever #(CLOCK_PERIOD/2) clock = ~clock;
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
  end else begin
    port_1_access_enable = 1;
    port_1_write         = 1;
    port_1_address       = address;
    port_1_write_data    = data;
  end
  @(posedge clock);
  // $display("[%0tns] Write %0d data '0x%0h' at address '0x%0h'.", $time, port_index, data, address);
  memory_model[address] = data;
  @(negedge clock);
  if (port_index == 0) begin
    port_0_access_enable =  0;
    port_0_write         =  0;
    port_0_address       = 'x;
    port_0_write_data    = 'x;
  end else begin
    port_1_access_enable =  0;
    port_1_write         =  0;
    port_1_address       = 'x;
    port_1_write_data    = 'x;
  end
endtask

// Write random task
task automatic write_random;
  input int port_index;
  logic [ADDRESS_WIDTH-1:0] random_address;
  logic         [WIDTH-1:0] random_data;
  random_address = $urandom_range(DEPTH);
  random_data    = $urandom_range(WIDTH_POW2);
  if (port_index == 1) begin
    #(1);
    if (port_0_access_enable && port_0_write) begin
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
  logic         [WIDTH-1:0] expected_data;
  if (port_index == 0) begin
    port_0_access_enable = 1;
    port_0_write         = 0;
    port_0_address       = address;
  end else begin
    port_1_access_enable = 1;
    port_1_write         = 0;
    port_1_address       = address;
  end
  if (WRITE_THROUGH) begin
    #(1);
    if (port_index == 0) begin
      #(1);
      expected_data = (port_1_write && port_1_address == address) ? port_1_write_data : memory_model[address];
    end else begin
      expected_data = (port_0_write && port_0_address == address) ? port_0_write_data : memory_model[address];
    end
  end else begin
    expected_data = memory_model[address];
  end
  if (REGISTERED_READ) @(posedge clock);
  #(1);
  if (port_index == 0) begin
    assert (port_0_read_data === expected_data)
      else $error("[%0tns] Port 0: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_0_read_data, address, expected_data);
  end else begin
    assert (port_1_read_data === expected_data)
      else $error("[%0tns] Port 1: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_1_read_data, address, expected_data);
  end
  @(negedge clock);
  if (port_index == 0) begin
    port_0_access_enable =  0;
    port_0_address       = 'x;
  end else begin
    port_1_access_enable =  0;
    port_1_address       = 'x;
  end
endtask

// Read random task
task automatic read_random;
  input int port_index;
  logic [ADDRESS_WIDTH-1:0] random_address;
  random_address = $urandom_range(DEPTH);
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
  $dumpfile("true_dual_port_ram.testbench.vcd");
  $dumpvars(0, true_dual_port_ram__testbench);

  // Initialization
  port_0_access_enable =  0;
  port_0_write         =  0;
  port_0_address       = 'x;
  port_0_write_data    = 'x;
  port_1_access_enable =  0;
  port_1_write         =  0;
  port_1_address       = 'x;
  port_1_write_data    = 'x;

  repeat(5) @(posedge clock);

  // Check 1.1 : All zero (port 0 write, port 1 read)
  $display("CHECK 1.1 : All zero (port 0 write, port 1 read)."); check = 1;
  @(negedge clock);
  write_all(0, '0);
  read_all(1);

  repeat(10) @(posedge clock);

  // Check 1.2 : All zero (port 1 write, port 0 read)
  $display("CHECK 1.2 : All zero (port 1 write, port 0 read)."); check = 2;
  @(negedge clock);
  write_all(1, '0);
  read_all(0);

  repeat(10) @(posedge clock);

  // Check 2.1 : Address walking ones (port 0 write, port 1 read)
  $display("CHECK 2.1 : Address walking ones (port 0 write, port 1 read)."); check = 3;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(0, address_index, '1);
    read_all(1);
    write_once(0, address_index, '0);
  end

  repeat(10) @(posedge clock);

  // Check 2.2 : Address walking ones (port 1 write, port 0 read)
  $display("CHECK 2.2 : Address walking ones (port 1 write, port 0 read)."); check = 4;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(1, address_index, '1);
    read_all(0);
    write_once(1, address_index, '0);
  end

  repeat(10) @(posedge clock);

  // Check 3.1 : Address walking zeros (port 0 write, port 1 read)
  $display("CHECK 3.1 : Address walking zeros (port 0 write, port 1 read)."); check = 5;
  @(negedge clock);
  write_all(0, '1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(0, address_index, '0);
    read_all(1);
    write_once(0, address_index, '1);
  end

  repeat(10) @(posedge clock);

  // Check 3.2 : Address walking zeros (port 1 write, port 0 read)
  $display("CHECK 3.2 : Address walking zeros (port 1 write, port 0 read)."); check = 6;
  @(negedge clock);
  write_all(1, '1);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(1, address_index, '0);
    read_all(0);
    write_once(1, address_index, '1);
  end

  repeat(10) @(posedge clock);

  // Check 4.1 : Data walking one (port 0 write, port 1 read)
  $display("CHECK 4.1 : Data walking one (port 0 write, port 1 read)."); check = 7;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(0, address_index, 1 << bit_index);
      read_once(1, address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 4.2 : Data walking one (port 1 write, port 0 read)
  $display("CHECK 4.2 : Data walking one (port 1 write, port 0 read)."); check = 8;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(1, address_index, 1 << bit_index);
      read_once(0, address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 5.1 : Data walking zero (port 0 write, port 1 read)
  $display("CHECK 5.1 : Data walking zero (port 0 write, port 1 read)."); check = 9;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(0, address_index, ~(1 << bit_index));
      read_once(1, address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 5.2 : Data walking zero (port 1 write, port 0 read)
  $display("CHECK 5.2 : Data walking zero (port 1 write, port 0 read)."); check = 10;
  @(negedge clock);
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(1, address_index, ~(1 << bit_index));
      read_once(0, address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 6 : Concurrent writes (port 0 and port 1)
  $display("CHECK 6 : Concurrent writes (port 0 and port 1)."); check = 11;
  @(negedge clock);
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
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  read_all(0);
  read_all(1);

  repeat(10) @(posedge clock);

  // Check 7 : Concurrent reads (port 0 and port 1)
  $display("CHECK 7 : Concurrent reads (port 0 and port 1)."); check = 12;
  @(negedge clock);
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
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // Check 8 : Concurrent read/write (port 0 read, port 1 write)
  $display("CHECK 8 : Concurrent read/write (port 0 read, port 1 write)."); check = 13;
  @(negedge clock);
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
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // Check 9 : Concurrent read/write (port 0 write, port 1 read)
  $display("CHECK 9 : Concurrent read/write (port 0 write, port 1 read)."); check = 14;
  @(negedge clock);
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
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;

  repeat(10) @(posedge clock);

  // Check 10 : Random stimulus
  $display("CHECK 10 : Random stimulus."); check = 15;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Port 0 stimulus
    begin
      logic [ADDRESS_WIDTH-1:0] address;
      logic         [WIDTH-1:0] data;
      logic         [WIDTH-1:0] expected_data;
      forever begin
        @(negedge clock);
        if (random_boolean(RANDOM_ACCESS_PROBABILITY)) begin
          // Write
          if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
            port_0_access_enable = 1;
            port_0_write         = 1;
            address              = $urandom_range(DEPTH);
            data                 = $urandom_range(WIDTH_POW2);
            port_0_address       = address;
            port_0_write_data    = data;
            @(posedge clock);
            if (!port_1_write || !port_1_access_enable || port_1_address !== address) begin
              memory_model[address] = data;
            end
          end
          // Read
          else begin
            port_0_access_enable = 1;
            port_0_write         = 0;
            address              = $urandom_range(DEPTH);
            port_0_address       = address;
            if (WRITE_THROUGH) begin
              #(1);
              expected_data = (port_1_write && port_1_address == address) ? port_1_write_data : memory_model[address];
            end else begin
              expected_data = memory_model[address];
            end
            if (REGISTERED_READ) @(posedge clock);
            #(1);
            assert (port_0_read_data === expected_data)
              else $error("[%0tns] Port 0: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_0_read_data, address, expected_data);
          end
        end else begin
          port_0_access_enable = 0;
          port_0_write         = 0;
          @(posedge clock);
        end
      end
    end
    // Port 1 stimulus
    begin
      logic [ADDRESS_WIDTH-1:0] address;
      logic         [WIDTH-1:0] data;
      logic         [WIDTH-1:0] expected_data;
      while(transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
        if (random_boolean(RANDOM_ACCESS_PROBABILITY)) begin
          // Write
          if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
            port_1_access_enable = 1;
            port_1_write         = 1;
            address              = $urandom_range(DEPTH);
            data                 = $urandom_range(WIDTH_POW2);
            port_1_address       = address;
            port_1_write_data    = data;
            @(posedge clock);
            memory_model[address] = data;
            transfer_count++;
          end
          // Read
          else begin
            port_1_access_enable = 1;
            port_1_write         = 0;
            address              = $urandom_range(DEPTH);
            port_1_address       = address;
            if (WRITE_THROUGH) begin
              #(1);
              expected_data = (port_0_write && port_0_address == address) ? port_0_write_data : memory_model[address];
            end else begin
              expected_data = memory_model[address];
            end
            if (REGISTERED_READ) @(posedge clock);
            #(1);
            assert (port_1_read_data === expected_data)
              else $error("[%0tns] Port 1: Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, port_1_read_data, address, expected_data);
            transfer_count++;
          end
        end else begin
          port_1_access_enable = 0;
          port_1_write         = 0;
          @(posedge clock);
        end
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

  repeat(10) @(posedge clock);

  $finish;
end

endmodule
