// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_block_corrector.sv                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Corrects single-bit errors in Hamming block.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "hamming.svh"



module hamming_block_corrector #(
  parameter  BLOCK_WIDTH      = 7,
  localparam DATA_WIDTH       = `GET_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam PARITY_WIDTH     = `GET_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH),
  localparam BLOCK_WIDTH_LOG2 = $clog2(BLOCK_WIDTH)
) (
  input             [BLOCK_WIDTH-1:0] block,
  output                              error,
  output            [BLOCK_WIDTH-1:0] corrected_block,
  output logic [BLOCK_WIDTH_LOG2-1:0] corrected_error_position
);

// Extract the data and code from the block
logic   [DATA_WIDTH-1:0] data;
logic [PARITY_WIDTH-1:0] received_code;

hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) unpacker (
  .block ( block         ),
  .data  ( data          ),
  .code  ( received_code )
);

// Calculate the expected code
logic [PARITY_WIDTH-1:0] expected_code;

hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) encoder (
  .data  ( data          ),
  .code  ( expected_code ),
  .block (               )
);

// Calculate the syndrome
logic [PARITY_WIDTH-1:0] syndrome;
assign syndrome = received_code ^ expected_code;

// Error detected if the syndrome is non-zero
assign error = |syndrome;

// Correct the error if the syndrome points to a data bit position
logic [BLOCK_WIDTH-1:0] error_mask;

// Generate the error mask based on the syndrome
integer syndrome_value;
always_comb begin
  syndrome_value = syndrome;
  corrected_error_position = 0;
  error_mask = 0;
  // Bounds checking
  if (syndrome_value > 0 && syndrome_value < BLOCK_WIDTH + 1) begin
    // The syndrome points to the position of the error in the block
    corrected_error_position = syndrome_value - 1;
    error_mask[corrected_error_position] = 1'b1;
  end
end

// Correct the block by XORing with the error mask
assign corrected_block = block ^ error_mask;

endmodule