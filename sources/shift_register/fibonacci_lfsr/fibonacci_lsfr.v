// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fibonacci_lfsr.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Fibonacci linear feedback shift register. The default taps   ║
// ║              are for a maximal length LFSR.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module fibonacci_lfsr #(
  parameter WIDTH = 8,
  parameter TAPS  = 8'b000011101,
  parameter SEED  = 1
) (
  input                  clock,
  input                  resetn,
  input                  enable,
  output reg [WIDTH-1:0] value
);

wire feedback = ^(value & TAPS);

wire [WIDTH-1:0] value_next = {feedback, value[WIDTH-1:1]};

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    value <= SEED;
  end else if (enable) begin
    value = value_next;
  end
end

endmodule
