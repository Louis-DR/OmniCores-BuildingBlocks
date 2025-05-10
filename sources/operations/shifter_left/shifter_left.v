// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        shifter_left.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Shift a vector to the left and pad with a given value.       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module shifter_left #(
  parameter WIDTH     = 8,
  parameter SHIFT     = 1,
  parameter PAD_VALUE = 1'b0
) (
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

function automatic [WIDTH-1:0] shifter_left_f;
  input [WIDTH-1:0] data;
  reg [2*WIDTH-1:0] data_extended; // Reg because inside a function
  begin
    if (SHIFT < WIDTH) begin
      data_extended  = {data, {WIDTH{PAD_VALUE[0]}}};
      shifter_left_f = data_extended[WIDTH - SHIFT +: WIDTH];
    end else begin
      shifter_left_f = {WIDTH{PAD_VALUE[0]}};
    end
  end
endfunction

assign data_out = shifter_left_f(data_in);

endmodule
