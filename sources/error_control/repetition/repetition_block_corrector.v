// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_block_corrector.v                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects errors in replicated data using majority voting.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_block_corrector #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input [REPETITION*DATA_WIDTH-1:0] block,
  output                            error,
  output           [DATA_WIDTH-1:0] corrected_data
);

genvar repetition_index;
genvar bit_index;

// Group bits by repetition
wire [REPETITION-1:0] grouped_bits [DATA_WIDTH-1:0];
generate
  for (repetition_index = 0; repetition_index < REPETITION; repetition_index = repetition_index+1) begin : gen_repetitions
    for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index+1) begin : gen_bits
      assign grouped_bits[bit_index][repetition_index] = block[repetition_index*DATA_WIDTH + bit_index];
    end
  end
endgenerate

// Detect repetition errors
wire [DATA_WIDTH-1:0] error_position;
generate
  for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index+1) begin : gen_bits
    wire all_ones  =  & grouped_bits[bit_index];
    wire all_zeros = ~| grouped_bits[bit_index];
    assign error_position[bit_index] = ~(all_ones | all_zeros);
    assign corrected_data[bit_index] = ($countones(grouped_bits[bit_index]) > (REPETITION / 2)) ? 1'b1 : 1'b0;
  end
endgenerate

assign error = |error_position;

endmodule
