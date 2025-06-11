// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        feedback_pulse_synchronizer.v                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a pulse signal lasting one clock cycle to a    ║
// ║              different clock domain using a feedback from the destination ║
// ║              domain to the source domain, and notify when it is busy.     ║
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



module feedback_pulse_synchronizer #(
  parameter STAGES = 2
) (
  input  source_clock,
  input  source_resetn,
  input  destination_clock,
  input  destination_resetn,
  input  pulse_in,
  output pulse_out,
  output busy
);

wire state_source;
wire state_destination;
wire feedback;

set_reset_flip_flop_with_reset #(
  .RESET_VALUE ( 0 )
) state_flip_flop (
  .clock  ( source_clock  ),
  .resetn ( source_resetn ),
  .set    ( pulse_in      ),
  .reset  ( feedback      ),
  .state  ( state_source  )
);

synchronizer #(
  .STAGES   ( STAGES )
) state_synchronizer (
  .clock    ( destination_clock  ),
  .resetn   ( destination_resetn ),
  .data_in  ( state_source       ),
  .data_out ( state_destination  )
);

rising_edge_detector pulse_generator (
  .clock       ( destination_clock  ),
  .resetn      ( destination_resetn ),
  .signal      ( state_destination  ),
  .rising_edge ( pulse_out          )
);

synchronizer #(
  .STAGES   ( STAGES )
) feedback_synchronizer (
  .clock    ( source_clock       ),
  .resetn   ( destination_resetn ),
  .data_in  ( state_destination  ),
  .data_out ( feedback           )
);

assign busy = state_source | feedback;

endmodule
