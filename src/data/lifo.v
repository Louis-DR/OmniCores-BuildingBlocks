// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        lifo.v                                                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Synchronous Last-In First-Out stack.                         ║
// ║                                                                           ║
// ║              If the LIFO isn't empty, the read_data output is the value   ║
// ║              of the top of the stack. Toggling the read input signal only ║
// ║              moves the read pointer to the next entry for the next clock  ║
// ║              cycle. Therefore, the value can be read instantly and        ║
// ║              without necessarily popping the value.                       ║
// ║                                                                           ║
// ║              Attempting to read and write at the same time will read the  ║
// ║              last value of the stack then write the next value, thus not  ║
// ║              moving the stack pointer. Passing the data from write_data   ║
// ║              to read_data in such a case would create a single timing     ║
// ║              path through the structure.                                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module lifo #(
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

localparam DEPTH = 2 ** DEPTH_LOG2;

// Memory array
reg [WIDTH-1:0] buffer [DEPTH-1:0];

// Pointer to the last item of the LIFO
reg [DEPTH_LOG2-1:0] stack_ptr;
wire stack_ptr_zero = stack_ptr == {DEPTH_LOG2-1{1'b0}};

// Flag for LIFO full/empy
reg can_write;
reg can_read;
// We also use the can_read flag to identify if the entry 0 is valid when stack_ptr==0

// Performing write/read operation
wire writing = write & can_write;
wire reading = read  & can_read;

// IO signals
assign full      = ~can_write;
assign empty     = ~can_read;
assign read_data = buffer[stack_ptr];



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

integer idx;
always @(posedge clk or negedge arstn) begin
  // Reset
  if (!arstn) begin
    stack_ptr <= '0;
    can_write <= '1;
    can_read  <= '0;
    for (idx=0; idx<DEPTH; idx=idx+1) begin
      buffer[idx] <= '0;
    end

  end else begin
    // Writing
    if (writing) begin
      // Use can_read flag to mark validity of buffer[0]
      if (can_read) begin
        // Reading and writing in same cycle
        if (reading) begin
          buffer[stack_ptr] <= write_data;
          can_write <= '1;
        // Writing only
        end else begin
          buffer[stack_ptr + 1] <= write_data;
          stack_ptr <= stack_ptr + 1;
          can_write <= ~(stack_ptr == {{DEPTH_LOG2-2{1'b1}} , 1'b0});
        end
      // Writing to empty stack
      end else begin
        buffer[0] <= write_data;
        stack_ptr <= '0;
        can_read  <= '1;
      end
    // Reading only
    end else if (reading) begin
      stack_ptr <= stack_ptr_zero ? stack_ptr : stack_ptr - 1;
      can_read  <= ~stack_ptr_zero;
      can_write <= '1;
    end
  end
end

endmodule
