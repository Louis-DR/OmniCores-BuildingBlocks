// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        static_priority_arbiter.testbench.sv                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the static priority arbiter.                   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "boolean.svh"



module static_priority_arbiter__testbench ();

// Test parameters
localparam int SIZE      = 4;
localparam int SIZE_POW2 = 2 ** SIZE;

// Device ports
logic [SIZE-1:0] requests;
logic [SIZE-1:0] grant;

// Test signals
logic [SIZE-1:0] grant_expected;
bool             found_grant;

// Device under test
static_priority_arbiter #(
  .SIZE     ( SIZE     )
) static_priority_arbiter_dut (
  .requests ( requests ),
  .grant    ( grant    )
);

// Main block
initial begin
  // Log waves
  $dumpfile("static_priority_arbiter.testbench.vcd");
  $dumpvars(0,static_priority_arbiter__testbench);

  // Initialization
  requests = 0;

  // Small delay after initialization
  #1;

  // Check 1 : Exhaustive test
  $display("CHECK 1 : Exhaustive test.");
  for (int request_configuration = 0; request_configuration < SIZE_POW2; request_configuration++) begin
    requests = request_configuration;

    // Calculate expected grant
    grant_expected = '0;
    found_grant    = false;
    for (int request_index = 0; request_index < SIZE; request_index++) begin
      if (requests[request_index] && !found_grant) begin
        grant_expected = (1 << request_index);
        found_grant    = true;
      end
    end

    // Wait for combinational logic propagation
    #1;

    // Check the grant output
    assert (grant === grant_expected) else begin
      $error("[%0tns] Incorrect grant for request configuration %b. Expected %b, got %b.", $time, requests, grant_expected, grant);
    end

    // Small delay before next configuration if desired
    #1;
  end

  // End of test
  $finish;
end

endmodule
