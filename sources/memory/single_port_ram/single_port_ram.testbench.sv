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
localparam real CLOCK_PERIOD             = 10;
localparam int  RANDOM_CHECK_DURATION    = 1000;
localparam real RANDOM_WRITE_PROBABILITY = 0.5;

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
  access_enable = 0;
  write         = 0;
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
  if (REGISTERED_READ) @(posedge clock);
  @(posedge clock);
  assert (read_data === memory_model[address_])
    else $error("[%0tns] Read data '0x%0h' at address '0x%0h' does not match expected '0x%0h'.", $time, read_data, address_, memory_model[address_]);
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

// Device under test
single_port_ram #(
  .WIDTH           ( WIDTH           ),
  .DEPTH           ( DEPTH           ),
  .REGISTERED_READ ( REGISTERED_READ ),
  .ADDRESS_WIDTH   ( ADDRESS_WIDTH   )
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

// Main block
initial begin
  // Log waves
  $dumpfile("single_port_ram.testbench.vcd");
  $dumpvars(0, single_port_ram__testbench);

  // Initialization
  access_enable = 0;
  write         = 0;
  address       = 'x;
  write_data    = 'x;

  // Check 1 : Write address as data to all locations, then read back
  $display("CHECK 1 : Write address as data to all locations, then read back."); check = 1;
  @(negedge clock);
  for (int index = 0; index < DEPTH; index++) begin
    write_once(index, index[WIDTH-1:0]);
  end
  read_all();

  repeat(10) @(posedge clock);

  // Check 2 : Write inverse address as data to all locations, then read back
  $display("CHECK 2 : Write inverse address as data to all locations, then read back."); check = 2;
  @(negedge clock);
  for (int index = 0; index < DEPTH; index++) begin
    write_once(index, ~index[WIDTH-1:0]);
  end
  read_all();

  repeat(10) @(posedge clock);

  // Check 3 : Walking 1s data pattern on a single address
  $display("CHECK 3 : Walking 1s data pattern on a single address."); check = 3;
  @(negedge clock);
  for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
    write_once(0, 1'b1 << bit_index);
    read_once(0);
  end

  repeat(10) @(posedge clock);

  // Check 4 : Walking 0s data pattern on a single address
  $display("CHECK 4 : Walking 0s data pattern on a single address."); check = 4;
  @(negedge clock);
  for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
    write_once(0, ~(1'b1 << bit_index));
    read_once(0);
  end

  repeat(10) @(posedge clock);

  // Check 5 : Random reads and writes
  $display("CHECK 5 : Random reads and writes."); check = 5;
  @(negedge clock);
  for (int iteration = 0; iteration < RANDOM_CHECK_DURATION; iteration++) begin
    if (random_boolean(RANDOM_WRITE_PROBABILITY)) begin
      // Random write
      write_once($urandom_range(DEPTH), $urandom_range(WIDTH_POW2-1));
    end else begin
      // Random read
      read_once($urandom_range(DEPTH));
    end
  end

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
