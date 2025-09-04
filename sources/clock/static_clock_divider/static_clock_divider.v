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

  // Duration of the high and low pulses
  localparam HIGH_PULSE_DURATION = (DIVISION + 1) / 2;
  localparam  LOW_PULSE_DURATION =  DIVISION      / 2;

  // Half pulse count-down
  localparam COUNTDOWN_WIDTH = `CLOG2(HIGH_PULSE_DURATION);
  reg [COUNTDOWN_WIDTH-1:0] countdown;

  // Divided clock flop, acts as the FSM state
  reg clock_divided;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      // Low pulse at reset
      clock_divided <= 0;
      countdown     <= LOW_PULSE_DURATION - 1;
    end
    // Operation
    else begin
      // When the countdown reaches zero, the current pulse has ended
      if (countdown == 0) begin
        // Invert the clock output
        clock_divided <= ~clock_divided;
        // Reload countdown based on the current pulse polarity
        if (clock_divided == 0) begin
          countdown <= HIGH_PULSE_DURATION - 1;
        end else begin
          countdown <= LOW_PULSE_DURATION - 1;
        end
      end
      // Keep counting down
      else begin
        countdown <= countdown - 1;
      end
    end
  end

  // Connect the output clock to the divided clock flop
  assign clock_out = clock_divided;
end

endmodule
