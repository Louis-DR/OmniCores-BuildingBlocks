// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        binary_to_grey.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Binary to Grey encoder. This code reorders the binary        ║
// ║              numeral system such that two successive values differ in     ║
// ║              only one bit.                                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module binary_to_grey #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] binary,
  output [WIDTH-1:0] grey
);

  // Gray code is obtained by XORing the binary input with itself shifted right by 1
  assign grey = binary ^ (binary >> 1);

endmodule