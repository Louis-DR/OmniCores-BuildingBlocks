// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
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



`include "clog2.vh"



module lifo #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input              clock,
  input              resetn,
  // Write interface
  input              write_enable,
  input  [WIDTH-1:0] write_data,
  output             full,
  // Read interface
  input              read_enable,
  output [WIDTH-1:0] read_data,
  output             empty
);

localparam DEPTH_LOG2 = `CLOG2(DEPTH);

// Memory array
reg [WIDTH-1:0] memory [DEPTH-1:0];

// Pointer to the last item of the LIFO
reg [DEPTH_LOG2-1:0] stack_pointer;
wire stack_pointer_zero = stack_pointer == {DEPTH_LOG2-1{1'b0}};

// Read and write control signals
reg can_write;
reg can_read;
// The can_read flag also identifies if the entry 0 is valid when stack_pointer==0

// Performing write/read operation
wire do_write = write_enable & can_write;
wire do_read = read_enable  & can_read;

// IO signals
assign full      = ~can_write;
assign empty     = ~can_read;
assign read_data = memory[stack_pointer];



// ┌───────────────────┐
// │ Synchronous logic │
// └───────────────────┘

integer depth_index;
always @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    stack_pointer <= 0;
    can_write     <= 1;
    can_read      <= 0;
    for (depth_index = 0; depth_index < DEPTH; depth_index = depth_index+1) begin
      memory[depth_index] <= 0;
    end
  end else begin
    // Writing
    if (do_write) begin
      // Use can_read flag to mark validity of memory[0]
      if (can_read) begin
        // Reading and writing in same cycle
        if (do_read) begin
          memory[stack_pointer] <= write_data;
          can_write <= 1;
        end
        // Writing only
        else begin
          memory[stack_pointer + 1] <= write_data;
          stack_pointer             <= stack_pointer + 1;
          can_write                 <= ~(stack_pointer == {{DEPTH_LOG2-2{1'b1}} , 1'b0});
        end
      end
      // Writing to empty stack
      else begin
        memory[0]     <= write_data;
        stack_pointer <= 0;
        can_read      <= 1;
      end
    end
    // Reading only
    else if (do_read) begin
      stack_pointer <= stack_pointer_zero ? stack_pointer : stack_pointer - 1;
      can_read      <= ~stack_pointer_zero;
      can_write     <= 1;
    end
  end
end

endmodule
