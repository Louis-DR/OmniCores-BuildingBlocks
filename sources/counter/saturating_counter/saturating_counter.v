// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        saturating_counter.v                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Counts up and down with overflow and underflow prevention    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module saturating_counter #(
  parameter WIDTH = 2,
  parameter RESET = 0
) (
  input              clock,
  input              resetn,
  input              increment,
  input              decrement,
  output [WIDTH-1:0] count
);

reg [WIDTH-1:0] counter;
wire counter_is_min = counter == 0;
wire counter_is_max = counter == {WIDTH{1'b1}};

always @(posedge clock or negedge resetn) begin
  if (!resetn) begin
    counter <= RESET;
  end else begin
    if (increment && !counter_is_min) begin
      counter <= counter + 1;
    end else if (decrement && !counter_is_max) begin
      counter <= counter - 1;
    end
  end
end

assign count = counter;

endmodule
