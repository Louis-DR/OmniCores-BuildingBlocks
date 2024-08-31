// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        registered_synchronizer.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Registers a signal in its source clock domain and then       ║
// ║              resynchronizes it to a destination clock with flip-flops.    ║
// ║                                                                           ║
// ║              The added source clock domain register is useful to ensure   ║
// ║              stable glitch-free input to the synchronizer stages.         ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              The synchronized signal must last at least one clock cycle   ║
// ║              of the synchronizing clock. In practice, this synchronizer   ║
// ║              should be used between clock domains of the same frequency   ║
// ║              or when moving to to a faster clock domain.                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module registered_synchronizer #(
  parameter STAGES = 2
) (
  input  source_clock,
  input  destination_clock,
  input  resetn,
  input  data_in,
  output data_out
);

reg presynchronization_stage;

always @(posedge source_clock or negedge resetn) begin
  if (!resetn) presynchronization_stage <= 0;
  else begin
    presynchronization_stage <= data_in;
  end
end

synchronizer #(
  .STAGES   ( STAGES            )
) destination_synchronizer (
  .clock    ( destination_clock ),
  .resetn   ( resetn            ),
  .data_in  ( state_source      ),
  .data_out ( state_destination )
);

endmodule
