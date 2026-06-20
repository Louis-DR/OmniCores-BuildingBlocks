// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_stream_arbiter.testbench.sv                  ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the static priority stream arbiter.            ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module static_priority_stream_arbiter__testbench ();

// Device parameters
localparam int PAYLOAD_WIDTH  = 8;
localparam int NUMBER_STREAMS = 4;

// Test parameters
localparam int  RANDOM_CHECK_ITERATIONS                   = 1000;
localparam real RANDOM_CHECK_UPSTREAM_VALID_PROBABILITY   = 0.25;
localparam real RANDOM_CHECK_DOWNSTREAM_READY_PROBABILITY = 0.5;

// Device ports
logic [NUMBER_STREAMS-1:0]                     upstream_valids;
logic [NUMBER_STREAMS-1:0]                     upstream_readys;
logic [NUMBER_STREAMS-1:0] [PAYLOAD_WIDTH-1:0] upstream_payloads;
logic                                          downstream_valid;
logic                                          downstream_ready;
logic                      [PAYLOAD_WIDTH-1:0] downstream_payload;

// Test signals
logic [NUMBER_STREAMS-1:0] expected_upstream_readys;
logic                      expected_downstream_valid;
logic  [PAYLOAD_WIDTH-1:0] expected_downstream_payload;
bool                       found_grant;

// Device under test
static_priority_stream_arbiter #(
  .PAYLOAD_WIDTH      ( PAYLOAD_WIDTH      ),
  .NUMBER_STREAMS     ( NUMBER_STREAMS     )
) static_priority_stream_arbiter_dut (
  .upstream_valids    ( upstream_valids    ),
  .upstream_readys    ( upstream_readys    ),
  .upstream_payloads  ( upstream_payloads  ),
  .downstream_valid   ( downstream_valid   ),
  .downstream_ready   ( downstream_ready   ),
  .downstream_payload ( downstream_payload )
);

// Main block
initial begin
  // Log waves
  $dumpfile("static_priority_stream_arbiter.testbench.vcd");
  $dumpvars(0,static_priority_stream_arbiter__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  upstream_valids  = '0;
  downstream_ready =  0;

  // Small delay after initialization
  #1;

  // Check 1 : Random stimulus
  $display("CHECK 1 : Random stimulus.");
  repeat (RANDOM_CHECK_ITERATIONS) begin
    // Random stimulus
    for (int stream_index = 0; stream_index < NUMBER_STREAMS; stream_index++) begin
      upstream_payloads[stream_index] = $urandom();
      upstream_valids[stream_index]   = random_boolean(RANDOM_CHECK_UPSTREAM_VALID_PROBABILITY);
    end
    downstream_ready = random_boolean(RANDOM_CHECK_DOWNSTREAM_READY_PROBABILITY);

    // Calculate expected state
    expected_upstream_readys    = '0;
    expected_downstream_valid   =  0;
    expected_downstream_payload = '0;
    if (|upstream_valids) begin
      expected_downstream_valid = 1;
      begin
        found_grant = false;
        for (int stream_index = 0; stream_index < NUMBER_STREAMS; stream_index++) begin
          if (upstream_valids[stream_index] && !found_grant) begin
            expected_downstream_payload = upstream_payloads[stream_index];
            if (downstream_ready) begin
              expected_upstream_readys[stream_index] = 1'b1;
            end
            found_grant = true;
          end
        end
      end
    end

    // Wait for combinational logic propagation
    #1;

    // Perform checks of all error cases
    if (|upstream_valids) begin
      assert (downstream_valid === 1'b1) else begin
        $error("[%t] Some upstream channels are valid but the downstream channel is not valid.", $realtime);
      end
    end

    if (upstream_valids === '0) begin
      assert (downstream_valid === 1'b0) else begin
        $error("[%t] No upstream channels are valid but the downstream channel valid.", $realtime);
      end
    end

    if (!downstream_ready) begin
      assert (upstream_readys === '0) else begin
        $error("[%t] The downstream channel is not ready but some upstream channels are ready.", $realtime);
      end
    end

    assert ((upstream_readys & (upstream_readys - 1)) === '0) else begin
      $error("[%t] Multiple upstream channels are ready.", $realtime);
    end

    assert ((upstream_readys & upstream_valids) === upstream_readys) else begin
      $error("[%t] Some upstream channels are ready but not valid.", $realtime);
    end

    // General expected values check
    assert (upstream_readys === expected_upstream_readys) else begin
      $error("[%t] Incorrect ready signals for upstream channels. Expected '%b', got '%b'.", $realtime, expected_upstream_readys, upstream_readys);
    end

    if (downstream_valid) begin
      assert (downstream_payload === expected_downstream_payload) else begin
        $error("[%t] Incorrect downstream payload. Expected '%h', got '%h'.", $realtime, expected_downstream_payload, downstream_payload);
      end
    end

    // Small delay before next configuration
    #1;
  end

  // End of test
  $finish;
end

endmodule
