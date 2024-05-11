// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_synchronizer.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a pulse signal lasting one clock cycle to a    ║
// ║              different clock domain.                                      ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              Input pulses should be spaced out sufficiently to allow the  ║
// ║              resynchronization to occur and to prevent metastability of   ║
// ║              the input state flip-flop.                                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module pulse_synchronizer #(
  parameter STAGES = 2
) (
  input  source_clock,
  input  destination_clock,
  input  resetn,
  input  pulse_in,
  output pulse_out
);

reg            state;
reg [STAGES:0] stages;

wire state_resetn = resetn & ~stages[STAGES-1];

always @(posedge source_clock or negedge state_resetn) begin
  if (!state_resetn) state <= 0;
  else if (pulse_in) state <= 1;
end

integer stage_index;
always @(posedge destination_clock or negedge resetn) begin
  if (!resetn) stages <= 0;
  else begin
    stages[0] <= state;
    for (stage_index=1; stage_index<=STAGES; stage_index=stage_index+1) begin
      stages[stage_index] <= stages[stage_index-1];
    end
  end
end

assign pulse_out = stages[STAGES-1] & ~stages[STAGES];

endmodule