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
localparam      TIMEOUT      = 8;
localparam      VARIANT      = "fast";

// Check parameters
localparam integer RANDOM_CHECK_DURATION    = 1000;
localparam real    FAIRNESS_THRESHOLD_LOWER = 1 / SIZE;
localparam real    FAIRNESS_THRESHOLD_UPPER = 1 - FAIRNESS_THRESHOLD_LOWER;

// Device ports
logic            clock;
logic            resetn;
logic [SIZE-1:0] requests;
logic [SIZE-1:0] grant;

// Test signals
logic [SIZE-1:0] grant_expected;
bool             found_grant;

// Test variables
integer          pattern_position;
integer unsigned request_counts [SIZE];
integer unsigned grant_counts   [SIZE];
real             grant_ratio;

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

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Concurrent Assertions
`ifdef SIMULATION_SUPPORT_CONCURRENT_ASSERTION

initial begin
  $display("Concurrent assertions enabled.");
end

// Assertion 1: At most one grant
assert property (@(negedge clock) #1 $countones(grant) <= 1)
  else $error("[%0tns] More than one grant asserted : %b", $time, grant);

// Assertion 2: Grant implies request
assert property (@(negedge clock) #1 (grant !== '0) |-> ((grant & requests) === grant))
  else $error("[%0tns] Grant given (grant=%b), but corresponding request is not active (requests=%b).", $time, grant, requests);

// Assertion 3: Requests implies exactly one grant
assert property (@(negedge clock) #1 resetn |-> (|requests) |-> ($countones(grant) == 1))
  else $error("[%0tns] Requests active (requests=%b), but grant count is not one (grant=%b).", $time, requests, grant);

`else // Procedural Assertions Fallback

initial begin
  $display("Concurrent assertions disabled, using procedural assertions.");
end

always @(posedge clock) begin
  // Only perform checks after reset is deasserted
  if (resetn) begin
    // Assertion 1: At most one grant
    assert ($countones(grant) <= 1)
      else $error("[%0tns] More than one grant asserted : %b", $time, grant);

    // Assertion 2: Grant implies request
    assert ((grant === '0) || ((grant & requests) === grant))
      else $error("[%0tns] Grant given (grant=%b), but corresponding request is not active (requests=%b).", $time, grant, requests);

    // Assertion 3: Requests implies exactly one grant
    assert (!(|requests) || ($countones(grant) == 1))
      else $error("[%0tns] Requests active (requests=%b), but grant count is not one (grant=%b).", $time, requests, grant);
  end
end

`endif // SIMULATION_SUPPORT_CONCURRENT_ASSERTION

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

  repeat (10) @(posedge clock);

  // Check 3 : All requests timeout
  $display("CHECK 3 : All requests timeout.");
  @(negedge clock);
  // Enable the all requests
  requests         = '1;
  grant_expected   = 1;
  pattern_position = 1 - TIMEOUT;
  #1; // Propagate the requests to the grant
  // Keep the requests stable and check the grant over multiple timeout periods
  for (integer timeout_index = 0; timeout_index < 5*TIMEOUT; timeout_index++) begin
    // Check the grant output
    assert (grant === grant_expected) else begin
      $error("[%0tns] Incorrect grant for requests %b stable for %0d cycles, with timeout of %0d cycles for channel %0d. Expected %b, got %b.", $time, requests, timeout_index, TIMEOUT, 0, grant_expected, grant);
    end
    @(posedge clock);
    // Update the pattern position
    if (pattern_position == SIZE - 1) begin
      pattern_position = SIZE - TIMEOUT - 1;
    end else begin
      pattern_position = pattern_position + 1;
    end
    // Calculate the expected grant based on the pattern position
    if (pattern_position <= 0) begin
       // Channel 0
      grant_expected = 1;
    end else begin
      // Channels 1 to SIZE-1
      grant_expected = 1 << pattern_position;
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

  // Check 4 : First channel requesting, other channels random and fairness between them
  $display("CHECK 4 : First channel requesting, other channels random and fairness between them.");
  foreach (grant_counts   [grant_index])   grant_counts   [grant_index]   = 0;
  foreach (request_counts [request_index]) request_counts [request_index] = 0;
  repeat (RANDOM_CHECK_DURATION) begin
    @(negedge clock);
    // Random requests
    requests = $urandom_range(0, SIZE_POW2 - 1) | 1;
    // Find which requests are active and increment their count
    for (integer request_index = 1; request_index < SIZE; request_index++) begin
      if (requests[request_index]) begin
        request_counts[request_index]++;
      end
    end
    @(posedge clock);
    // Find which grant is active and increment its count
    for (integer grant_index = 1; grant_index < SIZE; grant_index++) begin
      if (grant[grant_index]) begin
        grant_counts[grant_index]++;
      end
    end
  end
  // Check fairness
  for (integer channel_index = 1; channel_index < SIZE; channel_index++) begin
    grant_ratio = real'(grant_counts[channel_index]) / real'(request_counts[channel_index]);
    assert (grant_ratio >= FAIRNESS_THRESHOLD_LOWER)
      else $error("[%0tns] Channel %0d made %0d requests but only got %0d grants (%0f). The arbiter might not be fair.", $time, channel_index, request_counts[channel_index], grant_counts[channel_index], grant_ratio);
    assert (grant_ratio <= FAIRNESS_THRESHOLD_UPPER)
      else $error("[%0tns] Channel %0d made only %0d requests but got %0d grants (%0f). The arbiter might not be fair.", $time, channel_index, request_counts[channel_index], grant_counts[channel_index], grant_ratio);
  end

  // End of test
  $finish;
end

endmodule
