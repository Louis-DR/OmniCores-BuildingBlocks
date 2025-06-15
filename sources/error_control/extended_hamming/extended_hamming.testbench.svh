`ifndef __EXTENDED_HAMMING_TESTBENCH_HEADER__
`define __EXTENDED_HAMMING_TESTBENCH_HEADER__

`include "hamming.testbench.svh"

// Reference function for the Hamming(8,4) encoding
function automatic logic [3:0] extended_hamming_8_4(input logic [3:0] data);
  logic [2:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_7_4(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

// Reference function for the Hamming(16,11) encoding
function automatic logic [4:0] extended_hamming_16_11(input logic [10:0] data);
  logic [3:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_15_11(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

// Reference function for the Hamming(32,26) encoding
function automatic logic [5:0] extended_hamming_32_26(input logic [25:0] data);
  logic [4:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_31_26(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

// Reference function for the Hamming(64,57) encoding
function automatic logic [6:0] extended_hamming_64_57(input logic [56:0] data);
  logic [5:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_63_57(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

// Reference function for the Hamming(128,120) encoding
function automatic logic [7:0] extended_hamming_128_120(input logic [119:0] data);
  logic [6:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_127_120(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

// Reference function for the Hamming(256,247) encoding
function automatic logic [8:0] extended_hamming_256_247(input logic [246:0] data);
  logic [7:0] hamming_code;
  logic extra_parity;
  hamming_code = hamming_255_247(data);
  extra_parity = ^{data, hamming_code};
  return {hamming_code, extra_parity};
endfunction

`endif