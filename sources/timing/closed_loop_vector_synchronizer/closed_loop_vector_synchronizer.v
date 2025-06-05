// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        closed_loop_vector_synchronizer.v                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a vector of signals to a clock with flip-flop  ║
// ║              stages. All bits are transmitted at once.                    ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              The input data vector is captured in a first stage in the    ║
// ║              source domain. When the input data changes, an update pulse  ║
// ║              is generated. It is then synchronized to the destination     ║
// ║              domain and triggers the capture of data of the source stage  ║
// ║              the destination stage.                                       ║
// ║                                                                           ║
// ║              The delay introduced by the synchronization of the pulse to  ║
// ║              the destination domain allows for the data to stabilize      ║
// ║              between the source and destination capture stages.           ║
// ║                                                                           ║
// ║              When the updated data is being synchronized, the busy signal ║
// ║              is asserted and the input data is no longer captured by the  ║
// ║              source stage. The busy output can be used by the upstream    ║
// ║              logic in the source domain to prevent the data from changing ║
// ║              too quickly.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module closed_loop_vector_synchronizer #(
  parameter WIDTH  = 8,
  parameter STAGES = 2
) (
  input              source_clock,
  input              source_resetn,
  input              destination_clock,
  input              destination_resetn,
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out,
  output             busy
);

reg [WIDTH-1:0] source_stage;
reg [WIDTH-1:0] destination_stage;

wire update_pulse = data_in != source_stage;
wire capture_pulse;
wire feedback_pulse;

set_reset_flip_flop_with_asynchronous_reset #(
  .RESET_VALUE ( 0 )
) busy_flip_flop (
  .clock  ( source_clock   ),
  .resetn ( source_resetn  ),
  .set    ( update_pulse   ),
  .reset  ( feedback_pulse ),
  .state  ( busy           )
);

toggle_pulse_synchronizer #(
  .STAGES ( STAGES )
) update_pulse_synchronizer (
  .clock     ( destination_clock  ),
  .resetn    ( destination_resetn ),
  .pulse_in  ( update_pulse       ),
  .pulse_out ( capture_pulse      )
);

toggle_pulse_synchronizer #(
  .STAGES ( STAGES )
) feedback_pulse_synchronizer (
  .clock     ( source_clock   ),
  .resetn    ( source_resetn  ),
  .pulse_in  ( capture_pulse  ),
  .pulse_out ( feedback_pulse )
);

always @(posedge source_clock or negedge source_resetn) begin
  if (!source_resetn) source_stage <= 0;
  else if (!busy)     source_stage <= data_in;
end

always @(posedge destination_clock or negedge destination_resetn) begin
  if (!destination_resetn) destination_stage <= 0;
  else if (capture_pulse)  destination_stage <= source_stage;
end

assign data_out = destination_stage;

endmodule
