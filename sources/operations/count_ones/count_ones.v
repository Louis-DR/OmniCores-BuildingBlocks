// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        count_ones.v                                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Count the number of high bits in a vector.                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module count_ones #(
  parameter WIDTH      = 8,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH)
) (
  input       [WIDTH-1:0] data,
  output [WIDTH_LOG2-1:0] count
);

function [WIDTH_LOG2-1:0] count_ones_f;
  input [WIDTH-1:0] data;
  integer bit_index;
  begin
    count_ones_f = 0;
    for (bit_index = 0; bit_index < WIDTH; bit_index = bit_index+1) begin
      if (data[bit_index]) begin
        count_ones_f = count_ones_f + 1;
      end
    end
  end
endfunction

assign count = count_ones_f(data);

endmodule
