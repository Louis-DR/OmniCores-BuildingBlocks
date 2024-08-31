// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rising_edge_detector.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Generates a pulse at the rising edge of a signal.            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module rising_edge_detector (
  input  clock,
  input  resetn,
  input  signal,
  output rising_edge
);

reg signal_previous;

always @(posedge clock or negedge resetn) begin
  if (!resetn) signal_previous <= 0;
  else         signal_previous <= signal;
end

assign rising_edge = signal & ~signal_previous;

endmodule
