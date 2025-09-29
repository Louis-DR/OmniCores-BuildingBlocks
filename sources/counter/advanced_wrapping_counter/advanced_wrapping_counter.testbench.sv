// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        advanced_wrapping_counter.testbench.sv                       ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the wrapping counter.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"



module advanced_wrapping_counter__testbench ();

// Device parameters
localparam int  RANGE        = 4;
localparam int  RESET_VALUE  = 0;
localparam int  LAP_BIT      = 1;

// Derived parameters
localparam int  WIDTH_NO_LAP = $clog2(RANGE);
localparam int  WIDTH        = WIDTH_NO_LAP + LAP_BIT;
localparam int  LAP_INDEX    = WIDTH - 1;
localparam int  COUNT_MIN    = 0;
localparam int  COUNT_MAX    = RANGE - 1;

// Test parameters
localparam real CLOCK_PERIOD = 10;

// Check parameters
localparam int  CHECK_TIMEOUT                      = 1000;
localparam int  RANDOM_CHECK_DURATION              = 1000;
localparam real RANDOM_CHECK_INCREMENT_PROBABILITY = 0.5;
localparam real RANDOM_CHECK_DECREMENT_PROBABILITY = 0.5;

// Device ports
logic             clock;
logic             resetn;
logic             load_enable;
logic [WIDTH-1:0] load_count;
logic             decrement;
logic             increment;
logic [WIDTH-1:0] count;
logic             minimum;
logic             maximum;
logic             underflow;
logic             overflow;

// Test variables
int   expected_count;
int   timeout_countdown;
int   previous_index;
logic previous_lap;
logic [WIDTH_NO_LAP-1:0] count_no_lap;
assign count_no_lap = count[WIDTH_NO_LAP-1:0];

