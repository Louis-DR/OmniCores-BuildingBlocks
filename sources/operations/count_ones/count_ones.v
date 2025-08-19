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
  parameter DATA_WIDTH  = 8,
  parameter COUNT_WIDTH = `CLOG2(DATA_WIDTH+1)
) (
  input   [DATA_WIDTH-1:0] data,
  output [COUNT_WIDTH-1:0] count
);

function [COUNT_WIDTH-1:0] count_ones_f;
  input [DATA_WIDTH-1:0] data;
  integer bit_index;
  begin
    count_ones_f = 0;
    for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index+1) begin
      if (data[bit_index]) begin
        count_ones_f = count_ones_f + 1;
      end
    end
  end
endfunction

assign count = count_ones_f(data);

endmodule
