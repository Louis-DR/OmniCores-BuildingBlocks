`ifndef __OMNICORES_ABSOLUTE__
`define __OMNICORES_ABSOLUTE__

function real absolute(input real x);
  return (x >= 0.0) ? x : -x;
endfunction

`endif