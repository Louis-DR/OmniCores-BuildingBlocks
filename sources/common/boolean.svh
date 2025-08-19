`ifndef __OMNICORES_BOOLEAN__
`define __OMNICORES_BOOLEAN__

`ifdef SIMULATOR_NO_BOOL
typedef bit bool;
`endif

localparam bool true  = 1'b1;
localparam bool false = 1'b0;

`endif