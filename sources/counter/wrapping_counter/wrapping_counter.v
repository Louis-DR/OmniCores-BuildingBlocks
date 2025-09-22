// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wrapping_counter.v                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down and wraps around in both directions.      ║
// ║              Handles power-of-2 and non-power-of-2 ranges for wrapping.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module wrapping_counter #(
  parameter RANGE       = 4,
  parameter RANGE_LOG2  = `CLOG2(RANGE),
  parameter RESET_VALUE = 0
) (
  input                   clock,
  input                   resetn,
  input                   increment,
  input                   decrement,
  output [RANGE_LOG2-1:0] count
);

localparam COUNTER_MIN = 0;
localparam COUNTER_MAX = RANGE - 1;

reg [RANGE_LOG2-1:0] counter;

generate
  // If the range is a power of 2, the wrapping is automatic
  if (`IS_POW2(RANGE)) begin : gen_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter <= RESET_VALUE;
      end else begin
        if (increment && !decrement) begin
          counter <= counter + 1;
        end else if (decrement && !increment) begin
          counter <= counter - 1;
        end
      end
    end
  end
  // If the range is not a power of 2, we need to handle wrapping manually
  else begin : gen_non_pow2_counter
    wire counter_is_max = counter == COUNTER_MAX;
    wire counter_is_min = counter == COUNTER_MIN;
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter <= RESET_VALUE;
      end else begin
        if (increment && !decrement) begin
          if (counter_is_max) begin
            counter <= COUNTER_MIN;
          end else begin
            counter <= counter + 1;
          end
        end else if (decrement && !increment) begin
          if (counter_is_min) begin
            counter <= COUNTER_MAX;
          end else begin
            counter <= counter - 1;
          end
        end
      end
    end
  end
endgenerate

assign count = counter;

endmodule
