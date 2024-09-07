// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        saturating_counter.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down with overflow and underflow prevention.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module saturating_counter #(
  parameter WIDTH      = 4,
  parameter RESET      = 0,
  parameter WIDTH_LOG2 = `CLOG2(WIDTH)
) (
  input                   clock,
  input                   resetn,
  input                   increment,
  input                   decrement,
  output [WIDTH_LOG2-1:0] count
);

localparam COUNTER_MIN = 0;
localparam COUNTER_MAX = WIDTH-1;

reg [WIDTH_LOG2-1:0] counter;
wire counter_is_min = counter == COUNTER_MIN;
wire counter_is_max = counter == COUNTER_MAX;

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= RESET;
  end else begin
    if (increment && !counter_is_max) begin
      counter <= counter + 1;
    end else if (decrement && !counter_is_min) begin
      counter <= counter - 1;
    end
  end
end

assign count = counter;

endmodule
