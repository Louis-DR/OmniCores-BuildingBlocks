// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        first_one.v                                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Determine the position of the first one in a vector.         ║
// ║                                                                           ║
// ║              This is a wrapper the small and fast variants.               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module first_one #(
  parameter WIDTH   = 8,
  parameter VARIANT = "fast"
) (
  input  [WIDTH-1:0] data,
  output [WIDTH-1:0] first_one
);

// Small variant
generate
  if (VARIANT == "small") begin : gen_small
    small_first_one #(
      .WIDTH     ( WIDTH     )
    ) small_first_one (
      .data      ( data      ),
      .first_one ( first_one )
    );
  end

  // Fast variant
  else if (VARIANT == "fast") begin : gen_fast
    fast_first_one #(
      .WIDTH     ( WIDTH     )
    ) fast_first_one (
      .data      ( data      ),
      .first_one ( first_one )
    );
  end

  // Invalid variant
  else begin : gen_invalid
    initial begin
      $error("Invalid variant of first_one : %s", VARIANT);
      $finish;
    end
  end
endgenerate

endmodule
