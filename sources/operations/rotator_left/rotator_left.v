// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rotator_left.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Rotate a vector to the left.                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module rotator_left #(
  parameter WIDTH    = 8,
  parameter ROTATION = 1
) (
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

function [WIDTH-1:0] rotator_left_f;
  input [WIDTH-1:0] data;
  begin
    rotator_left_f = {data, data}[WIDTH - ROTATION +: WIDTH];
  end
endfunction

assign data_out = rotator_left_f(data_in);

endmodule
