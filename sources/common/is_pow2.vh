`ifndef IS_POW2
`define IS_POW2(x) ((x & (x-1)) == 0)
`endif