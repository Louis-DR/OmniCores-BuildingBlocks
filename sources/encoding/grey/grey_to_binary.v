// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        grey_to_binary.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Grey to binary decoder.                                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module grey_to_binary #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] grey,
  output [WIDTH-1:0] binary
);

  // The MSB remains the same
  assign binary[WIDTH-1] = grey[WIDTH-1];

  // Generate the rest of the bits using XOR operations from MSB to LSB
  generate
    for (genvar bit_index = WIDTH-2; bit_index >= 0; bit_index--) begin : gen_bits
      assign binary[bit_index] = binary[bit_index+1] ^ grey[bit_index];
    end
  endgenerate

endmodule