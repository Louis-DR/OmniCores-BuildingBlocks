// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_encoder.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Computes the Hamming code of the given data.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming_encoder.svh"



module hamming_encoder #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH),
  localparam BLOCK_WIDTH  = DATA_WIDTH+PARITY_WIDTH
) (
  input    [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code,
  output  [BLOCK_WIDTH-1:0] block
);

// Pad the data to the message length corresponding to the number of parity bits
localparam PADDED_DATA_WIDTH = `GET_HAMMING_DATA_WIDTH(PARITY_WIDTH);
logic [PADDED_DATA_WIDTH-1:0] data_padded;
assign data_padded = {{(PADDED_DATA_WIDTH-DATA_WIDTH){1'b0}}, data};

// Pad the block
localparam PADDED_BLOCK_WIDTH = PADDED_DATA_WIDTH+PARITY_WIDTH;
logic [PADDED_BLOCK_WIDTH-1:0] block_padded;

// Parity bits, combinational
logic [PARITY_WIDTH-1:0] parity;
assign code = parity;

// Place the parity bits in the block
generate
  for (genvar parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin : gen_code_and_data_1
    assign block_padded[2**parity_index-1] = parity[parity_index];
  end
endgenerate

// Place the data bits in the block
generate
  for (genvar parity_index = 2; parity_index <= PARITY_WIDTH; parity_index++) begin : gen_code_and_data_2
    assign block_padded[ 2** parity_index    - 2
                       : 2**(parity_index-1)     ] = data_padded[ 2**parity_index                       - parity_index - 2
                                                                : 2**parity_index - 2**(parity_index-1) - parity_index     ];
  end
endgenerate

// Generate the parity bits
always_comb begin
  parity = 0;
  for (integer bit_index = 0; bit_index < PADDED_DATA_WIDTH; bit_index++) begin
    for (integer parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin
      if (parity_index != bit_index) begin
        if ( ((bit_index + 1) % (2**(parity_index+1))) >= (2**(parity_index)) ) begin
          parity[parity_index] ^= block[bit_index];
        end
      end
    end
  end
end

// Block output
assign block = block_padded[BLOCK_WIDTH-1:0];

endmodule
