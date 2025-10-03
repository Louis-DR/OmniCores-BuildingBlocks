// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_to_binary.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Gray to binary decoder.                                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module gray_to_binary #(
  parameter RANGE = 16,
  parameter WIDTH = `CLOG2(RANGE)
) (
  input  [WIDTH-1:0] gray,
  output [WIDTH-1:0] binary
);

// Power-of-two range
if (`IS_POW2(RANGE)) begin : gen_power_of_two_range
  // The MSB remains the same
  assign binary[WIDTH-1] = gray[WIDTH-1];

  // Generate the rest of the bits using XOR operations from MSB to LSB
  genvar bit_index;
  for (bit_index = WIDTH-2; bit_index >= 0; bit_index = bit_index-1) begin : gen_bits
    assign binary[bit_index] = binary[bit_index+1] ^ gray[bit_index];
  end
end

// Non-power-of-two even range
else if (RANGE % 2 == 0) begin : gen_non_power_of_two_even_range
  // Convert the Gray encoding to binary then apply the reverse offset as for the encoding
  wire [WIDTH-1:0] offset_binary;

  // The MSB remains the same
  assign offset_binary[WIDTH-1] = gray[WIDTH-1];

  // Generate the rest of the bits using XOR operations from MSB to LSB
  genvar bit_index;
  for (bit_index = WIDTH-2; bit_index >= 0; bit_index = bit_index-1) begin : gen_bits
    assign offset_binary[bit_index] = offset_binary[bit_index+1] ^ gray[bit_index];
  end

  // The offset corresponds to the pruning of the ends of the next higher power-of-two range
  localparam OFFSET = (2 ** WIDTH - RANGE) / 2;
  assign binary = offset_binary - OFFSET;
end

// Odd range
else begin : gen_non_power_of_two_odd_range
  // Gray encoding requires even range
  initial $error("Gray encoding requires an even range.");
end

endmodule