// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_wrapping_counter.v                                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down and wraps around in both directions.      ║
// ║              Handles power-of-2 and non-power-of-2 ranges for wrapping.   ║
// ║                                                                           ║
// ║              This advanced variant has some additional features:          ║
// ║              - Load interface to load a value into the counter            ║
// ║              - Optional lap bit at the end of the counter updated when    ║
// ║                over or under flowing.                                     ║
// ║              - Minimum and maximum flag outputs.                          ║
// ║              - Overflow and underflow pulse signaling.                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module advanced_wrapping_counter #(
  parameter RANGE        = 4,
  parameter RESET_VALUE  = 0,
  parameter LAP_BIT      = 0,
  parameter WIDTH_NO_LAP = `CLOG2(RANGE),
  parameter WIDTH        = WIDTH_NO_LAP + LAP_BIT
) (
  input              clock,
  input              resetn,
  input              load_enable,
  input  [WIDTH-1:0] load_count,
  input              decrement,
  input              increment,
  output [WIDTH-1:0] count,
  output             minimum,
  output             maximum,
  output reg         underflow,
  output reg         overflow
);

// Counter register
reg               [WIDTH-1:0] counter;
wire       [WIDTH_NO_LAP-1:0] counter_no_lap = counter[WIDTH_NO_LAP-1:0];
localparam [WIDTH_NO_LAP-1:0] COUNTER_MIN    = 0;
localparam [WIDTH_NO_LAP-1:0] COUNTER_MAX    = RANGE - 1;

// Minimum and maximum flags
assign minimum = counter_no_lap == COUNTER_MIN;
assign maximum = counter_no_lap == COUNTER_MAX;

generate
  // If the range is a power of 2, the wrapping and lap bit are automatic
  if (`IS_POW2(RANGE)) begin : gen_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter   <= RESET_VALUE;
        underflow <= 0;
        overflow  <= 0;
      end else begin
        underflow <= 0;
        overflow  <= 0;
        if (load_enable) begin
          counter <= load_count;
        end else begin
          reg [WIDTH_NO_LAP-1:0] next_index;
          reg                    next_lap;
          next_index = counter_no_lap;
          next_lap   = LAP_BIT ? counter[WIDTH_NO_LAP] : 1'b0;
          if (increment && !decrement) begin
            if (counter_no_lap == COUNTER_MAX) begin
              overflow   <= 1;
              next_index = COUNTER_MIN;
              if (LAP_BIT) next_lap = ~counter[WIDTH_NO_LAP];
            end else begin
              next_index = counter_no_lap + {{(WIDTH_NO_LAP-1){1'b0}},1'b1};
            end
          end else if (decrement && !increment) begin
            if (counter_no_lap == COUNTER_MIN) begin
              underflow  <= 1;
              next_index = COUNTER_MAX;
              if (LAP_BIT) next_lap = ~counter[WIDTH_NO_LAP];
            end else begin
              next_index = counter_no_lap - {{(WIDTH_NO_LAP-1){1'b0}},1'b1};
            end
          end
          if (LAP_BIT) counter <= {next_lap, next_index};
          else         counter <= next_index;
        end
      end
    end
  end
  // If the range is not a power of 2, we need to handle wrapping manually
  else begin : gen_non_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter   <= RESET_VALUE;
        underflow <= 0;
        overflow  <= 0;
      end else begin
        underflow <= 0;
        overflow  <= 0;
        if (load_enable) begin
          counter <= load_count;
        end else begin
          if (increment && !decrement) begin
            if (maximum) begin
              overflow <= 1;
              if (LAP_BIT) counter <= {~counter[WIDTH_NO_LAP], COUNTER_MIN};
              else         counter <= COUNTER_MIN;
            end else begin
              if (LAP_BIT) counter <= {counter[WIDTH_NO_LAP], counter_no_lap + 1};
              else         counter <= counter_no_lap + 1;
            end
          end else if (decrement && !increment) begin
            if (minimum) begin
              underflow <= 1;
              if (LAP_BIT) counter <= {~counter[WIDTH_NO_LAP], COUNTER_MAX};
              else         counter <= COUNTER_MAX;
            end else begin
              if (LAP_BIT) counter <= {counter[WIDTH_NO_LAP], counter_no_lap - 1};
              else         counter <= counter_no_lap - 1;
            end
          end
        end
      end
    end
  end
endgenerate

assign count = counter;

endmodule
