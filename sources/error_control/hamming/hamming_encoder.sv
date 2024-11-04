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



module hamming_encoder #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = (DATA_WIDTH <=     1) ?  2 : // Hamming(  3,  1)
                            (DATA_WIDTH <=     4) ?  3 : // Hamming(  7,  4)
                            (DATA_WIDTH <=    11) ?  4 : // Hamming( 15, 11)
                            (DATA_WIDTH <=    26) ?  5 : // Hamming( 31, 26)
                            (DATA_WIDTH <=    57) ?  6 : // Hamming( 63, 57)
                            (DATA_WIDTH <=   120) ?  7 : // Hamming(127,120)
                            (DATA_WIDTH <=   247) ?  8 : // Hamming(255,247)
                            (DATA_WIDTH <=   502) ?  9 :
                            (DATA_WIDTH <=  1013) ? 10 :
                            (DATA_WIDTH <=  2036) ? 11 :
                            (DATA_WIDTH <=  4083) ? 12 :
                            (DATA_WIDTH <=  8178) ? 13 :
                            (DATA_WIDTH <= 16369) ? 14 :
                            (DATA_WIDTH <= 32752) ? 15 :
                            (DATA_WIDTH <= 65519) ? 16 : -1,
  localparam BLOCK_WIDTH = DATA_WIDTH+PARITY_WIDTH
) (
  input    [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code,
  output  [BLOCK_WIDTH-1:0] block
);

// Pad the data to the message length corresponding to the number of parity bits
localparam PADDED_DATA_WIDTH = (DATA_WIDTH <=     1) ?     1 : // Hamming(  3,  1)
                               (DATA_WIDTH <=     4) ?     4 : // Hamming(  7,  4)
                               (DATA_WIDTH <=    11) ?    11 : // Hamming( 15, 11)
                               (DATA_WIDTH <=    26) ?    26 : // Hamming( 31, 26)
                               (DATA_WIDTH <=    57) ?    57 : // Hamming( 63, 57)
                               (DATA_WIDTH <=   120) ?   120 : // Hamming(127,120)
                               (DATA_WIDTH <=   247) ?   247 : // Hamming(255,247)
                               (DATA_WIDTH <=   502) ?   502 :
                               (DATA_WIDTH <=  1013) ?  1013 :
                               (DATA_WIDTH <=  2036) ?  2036 :
                               (DATA_WIDTH <=  4083) ?  4083 :
                               (DATA_WIDTH <=  8178) ?  8178 :
                               (DATA_WIDTH <= 16369) ? 16369 :
                               (DATA_WIDTH <= 32752) ? 32752 :
                               (DATA_WIDTH <= 65519) ? 65519 : -1;
logic [PADDED_DATA_WIDTH-1:0] data_padded = {{PADDED_DATA_WIDTH-DATA_WIDTH{1'b0}}, data};

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
  for (genvar parity_index = 2; parity_index < PARITY_WIDTH; parity_index++) begin : gen_code_and_data_2
    assign block_padded[ 2** parity_index    - 2
                       : 2**(parity_index-1)     ] = data[ 2**parity_index                       - parity_index - 2
                                                         : 2**parity_index - 2**(parity_index-1) - parity_index     ];
  end
endgenerate

// Generate the parity bits
always_comb begin
  parity = 0;
  for (integer bit_index = 0; bit_index < PADDED_DATA_WIDTH; bit_index++) begin
    for (integer parity_index = 0; parity_index < PARITY_WIDTH; parity_index++) begin
      if ( ((bit_index + 1) % (2**(parity_index+1))) >= (2**(parity_index)) ) begin
        parity[parity_index] = parity[parity_index] ^ block[bit_index];
      end
    end
  end
end

// Block output
assign block = block_padded[BLOCK_WIDTH-1:0];

endmodule
