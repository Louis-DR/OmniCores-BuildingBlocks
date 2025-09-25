// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        binary_to_gray.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Binary to Gray encoder. This code reorders the binary        ║
// ║              numeral system such that two successive values differ in     ║
// ║              only one bit.                                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module binary_to_gray #(
  parameter RANGE = 16,
  parameter WIDTH = `CLOG2(RANGE)
) (
  input  [WIDTH-1:0] binary,
  output [WIDTH-1:0] gray
);

// Power-of-two range
if (`IS_POW2(RANGE)) begin : gen_power_of_two_range
  // Gray code is obtained by XORing the binary input with itself shifted right by 1
  assign gray = binary ^ (binary >> 1);
end

// Non-power-of-two even range
else if (RANGE % 2 == 0) begin : gen_non_power_of_two_even_range
  // Prune the ends of the Gray encoding of the next higher power-of-two range using an offset
  localparam OFFSET = (2 ** WIDTH - RANGE) / 2;
  wire [WIDTH-1:0] offset_binary = binary + OFFSET;
  // Then use the standard power-of-two encoding formula as above
  assign gray = offset_binary ^ (offset_binary >> 1);
end

// Odd range
else begin : gen_non_power_of_two_odd_range
  // Gray encoding requires even range
  $error("Gray encoding requires an even range.");
end

endmodule