// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_wrapping_increment_counter.v                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Gray-coded counter that counts up and wraps. Handles power-  ║
// ║              of-2 and non-power-of-2 even ranges.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"
`include "is_pow2.vh"



module gray_wrapping_increment_counter #(
  parameter RANGE       = 4,
  parameter RESET_VALUE = 0,
  parameter WIDTH       = `CLOG2(RANGE)
) (
  input              clock,
  input              resetn,
  input              increment,
  output [WIDTH-1:0] count_gray,
  output [WIDTH-1:0] count_binary
);

localparam COUNTER_BINARY_MIN = 0;
localparam COUNTER_BINARY_MAX = RANGE - 1;

// Counter register
reg [WIDTH-1:0] counter_gray;
reg [WIDTH-1:0] counter_binary;
wire  maximum = counter_binary == COUNTER_BINARY_MAX;

// Incremented counter values
wire [WIDTH-1:0] counter_binary_incremented = maximum ? COUNTER_BINARY_MIN : counter_binary + 1;
wire [WIDTH-1:0] counter_gray_incremented;
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

// Sequential logic
always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter_binary <= reset_count_binary;
    counter_gray   <= reset_count_gray;
  end else begin
    if (increment) begin
      counter_binary <= counter_binary_incremented;
      counter_gray   <= counter_gray_incremented;
    end
  end
end

assign count_gray   = counter_gray;
assign count_binary = counter_binary;

endmodule


