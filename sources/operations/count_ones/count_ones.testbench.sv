// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        count_ones.testbench.sv                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the count ones module.                         ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module count_ones__testbench ();

// Device parameters
localparam int DATA_WIDTH  = 12;
localparam int COUNT_WIDTH = $clog2(DATA_WIDTH+1);

// Test parameters
localparam int DATA_WIDTH_POW2       = 2**DATA_WIDTH;
localparam int FULL_CHECK_MAX_DURATION = 1024; // Exhaustive up to 2^10
localparam int RANDOM_CHECK_DURATION   = 1000; // Number of random iterations

// Device ports
logic  [DATA_WIDTH-1:0] data;
logic [COUNT_WIDTH-1:0] count;

// Device under test
count_ones #(
  .DATA_WIDTH  ( DATA_WIDTH  ),
  .COUNT_WIDTH ( COUNT_WIDTH )
) count_ones_dut (
  .data  ( data  ),
  .count ( count )
);

// Reference function for counting ones
function logic [COUNT_WIDTH-1:0] reference_count_ones(input logic [DATA_WIDTH-1:0] data_value);
  logic [COUNT_WIDTH-1:0] count_result;
  count_result = 0;
  for (int bit_index = 0; bit_index < DATA_WIDTH; bit_index++) begin
    if (data_value[bit_index]) begin
      count_result++;
    end
  end
  return count_result;
endfunction

// Task to check count correctness for a single data value
task check_count(input logic [DATA_WIDTH-1:0] data_value);
  logic [COUNT_WIDTH-1:0] expected_count;

  // Stimulus
  data = data_value;
  #1;

  // Check
  expected_count = reference_count_ones(data_value);
  assert (count === expected_count)
    else $error("[%0tns] Incorrect count for input '%b'. Expected '%0d', got '%0d'.",
                $time, data_value, expected_count, count);
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("count_ones.testbench.vcd");
  $dumpvars(0, count_ones__testbench);

  // Initialization
  data = 0;

  // Small delay after initialization
  #1;

  // If the data width is small, we perform exhaustive testing
  if (DATA_WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test
    $display("CHECK 1: Exhaustive test.");
    for (int value = 0; value < DATA_WIDTH_POW2; value++) begin
      check_count(value);
    end

  end

  // If the data width is large, we perform directed and random testing
  else begin

    // Check 1: Directed patterns
    $display("CHECK 1: Directed patterns.");

    // All zeros
    check_count({DATA_WIDTH{1'b0}});

    // All ones
    check_count({DATA_WIDTH{1'b1}});

    // Walking ones
    for (int bit_position = 0; bit_position < DATA_WIDTH; bit_position++) begin
      check_count(1'b1 << bit_position);
    end

    // Walking zeros
    for (int bit_position = 0; bit_position < DATA_WIDTH; bit_position++) begin
      check_count(~(1'b1 << bit_position));
    end

    // Shifting ones (0001, 0011, 0111, 1111)
    for (int ones_count = 1; ones_count <= DATA_WIDTH; ones_count++) begin
      check_count(~({DATA_WIDTH{1'b1}} << ones_count));
    end

    // Shifting zeros (1110, 1100, 1000, 0000)
    for (int zeros_count = 1; zeros_count <= DATA_WIDTH; zeros_count++) begin
      check_count({DATA_WIDTH{1'b1}} << zeros_count);
    end

    // Check 2: Random test
    $display("CHECK 2: Random test.");
    repeat (RANDOM_CHECK_DURATION) begin
      check_count($urandom_range(0, DATA_WIDTH_POW2-1));
    end

  end

  // End of test
  $finish;
end

endmodule
