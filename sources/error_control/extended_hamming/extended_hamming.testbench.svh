`ifndef __EXTENDED_HAMMING_TESTBENCH_HEADER__
`define __EXTENDED_HAMMING_TESTBENCH_HEADER__

`include "hamming.testbench.svh"

// Reference function for the Hamming(8,4) encoding
function logic [3:0] extended_hamming_8_4(input logic [3:0] data);
  logic [2:0] hamming_7_4_code = hamming_7_4(data);
  logic extra_parity = ^{data, hamming_7_4_code};
  return {hamming_7_4_code, extra_parity};
endfunction

// Reference function for the Hamming(16,11) encoding
function logic [4:0] extended_hamming_16_11(input logic [10:0] data);
  logic [3:0] hamming_15_11_code = hamming_15_11(data);
  logic extra_parity = ^{data, hamming_15_11_code};
  return {hamming_15_11_code, extra_parity};
endfunction

// Reference function for the Hamming(32,26) encoding
function logic [5:0] extended_hamming_32_26(input logic [25:0] data);
  logic [4:0] hamming_31_26_code = hamming_31_26(data);
  logic extra_parity = ^{data, hamming_31_26_code};
  return {hamming_31_26_code, extra_parity};
endfunction

// Reference function for the Hamming(64,57) encoding
function logic [6:0] extended_hamming_64_57(input logic [56:0] data);
  logic [5:0] hamming_63_57_code = hamming_63_57(data);
  logic extra_parity = ^{data, hamming_63_57_code};
  return {hamming_63_57_code, extra_parity};
endfunction

// Reference function for the Hamming(128,120) encoding
function logic [7:0] extended_hamming_128_120(input logic [119:0] data);
  logic [6:0] hamming_127_120_code = hamming_127_120(data);
  logic extra_parity = ^{data, hamming_127_120_code};
  return {hamming_127_120_code, extra_parity};
endfunction

// Reference function for the Hamming(256,247) encoding
function logic [8:0] extended_hamming_256_247(input logic [246:0] data);
  logic [7:0] hamming_255_247_code = hamming_255_247(data);
  logic extra_parity = ^{data, hamming_255_247_code};
  return {hamming_255_247_code, extra_parity};
endfunction

`endif