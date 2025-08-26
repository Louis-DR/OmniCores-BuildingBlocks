`ifndef __OMNICORES_RANDOM__
`define __OMNICORES_RANDOM__

`include "boolean.svh"
`include "constants.svh"

function real random_ratio();
  return $urandom / real'(INT_UNSIGNED_MAX);
endfunction

function bool random_boolean(input real probability);
  return random_ratio() < probability;
endfunction

`endif