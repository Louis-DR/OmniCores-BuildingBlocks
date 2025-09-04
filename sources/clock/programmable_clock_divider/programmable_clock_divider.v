// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        programmable_clock_divider.v                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Divides the frequency of the clock by the division factor    ║
// ║              input.                                                       ║
// ║                                                                           ║
// ║              If if the parameter POWER_OF_TWO is zero, then it divides by ║
// ║              the value of the division input plus one.                    ║
// ║               - division=0 : passthrough                                  ║
// ║               - division=1 : divide by 2                                  ║
// ║               - division=2 : divide by 3                                  ║
// ║               - division=n : divide by n+1                                ║
// ║              If the division factor is odd, the high pulse is longer than ║
// ║              the low pulse by one cycle.                                  ║
// ║                                                                           ║
// ║              If if the parameter POWER_OF_TWO is one, then it divides by  ║
// ║              two to the power of the division input.                      ║
// ║               - division=0 : passthrough                                  ║
// ║               - division=1 : divide by 2                                  ║
// ║               - division=2 : divide by 4                                  ║
// ║               - division=n : divide by 2^n                                ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module programmable_clock_divider #(
  parameter DIVISION_WIDTH = 4,
  parameter POWER_OF_TWO   = 0
) (
  input                      clock_in,
  input                      resetn,
  input [DIVISION_WIDTH-1:0] division,
  output                     clock_out
);

// Division factor registered to prevent glitches
reg [DIVISION_WIDTH-1:0] division_reg;

// Coarse power-of-two division
if (POWER_OF_TWO == 1) begin

  // Chain of flops for clock dividion, each dividing the previous output frequency by 2
  localparam DIVISION_WIDTH_POW2 = 2**DIVISION_WIDTH;
  reg [DIVISION_WIDTH_POW2-1:0] chain_divider;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      division_reg  <= division;
      chain_divider <= 0;
    end
    // Operation
    else begin
      // Should be synthesized as chain of toggle flip-flops
      chain_divider <= chain_divider + 1;
      // Update division factor on counter overflow
      if (chain_divider == {DIVISION_WIDTH_POW2{1'b1}}) begin
        division_reg <= division;
      end
    end
  end

  // Tap the division chain for the correct power-of-two factor
  assign clock_out = (division_reg == 0) ? clock_in : chain_divider[division_reg-1];
end

// Fine decimal division
else begin

  // Counter register
  reg [DIVISION_WIDTH-1:0] counter;

  // Divided clock flop
  reg clock_divided;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      division_reg  <= division;
      clock_divided <= 0;
      counter       <= 0;
    end
    // Operation
    else begin
      // Passthrough
      if (division_reg == 0) begin
        counter       <= 0;
        clock_divided <= 0;
        // Update division factor
        division_reg  <= division;
      end
      // Division
      else begin
        // Counter max, divided clock rising edge
        if (counter == division_reg) begin
          clock_divided <= 1;
          counter       <= 0;
          // Update division factor
          division_reg  <= division;
        end
        // Counter half, divided clock falling edge
        // The formula is equivalent to `ceil(division_reg/2)-1`
        // which makes the high pulse longer for odd division factor
        else if (counter == ((division_reg + 2) / 2) - 1) begin
          clock_divided <= 0;
          counter       <= counter + 1;
        end
        // Increment counter
        else begin
          counter <= counter + 1;
        end
      end
    end
  end

  assign clock_out = (division_reg == 0) ? clock_in : clock_out_generated;

  // Connect the output clock to the divided clock flop
  assign clock_out_generated = clock_divided;
end

endmodule
