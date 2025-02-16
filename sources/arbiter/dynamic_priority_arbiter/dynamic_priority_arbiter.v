// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        dynamic_priority_arbiter.v                                   ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The grant is    ║
// ║              given to the highest priority ready request channel. In case ║
// ║              multiple channels with the highest priority are ready, the   ║
// ║              fallback arbiter is used. It can be configured to a static   ║
// ║              priority arbiter, or round-robin arbiter.                    ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module dynamic_priority_arbiter #(
  parameter SIZE                 = 4,
  parameter PRIORITY_WIDTH       = `CLOG2(SIZE),
  parameter PRIORITIES_WIDTH     = PRIORITY_WIDTH * SIZE,
  parameter FALLBACK_ROUND_ROBIN = 0
) (
  input                         clock,
  input                         resetn,
  input              [SIZE-1:0] requests,
  input  [PRIORITIES_WIDTH-1:0] priorities,
  output             [SIZE-1:0] grant
);

localparam PRIORITY_WIDTH_POW2 = 2**PRIORITY_WIDTH;

genvar request_index;
genvar priority_index;
genvar priority_class_index;

// Unpack the priorities array
wire [PRIORITY_WIDTH-1:0] priorities_unpacked [SIZE-1:0];
generate
  for (request_index = 0; request_index < SIZE; request_index = request_index+1) begin : gen_unpack_priorities
    assign priorities_unpacked[request_index] = priorities [ (request_index + 1) * PRIORITY_WIDTH - 1
                                                            : request_index      * PRIORITY_WIDTH ];
  end
endgenerate

// Get the one-hot encoding of the priorities
wire [PRIORITY_WIDTH_POW2-1:0] priorities_onehot [SIZE-1:0];
generate
  for (request_index = 0; request_index < SIZE; request_index = request_index+1) begin : gen_priorities_onehot
    binary_to_onehot #(
      .WIDTH_BINARY ( PRIORITY_WIDTH )
    ) priority_onehot_encoder (
      .binary ( priorities_unpacked [request_index] ),
      .onehot ( priorities_onehot   [request_index] )
    );
  end
endgenerate

// Get the requests per priority class
wire [SIZE-1:0] requests_per_priority_class [PRIORITY_WIDTH_POW2-1:0];
generate
  for (priority_index = 0; priority_index < PRIORITY_WIDTH_POW2; priority_index = priority_index+1) begin : requests_per_priority_class_1
    for (request_index = 0; request_index < SIZE; request_index = request_index+1) begin : requests_per_priority_class_2
      assign requests_per_priority_class[priority_index][request_index] = requests[request_index] & priorities_onehot[request_index][priority_index];
    end
  end
endgenerate

// Transpose the previous array
wire [PRIORITY_WIDTH_POW2-1:0] priority_class_per_requests [SIZE-1:0];
generate
  for (request_index = 0; request_index < SIZE; request_index = request_index+1) begin : priority_class_per_requests_1
    for (priority_index = 0; priority_index < PRIORITY_WIDTH_POW2; priority_index = priority_index+1) begin : priority_class_per_requests_2
      assign priority_class_per_requests[request_index][priority_index] = requests_per_priority_class[priority_index][request_index];
    end
  end
endgenerate

// Create mask of which priority classes are active
wire [PRIORITY_WIDTH_POW2-1:0] active_priority_classes;
generate
  for (priority_class_index = 0; priority_class_index < PRIORITY_WIDTH_POW2; priority_class_index = priority_class_index+1) begin : gen_active_priority_classes
    assign active_priority_classes[priority_class_index] = |requests_per_priority_class[priority_class_index];
  end
endgenerate

// Locate the highest active priority class
wire [PRIORITY_WIDTH_POW2-1:0] highest_priority_class;
assign highest_priority_class[0] = active_priority_classes[0];
generate
  for (priority_class_index = 1; priority_class_index < PRIORITY_WIDTH_POW2; priority_class_index = priority_class_index+1) begin : gen_highest_priority_classes
    assign highest_priority_class[priority_class_index] = ~highest_priority_class[priority_class_index-1] & active_priority_classes[priority_class_index];
  end
endgenerate

// Get the requests with the highest priority
wire [SIZE-1:0] highest_priority_requests;
generate
  for (request_index = 0; request_index < PRIORITY_WIDTH_POW2; request_index = request_index+1) begin : gen_highest_priority_requests
    assign highest_priority_requests[request_index] = highest_priority_class & priority_class_per_requests[request_index];
  end
endgenerate

generate
  // Round robin between the requests of highest priority
  if (FALLBACK_ROUND_ROBIN) begin
    round_robin_arbiter #(
      .SIZE ( SIZE )
    ) fallback_arbiter (
      .clock    ( clock                     ),
      .resetn   ( resetn                    ),
      .requests ( highest_priority_requests ),
      .grant    ( grant                     )
    );
  end
  // Static priority between the requests of highest priority
  else begin
    static_priority_arbiter #(
      .SIZE ( SIZE )
    ) fallback_arbiter (
      .requests ( highest_priority_requests ),
      .grant    ( grant                     )
    );
  end
endgenerate

endmodule