// Device under test
advanced_wrapping_counter #(
  .RANGE       ( RANGE       ),
  .RESET_VALUE ( RESET_VALUE ),
  .LAP_BIT     ( LAP_BIT     )
) advanced_wrapping_counter_dut (
  .clock       ( clock       ),
  .resetn      ( resetn      ),
  .load_enable ( load_enable ),
  .load_count  ( load_count  ),
  .decrement   ( decrement   ),
  .increment   ( increment   ),
  .count       ( count       ),
  .minimum     ( minimum     ),
  .maximum     ( maximum     ),
  .underflow   ( underflow   ),
  .overflow    ( overflow    )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Function to predict next count value with wrapping
function int predict_next_count(input int current_count, input logic increment_signal, input logic decrement_signal);
  if (increment_signal && !decrement_signal) begin
    if (current_count == COUNT_MAX) begin
      return COUNT_MIN; // Wrap to min
    end else begin
      return current_count + 1;
    end
  end else if (decrement_signal && !increment_signal) begin
    if (current_count == COUNT_MIN) begin
      return COUNT_MAX; // Wrap to max
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
  $dumpfile("advanced_wrapping_counter.testbench.vcd");
  $dumpvars(0,advanced_wrapping_counter__testbench);

  // Initialization
  decrement   = 0;
  increment   = 0;
  load_enable = 0;
  load_count  = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Reset value
  $display("CHECK 1 : Reset value.");
  expected_count = RESET_VALUE;
  if (count_no_lap != expected_count) begin
    $error("[%0tns] Value at reset '%0d' is different than the one given as parameter '%0d'.", $time, count, RESET_VALUE);
  end
  if (minimum != (count_no_lap == COUNT_MIN)) begin
    $error("[%0tns] Minimum flag mismatch at reset.", $time);
  end
  if (maximum != (count_no_lap == COUNT_MAX)) begin
    $error("[%0tns] Maximum flag mismatch at reset.", $time);
  end
  if (overflow || underflow) begin
    $error("[%0tns] Overflow/Underflow should be low at reset.", $time);
  end

  repeat(10) @(posedge clock);

  // Check 2 : Increment without wrapping
  $display("CHECK 2 : Increment without wrapping.");
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count_no_lap != COUNT_MAX) begin
        previous_index = count_no_lap;
        previous_lap   = count[LAP_INDEX];
        @(posedge clock);
        expected_count += 1;
        @(negedge clock);
        #(1);
        if (overflow || underflow) begin
          $error("[%0tns] No wrap expected, overflow/underflow should be low.", $time);
        end
        if (count_no_lap != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
        if (LAP_BIT && count[LAP_INDEX] != previous_lap) begin
          $error("[%0tns] Lap bit should not toggle without wrapping.", $time);
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
  if (count_no_lap != COUNT_MAX) begin
    $error("[%0tns] Counter should be at maximum '%0d' but is at '%0d'.", $time, COUNT_MAX, count);
  end
  @(negedge clock);
  increment = 1;
  previous_index = count_no_lap;
  previous_lap   = count[LAP_INDEX];
  @(posedge clock);
  @(negedge clock);
  #(1);
  if (!overflow || underflow) begin
    $error("[%0tns] Overflow pulse expected on increment at maximum (underflow should be low).", $time);
  end
  if (count_no_lap != COUNT_MIN) begin
    $error("[%0tns] Counter should wrap to minimum '%0d' but is at '%0d'.", $time, COUNT_MIN, count);
  end
  if (!minimum || maximum) begin
    $error("[%0tns] After wrapping up, minimum should be high and maximum low.", $time);
  end
  if (LAP_BIT && count[LAP_INDEX] == previous_lap) begin
    $error("[%0tns] Lap bit should toggle on wrap (increment at max).", $time);
  end
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Decrement with wrapping
  $display("CHECK 4 : Decrement with wrapping.");
  if (count_no_lap != COUNT_MIN) begin
    $error("[%0tns] Counter should be at minimum '%0d' but is at '%0d'.", $time, COUNT_MIN, count);
  end
  @(negedge clock);
  decrement = 1;
  previous_index = count_no_lap;
  previous_lap   = count[LAP_INDEX];
  @(posedge clock);
  @(negedge clock);
  #(1);
  if (!underflow || overflow) begin
    $error("[%0tns] Underflow pulse expected on decrement at minimum (overflow should be low).", $time);
  end
  if (count_no_lap != COUNT_MAX) begin
    $error("[%0tns] Counter should wrap to maximum '%0d' but is at '%0d'.", $time, COUNT_MAX, count);
  end
  if (!maximum || minimum) begin
    $error("[%0tns] After wrapping down, maximum should be high and minimum low.", $time);
  end
  if (LAP_BIT && count[LAP_INDEX] == previous_lap) begin
    $error("[%0tns] Lap bit should toggle on wrap (decrement at min).", $time);
  end
  decrement = 0;

  repeat(10) @(posedge clock);

  // Check 5 : Decrement without wrapping
  $display("CHECK 5 : Decrement without wrapping.");
  expected_count = COUNT_MAX;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      while (count_no_lap != COUNT_MIN) begin
        @(posedge clock);
        expected_count -= 1;
        @(negedge clock);
        #(1);
        if (count_no_lap != expected_count) begin
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
  expected_count = COUNT_MIN;
  @(negedge clock);
  increment = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        previous_index = count_no_lap;
        previous_lap   = count[LAP_INDEX];
        @(posedge clock);
        @(negedge clock);
        #(1);
        if ((previous_index == COUNT_MAX) ? (!overflow) : (overflow)) begin
          $error("[%0tns] Overflow pulse mismatch during full-cycle increment.", $time);
        end
        if (underflow) begin
          $error("[%0tns] Underflow should be low during increment-only.", $time);
        end
        expected_count = predict_next_count(previous_index, 1, 0);
        if (count_no_lap != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
        if (LAP_BIT) begin
          if ((previous_index == COUNT_MAX) ? (count[LAP_INDEX] == previous_lap) : (count[LAP_INDEX] != previous_lap)) begin
            $error("[%0tns] Lap bit mismatch during full-cycle increment.", $time);
          end
        end
      end
      // Should be back to COUNT_MIN after full cycle
      if (count_no_lap != COUNT_MIN) begin
        $error("[%0tns] Counter should be back to minimum '%0d' after full cycle but is at '%0d'.", $time, COUNT_MIN, count);
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
  expected_count = COUNT_MIN;
  @(negedge clock);
  decrement = 1;
  timeout_countdown = CHECK_TIMEOUT;
  fork
    // Check
    begin
      repeat (RANGE) begin
        previous_index = count_no_lap;
        previous_lap   = count[LAP_INDEX];
        @(posedge clock);
        @(negedge clock);
        #(1);
        if ((previous_index == COUNT_MIN) ? (!underflow) : (underflow)) begin
          $error("[%0tns] Underflow pulse mismatch during full-cycle decrement.", $time);
        end
        if (overflow) begin
          $error("[%0tns] Overflow should be low during decrement-only.", $time);
        end
        expected_count = predict_next_count(previous_index, 0, 1);
        if (count_no_lap != expected_count) begin
          $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count, expected_count);
        end
        if (LAP_BIT) begin
          if ((previous_index == COUNT_MIN) ? (count[LAP_INDEX] == previous_lap) : (count[LAP_INDEX] != previous_lap)) begin
            $error("[%0tns] Lap bit mismatch during full-cycle decrement.", $time);
          end
        end
      end
      // Should be back to COUNT_MIN after full cycle
      if (count_no_lap != COUNT_MIN) begin
        $error("[%0tns] Counter should be back to minimum '%0d' after full cycle but is at '%0d'.", $time, COUNT_MIN, count);
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
    previous_index = count_no_lap;
    previous_lap   = count[LAP_INDEX];
    @(posedge clock);
    @(negedge clock);
    #(1);
    begin
      logic expected_overflow;
      logic expected_underflow;
      expected_overflow  = (increment && !decrement && previous_index == COUNT_MAX);
      expected_underflow = (decrement && !increment && previous_index == COUNT_MIN);
      if (overflow != expected_overflow) $error("[%0tns] Overflow pulse mismatch in random test.", $time);
      if (underflow != expected_underflow) $error("[%0tns] Underflow pulse mismatch in random test.", $time);
      if (LAP_BIT) begin
        logic lap_toggled = (count[LAP_INDEX] != previous_lap);
        if (lap_toggled != (expected_overflow || expected_underflow)) $error("[%0tns] Lap bit toggle mismatch in random test.", $time);
      end
    end
    expected_count = predict_next_count(previous_index, increment, decrement);
    if (count_no_lap != expected_count) $error("[%0tns] Counter value mismatch in random test.", $time);
    if (minimum != (expected_count == COUNT_MIN)) $error("[%0tns] Minimum flag mismatch in random test.", $time);
    if (maximum != (expected_count == COUNT_MAX)) $error("[%0tns] Maximum flag mismatch in random test.", $time);
  end
  decrement = 0;
  increment = 0;

  // Check 9 : Load feature
  $display("CHECK 9 : Load feature.");
  @(negedge clock);
  load_count  = COUNT_MAX;
  load_enable = 1;
  @(posedge clock);
  if (overflow || underflow) begin
    $error("[%0tns] Overflow/Underflow should be low on load.", $time);
  end
  @(negedge clock);
  if (count_no_lap != COUNT_MAX) begin
    $error("[%0tns] Load to COUNT_MAX failed.", $time);
  end
  if (!maximum || minimum) begin
    $error("[%0tns] Maximum should be high and minimum low after load to COUNT_MAX.", $time);
  end
  load_enable = 0;

  // End of test
  $finish;
end

endmodule