// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fifo.v                                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous First-In First-Out queue.                        ║
// ║                                                                           ║
// ║              If the FIFO isn't empty, the read_data output is the value   ║
// ║              of the tail of the queue. Toggling the read input signal     ║
// ║              only moves the read pointer to the next entry for the next   ║
// ║              clock cycle. Therefore, the value can be read instantly and  ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module fifo #(
  parameter WIDTH      = 8,
  parameter DEPTH_LOG2 = 2
) (
  input clk,
  input arstn,
  // Write interface
  input              write,
  input  [WIDTH-1:0] write_data,
  output             full,
  // Read interface
  input              read,
  output [WIDTH-1:0] read_data,
  output             empty
);

parameter DEPTH = 2 ** DEPTH_LOG2;

// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];



// ┌─────────────┐
// │ Write logic │
// └─────────────┘

// Flag true if FIFO not full
reg can_write;
// Write pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] write_ptr;
// Write address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] write_addr = write_ptr[DEPTH_LOG2-1:0];
// Write pointer incremented
wire [DEPTH_LOG2:0] write_ptr_incr = write_ptr + 1;

// Buffer is full if read and write addresses are the same and wrap bits are different
wire can_write_next = (write_ptr_incr != { ~read_ptr[DEPTH_LOG2:DEPTH_LOG2-1], read_ptr[DEPTH_LOG2-2:0] }) | read;

assign full = ~can_write;



// ┌────────────┐
// │ Read logic │
// └────────────┘

// Flag true if FIFO not empty
reg can_read;
// Read pointer with wrap bit to compare with the read pointer
reg [DEPTH_LOG2:0] read_ptr;
// Read address without wrap bit to index the buffer
wire [DEPTH_LOG2-1:0] read_addr = read_ptr[DEPTH_LOG2-1:0];
// Read pointer incremented
wire [DEPTH_LOG2:0] read_ptr_incr = read_ptr + 1;

// Buffer empty if read and write addresses are the same including the wrap bits
wire can_read_next = (read ? read_ptr_incr : read_ptr) != (write ? write_ptr_incr : write_ptr);

assign empty = ~can_read;
assign read_data = buffer[read_addr];



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

integer idx;
always @(posedge clk or negedge arstn) begin
  if (!arstn) begin
    write_ptr <= '0;
    can_write <= '1;
    read_ptr  <= '0;
    can_read  <= '0;
    for (idx=0; idx<DEPTH; idx++) begin
      buffer[idx] <= '0;
    end
  end else begin
    can_write <= can_write_next;
    can_read  <= can_read_next;
    if (write && can_write) begin
      write_ptr <= write_ptr_incr;
      buffer[write_addr] <= write_data;
    end
    if (read) begin
      if (can_read) begin
        read_ptr <= read_ptr_incr;
      end
    end
  end
end

endmodule
