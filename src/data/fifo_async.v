// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo_async.v                                                 ║
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



module async_fifo #(
  parameter WIDTH      = 8,
  parameter DEPTH_LOG2 = 2,
  parameter STAGES     = 2
) (
  input arstn,
  // Write interface
  input                  write_clk,
  input                  write,
  input      [WIDTH-1:0] write_data,
  output                 full,
  // Read interface
  input                  read_clk,
  input                  read,
  output reg [WIDTH-1:0] read_data,
  output                 empty
);

parameter DEPTH = 2 ** DEPTH_LOG2;

// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];



// ┌────────────────────┐
// │ Write clock domain │
// └────────────────────┘

// Flag true if FIFO not full
reg can_write;
assign full = ~can_write;
// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_ptr;
// Write address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] write_addr = write_ptr[DEPTH_LOG2-1:0];

// Grey-coded pointers in write clock domain
reg [DEPTH_LOG2:0] write_ptr_grey_w;
reg [DEPTH_LOG2:0] read_ptr_grey_w;

// Write pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] write_ptr_incr = write_ptr + 1;
wire [DEPTH_LOG2:0] write_ptr_incr_grey = (write_ptr_incr >> 1) ^ write_ptr_incr;

// Buffer is full if read and write addresses are the same and wrap bits are different
wire can_write_current = write_ptr_grey_w    != { ~read_ptr_grey_w[DEPTH_LOG2:DEPTH_LOG2-1], read_ptr_grey_w[DEPTH_LOG2-2:0] };
wire can_write_next    = write_ptr_incr_grey != { ~read_ptr_grey_w[DEPTH_LOG2:DEPTH_LOG2-1], read_ptr_grey_w[DEPTH_LOG2-2:0] };

always @(posedge write_clk or negedge arstn) begin
  if (!arstn) begin
    write_ptr <= '0;
    write_ptr_grey_w <= '0;
    can_write <= '1;
  end else begin
    if (write && can_write) begin
      write_ptr <= write_ptr_incr;
      write_ptr_grey_w <= write_ptr_incr_grey;
      can_write <= can_write_next;
      buffer[write_addr] <= write_data;
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
reg [DEPTH_LOG2:0] read_ptr;
// Read address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] read_addr = read_ptr[DEPTH_LOG2-1:0];

// Grey-coded pointers in read clock domain
reg [DEPTH_LOG2:0] write_ptr_grey_r;
reg [DEPTH_LOG2:0] read_ptr_grey_r;

// Read pointer incremented and corresponding grey-code
wire [DEPTH_LOG2:0] read_ptr_incr = read_ptr + 1;
wire [DEPTH_LOG2:0] read_ptr_incr_grey = (read_ptr_incr >> 1) ^ read_ptr_incr;

// Buffer empty if read and write addresses are the same including the wrap bits
wire can_read_current = read_ptr_grey_r    != write_ptr_grey_r;
wire can_read_next    = read_ptr_incr_grey != write_ptr_grey_r;

always @(posedge read_clk or negedge arstn) begin
  if (!arstn) begin
    read_ptr <= '0;
    read_ptr_grey_r <= '0;
    read_data <= '0;
    can_read <= '0;
  end else begin
    if (read) begin
      if (can_read) begin
        read_ptr <= read_ptr_incr;
        read_ptr_grey_r <= read_ptr_incr_grey;
      end
      can_read <= can_read_next;
      if (can_read_next) begin
        read_data <= buffer[read_ptr_incr];
      end else begin
        read_data <= '0;
      end
    end else begin
      can_read = can_read_current;
      if (can_read_current) begin
        read_data <= buffer[read_addr];
      end else begin
        read_data <= '0;
      end
    end
  end
end



// ┌───────────────────────┐
// │ Clock domain crossing │
// └───────────────────────┘

sync_vec #(
  .WIDTH  (DEPTH_LOG2+1),
  .STAGES (STAGES)
) read_ptr_grey_sync (
  .clk   (write_clk),
  .arstn (arstn),
  .din   (read_ptr_grey_r),
  .dout  (read_ptr_grey_w)
);

sync_vec #(
  .WIDTH  (DEPTH_LOG2+1),
  .STAGES (STAGES)
) write_ptr_grey_sync (
  .clk   (read_clk),
  .arstn (arstn),
  .din   (write_ptr_grey_w),
  .dout  (write_ptr_grey_r)
);

endmodule