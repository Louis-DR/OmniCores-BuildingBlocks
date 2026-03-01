// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        running_clock_detector.v                                     ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Detects if a clock is running.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module running_clock_detector #(
  parameter DETECTOR_STAGES     = 2,
  parameter SYNCHRONIZER_STAGES = 2
) (
  input  reference_clock,
  input  observed_clock,
  input  resetn,
  output clock_is_running
);

// Detection flip-flop stages
reg [DETECTOR_STAGES-1:0] detection_stages;
integer stage_index;

// Synthesize as flip-flops with asynchronous set and clear
always @(posedge reference_clock or posedge observed_clock or negedge resetn) begin
  // Reset low
  if      (!resetn)        detection_stages <= '0;
  // Set high by the observed clock
  else if (observed_clock) detection_stages <= '1;
  // Low value propagated by reference clock
  else begin
    detection_stages[0] <= 0;
    for (stage_index = 1; stage_index < DETECTOR_STAGES; stage_index = stage_index+1) begin
      detection_stages[stage_index] <= detection_stages[stage_index-1];
    end
  end
end

// Unstable value because of the asynchronous set by the observed clock
wire clock_is_running_unstable = detection_stages[DETECTOR_STAGES-1];

// Resynchronized to the reference clock
synchronizer #(
  .STAGES   ( SYNCHRONIZER_STAGES )
) synchronizer (
  .clock    ( reference_clock           ),
  .resetn   ( resetn                    ),
  .data_in  ( clock_is_running_unstable ),
  .data_out ( clock_is_running          )
);

endmodule
