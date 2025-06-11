// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        toggle_pulse_synchronizer.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a pulse signal lasting one clock cycle to a    ║
// ║              different clock domain using a toggle flop in the source     ║
// ║              domain.                                                      ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              Input pulses should be spaced out sufficiently to allow the  ║
// ║              resynchronization to occur and to prevent metastability of   ║
// ║              the input state flip-flop. The input pulse must be exactly   ║
// ║              one clock cycle.                                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module toggle_pulse_synchronizer #(
  parameter STAGES = 2
) (
  input  source_clock,
  input  source_resetn,
  input  destination_clock,
  input  destination_resetn,
  input  pulse_in,
  output pulse_out
);

wire state_source;
wire state_destination;

toggle_flip_flop_with_reset toggle_flip_flop (
  .clock  ( source_clock  ),
  .resetn ( source_resetn ),
  .toggle ( pulse_in      ),
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

edge_detector pulse_generator (
  .clock      ( destination_clock  ),
  .resetn     ( destination_resetn ),
  .signal     ( state_destination  ),
  .edge_pulse ( pulse_out          )
);

endmodule
