// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hysteresis_saturating_counter.v                              ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down with overflow and underflow prevention,   ║
// ║              and hysteresis. The coercivity is the width of the jump of   ║
// ║              the hysteresis loop.                                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module hysteresis_saturating_counter #(
  parameter WIDTH      = 4,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH),
  parameter RESET      = 0,
  parameter COERCIVITY = 1
) (
  input                   clock,
  input                   resetn,
  input                   increment,
  input                   decrement,
  output [WIDTH_LOG2-1:0] count
);

localparam COUNTER_MIN       = 0;
localparam COUNTER_MAX       = WIDTH-1;
localparam COUNTER_HALF_LOW  = WIDTH/2-1;
localparam COUNTER_HALF_HIGH = WIDTH/2;
localparam COUNTER_JUMP_LOW  = COUNTER_HALF_LOW  - COERCIVITY;
localparam COUNTER_JUMP_HIGH = COUNTER_HALF_HIGH + COERCIVITY;

reg [WIDTH_LOG2-1:0] counter;
wire counter_is_min       = counter == COUNTER_MIN;
wire counter_is_max       = counter == COUNTER_MAX;
wire counter_is_half_low  = counter == COUNTER_HALF_LOW;
wire counter_is_half_high = counter == COUNTER_HALF_HIGH;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= RESET;
  end else begin
    if (increment && !counter_is_max) begin
      if (counter_is_half_low) begin
        counter <= COUNTER_JUMP_HIGH;
      end else begin
        counter <= counter + 1;
      end
    end else if (decrement && !counter_is_min) begin
      if (counter_is_half_high) begin
        counter <= COUNTER_JUMP_LOW;
      end else begin
        counter <= counter - 1;
      end
    end
  end
end

assign count = counter;

endmodule
