// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        binary_to_bcd.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Binary to Binary-Coded Decimal encoder.                      ║
// ║                                                                           ║
// ║              This implementation is based on the Double-Dabble algorithm. ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "bcd.vh"



module binary_to_bcd #(
  parameter WIDTH_BINARY = 8,
  parameter WIDTH_BCD    = `BINARY_TO_BCD_WIDTH(WIDTH_BINARY) * 4
) (
  input [WIDTH_BINARY-1:0] binary,
  output   [WIDTH_BCD-1:0] bcd
);

localparam SCRATCH_WIDTH     = WIDTH_BCD + WIDTH_BINARY;
localparam NUMBER_ITERATIONS = WIDTH_BINARY;
localparam BCD_DIGIT_WIDTH   = 4;
localparam NUMBER_BCD_DIGITS = WIDTH_BCD / BCD_DIGIT_WIDTH;

wire [SCRATCH_WIDTH-1:0] scratch [NUMBER_ITERATIONS:0];

// Initialize the scratch with the binary input
assign scratch[0] = {{WIDTH_BCD{1'b0}}, binary};

generate
  for (genvar iteration = 0; iteration < NUMBER_ITERATIONS; iteration = iteration + 1) begin : double_dabble
    // Decode the BCD digits from the current scratch
    wire [3:0] bcd_digits [NUMBER_BCD_DIGITS-1:0];
    for (genvar digit = 0; digit < NUMBER_BCD_DIGITS; digit = digit + 1) begin : decode_bcd_digits
      assign bcd_digits[digit] = scratch[iteration][WIDTH_BINARY + BCD_DIGIT_WIDTH*digit +: BCD_DIGIT_WIDTH];
    end
    // Add 3 to any BCD digit which is at least 5
    wire [SCRATCH_WIDTH-1:0] scratch_temporary;
    for (genvar digit = 0; digit < NUMBER_BCD_DIGITS; digit = digit + 1) begin : add_3_to_bcd_digits
      assign scratch_temporary[WIDTH_BINARY + BCD_DIGIT_WIDTH*digit +: BCD_DIGIT_WIDTH] =
             (bcd_digits[digit] >= 5) ? bcd_digits[digit] + 3 : bcd_digits[digit];
    end
    // Copy the binary portion unchanged
    assign scratch_temporary[WIDTH_BINARY-1:0] = scratch[iteration][WIDTH_BINARY-1:0];
    // Shift left by 1
    shift_left #(
      .WIDTH ( SCRATCH_WIDTH )
    ) shift_left_inst (
      .data_in  ( scratch_temporary    ),
      .data_out ( scratch[iteration+1] )
    );
  end
endgenerate

assign bcd = scratch[NUMBER_ITERATIONS][WIDTH_BINARY +: WIDTH_BCD];

endmodule
