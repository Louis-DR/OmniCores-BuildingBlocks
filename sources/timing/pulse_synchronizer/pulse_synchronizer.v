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

reg  state_source;
wire state_destination;

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

endmodule
