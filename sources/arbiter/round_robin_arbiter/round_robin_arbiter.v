// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        round_robin_arbiter.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The priority of ║
// ║              the request channels shifts each cycle to ensure fairness of ║
// ║              arbitration.                                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module round_robin_arbiter #(
  parameter SIZE            = 4,
  parameter ROTATE_ON_GRANT = 0,
  parameter VARIANT         = "balanced"
) (
  input             clock,
  input             resetn,
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

generate
  // Small variant
  if (VARIANT == "small") begin : gen_small
    small_round_robin_arbiter #(
      .SIZE            ( SIZE            ),
      .ROTATE_ON_GRANT ( ROTATE_ON_GRANT )
    ) small_round_robin_arbiter (
      .clock    ( clock    ),
      .resetn   ( resetn   ),
      .requests ( requests ),
      .grant    ( grant    )
    );
  end

  // Balanced variant (default)
  else if (VARIANT == "balanced") begin : gen_balanced
    balanced_round_robin_arbiter #(
      .SIZE            ( SIZE            ),
      .ROTATE_ON_GRANT ( ROTATE_ON_GRANT )
    ) balanced_round_robin_arbiter (
      .clock    ( clock    ),
      .resetn   ( resetn   ),
      .requests ( requests ),
      .grant    ( grant    )
    );
  end

  // Fast variant
  else if (VARIANT == "fast") begin : gen_fast
    fast_round_robin_arbiter #(
      .SIZE            ( SIZE            ),
      .ROTATE_ON_GRANT ( ROTATE_ON_GRANT )
    ) fast_round_robin_arbiter (
      .clock    ( clock    ),
      .resetn   ( resetn   ),
      .requests ( requests ),
      .grant    ( grant    )
    );
  end

  // Invalid variant
  else begin : gen_invalid
    initial begin
      $error("Invalid variant of round_robin_arbiter : %s", VARIANT);
      $finish;
    end
  end
endgenerate

endmodule
