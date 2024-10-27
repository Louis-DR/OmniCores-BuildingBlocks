// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        binary_to_onehot.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Binary to one-hot encoder.                                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module binary_to_onehot #(
  parameter WIDTH_BINARY = 8,
  parameter WIDTH_ONEHOT = 2**WIDTH
) (
  input  [WIDTH_BINARY-1:0] binary,
  output [WIDTH_ONEHOT-1:0] onehot
);

assign onehot = 1'b1 << binary;

endmodule