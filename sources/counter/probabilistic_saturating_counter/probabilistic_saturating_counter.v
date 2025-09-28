// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        probabilistic_saturating_counter.v                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down with overflow and underflow prevention.   ║
// ║              The transition to the saturated values is probabilistic to   ║
// ║              simulate a wider counter.                                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module probabilistic_saturating_counter #(
  parameter      RANGE                  = 4,
  parameter      RESET_VALUE            = 0,
  parameter      RANDOM_NUMBER_WIDTH    = 8,
  parameter real SATURATION_PROBABILITY = 0.25,
  parameter      WIDTH                  = `CLOG2(RANGE)
) (
  input                           clock,
  input                           resetn,
  input                           decrement,
  input                           increment,
  input [RANDOM_NUMBER_WIDTH-1:0] random_number,
  output              [WIDTH-1:0] count
);

localparam COUNTER_MIN = 0;
localparam COUNTER_MAX = RANGE - 1;

localparam RANDOM_NUMBER_MAX = 2 ** RANDOM_NUMBER_WIDTH;

reg [WIDTH-1:0] counter;
wire counter_is_min           = counter == COUNTER_MIN;
wire counter_is_max           = counter == COUNTER_MAX;
wire counter_is_min_plus_one  = counter == COUNTER_MIN + 1;
wire counter_is_max_minus_one = counter == COUNTER_MAX - 1;

wire enable_saturation = random_number < SATURATION_PROBABILITY * RANDOM_NUMBER_MAX;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= RESET_VALUE;
  end else begin
    if (increment && !counter_is_max && !decrement) begin
      if (!counter_is_max_minus_one || enable_saturation) begin
        counter <= counter + 1;
      end
    end else if (decrement && !counter_is_min && !increment) begin
      if (!counter_is_min_plus_one || enable_saturation) begin
        counter <= counter - 1;
      end
    end
  end
end

assign count = counter;

endmodule
