// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        array_onehot_select.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Select an element in an array using a one-hot encoded signal ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module array_onehot_select #(
  parameter ELEMENT_WIDTH = 8,
  parameter ARRAY_SIZE    = 4
) (
  input  [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] array,
  input  [ARRAY_SIZE-1:0]                     onehot_select,
  output                  [ELEMENT_WIDTH-1:0] element
);

wire [ARRAY_SIZE-1:0] [ELEMENT_WIDTH-1:0] and_or_tree;

assign and_or_tree[0] = {ELEMENT_WIDTH{onehot_select[0]}} & array[0];

genvar stream_index;
generate
  for (stream_index = 1; stream_index < ARRAY_SIZE; stream_index = stream_index+1) begin
    assign and_or_tree[stream_index] = and_or_tree[stream_index-1] | ({ELEMENT_WIDTH{onehot_select[stream_index]}} & array[stream_index]);
  end
endgenerate

assign element = and_or_tree[ARRAY_SIZE-1];

endmodule
