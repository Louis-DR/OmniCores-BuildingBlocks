// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        onehot_to_binary.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: One-hot to binary decoder.                                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module onehot_to_binary #(
  parameter WIDTH_ONEHOT = 8,
  parameter WIDTH_BINARY = `CLOG2(WIDTH_ONEHOT)
) (
  input  [WIDTH_ONEHOT-1:0] onehot,
  output [WIDTH_BINARY-1:0] binary
);

function [WIDTH_BINARY-1:0] onehot_to_binary_f;
  input [WIDTH_ONEHOT-1:0] onehot;
  integer bit_index;
  begin
    onehot_to_binary_f = 0;
    for (bit_index = 0; bit_index < WIDTH_ONEHOT; bit_index = bit_index+1) begin
      if (onehot[bit_index]) onehot_to_binary_f = bit_index;
    end
  end
endfunction

assign binary = onehot_to_binary_f(onehot);

endmodule
