// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        balanced_round_robin_arbiter.v                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The priority of ║
// ║              the request channels shifts each cycle to ensure fairness of ║
// ║              arbitration.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module balanced_round_robin_arbiter #(
  parameter SIZE            = 4,
  parameter ROTATE_ON_GRANT = 0
) (
  input             clock,
  input             resetn,
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

// Rotating mask used to select the static arbiter
reg  [SIZE-1:0] region_mask;
wire [SIZE-1:0] region_mask_next;
wire [SIZE-1:0] region_mask_shifted;

// Reset the mask when it is a single 1 at the MSB
wire reset_mask = region_mask == {1'b1, {(SIZE-1){1'b0}}};

// When to rotate the mask
wire rotate_mask = ROTATE_ON_GRANT ? |grant : 1;

// Shift the 1s to the left and pad with 0s
shift_left #(
  .WIDTH     ( SIZE ),
  .SHIFT     ( 1    ),
  .PAD_VALUE ( 1'b0 )
) shift_region_mask (
  .data_in   ( region_mask         ),
  .data_out  ( region_mask_shifted )
);

// Next value of the mask
assign region_mask_next = reset_mask ? '1 : region_mask_shifted;

// Update the mask
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    region_mask <= '1;
  end
  else begin
    if (rotate_mask) begin
      region_mask <= region_mask_next;
    end
  end
end

// High priority region corresponds to channels marked by the mask
wire [SIZE-1:0] high_priority_region_requests = requests & region_mask;
wire [SIZE-1:0] high_priority_region_grant;

// Low priority region is the fallback (don't need to mask off the high priority region)
wire [SIZE-1:0] low_priority_region_requests = requests;
wire [SIZE-1:0] low_priority_region_grant;

// Arbiter for the high priority region
static_priority_arbiter #(
  .SIZE     ( SIZE   ),
  .VARIANT  ( "fast" )
) high_priority_region_arbiter (
  .requests ( high_priority_region_requests ),
  .grant    ( high_priority_region_grant    )
);

// Arbiter for the low priority region
static_priority_arbiter #(
  .SIZE     ( SIZE   ),
  .VARIANT  ( "fast" )
) low_priority_region_arbiter (
  .requests ( low_priority_region_requests ),
  .grant    ( low_priority_region_grant    )
);

// Grant in the high priority region if it is granted, otherwise grant in low priority region
wire high_priority_region_granted = |high_priority_region_grant;
assign grant = high_priority_region_granted ? high_priority_region_grant : low_priority_region_grant;

endmodule
