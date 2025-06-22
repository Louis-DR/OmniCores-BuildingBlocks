// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_first_one.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Determine the position of the first one in a vector using a  ║
// ║              Sklansky-style parallel prefix network.                      ║
// ║                                                                           ║
// ║              This variant is fast (O(log2(WIDTH)) delay) but large        ║
// ║              (O(WIDTH) gates). There is a smaller variant.                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fast_first_one #(
  parameter WIDTH = 8
) (
  input  [WIDTH-1:0] data,
  output [WIDTH-1:0] first_one
);

localparam WIDTH_LOG2 = `CLOG2(WIDTH);

// Array for parallel prefix OR
wire [WIDTH-1:0] prefix_or_stages [WIDTH_LOG2:0];

// Stage 0 is just the input data
assign prefix_or_stages[0] = data;

genvar stage_index;
genvar bit_index;
generate
  // Iterate over stages
  for (stage_index = 0; stage_index < WIDTH_LOG2; stage_index = stage_index+1) begin : gen_stages
    // For each stage, we combine prefixes from the previous stage at a distance of 2^stage_index
    localparam distance = 2 ** stage_index;
    // Iterate over all bits
    for (bit_index = 0; bit_index < WIDTH; bit_index = bit_index+1) begin : gen_bits
      // For bits below the distance, the required left-side prefix doesn't exist at the previous stage,
      if (bit_index < distance) begin
        // So just propagate the prefix from the previous stage
        assign prefix_or_stages[stage_index+1][bit_index] = prefix_or_stages[stage_index][bit_index];
      end
      // For bits above the distance, we can combine the prefixes
      else begin
        // Compute prefix by ORing two prefixes from the previous level with a distance of 2^stage_index
        assign prefix_or_stages[stage_index+1][bit_index] = prefix_or_stages[stage_index][bit_index]
                                                          | prefix_or_stages[stage_index][bit_index - distance];
      end
    end
  end
endgenerate

// The final prefix OR vector where prefix_or_vector[i] = data[i] | ... | data[0]
wire [WIDTH-1:0] prefix_or_vector = prefix_or_stages[WIDTH_LOG2];

// Shift the prefix OR vector once to the left
wire [WIDTH-1:0] prefix_or_vector_shifted;
shift_left #(
  .WIDTH     ( WIDTH ),
  .SHIFT     ( 1     ),
  .PAD_VALUE ( 1'b0  )
) shift_prefix_or_vector (
  .data_in   ( prefix_or_vector         ),
  .data_out  ( prefix_or_vector_shifted )
);

// Detect the first one by ANDing the original data with the complement of the prefix OR vector shifted once to the left
assign first_one = data & ~prefix_or_vector_shifted;

endmodule
