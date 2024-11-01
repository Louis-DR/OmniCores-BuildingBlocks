// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        asynchronous_fifo.v                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Asynchronous First-In First-Out queue.                       ║
// ║                                                                           ║
// ║              If the FIFO isn't empty, the read_data output is the value   ║
// ║              of the tail of the queue. Toggling the read input signal     ║
// ║              only moves the read pointer to the next entry for the next   ║
// ║              clock cycle. Therefore, the value can be read instantly and  ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module asynchronous_fifo #(
  parameter WIDTH  = 8,
  parameter DEPTH  = 4,
  parameter STAGES = 2
) (
  // Write interface
  input              write_clock,
  input              write_resetn,
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  output             write_full,
  // Read interface
  input              read_clock,
  input              read_resetn,
  input              read_enable,
  output [WIDTH-1:0] read_data,
  output             read_empty
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;

// Write address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Grey-coded pointers in write clock domain
reg [DEPTH_LOG2:0] write_pointer_grey_w;
reg [DEPTH_LOG2:0] read_pointer_grey_w;

// Write pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] write_pointer_incremented = write_pointer + 1;
wire [DEPTH_LOG2:0] write_pointer_incremented_grey;

binary_to_grey #(
  .WIDTH  ( DEPTH_LOG2+1 )
) write_pointer_incremented_grey_encoder (
  .binary ( write_pointer_incremented      ),
  .grey   ( write_pointer_incremented_grey )
);

// Queue is full if the grey-coded pointers match this expression
assign write_full = write_pointer_grey_w == {~read_pointer_grey_w[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_grey_w[DEPTH_LOG2-2:0]};

always @(posedge write_clock or negedge write_resetn) begin
  if (!write_resetn) begin
    write_pointer        <= 0;
    write_pointer_grey_w <= 0;
  end else begin
    if (write_enable) begin
      write_pointer         <= write_pointer_incremented;
      write_pointer_grey_w  <= write_pointer_incremented_grey;
      buffer[write_address] <= write_data;
    end
  end
end



// ┌───────────────────┐
// │ Read clock domain │
// └───────────────────┘

// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;

// Read address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Grey-coded pointers in read clock domain
reg [DEPTH_LOG2:0] write_pointer_grey_r;
reg [DEPTH_LOG2:0] read_pointer_grey_r;

// Read pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] read_pointer_incremented = read_pointer + 1;
wire [DEPTH_LOG2:0] read_pointer_incremented_grey;

binary_to_grey #(
  .WIDTH  ( DEPTH_LOG2+1 )
) read_pointer_incremented_grey_encoder (
  .binary ( read_pointer_incremented      ),
  .grey   ( read_pointer_incremented_grey )
);

// Queue is empty if the grey-coded read and write pointers are the same
assign read_empty = write_pointer_grey_r == read_pointer_grey_r;

// Value at the read pointer is always on the read data bus
assign read_data = buffer[read_address];

always @(posedge read_clock or negedge read_resetn) begin
  if (!read_resetn) begin
    read_pointer        <= 0;
    read_pointer_grey_r <= 0;
  end else begin
    if (read_enable) begin
      read_pointer        <= read_pointer_incremented;
      read_pointer_grey_r <= read_pointer_incremented_grey;
    end
  end
end



// ┌───────────────────────┐
// │ Clock domain crossing │
// └───────────────────────┘

vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2+1        ),
  .STAGES   ( STAGES              )
) read_pointer_grey_sync (
  .clock    ( write_clock         ),
  .resetn   ( write_resetn        ),
  .data_in  ( read_pointer_grey_r ),
  .data_out ( read_pointer_grey_w )
);

vector_synchronizer #(
  .WIDTH    ( DEPTH_LOG2+1         ),
  .STAGES   ( STAGES               )
) write_pointer_grey_sync (
  .clock    ( read_clock           ),
  .resetn   ( read_resetn          ),
  .data_in  ( write_pointer_grey_w ),
  .data_out ( write_pointer_grey_r )
);

endmodule