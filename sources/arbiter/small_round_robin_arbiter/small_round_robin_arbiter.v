// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        small_round_robin_arbiter.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The priority of ║
// ║              the request channels shifts each cycle to ensure fairness of ║
// ║              arbitration.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module small_round_robin_arbiter #(
  parameter SIZE            = 4,
  parameter VARIANT         = "fast",
  parameter ROTATE_ON_GRANT = 0
) (
  input             clock,
  input             resetn,
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

localparam SIZE_LOG2 = `CLOG2(SIZE);

wire [SIZE_LOG2-1:0] rotating_pointer;
wire rotate_pointer = ROTATE_ON_GRANT ? |grant : 1;

wrapping_increment_counter #(
  .RANGE       ( SIZE             ),
  .RESET_VALUE ( '0               )
) rotating_pointer_counter (
  .clock       ( clock            ),
  .resetn      ( resetn           ),
  .increment   ( rotate_pointer   ),
  .count       ( rotating_pointer )
);

wire [SIZE-1:0] rotated_requests;
wire [SIZE-1:0] rotated_grant;

barrel_rotator_left #(
  .WIDTH    ( SIZE             )
) request_rotator (
  .data_in  ( requests         ),
  .rotation ( rotating_pointer ),
  .data_out ( rotated_requests )
);

static_priority_arbiter #(
  .SIZE     ( SIZE             ),
  .VARIANT  ( VARIANT          )
) static_priority_arbiter (
  .requests ( rotated_requests ),
  .grant    ( rotated_grant    )
);

barrel_rotator_right #(
  .WIDTH    ( SIZE             )
) grant_rotator (
  .data_in  ( rotated_grant    ),
  .rotation ( rotating_pointer ),
  .data_out ( grant            )
);

endmodule
