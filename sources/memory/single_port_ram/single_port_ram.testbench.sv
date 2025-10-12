// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        single_port_ram.testbench.sv                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the single-port RAM.                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module single_port_ram__testbench ();

// Device parameters
localparam int  WIDTH           = 8;
localparam int  DEPTH           = 16;
localparam bit  REGISTERED_READ = 1;

// Derived parameters
localparam int  ADDRESS_WIDTH   = $clog2(DEPTH);
localparam int  WIDTH_POW2      = 2**WIDTH;

// Test parameters
localparam real CLOCK_PERIOD              = 10;
localparam int  RANDOM_CHECK_DURATION     = 1000;
localparam int  RANDOM_CHECK_TIMEOUT      = 10000;
localparam real RANDOM_ACCESS_PROBABILITY = 0.5;
localparam real RANDOM_WRITE_PROBABILITY  = 0.5;

// Device ports
logic                     clock;
logic                     access_enable;
logic                     write;
logic [ADDRESS_WIDTH-1:0] address;
logic         [WIDTH-1:0] write_data;
logic         [WIDTH-1:0] read_data;

// Test variables
int               check;
logic [WIDTH-1:0] memory_model [DEPTH];
logic [WIDTH-1:0] expected_data;
int               transfer_count;
int               timeout_countdown;

// Device under test
single_port_ram #(
  .WIDTH           ( WIDTH           ),
  .DEPTH           ( DEPTH           ),
  .REGISTERED_READ ( REGISTERED_READ )
) single_port_ram_dut (
  .clock         ( clock         ),
  .access_enable ( access_enable ),
  .write         ( write         ),
  .address       ( address       ),
  .write_data    ( write_data    ),
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
  input [ADDRESS_WIDTH-1:0] address_;
  input         [WIDTH-1:0] data;
  access_enable = 1;
  write         = 1;
  address       = address_;
  write_data    = data;
  @(posedge clock);
  memory_model[address_] = data;
  @(negedge clock);
  access_enable =  0;
  write         =  0;
  address       = 'x;
  write_data    = 'x;
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
  input [ADDRESS_WIDTH-1:0] address_;
  access_enable = 1;
  write         = 0;
  address       = address_;
  expected_data = memory_model[address_];
  if (REGISTERED_READ) @(posedge clock);
  #(1);
  assert (read_data === expected_data)
    else $error("[%t] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $realtime, read_data, address_, expected_data);
  @(negedge clock);
  access_enable = 0;
  address       = 'x;
endtask

// Read all task
task automatic read_all;
  for (int index = 0; index < DEPTH; index++) begin
    read_once(index);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("single_port_ram.testbench.vcd");
  $dumpvars(0, single_port_ram__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  access_enable =  0;
  write         =  0;
  address       = 'x;
  write_data    = 'x;

  // Check 1 : All zero
  $display("CHECK 1 : All zero."); check = 1;
  @(negedge clock);
  write_all('0);
  read_all();

  repeat(10) @(posedge clock);

  // Check 2 : Address walking ones
  $display("CHECK 2 : Address walking ones."); check = 2;
  @(negedge clock);
  // Memory is already filled with all zeros
  // Walk vector of ones through the memory and check address aliasing
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '1);
    read_all();
    write_once(address_index, '0);
  end

  repeat(10) @(posedge clock);

  // Check 3 : Address walking zeros
  $display("CHECK 3 : Address walking zeros."); check = 3;
  @(negedge clock);
  // Fill the memory with all ones
  write_all('1);
  // Walk vector of zeros through the memory and check address aliasing
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    write_once(address_index, '0);
    read_all();
    write_once(address_index, '1);
  end

  repeat(10) @(posedge clock);

  // Check 4 : Data walking one
  $display("CHECK 4 : Data walking one."); check = 4;
  @(negedge clock);
  // For each address, walk a one through the data bits and check data aliasing
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
  // For each address, walk a zero through the data bits and check data aliasing
  for (int address_index = 0; address_index < DEPTH; address_index++) begin
    for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
      write_once(address_index, ~(1 << bit_index));
      read_once(address_index);
    end
  end

  repeat(10) @(posedge clock);

  // Check 6 : Random stimulus
  $display("CHECK 6 : Random stimulus."); check = 6;
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing and reading
    begin
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
        if (random_boolean(RANDOM_ACCESS_PROBABILITY)) begin
          if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
            write_once($urandom_range(DEPTH), $urandom_range(WIDTH_POW2));
          end else begin
            read_once($urandom_range(DEPTH));
          end
          transfer_count++;
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

  // End of test
  $finish;
end

endmodule
