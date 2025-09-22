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



module gray_to_binary #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] gray,
  output [WIDTH-1:0] binary
);

// The MSB remains the same
assign binary[WIDTH-1] = gray[WIDTH-1];

// Generate the rest of the bits using XOR operations from MSB to LSB
genvar bit_index;
generate
  for (bit_index = WIDTH-2; bit_index >= 0; bit_index = bit_index-1) begin : gen_bits
    assign binary[bit_index] = binary[bit_index+1] ^ gray[bit_index];
  end
endgenerate

endmodule