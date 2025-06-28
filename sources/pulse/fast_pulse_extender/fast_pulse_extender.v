// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_pulse_extender.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Forwards a pulse and extends its duration by a number of     ║
// ║              clock cycles as specified by its parameter. This is a fast   ║
// ║              variant that includes a combinational path from input to     ║
// ║              output, eliminating the one-cycle latency for immediate      ║
// ║              pulse response.                                              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fast_pulse_extender #(
  parameter PULSE_LENGTH = 2
) (
  input  clock,
  input  resetn,
  input  pulse_in,
  output pulse_out
);

localparam COUNTER_WIDTH = `CLOG2(PULSE_LENGTH);

reg [COUNTER_WIDTH-1:0] counter;
wire counter_is_not_zero = counter != 0;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= 0;
  end else begin
    if (pulse_in) begin
      counter <= PULSE_LENGTH - 1;
    end else if (counter_is_not_zero) begin
      counter <= counter - 1;
    end
  end
end

assign pulse_out = pulse_in | counter_is_not_zero;

endmodule