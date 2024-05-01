// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
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
  input                  write_clock,
  input                  write_resetn,
  input                  write,
  input      [WIDTH-1:0] write_data,
  output                 full,
  // Read interface
  input                  read_clock,
  input                  read_resetn,
  input                  read,
  output reg [WIDTH-1:0] read_data,
  output                 empty
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Flag true if FIFO not full
reg can_write;
assign full = ~can_write;
// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_pointer;
// Write address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] write_address = write_pointer[DEPTH_LOG2-1:0];

// Grey-coded pointers in write clock domain
reg [DEPTH_LOG2:0] write_pointer_grey_w;
reg [DEPTH_LOG2:0] read_pointer_grey_w;

// Write pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] write_pointer_incremented      = write_pointer + 1;
wire [DEPTH_LOG2:0] write_pointer_incremented_grey = (write_pointer_incremented >> 1) ^ write_pointer_incremented;

// Buffer is full if read and write addresses are the same and wrap bits are different
wire can_write_current = write_pointer_grey_w           != { ~read_pointer_grey_w[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_grey_w[DEPTH_LOG2-2:0] };
wire can_write_next    = write_pointer_incremented_grey != { ~read_pointer_grey_w[DEPTH_LOG2:DEPTH_LOG2-1], read_pointer_grey_w[DEPTH_LOG2-2:0] };

always @(posedge write_clock or negedge write_resetn) begin
  if (!write_resetn) begin
    write_pointer        <= 0;
    write_pointer_grey_w <= 0;
    can_write            <= 1;
  end else begin
    if (write && can_write) begin
      write_pointer <= write_pointer_incremented;
      write_pointer_grey_w <= write_pointer_incremented_grey;
      can_write <= can_write_next;
      buffer[write_address] <= write_data;
    end else begin
      can_write <= can_write_current;
    end
  end
end



// ┌───────────────────┐
// │ Read clock domain │
// └───────────────────┘

// Flag true if FIFO not empty
reg can_read;
assign empty = ~can_read;
// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_pointer;
// Read address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] read_address = read_pointer[DEPTH_LOG2-1:0];

// Grey-coded pointers in read clock domain
reg [DEPTH_LOG2:0] write_pointer_grey_r;
reg [DEPTH_LOG2:0] read_pointer_grey_r;

// Read pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] read_pointer_incremented = read_pointer + 1;
wire [DEPTH_LOG2:0] read_pointer_incremented_grey = (read_pointer_incremented >> 1) ^ read_pointer_incremented;

// Buffer empty if read and write addresses are the same including the wrap bits
wire can_read_current = read_pointer_grey_r    != write_pointer_grey_r;
wire can_read_next    = read_pointer_incremented_grey != write_pointer_grey_r;

always @(posedge read_clock or negedge read_resetn) begin
  if (!read_resetn) begin
    read_pointer        <= 0;
    read_pointer_grey_r <= 0;
    read_data           <= 0;
    can_read            <= 0;
  end else begin
    if (read) begin
      if (can_read) begin
        read_pointer        <= read_pointer_incremented;
        read_pointer_grey_r <= read_pointer_incremented_grey;
      end
      can_read <= can_read_next;
      if (can_read_next) begin
        read_data <= buffer[read_pointer_incremented];
      end else begin
        read_data <= 0;
      end
    end else begin
      can_read = can_read_current;
      if (can_read_current) begin
        read_data <= buffer[read_address];
      end else begin
        read_data <= 0;
      end
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