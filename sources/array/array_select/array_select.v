// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        array_select.v                                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Select an element in an array.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "clog2.vh"



module array_select #(
  parameter ELEMENT_WIDTH = 8,
  parameter ARRAY_SIZE    = 4,
  parameter SELECT_ONEHOT = 0,
  parameter SELECT_WIDTH  = SELECT_ONEHOT ? ARRAY_SIZE : `CLOG2(ARRAY_SIZE)
) (
  input [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] array,
  input                   [SELECT_WIDTH-1:0] select,
  output                 [ELEMENT_WIDTH-1:0] element
);

generate
  // Select with one-hot encoded signal
  if (SELECT_ONEHOT) begin : gen_onehot
    wire [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] and_or_tree;

    assign and_or_tree[0] = {ELEMENT_WIDTH{select[0]}} & array[0];

    genvar stream_index;
    for (stream_index = 1; stream_index < ARRAY_SIZE; stream_index = stream_index+1) begin : gen_and_or_tree
      assign and_or_tree[stream_index] = and_or_tree[stream_index-1] | ({ELEMENT_WIDTH{select[stream_index]}} & array[stream_index]);
    end

    assign element = and_or_tree[ARRAY_SIZE-1];
  end

  // Select with normal signal
  else begin : gen_normal
    assign element = array[select];
  end
endgenerate

endmodule
