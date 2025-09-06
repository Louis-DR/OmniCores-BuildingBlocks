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



`include "clog2.vh"



module programmable_clock_divider #(
  parameter DIVISION_WIDTH = 4,
  parameter POWER_OF_TWO   = 0
) (
  input                      clock_in,
  input                      resetn,
  input [DIVISION_WIDTH-1:0] division,
  output                     clock_out
);

// Generated clock signal before multiplexing
reg clock_divider;

// Division factor registered to prevent glitches
reg [DIVISION_WIDTH-1:0] division_reg;
wire passthrough_mode = division_reg == 0;
wire division_mode    = ~passthrough_mode;

// Use a glitchless multiplexer to switch between passthrough and divided clock
clock_multiplexer #(
  .STAGES ( 1 ) // Clocks are synchronous
) clock_out_multiplexer (
  .clock_0   ( clock_in      ),
  .clock_1   ( clock_divider ),
  .resetn_0  ( resetn        ),
  .resetn_1  ( resetn        ),
  .select    ( division_mode ),
  .clock_out ( clock_out     )
);

// Coarse power-of-two division
if (POWER_OF_TWO == 1) begin

  // Half pulse count-down
  localparam COUNTDOWN_WIDTH = (2**DIVISION_WIDTH) - 1;
  reg [COUNTDOWN_WIDTH-1:0] countdown;

  // The duration of each half-pulse is 2^(division-1) cycles.
  // The value to load is the duration - 1.
  wire [COUNTDOWN_WIDTH-1:0] reload_value = (division_reg > 0) ? (1 << (division_reg - 1)) - 1 : 0;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      division_reg  <= division;
      clock_divider <= 0;
      // Initialize countdown based on the initial division value
      countdown     <= (division > 0) ? (1 << (division - 1)) - 1 : 0;
    end
    // Operation
    else begin
      // Passthrough mode
      if (passthrough_mode) begin
        countdown     <= 0;
        clock_divider <= 0;
        division_reg  <= division;
      end
      // Division mode
      else begin
        // When countdown reaches zero, the half-pulse has ended
        if (countdown == 0) begin
          // Invert the clock output
          clock_divider <= ~clock_divider;
          // Reload countdown for the next half-pulse
          countdown     <= reload_value;
          // Update division factor at the end of a full cycle
          if (clock_divider == 0) begin
            division_reg <= division;
          end
        end
        // Keep counting down
        else begin
          countdown <= countdown - 1;
        end
      end
    end
  end
end

// Fine decimal division
else begin

  // Duration of the high and low pulses
  wire [DIVISION_WIDTH-1:0] high_pulse_duration = (division_reg + 2) / 2;
  wire [DIVISION_WIDTH-1:0]  low_pulse_duration = (division_reg + 1) / 2;

  // Half pulse count-down
  reg [DIVISION_WIDTH-1:0] countdown;

  always @(posedge clock_in or negedge resetn) begin
    // Reset
    if (!resetn) begin
      // Low pulse at reset
      division_reg  <= division;
      clock_divider <= 0;
      countdown     <= (division + 1) / 2 - 1;
    end
    // Operation
    else begin
      // Passthrough mode
      if (passthrough_mode) begin
        countdown     <= 0;
        clock_divider <= 0;
        // Update division factor
        division_reg  <= division;
      end
      // Division mode
      else begin
        // When the countdown reaches zero, the current pulse has ended
        if (countdown == 0) begin
          // Invert the clock output
          clock_divider <= ~clock_divider;
          // Reload countdown based on the current pulse polarity
          if (clock_divider == 0) begin
            countdown    <= high_pulse_duration - 1;
            // Update division factor at the end of a full cycle
            division_reg <= division;
          end else begin
            countdown <= low_pulse_duration - 1;
          end
        end
        // Keep counting down
        else begin
          countdown <= countdown - 1;
        end
      end
    end
  end
end

endmodule
