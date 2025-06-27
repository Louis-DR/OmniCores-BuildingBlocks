`ifndef __OMNICORES_RANDOM__
`define __OMNICORES_RANDOM__

`include "boolean.svh"
`include "constants.svh"

function bool random_boolean(input real probability);
  return ($urandom / real'(INT_UNSIGNED_MAX)) < probability;
endfunction

`endif