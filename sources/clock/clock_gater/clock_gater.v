// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     VerSiTile-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        clock_gater.v                                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Gate the clock with the enable signal using a latch-and      ║
// ║              architecture. It also has a second enable signal for test    ║
// ║              mode.                                                        ║
// ║                                                                           ║
// ║              This clock gater should be used as a behavioral model and    ║
// ║              replaced with a technology specific integrated clock gater.  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module clock_gater (
  input  clock_in,
  input  enable,
  input  test_enable,
  output clock_out
);

reg enable_latched;

always @(negedge clock_in) begin
  enable_latched <= enable | test_enable;
end

assign clock_out = clock_in & enable_latched;

endmodule
