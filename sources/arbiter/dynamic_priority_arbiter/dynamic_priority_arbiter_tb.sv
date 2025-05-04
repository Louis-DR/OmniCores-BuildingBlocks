// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        dynamic_priority_arbiter_tb.sv                               ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the dynamic priority arbiter.                  ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "common.svh"



module dynamic_priority_arbiter_tb ();

// Test parameters
localparam real CLOCK_PERIOD          = 10;
localparam      SIZE                  = 4;
localparam      SIZE_POW2             = 2 ** SIZE;
localparam      PRIORITY_WIDTH        = $clog2(SIZE);
localparam      PRIORITIES_WIDTH      = PRIORITY_WIDTH * SIZE;
localparam      PRIORITIES_WIDTH_POW2 = 2 ** PRIORITIES_WIDTH;
localparam      FALLBACK_ARBITER      = "static_priority";
localparam      FALLBACK_VARIANT      = "fast";

// Check parameters
localparam integer RANDOM_CHECK_DURATION = 1000;

// Device ports
logic                        clock;
logic                        resetn;
logic             [SIZE-1:0] requests;
logic [PRIORITIES_WIDTH-1:0] priorities;
logic             [SIZE-1:0] grant;

// Test variables
logic [SIZE-1:0] highest_priority_requests; // Expected mask of highest prio active requests

// Device under test
dynamic_priority_arbiter #(
  .SIZE             ( SIZE             ),
  .PRIORITY_WIDTH   ( PRIORITY_WIDTH   ),
  .PRIORITIES_WIDTH ( PRIORITIES_WIDTH ),
  .FALLBACK_ARBITER ( FALLBACK_ARBITER ),
  .FALLBACK_VARIANT ( FALLBACK_VARIANT )
) dynamic_priority_arbiter_dut (
  .clock            ( clock            ),
  .resetn           ( resetn           ),
  .requests         ( requests         ),
  .priorities       ( priorities       ),
  .grant            ( grant            )
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

// Procedural Assertions Fallback
`else

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

// Helper function to calculate the mask of highest priority active requests
function automatic logic [SIZE-1:0] get_highest_priority_active_requests (
  input logic             [SIZE-1:0] requests,
  input logic [PRIORITIES_WIDTH-1:0] priorities
);
  logic [PRIORITY_WIDTH-1:0] priorities_unpacked [SIZE-1:0];
  logic [PRIORITY_WIDTH-1:0] highest_priority_level;
  bool                       highest_priority_found;
  logic           [SIZE-1:0] highest_priority_active_requests;

  // Unpack priorities
  for (integer request_index = 0; request_index < SIZE; request_index++) begin
    priorities_unpacked[request_index] = priorities[request_index * PRIORITY_WIDTH +: PRIORITY_WIDTH];
  end

  // Find highest priority level among the active requests
  highest_priority_level = '0; // Initialize to lowest possible priority
  highest_priority_found = false;
  for (integer request_index = 0; request_index < SIZE; request_index++) begin
    if (requests[request_index]) begin
      // If this is the first found or its priority is higher than the current highest
      if (!highest_priority_found || priorities_unpacked[request_index] > highest_priority_level) begin
        highest_priority_level = priorities_unpacked[request_index];
        highest_priority_found = true;
      end
    end
  end

  // Generate mask of active requests matching the highest priority level
  highest_priority_active_requests = '0;
  if (highest_priority_found) begin
    for (integer request_index = 0; request_index < SIZE; request_index++) begin
      if (requests[request_index] && (priorities_unpacked[request_index] == highest_priority_level)) begin
        highest_priority_active_requests[request_index] = 1'b1;
      end
    end
  end

  return highest_priority_active_requests;
endfunction

// Main block
initial begin
  // Log waves
  $dumpfile("dynamic_priority_arbiter_tb.vcd");
  $dumpvars(0,dynamic_priority_arbiter_tb);

  // Initialization
  requests   = '0;
  priorities = '0;

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

  repeat (10) @(posedge clock);

  // Check 2 : All requests active, exaustive priorities
  $display("CHECK 2 : All requests active, exaustive priorities.");
  // Activate all requests
  requests = '1;
  // Check all possible priorities
  for (integer priorities_configuration = 0; priorities_configuration < PRIORITIES_WIDTH_POW2; priorities_configuration++) begin
    priorities = priorities_configuration;
    // Get the mask of expected possible grants
    highest_priority_requests = get_highest_priority_active_requests(requests, priorities);
    @(posedge clock);
    // Grant must be given to active request with the highest priority
    assert ((grant & highest_priority_requests) === grant) else begin
      $error("[%0tns] Grant is not given to an active request with the highest priority (requests=%b, priorities=%h, grant=%b, expected=%b).", $time, requests, priorities, grant, highest_priority_requests);
    end
  end
  requests   = '0;
  priorities = '0;

  repeat (10) @(posedge clock);

  // Check 3 : Random stimulus
  $display("CHECK 3 : Random stimulus.");
  repeat (RANDOM_CHECK_DURATION) begin
    @(negedge clock);
    // Generate random requests and priorities
    requests   = $urandom_range(0, SIZE_POW2 - 1);
    priorities = $urandom_range(0, PRIORITIES_WIDTH_POW2 - 1);
    // Get the mask of expected possible grants
    highest_priority_requests = get_highest_priority_active_requests(requests, priorities);
    @(posedge clock);
    // Grant must be given to active request with the highest priority
    assert ((grant & highest_priority_requests) === grant) else begin
      $error("[%0tns] Grant is not given to an active request with the highest priority (requests=%b, priorities=%h, grant=%b, expected=%b).", $time, requests, priorities, grant, highest_priority_requests);
    end
  end

  // End of test
  $finish;
end

endmodule
