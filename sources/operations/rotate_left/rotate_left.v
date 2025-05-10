// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rotate_left.v                                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Rotate a vector to the left.                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module rotate_left #(
  parameter WIDTH    = 8,
  parameter ROTATION = 1
) (
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

localparam ROTATION_MOD = ROTATION % WIDTH;

function automatic [WIDTH-1:0] rotate_left_f;
  input [WIDTH-1:0] data;
  reg [2*WIDTH-1:0] data_extended; // Reg because inside a function
  begin
    data_extended  = {data, data};
    rotate_left_f = data_extended[WIDTH - ROTATION_MOD +: WIDTH];
  end
endfunction

assign data_out = rotate_left_f(data_in);

endmodule
