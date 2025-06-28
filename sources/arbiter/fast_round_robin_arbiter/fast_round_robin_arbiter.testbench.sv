// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        fast_round_robin_arbiter.testbench.sv                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the fast variant of the round-robin arbiter.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module fast_round_robin_arbiter__testbench ();

// Test parameters
localparam real CLOCK_PERIOD    = 10;
localparam      SIZE            = 4;
localparam      SIZE_POW2       = 2 ** SIZE;
localparam      ROTATE_ON_GRANT = 0;

// Check parameters
localparam integer RANDOM_CHECK_DURATION    = 1000;
localparam real    FAIRNESS_THRESHOLD_LOWER = 1 / SIZE;
localparam real    FAIRNESS_THRESHOLD_UPPER = 1 - FAIRNESS_THRESHOLD_LOWER;

// Device ports
logic            clock;
logic            resetn;
logic [SIZE-1:0] requests;
logic [SIZE-1:0] grant;

// Test variables
logic [SIZE-1:0] granted_mask;
integer unsigned request_counts [SIZE];
integer unsigned grant_counts   [SIZE];
real             grant_ratio;

// Device under test
fast_round_robin_arbiter #(
  .SIZE            ( SIZE            ),
  .ROTATE_ON_GRANT ( ROTATE_ON_GRANT )
) fast_round_robin_arbiter_dut (
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
assert property (@(posedge clock) $countones(grant) <= 1)
  else $error("[%0tns] More than one grant asserted : %b", $time, grant);

// Assertion 2: Grant implies request
assert property (@(posedge clock) (grant !== '0) |-> ((grant & requests) === grant))
  else $error("[%0tns] Grant given (grant=%b), but corresponding request is not active (requests=%b).", $time, grant, requests);

// Assertion 3: Requests implies exactly one grant
assert property (@(posedge clock) resetn |-> (|requests) |-> ($countones(grant) == 1))
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
  $dumpfile("fast_round_robin_arbiter.testbench.vcd");
  $dumpvars(0,fast_round_robin_arbiter__testbench);

  // Initialization
  requests = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Single request active
  $display("CHECK 1 : Single request active.");
  requests = '0;
  // Activate requests one at a time
  for (integer request_index = 0; request_index < SIZE; request_index++) begin
    requests = (1 << request_index);
    // Repeat to check all positions of the priority pointer
    repeat (SIZE) begin
      @(posedge clock);
      // Grant should always match the single request
      assert (grant === requests)
        else $error("[%0tns] Grant doesn't match the only active request (requests=%b, grant=%b).", $time, requests, grant);
    end
  end
  requests = '0;

  repeat(10) @(posedge clock);

  // Check 2 : All requests active
  $display("CHECK 2 : All requests active.");
  requests     = '1; // Activate all requests
  granted_mask = '0; // Reset mask for this check
  // Repeat to check all positions of the priority pointer
  repeat (SIZE) begin
    @(posedge clock);
    // Mark the granted_mask request
    granted_mask = granted_mask | grant;
  end
  requests = '0;
  // Verify that all requests received a grant at least once
  assert (granted_mask === '1)
    else $error("[%0tns] Not all requests received a grant when all were active (granted_mask=%b).", $time, granted_mask);

  repeat(10) @(posedge clock);

  // Check 3 : Random stimulus and fairness
  $display("CHECK 3 : Random stimulus and fairness.");
  foreach (grant_counts   [grant_index])   grant_counts   [grant_index]   = 0;
  foreach (request_counts [request_index]) request_counts [request_index] = 0;
  repeat (RANDOM_CHECK_DURATION) begin
    @(negedge clock);
    // Random requests
    requests = $urandom_range(0, SIZE_POW2 - 1);
    // Find which requests are active and increment their count
    for (integer request_index = 0; request_index < SIZE; request_index++) begin
      if (requests[request_index]) begin
        request_counts[request_index]++;
      end
    end
    @(posedge clock);
    // Find which grant is active and increment its count
    for (integer grant_index = 0; grant_index < SIZE; grant_index++) begin
      if (grant[grant_index]) begin
        grant_counts[grant_index]++;
      end
    end
  end
  // Check fairness
  for (integer channel_index = 0; channel_index < SIZE; channel_index++) begin
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
