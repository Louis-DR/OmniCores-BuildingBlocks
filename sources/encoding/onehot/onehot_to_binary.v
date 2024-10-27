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

always @(*) begin
  // Default value
  binary = 0;
  // Check each one-hot encoded value
  for (integer bit_index = 0; bit_index < WIDTH_ONEHOT; bit_index++) begin
    if (onehot[bit_index]) begin
      binary = `CLOG2(bit_index);
    end
  end
end

endmodule