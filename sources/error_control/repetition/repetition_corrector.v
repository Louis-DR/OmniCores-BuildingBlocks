// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        repetition_corrector.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects errors in replicated data using majority voting.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module repetition_corrector #(
  parameter DATA_WIDTH = 8,
  parameter REPETITION = 3
) (
  input                  [DATA_WIDTH-1:0] data,
  input [(REPETITION-1)*(DATA_WIDTH-1):0] code,
  output                                  error,
  output                 [DATA_WIDTH-1:0] corrected_data
);

wire [REPETITION_INDEX(DATA_WIDTH-1):0] repeated_data;
assign repeated_data = {data, code};

wire [REPETITION-1:0] grouped_bits [DATA_WIDTH-1:0];

generate
  for (genvar repetition_index = 0; repetition_index < REPETITION; repetition_index = repetition_index++) begin : gen_repetitions
    for (genvar bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin : gen_bits
      assign grouped_bits[bit_index][repetition_index] = repeated_data[repetition_index*DATA_WIDTH + bit_index];
    end
  end
endgenerate

generate
  for (genvar bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin : gen_bits
    wire all_ones  =  & grouped_bits[bit_index];
    wire all_zeros = ~| grouped_bits[bit_index];
    assign corrected_data[bit_index] = ($countones(grouped_bits[bit_index]) > (REPETITION / 2)) ? 1'b1 : 1'b0;
  end
endgenerate

endmodule
