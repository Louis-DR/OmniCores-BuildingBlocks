// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_detector.v                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Detects if a clock is running.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module clock_detector #(
  parameter DETECTOR_STAGES     = 2
  parameter SYNCHRONIZER_STAGES = 2
) (
  input  reference_clock,
  input  observed_clock,
  input  resetn,
  output clock_is_running
);

reg [DETECTOR_STAGES-1:0] detection_stages;
integer stage_index;

always @(posedge reference_clock or posedge observed_clock or negedge resetn) begin
  if      (!resetn)        detection_stages <= '0;
  else if (observed_clock) detection_stages <= '1;
  else begin
    detection_stages[0] <= 0;
    for (stage_index = 1; stage_index < DETECTOR_STAGES; stage_index = stage_index+1) begin
      detection_stages[stage_index] <= detection_stages[stage_index-1];
    end
  end
end

wire clock_is_running_unstable = detection_stages[DETECTOR_STAGES-1]

synchronizer #(
  .STAGES   ( SYNCHRONIZER_STAGES )
) synchronizer (
  .clock    ( reference_clock           ),
  .resetn   ( resetn                    ),
  .data_in  ( clock_is_running_unstable ),
  .data_out ( clock_is_running          )
)

endmodule
