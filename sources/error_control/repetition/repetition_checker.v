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
  parameter REPETITION_INDEX = 3
) (
  input                        [DATA_WIDTH-1:0] data,
  input [(REPETITION_INDEX-1)*(DATA_WIDTH-1):0] code,
  output                                        error
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

wire [DATA_WIDTH-1:0] error_position;

generate
  for (genvar bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin : gen_bits
    wire all_ones  =  & grouped_bits[bit_index];
    wire all_zeros = ~| grouped_bits[bit_index];
    assign error_position[bit_index] = ($countones(grouped_bits[bit_index]) > (REPETITION / 2)) ? 1'b1 : 1'b0;
  end
endgenerate

assign error = |error_position;

endmodule
