// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        wrapping_counter.testbench.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the wrapping counter.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module wrapping_counter__testbench ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer RANGE        = 4;
localparam integer RANGE_LOG2   = $clog2(RANGE);
localparam integer RESET_VALUE  = 0;

// Check parameters
localparam integer CHECK_TIMEOUT             = 1000;
localparam integer RANDOM_CHECK_DURATION     = 1000;
localparam real    RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real    RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic                  clock;
logic                  resetn;
logic                  increment;
logic                  decrement;
logic [RANGE_LOG2-1:0] count;

// Test variables
integer min_count = 0;
integer max_count = RANGE - 1;
integer expected_count;
integer timeout_countdown;

// Device under test
wrapping_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE )
) wrapping_counter_dut (
  .clock     ( clock     ),
  .resetn    ( resetn    ),
  .increment ( increment ),
  .decrement ( decrement ),
  .count     ( count     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Function to predict next count value with wrapping
function integer predict_next_count(input integer current_count, input logic increment_signal, input logic decrement_signal);
  if (increment_signal && !decrement_signal) begin
    if (current_count == max_count) begin
      return min_count; // Wrap to min
    end else begin
      return current_count + 1;
    end
  end else if (decrement_signal && !increment_signal) begin
    if (current_count == min_count) begin
      return max_count; // Wrap to max
    end else begin
      return current_count - 1;
    end
  end else begin
    return current_count;
  end
endfunction

// Main block
initial begin
  // Log waves
  $dumpfile("wrapping_counter.testbench.vcd");
  $dumpvars(0,wrapping_counter__testbench);

  // Initialization
  increment = 0;
  decrement = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  expected_count = RESET_VALUE;
  if (count != expected_count) begin
    $error("[%0tns] Value at reset '%0d' is different than the one given as parameter '%0d'.", $time, count, RESET_VALUE);
  end

  repeat(10) @(posedge clock);

  // Check 2 : Increment without wrapping
  $display("CHECK 2 : Increment without wrapping.");
  expected_count = min_count;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count != max_count) begin
        @(posedge clock);
        expected_count += 1;
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not reach max count.", $time);
    end
  join_any
  disable fork;
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 3 : Increment with wrapping
  $display("CHECK 3 : Increment with wrapping.");
  if (count != max_count) begin
    $error("[%0tns] Counter should be at max_count '%0d' but is at '%0d'.", $time, max_count, count);
  end
  @(negedge clock);
  increment = 1;
  @(negedge clock);
  if (count != min_count) begin
    $error("[%0tns] Counter should wrap to min_count '%0d' but is at '%0d'.", $time, min_count, count);
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Decrement with wrapping
  $display("CHECK 4 : Decrement with wrapping.");
  if (count != min_count) begin
    $error("[%0tns] Counter should be at min_count '%0d' but is at '%0d'.", $time, min_count, count);
  end
  @(negedge clock);
  decrement = 1;
  @(negedge clock);
  if (count != max_count) begin
    $error("[%0tns] Counter should wrap to max_count '%0d' but is at '%0d'.", $time, max_count, count);
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Decrement without wrapping
  $display("CHECK 5 : Decrement without wrapping.");
  expected_count = max_count;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count != min_count) begin
        @(posedge clock);
        expected_count -= 1;
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not reach min count.", $time);
    end
  join_any
  disable fork;
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 6 : Full cycle increment
  $display("CHECK 6 : Full cycle increment.");
  expected_count = min_count;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        @(posedge clock);
        expected_count = predict_next_count(count, 1, 0);
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
      end
      // Should be back to min_count after full cycle
      if (count != min_count) begin
        $error("[%0tns] Counter should be back to min_count '%0d' after full cycle but is at '%0d'.", $time, min_count, count);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not complete full increment cycle.", $time);
    end
  join_any
  disable fork;
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 7 : Full cycle decrement
  $display("CHECK 7 : Full cycle decrement.");
  expected_count = min_count;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        @(posedge clock);
        expected_count = predict_next_count(count, 0, 1);
        @(negedge clock);
        if (count != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
      end
      // Should be back to min_count after full cycle
      if (count != min_count) begin
        $error("[%0tns] Counter should be back to min_count '%0d' after full cycle but is at '%0d'.", $time, min_count, count);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(posedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout, could not complete full decrement cycle.", $time);
    end
  join_any
  disable fork;
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 8 : Random
  $display("CHECK 8 : Random.");
  @(negedge clock);
  decrement = 0;
  increment = 0;
  resetn    = 0;
  expected_count = RESET_VALUE;
  @(negedge clock);
  resetn = 1;
  @(negedge clock);
  repeat (RANDOM_CHECK_DURATION) begin
    increment = random_boolean(RANDOM_CHECK_INCREMENT_PROBABILITY);
    decrement = random_boolean(RANDOM_CHECK_DECREMENT_PROBABILITY);
    @(posedge clock);
    expected_count = predict_next_count(count, increment, decrement);
    @(negedge clock);
    if (count != expected_count) begin
      $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
    end
  end
  increment = 0;
  decrement = 0;

  // End of test
  $finish;
end

endmodule