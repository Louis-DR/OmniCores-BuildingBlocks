// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        multi_edge_detector.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Generates separate pulses at the rising and falling edges of ║
// ║              a signal, and also a pulse for both edges.                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module multi_edge_detector (
  input  clock,
  input  resetn,
  input  signal,
  output any_edge,
  output rising_edge,
  output falling_edge
);

reg signal_previous;

always @(posedge clock or negedge resetn) begin
  if (!resetn) signal_previous <= 0;
  else         signal_previous <= signal;
end

assign any_edge     =  signal ^  signal_previous;
assign rising_edge  =  signal & ~signal_previous;
assign falling_edge = ~signal &  signal_previous;

endmodule
