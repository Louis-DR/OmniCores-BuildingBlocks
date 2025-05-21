// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        timout_static_priority_arbiter.v                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Arbiters between different request channels. The grant is    ║
// ║              given to the first ready request channel. If a request is    ║
// ║              waiting for a long time, it will be given priority.          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`include "common.vh"



module timout_static_priority_arbiter #(
  parameter SIZE    = 4,
  parameter VARIANT = "fast",
  parameter TIMEOUT = 8
) (
  input             clock,
  input             resetn,
  input  [SIZE-1:0] requests,
  output [SIZE-1:0] grant
);

localparam TIMEOUT_LOG2 = `CLOG2(TIMEOUT);

// Timeout countdowns for each channel
// The first channel cannot timeout as it is the highest priority
reg [TIMEOUT_LOG2-1:0] timeout_countdowns [SIZE-1:1];

// Requests that are not granted this cycle
wire [SIZE-1:1] requests_not_granted = requests[SIZE-1:1] & ~grant[SIZE-1:1];

// Requests that have timed out
wire [SIZE-1:1] requests_timeout = requests_not_granted & (timeout_countdowns[SIZE-1:1] == 0);

// Timeout countdowns sequential logic
always_ff @(posedge clock or negedge resetn) begin
  // Reset
  if (!resetn) begin
    for (int channel_index = 1; channel_index < SIZE; channel_index = channel_index+1) begin
      timeout_countdowns[channel_index] <= TIMEOUT;
    end
  end
  // Operation
  else begin
    for (int channel_index = 1; channel_index < SIZE; channel_index = channel_index+1) begin
      // If the channel is not granted and is not already timed out, decrement the timeout countdown
      if (requests_not_granted[channel_index] && !requests_timeout[channel_index]) begin
        timeout_countdowns[channel_index] <= timeout_countdowns[channel_index] - 1;
      end
      // If the request has been granted, or the channel is not requesting, reset the timeout countdown
      else begin
        timeout_countdowns[channel_index] <= TIMEOUT;
      end
    end
  end
end

// If any request has timed out, give priority to the timed out requests
wire any_request_timeout = |requests_timeout;
wire [SIZE-1:0] priority_requests = any_request_timeout ? {requests_timeout, 1'b0} : requests;

static_priority_arbiter #(
  .SIZE     ( SIZE    ),
  .VARIANT  ( VARIANT )
) static_priority_arbiter (
  .requests ( priority_requests ),
  .grant    ( grant             )
);

endmodule
