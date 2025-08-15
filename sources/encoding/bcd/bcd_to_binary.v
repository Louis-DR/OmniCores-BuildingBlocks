// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        bcd_to_binary.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Binary-Coded Decimal to binary decoder.                      ║
// ║                                                                           ║
// ║              This implementation is based on the reverse Double-Dabble    ║
// ║              algorithm.                                                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "bcd.vh"



module bcd_to_binary #(
  parameter WIDTH_BCD    = 8,
  parameter WIDTH_BINARY = `BCD_TO_BINARY_WIDTH(WIDTH_BCD)
) (
  input     [WIDTH_BCD-1:0] bcd,
  output [WIDTH_BINARY-1:0] binary
);

localparam SCRATCH_WIDTH     = WIDTH_BCD + WIDTH_BINARY;
localparam NUMBER_ITERATIONS = WIDTH_BINARY;
localparam BCD_DIGIT_WIDTH   = 4;
localparam NUMBER_BCD_DIGITS = WIDTH_BCD / BCD_DIGIT_WIDTH;

wire [SCRATCH_WIDTH-1:0] scratch [NUMBER_ITERATIONS:0];

generate
  for (genvar iteration = 0; iteration < NUMBER_ITERATIONS; iteration = iteration + 1) begin : reverse_double_dabble
    // Initialize the scratch with the BCD input
    if (iteration == 0) begin : initialization
      assign scratch[iteration] = {bcd, {WIDTH_BINARY{1'b0}}};
    end
    // For each iteration
    else begin : iteration
      // Shift the previous scratch right by 1
      wire [SCRATCH_WIDTH-1:0] scratch_temporary;
      shift_right #(
        .WIDTH ( SCRATCH_WIDTH )
      ) shift_right_inst (
        .data_in  ( scratch[iteration-1] ),
        .data_out ( scratch_temporary )
      );
      // Decode the BCD digits from the shifted scratch
      wire [3:0] bcd_digits [NUMBER_BCD_DIGITS-1:0];
      for (genvar digit = 0; digit < NUMBER_BCD_DIGITS; digit = digit + 1) begin : decode_bcd_digits
        assign bcd_digits[digit] = scratch_temporary[WIDTH_BINARY + BCD_DIGIT_WIDTH*digit +: BCD_DIGIT_WIDTH];
      end
      // Subtract 3 from any BCD digit which is at least 8
      for (genvar digit = 0; digit < NUMBER_BCD_DIGITS; digit = digit + 1) begin : subtract_3_from_bcd_digits
        assign scratch[iteration][WIDTH_BINARY + BCD_DIGIT_WIDTH*digit +: BCD_DIGIT_WIDTH] =
               (bcd_digits[digit] >= 8) ? bcd_digits[digit] - 3 : bcd_digits[digit];
      end
      // Copy the binary portion unchanged
      assign scratch[iteration][WIDTH_BINARY-1:0] = scratch_temporary[WIDTH_BINARY-1:0];
    end
  end
endgenerate

assign binary = scratch[NUMBER_ITERATIONS][WIDTH_BINARY-1:0];

endmodule
