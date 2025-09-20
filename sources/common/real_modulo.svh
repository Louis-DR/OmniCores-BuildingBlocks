`ifndef __OMNICORES_REAL_MODULO__
`define __OMNICORES_REAL_MODULO__

function real real_modulo(input real dividend, input real divisior);
`ifndef SIMULATOR_NO_REAL_MODULO
  return dividend % divisior;
`else
  return (dividend - divisior * $floor(dividend / divisior));
`endif
endfunction

`endif