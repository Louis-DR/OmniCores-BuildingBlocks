`ifndef __OMNICORES_COMMON_HEADER__
`define __OMNICORES_COMMON_HEADER__

`ifndef INFINITE
`define INFINITE (1/0)
`endif

`ifdef SIMUMLATOR_NO_BOOL
typedef bit bool;
`endif

localparam bool true  = 1'b1;
localparam bool false = 1'b0;

`endif