// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        credit_based_fifo.v                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue with credit-based flow  ║
// ║              control.                                                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module credit_based_fifo #(
  parameter WIDTH        = 8,
  parameter DEPTH        = 4,
  parameter CREDIT_COUNT = 4
) (
  input              clock,
  input              resetn,
  // Write interface
  input  [WIDTH-1:0] write_data,
  input              write_valid,
  output reg         write_credit,
  output             full,
  // Read interface
  output [WIDTH-1:0] read_data,
  output             read_valid,
  input              read_credit,
  output             empty
);

localparam CREDIT_COUNT_LOG2 = `CLOG2(CREDIT_COUNT);

reg [CREDIT_COUNT_LOG2-1:0] write_credit_count;
reg [CREDIT_COUNT_LOG2-1:0] read_credit_count;

assign read_valid = ~empty & (read_credit_count > 0);

always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    write_credit_count <= 0;
    read_credit_count  <= 0;
  end
  // Operation
  else begin
    // Write credit
    if (write_valid && !read_valid) begin
      write_credit_count <= write_credit_count - 1;
      write_credit       <= 0;
    end else if (read_valid) begin
      write_credit_count <= write_credit_count + 1;
      write_credit       <= 1;
    end else begin
      write_credit       <= 0;
    end
    // Read credit
    if (read_valid && !read_credit) begin
      read_credit_count <= read_credit_count - 1;
    end else if (read_credit) begin
      read_credit_count <= read_credit_count + 1;
    end
  end
end

wire write_enable = write_valid;
wire read_enable  = read_valid;

fifo #(
  .WIDTH ( WIDTH ),
  .DEPTH ( DEPTH )
) fifo (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .full         ( full         ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .empty        ( empty        )
);

endmodule
