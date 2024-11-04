// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        extended_hamming_encoder.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Computes the Hamming code of the given data with an extra    ║
// ║              parity bit.                                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module extended_hamming_encoder #(
  parameter  DATA_WIDTH   = 8,
  localparam PARITY_WIDTH = (DATA_WIDTH <=     1) ?  3 : // Hamming(  4,  1)
                            (DATA_WIDTH <=     4) ?  4 : // Hamming(  8,  4)
                            (DATA_WIDTH <=    11) ?  5 : // Hamming( 16, 11)
                            (DATA_WIDTH <=    26) ?  6 : // Hamming( 32, 26)
                            (DATA_WIDTH <=    57) ?  7 : // Hamming( 64, 57)
                            (DATA_WIDTH <=   120) ?  8 : // Hamming(128,120)
                            (DATA_WIDTH <=   247) ?  9 : // Hamming(256,247)
                            (DATA_WIDTH <=   502) ? 10 :
                            (DATA_WIDTH <=  1013) ? 11 :
                            (DATA_WIDTH <=  2036) ? 12 :
                            (DATA_WIDTH <=  4083) ? 13 :
                            (DATA_WIDTH <=  8178) ? 14 :
                            (DATA_WIDTH <= 16369) ? 15 :
                            (DATA_WIDTH <= 32752) ? 16 :
                            (DATA_WIDTH <= 65519) ? 17 : -1,
  localparam BLOCK_WIDTH = DATA_WIDTH+PARITY_WIDTH
) (
  input    [DATA_WIDTH-1:0] data,
  output [PARITY_WIDTH-1:0] code,
  output  [BLOCK_WIDTH-1:0] block
);

// First generate the Hamming parity bits
wire [BLOCK_WIDTH-2:0] hamming_block;
hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_encoder (
  .data  ( data          ),
  .code  (               ),
  .block ( hamming_block )
);

// Second generate the extra parity bit
wire extra_parity;
parity_encoder #(
  .DATA_WIDTH ( BLOCK_WIDTH-1 )
) parity_encoder (
  .data   ( hamming_block ),
  .code   ( extra_parity  )
);

// Concatenate the block
assign block = {hamming_block, extra_parity};

endmodule
