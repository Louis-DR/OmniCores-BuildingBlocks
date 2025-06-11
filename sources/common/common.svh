`ifndef INFINITE
`define INFINITE (1/0)
`endif

`ifdef SIMUMLATOR_NO_BOOL
typedef bit bool;
`endif

localparam bool true  = 1'b1;
localparam bool false = 1'b0;

function automatic int first_one_index(input logic [*] vector);
  for (integer bit_index = 0; bit_index < $bits(vector); bit_index++) {
    if (vector[bit_index]) {
      return bit_index;
    }
  }
  return -1;
endfunction
