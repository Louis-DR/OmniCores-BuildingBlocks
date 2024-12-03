// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        count_ones.v                                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check the data with its Hamming code.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module count_ones #(
  parameter WIDTH      = 8,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH)
) (
  input       [WIDTH-1:0] data,
  output [WIDTH_LOG2-1:0] count
);

always @(*) begin
  count = 0;
  for (integer bit_index=0 ; bit_index<WIDTH ; bit_index++) begin
    if (data[bit_index]) begin
      count = count + 1;
    end
  end
end

endmodule
