// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        galois_lfsr.v                                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Galois linear feedback shift register. The default taps are  ║
// ║              for a maximal length LFSR.                                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "galois_lfsr.vh"



module galois_lfsr #(
  parameter WIDTH = 8,
  parameter SEED  = 1,
  parameter TAPS  = `GET_GALOIS_LFSR_TAPS(WIDTH)
) (
  input                  clock,
  input                  resetn,
  input                  enable,
  output reg [WIDTH-1:0] value
);

wire feedback = value[0];

wire [WIDTH-1:0] value_next = {feedback, ({WIDTH-1{feedback}} & TAPS[WIDTH-2:0]) ^ value[WIDTH-1:1]};

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    value <= SEED;
  end else if (enable) begin
    value = value_next;
  end
end

endmodule
