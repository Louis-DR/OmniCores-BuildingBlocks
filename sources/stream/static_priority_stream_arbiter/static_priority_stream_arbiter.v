// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_stream_arbiter.v                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiter between multiple valid-ready streams and transmit    ║
// ║              the payload of the first ready channel in the order of the   ║
// ║              bus.                                                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module static_priority_stream_arbiter #(
  parameter PAYLOAD_WIDTH  = 8,
  parameter NUMBER_STREAMS = 4
) (
  input  [NUMBER_STREAMS-1:0]                     upstream_valids,
  output [NUMBER_STREAMS-1:0]                     upstream_readys,
  input  [NUMBER_STREAMS-1:0] [PAYLOAD_WIDTH-1:0] upstream_payloads,
  output                                          downstream_valid,
  input                                           downstream_ready,
  output                      [PAYLOAD_WIDTH-1:0] downstream_payload
);

wire [NUMBER_STREAMS-1:0] upstream_grant;

static_priority_arbiter #(
  .SIZE ( NUMBER_STREAMS )
) arbiter (
  .requests ( upstream_valids ),
  .grant    ( upstream_grant  )
);

assign downstream_valid = |upstream_valids;
assign upstream_readys  = downstream_ready ? upstream_grant : '0;

array_select #(
  .ELEMENT_WIDTH ( PAYLOAD_WIDTH  ),
  .ARRAY_SIZE    ( NUMBER_STREAMS ),
  .SELECT_ONEHOT ( 1              )
) payload_selector (
  .array   ( upstream_payloads  ),
  .select  ( upstream_grant     ),
  .element ( downstream_payload )
);

endmodule
