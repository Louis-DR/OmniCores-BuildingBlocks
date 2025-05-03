// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_arbiter.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The grant is    ║
// ║              given to the first ready request channel. It works by        ║
// ║              finding the first one in the request bus.                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module static_priority_arbiter #(
  parameter SIZE    = 4,
  parameter VARIANT = "fast"
) (
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

first_one #(
  .WIDTH     ( SIZE     ),
  .VARIANT   ( VARIANT  )
) first_one (
  .data      ( requests ),
  .first_one ( grant    )
);

endmodule
