// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_encoder_tb.sv                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Hamming encoder.                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "hamming_encoder.svh"



module hamming_encoder_tb ();

// Test parameters
localparam CLOCK_PERIOD      = 10;
localparam DATA_WIDTH        = 4;
localparam DATA_WIDTH_POW2   = 2**DATA_WIDTH;
localparam PARITY_WIDTH      = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH);
localparam PADDED_DATA_WIDTH = `GET_HAMMING_DATA_WIDTH(PARITY_WIDTH);
localparam BLOCK_WIDTH       = DATA_WIDTH+PARITY_WIDTH;

// Device ports
logic                    clock;
logic   [DATA_WIDTH-1:0] data;
logic [PARITY_WIDTH-1:0] code;
logic  [BLOCK_WIDTH-1:0] block;

// Device under test
hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_encoder_dut (
  .data  ( data  ),
  .code  ( code  ),
  .block ( block )
);

// Clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Reference function for the Hamming(7,4) encoding
function logic [2:0] hamming_7_4(input logic [3:0] data);
  return {data[3] ^ data[2] ^ data[1],
          data[3] ^ data[2] ^ data[0],
          data[3] ^ data[1] ^ data[0]};
endfunction

// Checker task for the code
task automatic check_code();
  logic [PARITY_WIDTH-1:0] expected_code = hamming_7_4(data);
  if (code != expected_code) begin
    $error("[%0tns] Incorrect code for data '%b' : expected '%b' but got '%b'.", $time, data, expected_code, code);
  end
endtask

// Reference function for Hamming block packing
function logic [BLOCK_WIDTH-1:0] hamming_block(input logic [DATA_WIDTH-1:0] data, input logic [PARITY_WIDTH-1:0] code);
  logic [BLOCK_WIDTH-1:0] expected_block;
  expected_block[  0] = code[  0];
  expected_block[  1] = code[  1];
  expected_block[  2] = data[  0];
  expected_block[  3] = code[  2];
  expected_block[7:4] = data[3:1];
  return expected_block;
endfunction

// Checker task for the block
task automatic check_block();
  logic [BLOCK_WIDTH-1:0] expected_block = hamming_block(data, code);
  if (block != expected_block) begin
    $error("[%0tns] Incorrect block packing : expected '%b' but got '%b'.", $time, expected_block, block);
  end
endtask

// Main block
initial begin
  // Log waves
  $dumpfile("hamming_encoder_tb.vcd");
  $dumpvars(0,hamming_encoder_tb);

  // Initialization
  data = 0;

  // Check 1 : full coverage
  $display("CHECK 1 : Full coverage.");
  for (integer data_index=0 ; data_index<DATA_WIDTH_POW2 ; data_index++) begin
    @(negedge clock);
    data = data_index;
    @(posedge clock);
    check_code();
    check_block();
  end

  // End of test
  $finish;
end

endmodule
