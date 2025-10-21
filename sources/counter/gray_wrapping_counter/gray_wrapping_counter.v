// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_wrapping_counter.v                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down and wraps around in both directions.      ║
// ║              Handles power-of-2 and non-power-of-2 ranges for wrapping.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module gray_wrapping_counter #(
  parameter RANGE       = 4,
  parameter RESET_VALUE = 0,
  parameter LOAD_BINARY = 0,
  parameter WIDTH       = `CLOG2(RANGE)
) (
  input              clock,
  input              resetn,
  input              load_enable,
  input  [WIDTH-1:0] load_count,
  input              decrement,
  input              increment,
  output [WIDTH-1:0] count_gray,
  output [WIDTH-1:0] count_binary,
  output             minimum,
  output             maximum,
  output reg         underflow,
  output reg         overflow
);

localparam COUNTER_BINARY_MIN = 0;
localparam COUNTER_BINARY_MAX = RANGE - 1;

// Counter register
reg  [WIDTH-1:0] counter_binary;
wire [WIDTH-1:0] counter_binary_decremented = minimum ? COUNTER_BINARY_MAX : counter_binary - 1;
wire [WIDTH-1:0] counter_binary_incremented = maximum ? COUNTER_BINARY_MIN : counter_binary + 1;
reg  [WIDTH-1:0] counter_gray;
wire [WIDTH-1:0] counter_gray_decremented;
wire [WIDTH-1:0] counter_gray_incremented;

// Decrement Gray encoder
binary_to_gray #(
  .RANGE ( RANGE ),
  .WIDTH ( WIDTH )
) counter_decremented_gray_encoder (
  .binary ( counter_binary_decremented ),
  .gray   ( counter_gray_decremented   )
);

// Increment Gray encoder
binary_to_gray #(
  .RANGE ( RANGE ),
  .WIDTH ( WIDTH )
) counter_incremented_gray_encoder (
  .binary ( counter_binary_incremented ),
  .gray   ( counter_gray_incremented   )
);

// Reset counter values
wire [WIDTH-1:0] reset_count_binary = RESET_VALUE[WIDTH-1:0];
wire [WIDTH-1:0] reset_count_gray;
binary_to_gray #(
  .RANGE ( RANGE ),
  .WIDTH ( WIDTH )
) reset_gray_encoder (
  .binary ( reset_count_binary ),
  .gray   ( reset_count_gray   )
);

// Convert load to binary or Gray
wire [WIDTH-1:0] load_count_binary_value;
wire [WIDTH-1:0] load_count_gray_value;
generate
  if (LOAD_BINARY) begin : gen_load_binary
    assign load_count_binary_value = load_count;
    binary_to_gray #(
      .RANGE ( RANGE ),
      .WIDTH ( WIDTH )
    ) load_gray_encoder (
      .binary ( load_count_binary_value ),
      .gray   ( load_count_gray_value   )
    );
  end else begin : gen_load_gray
    assign load_count_gray_value = load_count;
    gray_to_binary #(
      .RANGE ( RANGE ),
      .WIDTH ( WIDTH )
    ) load_binary_decoder (
      .gray   ( load_count_gray_value   ),
      .binary ( load_count_binary_value )
    );
  end
endgenerate

// Minimum and maximum flags
assign minimum = counter_binary == COUNTER_BINARY_MIN;
assign maximum = counter_binary == COUNTER_BINARY_MAX;

// Sequential logic
generate
  // If the range is a power of 2, wrapping is automatic
  if (`IS_POW2(RANGE)) begin : gen_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter_binary <= reset_count_binary;
        counter_gray   <= reset_count_gray;
        underflow      <= 0;
        overflow       <= 0;
      end else begin
        underflow <= 0;
        overflow  <= 0;
        if (load_enable) begin
          counter_binary <= load_count_binary_value;
          counter_gray   <= load_count_gray_value;
        end else begin
          if (increment && !decrement) begin
            overflow       <= maximum;
            counter_binary <= counter_binary_incremented;
            counter_gray   <= counter_gray_incremented;
          end else if (decrement && !increment) begin
            underflow      <= minimum;
            counter_binary <= counter_binary_decremented;
            counter_gray   <= counter_gray_decremented;
          end
        end
      end
    end
  end
  // For non-power-of-2 ranges, handle wrapping manually
  else begin : gen_non_pow2_counter
    always @(posedge clock or negedge resetn) begin
      if (!resetn) begin
        counter_binary <= RESET_VALUE;
        counter_gray   <= reset_count_gray;
        underflow      <= 0;
        overflow       <= 0;
      end else begin
        underflow <= 0;
        overflow  <= 0;
        if (load_enable) begin
          counter_binary <= load_count_binary_value;
          counter_gray   <= load_count_gray_value;
        end else begin
          if (increment && !decrement) begin
            overflow       <= maximum;
            counter_binary <= counter_binary_incremented;
            counter_gray   <= counter_gray_incremented;
          end else if (decrement && !increment) begin
            underflow      <= minimum;
            counter_binary <= counter_binary_decremented;
            counter_gray   <= counter_gray_decremented;
          end
        end
      end
    end
  end
endgenerate

assign count_gray   = counter_gray;
assign count_binary = counter_binary;

endmodule
