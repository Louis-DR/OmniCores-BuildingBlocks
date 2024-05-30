// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     VerSiTile-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        edge_detector.v                                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Generates a pulse at the rising and falling edge of a        ║
// ║              signal.                                                      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module edge_detector (
  input  clock,
  input  resetn,
  input  signal,
  output edge_pulse
);

reg signal_previous;

always @(posedge clock or negedge resetn) begin
  if (!resetn) signal_previous <= 0;
  else         signal_previous <= signal;
end

assign edge_pulse = signal ^ signal_previous;

endmodule
