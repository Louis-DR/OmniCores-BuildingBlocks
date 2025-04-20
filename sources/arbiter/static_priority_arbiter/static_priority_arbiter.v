// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_arbiter.v                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The grant is    ║
// ║              given to the first ready request channel (the least          ║
// ║              significant one bit).                                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module static_priority_arbiter #(
  parameter SIZE = 4
) (
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

first_one #(
  .WIDTH     ( SIZE     )
) first_one (
  .data      ( requests ),
  .first_one ( grant    )
);

endmodule
