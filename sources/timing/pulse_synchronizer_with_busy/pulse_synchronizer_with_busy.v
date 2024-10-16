// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
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

reg  state_source;
wire state_destination;
wire feedback;

wire state_resetn = resetn & ~state_destination;

always @(posedge source_clock or negedge state_resetn) begin
  if (!state_resetn) state_source <= 0;
  else if (pulse_in) state_source <= 1;
end

synchronizer #(
  .STAGES   ( STAGES            )
) state_synchronizer (
  .clock    ( destination_clock ),
  .resetn   ( resetn            ),
  .data_in  ( state_source      ),
  .data_out ( state_destination )
);

rising_edge_detector pulse_generator (
  .clock       ( destination_clock ),
  .resetn      ( resetn            ),
  .signal      ( state_destination ),
  .rising_edge ( pulse_out         )
);

synchronizer #(
  .STAGES   ( STAGES            )
) feedback_synchronizer (
  .clock    ( source_clock      ),
  .resetn   ( resetn            ),
  .data_in  ( state_destination ),
  .data_out ( feedback          )
);

assign busy = state | feedback;

endmodule
