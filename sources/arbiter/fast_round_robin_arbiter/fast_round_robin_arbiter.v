// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_round_robin_arbiter.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The priority of ║
// ║              the request channels shifts each cycle to ensure fairness of ║
// ║              arbitration.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module fast_round_robin_arbiter #(
  parameter SIZE            = 4,
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

wire [SIZE-1:0] rotated_requests [SIZE-1:0];
wire [SIZE-1:0] rotated_grants   [SIZE-1:0];
wire [SIZE-1:0] grants           [SIZE-1:0];

genvar rotation_index;
generate
  for (rotation_index = 0; rotation_index < SIZE; rotation_index = rotation_index+1) begin : gen_rotated_requests

    rotate_left #(
      .WIDTH    ( SIZE           ),
      .ROTATION ( rotation_index )
    ) rotate_requests (
      .data_in  ( requests                         ),
      .data_out ( rotated_requests[rotation_index] )
    );

    static_priority_arbiter #(
      .SIZE     ( SIZE   ),
      .VARIANT  ( "fast" )
    ) static_priority_arbiter (
      .requests ( rotated_requests[rotation_index] ),
      .grant    ( rotated_grants[rotation_index]   )
    );

    rotate_right #(
      .WIDTH    ( SIZE           ),
      .ROTATION ( rotation_index )
    ) rotate_grants (
      .data_in  ( rotated_grants[rotation_index] ),
      .data_out ( grants[rotation_index]         )
    );

  end
endgenerate

assign grant = grants[rotating_pointer];

endmodule
