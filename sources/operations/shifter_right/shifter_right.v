// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        shifter_right.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Shift a vector to the right and pad with a given value.      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module shifter_right #(
  parameter WIDTH     = 8,
  parameter SHIFT     = 1,
  parameter PAD_VALUE = 1'b0
) (
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

function automatic [WIDTH-1:0] shifter_right_f;
  input [WIDTH-1:0] data;
  reg [2*WIDTH-1:0] data_extended; // Reg because inside a function
  begin
    if (SHIFT < WIDTH) begin
      data_extended  = {{WIDTH{PAD_VALUE[0]}}, data_in};
      shifter_right_f = data_extended[SHIFT +: WIDTH];
    end else begin
      shifter_right_f = {WIDTH{PAD_VALUE[0]}};
    end
  end
endfunction

assign data_out = shifter_right_f(data_in);

endmodule
