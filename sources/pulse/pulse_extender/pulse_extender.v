// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_extender.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Forwards a pulse and extends its duration by a number of     ║
// ║              clock cycles as specified by its parameter.                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module pulse_extender #(
  parameter PULSE_LENGTH = 2
) (
  input  clock,
  input  resetn,
  input  pulse_in,
  output pulse_out
);

localparam COUNTER_WIDTH = `CLOG2(PULSE_LENGTH+1);

reg [COUNTER_WIDTH-1:0] counter;
wire counter_is_not_zero = counter != 0;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= 0;
  end else begin
    if (pulse_in) begin
      counter <= PULSE_LENGTH;
    end else if (counter_is_not_zero) begin
      counter <= counter - 1;
    end
  end
end

assign pulse_out = counter_is_not_zero;

endmodule
