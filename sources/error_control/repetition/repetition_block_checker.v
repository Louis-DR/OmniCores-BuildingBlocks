// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_checker.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Check replicated data for errors.                            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_checker #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input [REPETITION*DATA_WIDTH-1:0] block,
  output                            error
);

// Group bits by repetition
wire [REPETITION-1:0] grouped_bits [DATA_WIDTH-1:0];
generate
  for (genvar repetition_index = 0; repetition_index < REPETITION; repetition_index++) begin : gen_repetitions
    for (genvar bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin : gen_bits
      assign grouped_bits[bit_index][repetition_index] = block[repetition_index*DATA_WIDTH + bit_index];
    end
  end
endgenerate

// Detect repetition errors
wire [DATA_WIDTH-1:0] error_position;
generate
  for (genvar bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin : gen_bits
    wire all_ones  =  & grouped_bits[bit_index];
    wire all_zeros = ~| grouped_bits[bit_index];
    assign error_position[bit_index] = ~(all_ones | all_zeros);
  end
endgenerate

assign error = |error_position;

endmodule
