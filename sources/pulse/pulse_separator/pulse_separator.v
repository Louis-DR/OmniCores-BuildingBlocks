// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     VerSiTile-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_separator.v                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Generate one-cycle pulses from multi-cycle pulses. For       ║
// ║              instance, a four-cycle long input pulse results in four      ║
// ║              successive one-cycle pulses. Therefore it can only generate  ║
// ║              pulses at half the clock frequency.                          ║
// ║                                                                           ║
// ║              It uses an internal counter to keep track of how many pulses ║
// ║              to generate. If the counter is saturated because the input   ║
// ║              pulse frequency or length is too high, it emits a busy       ║
// ║              signal to create backpressure or to detect missed pulses.    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module pulse_separator #(
  parameter PULSE_COUNTER_WIDTH = 3
) (
  input      clock,
  input      resetn,
  input      pulse_in,
  output reg pulse_out,
  output     busy
);

reg  [PULSE_COUNTER_WIDTH-1:0] pulse_counter;
wire [PULSE_COUNTER_WIDTH-1:0] pulse_counter_next;
wire pulse_counter_is_not_zero  = pulse_counter != 0;
wire pulse_counter_is_saturated = pulse_counter == {PULSE_COUNTER_WIDTH{1'b1}};

wire pulse_out_next = pulse_counter_is_not_zero & ~pulse_out;

assign pulse_counter_next = pulse_counter + pulse_in - pulse_out;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    pulse_counter <= 0;
    pulse_out     <= 0;
  end else begin
    pulse_counter <= pulse_counter_next;
    pulse_out     <= pulse_out_next;
  end
end

assign busy = pulse_counter_is_saturated;

endmodule
