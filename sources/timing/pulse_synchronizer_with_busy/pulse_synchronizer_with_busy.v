// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        pulse_synchronizer_with_busy.v                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a pulse signal lasting one clock cycle to a    ║
// ║              different clock domain, and notifies when it is busy.        ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              When a pulse is being resynchronized, the device is busy and ║
// ║              no other input pulse can be received. The busy output signal ║
// ║              can be used to prevent the upstream device from generating a ║
// ║              pulse when the synchronizer is busy.                         ║
// ║                                                                           ║
// ║              This pulse resynchronizer needs more time between input      ║
// ║              pulses because it resynchronizes the feedback to drive the   ║
// ║              busy signal.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module pulse_synchronizer_with_busy #(
  parameter STAGES = 2
) (
  input  source_clock,
  input  destination_clock,
  input  resetn,
  input  pulse_in,
  output pulse_out,
  output busy
);

reg            state;
reg [STAGES:0] stages;
wire           feedback;

wire state_resetn = resetn & ~feedback;

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

synchronizer #(
  .STAGES   ( STAGES           )
) feedback_synchronizer (
  .clock    ( source_clock     ),
  .resetn   ( resetn           ),
  .data_in  ( stages[STAGES-1] ),
  .data_out ( feedback         )
);

assign busy = state | feedback;

endmodule
