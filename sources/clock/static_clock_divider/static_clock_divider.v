// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_clock_divider.v                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Divides the frequency of the clock by the DIVISION factor    ║
// ║              parameter.                                                   ║
// ║                                                                           ║
// ║              If the division factor is 1 or lower, the clock is forwarded ║
// ║              without any logic.                                           ║
// ║                                                                           ║
// ║              If the division factor is odd, the high pulse is longer than ║
// ║              the low pulse by one cycle.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module static_clock_divider #(
  parameter DIVISION = 2
) (
  input  clock_in,
  input  resetn,
  output clock_out
);

// Division factor of 1 or less
if (DIVISION < 2) begin
  // Clock passes through
  assign clock_out = clock_in;
end

// Division factor is a power of two
else if (`IS_POW2(DIVISION)) begin

  // Width of the counter
  localparam DIVISION_LOG2 = `CLOG2(DIVISION);

  // Free-running counter
  reg [DIVISION_LOG2-1:0] counter;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      counter <= 0;
    end
    // Operation
    else begin
      counter <= counter + 1;
    end
  end

  // Use the MSB of the binary counter
  assign clock_out = counter[DIVISION_LOG2-1];
end

// Division factor of 2 or more and not a power of two
else begin

  // Width of the counter
  localparam DIVISION_LOG2 = `CLOG2(DIVISION);

  // Counter register
  reg [DIVISION_LOG2-1:0] counter;

  // Divided clock flop
  reg clock_divided;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      clock_divided <= 0;
      counter       <= 0;
    end
    // Operation
    else begin
      // Counter full, divided clock rising edge
      if (counter == DIVISION-1) begin
        clock_divided <= 1;
        counter       <= 0;
      end
      // Counter half, divided clock falling edge
      // The modulo part makes the high pulse longer for odd division factors
      else if (counter == DIVISION/2 - (1-DIVISION%2)) begin
        clock_divided <= 0;
        counter       <= counter + 1;
      end
      // Increment counter
      else begin
        counter       <= counter + 1;
      end
    end
  end

  // Connect the output clock to the divided clock flop
  assign clock_out = clock_divided;
end

endmodule
