// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        timeout_static_priority_arbiter_tb.sv                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the static priority arbiter with timeout.      ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "common.svh"



module timeout_static_priority_arbiter_tb ();

// Test parameters
localparam real CLOCK_PERIOD = 10;
localparam      SIZE         = 4;
localparam      SIZE_POW2    = 2 ** SIZE;
localparam      TIMEOUT      = 16;
localparam      VARIANT      = "fast";

// Device ports
logic            clock;
logic            resetn;
logic [SIZE-1:0] requests;
logic [SIZE-1:0] grant;

// Test signals
logic [SIZE-1:0] grant_expected;
bool             found_grant;

// Device under test
timeout_static_priority_arbiter #(
  .SIZE     ( SIZE     ),
  .VARIANT  ( VARIANT  ),
  .TIMEOUT  ( TIMEOUT  )
) timeout_static_priority_arbiter_dut (
  .clock    ( clock    ),
  .resetn   ( resetn   ),
  .requests ( requests ),
  .grant    ( grant    )
);

localparam TIMEOUT_LOG2 = $clog2(TIMEOUT);
wire [TIMEOUT_LOG2-1:0] timeout_countdowns_1 = timeout_static_priority_arbiter_dut.timeout_countdowns[1];
wire [TIMEOUT_LOG2-1:0] timeout_countdowns_2 = timeout_static_priority_arbiter_dut.timeout_countdowns[2];
wire [TIMEOUT_LOG2-1:0] timeout_countdowns_3 = timeout_static_priority_arbiter_dut.timeout_countdowns[3];

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("timeout_static_priority_arbiter_tb.vcd");
  $dumpvars(0,timeout_static_priority_arbiter_tb);

  // Initialization
  requests = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Exhaustive test
  $display("CHECK 1 : Exhaustive test.");
  for (integer request_configuration = 0; request_configuration < SIZE_POW2; request_configuration++) begin
    @(negedge clock);
    requests = request_configuration;
    // Calculate expected grant
    grant_expected = 0;
    found_grant    = false;
    for (integer request_index = 0; request_index < SIZE; request_index++) begin
      if (requests[request_index] == 1'b1 && !found_grant) begin
        grant_expected = (1 << request_index);
        found_grant    = true;
      end
    end
    // Check the grant output
    @(posedge clock);
    assert (grant === grant_expected) else begin
      $error("[%0tns] Incorrect grant for request configuration %b. Expected %b, got %b.", $time, requests, grant_expected, grant);
    end
    // Reset the timeout countdowns
    @(negedge clock);
    requests       = 0;
    grant_expected = 0;
    @(negedge clock);
    resetn = 0;
    @(negedge clock);
    resetn = 1;
  end

  repeat (10) @(posedge clock);

  // Check 2 : Single request timeout
  $display("CHECK 2 : Single request timeout.");
  for (integer request_index = 1; request_index < SIZE; request_index++) begin
    @(negedge clock);
    // Enable the first request and one request that will timeout
    requests       = (1 << request_index) | 1;
    grant_expected = 1;
    #1; // Propagate the requests to the grant
    // Keep the requests stable and check the grant over multiple timeout periods
    for (integer timeout_index = 0; timeout_index < 5*TIMEOUT; timeout_index++) begin
      // Check the grant output
      assert (grant === grant_expected) else begin
        $error("[%0tns] Incorrect grant for requests %b stable for %0d cycles, with timeout of %0d cycles for channel %0d. Expected %b, got %b.", $time, requests, timeout_index, TIMEOUT, request_index, grant_expected, grant);
      end
      // Update the expected grant when the timeout countdowns are updated
      @(posedge clock);
      if (timeout_index > 0 && (timeout_index+2) % (TIMEOUT+1) == 0) begin
        grant_expected = 1 << request_index;
      end else begin
        grant_expected = 1;
      end
      @(negedge clock);
    end
    // Reset the timeout countdowns
    @(negedge clock);
    requests       = 0;
    grant_expected = 0;
    @(negedge clock);
    resetn = 0;
    @(negedge clock);
    resetn = 1;
  end

  // End of test
  $finish;
end

endmodule
