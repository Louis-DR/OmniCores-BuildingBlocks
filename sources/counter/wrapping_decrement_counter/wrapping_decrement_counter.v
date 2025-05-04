// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wrapping_decrement_counter.v                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts down and wraps around. Handles power-of-2 and non-    ║
// ║              power-of-2 ranges for wrapping.                              ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module wrapping_decrement_counter #(
  parameter RANGE       = 4,
  parameter RANGE_LOG2  = `CLOG2(RANGE),
  parameter RESET_VALUE = 0
) (
  input                   clock,
  input                   resetn,
  input                   decrement,
  output [RANGE_LOG2-1:0] count
);

localparam RANGE_IS_POW2 = RANGE == 2 ** RANGE_LOG2;
localparam COUNTER_MIN   = 0;
localparam COUNTER_MAX   = RANGE - 1;

reg [RANGE_LOG2-1:0] counter;

generate
  // If the range is a power of 2, the wrapping is automatic
  if (RANGE_IS_POW2) begin : gen_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter <= RESET_VALUE;
      end else begin
        if (decrement) begin
          counter <= counter - 1;
        end
      end
    end
  end
  // If the range is not a power of 2, we need to handle wrapping manually
  else begin : gen_non_pow2_counter
    wire counter_is_min = counter == COUNTER_MIN;
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter <= RESET_VALUE;
      end else begin
        if (decrement) begin
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
