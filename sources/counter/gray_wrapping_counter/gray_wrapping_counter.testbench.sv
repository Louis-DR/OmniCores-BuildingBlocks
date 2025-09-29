// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        gray_wrapping_counter.testbench.sv                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the gray wrapping counter.                     ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "random.svh"
`include "boolean.svh"
`include "count_differences.svh"



module gray_wrapping_counter__testbench ();

// Device parameters
localparam int  RANGE        = 4;
localparam int  RESET_VALUE  = 0;
localparam int  LOAD_BINARY  = 0;

// Derived parameters
localparam int  WIDTH        = $clog2(RANGE);
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
logic [WIDTH-1:0] count_binary;
logic [WIDTH-1:0] count_gray;
logic             minimum;
logic             maximum;
logic             underflow;
logic             overflow;

// Test variables
int   expected_count;
int   timeout_countdown;
int   previous_index;
logic [WIDTH-1:0] previous_gray;

// Device under test
gray_wrapping_counter #(
  .RANGE        ( RANGE        ),
  .RESET_VALUE  ( RESET_VALUE  ),
  .LOAD_BINARY  ( LOAD_BINARY  )
) gray_wrapping_counter_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .load_enable  ( load_enable  ),
  .load_count   ( load_count   ),
  .decrement    ( decrement    ),
  .increment    ( increment    ),
  .count_gray   ( count_gray   ),
  .count_binary ( count_binary ),
  .minimum      ( minimum      ),
  .maximum      ( maximum      ),
  .underflow    ( underflow    ),
  .overflow     ( overflow     )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Reference function for binary to gray conversion (matches design mapping)
function logic [WIDTH-1:0] reference_binary_to_gray;
  input logic [WIDTH-1:0] binary;
  logic [WIDTH-1:0] offset_binary;
  int offset = ((2 ** WIDTH) - RANGE) / 2;
  offset_binary = binary + offset;
  return offset_binary ^ (offset_binary >> 1);
endfunction

// Check single-bit difference between two successive gray codes
task check_bit_difference;
  input logic [WIDTH-1:0] gray1;
  input logic [WIDTH-1:0] gray2;
  int bit_differences;
  `COUNT_BIT_DIFFERENCES(WIDTH, gray1, gray2, bit_differences)
  assert (bit_differences === 1)
    else $error("[%0tns] More than one bit difference between successive gray codes '%b' and '%b': %0d bit differences.",
                $time, gray1, gray2, bit_differences);
endtask

// Function to predict next count value with wrapping
function int predict_next_count;
  input int   current_count;
  input logic increment_signal;
  input logic decrement_signal;
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
  $dumpfile("gray_wrapping_counter.testbench.vcd");
  $dumpvars(0,gray_wrapping_counter__testbench);

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
  assert (count_binary == expected_count)
    else $error("[%0tns] Value at reset '%0d' is different than the one given as parameter '%0d'.", $time, count_binary, RESET_VALUE);
  assert (minimum == (count_binary == COUNT_MIN))
    else $error("[%0tns] Minimum flag mismatch at reset.", $time);
  assert (maximum == (count_binary == COUNT_MAX))
    else $error("[%0tns] Maximum flag mismatch at reset.", $time);
  assert (!(overflow || underflow))
    else $error("[%0tns] Overflow/Underflow should be low at reset.", $time);
  // Gray mapping check at reset
  assert (count_gray == reference_binary_to_gray(count_binary))
    else $error("[%0tns] Gray code does not match binary at reset.", $time);

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
      while (count_binary != COUNT_MAX) begin
        previous_index = count_binary;
        previous_gray  = count_gray;
        @(posedge clock);
        expected_count += 1;
        @(negedge clock);
        #(1);
        assert (!(overflow || underflow))
          else $error("[%0tns] No wrap expected, overflow/underflow should be low.", $time);
        assert (count_binary == expected_count)
          else $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count_binary, expected_count);
        // Gray single-bit difference and mapping
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%0tns] Gray mapping mismatch after increment.", $time);
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
  assert (count_binary == COUNT_MAX)
    else $error("[%0tns] Counter should be at maximum '%0d' but is at '%0d'.", $time, COUNT_MAX, count_binary);
  @(negedge clock);
  increment = 1;
  previous_index = count_binary;
  previous_gray  = count_gray;
  @(posedge clock);
  @(negedge clock);
  #(1);
  assert (overflow && !underflow)
    else $error("[%0tns] Overflow pulse expected on increment at maximum (underflow should be low).", $time);
  assert (count_binary == COUNT_MIN)
    else $error("[%0tns] Counter should wrap to minimum '%0d' but is at '%0d'.", $time, COUNT_MIN, count_binary);
  assert (minimum && !maximum)
    else $error("[%0tns] After wrapping up, minimum should be high and maximum low.", $time);
  check_bit_difference(previous_gray, count_gray);
  assert (count_gray == reference_binary_to_gray(count_binary))
    else $error("[%0tns] Gray mapping mismatch after wrap up.", $time);
  increment = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Decrement with wrapping
  $display("CHECK 4 : Decrement with wrapping.");
  assert (count_binary == COUNT_MIN)
    else $error("[%0tns] Counter should be at minimum '%0d' but is at '%0d'.", $time, COUNT_MIN, count_binary);
  @(negedge clock);
  decrement = 1;
  previous_index = count_binary;
  previous_gray  = count_gray;
  @(posedge clock);
  @(negedge clock);
  #(1);
  assert (underflow && !overflow)
    else $error("[%0tns] Underflow pulse expected on decrement at minimum (overflow should be low).", $time);
  assert (count_binary == COUNT_MAX)
    else $error("[%0tns] Counter should wrap to maximum '%0d' but is at '%0d'.", $time, COUNT_MAX, count_binary);
  assert (maximum && !minimum)
    else $error("[%0tns] After wrapping down, maximum should be high and minimum low.", $time);
  check_bit_difference(previous_gray, count_gray);
  assert (count_gray == reference_binary_to_gray(count_binary))
    else $error("[%0tns] Gray mapping mismatch after wrap down.", $time);
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
      while (count_binary != COUNT_MIN) begin
        @(posedge clock);
        expected_count -= 1;
        @(negedge clock);
        #(1);
        assert (count_binary == expected_count)
          else $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count_binary, expected_count);
        // Gray single-bit difference and mapping
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%0tns] Gray mapping mismatch after decrement.", $time);
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
        previous_index = count_binary;
        previous_gray  = count_gray;
        @(posedge clock);
        @(negedge clock);
        #(1);
        assert ( (previous_index == COUNT_MAX) ? overflow : !overflow )
          else $error("[%0tns] Overflow pulse mismatch during full-cycle increment.", $time);
        assert (!underflow)
          else $error("[%0tns] Underflow should be low during increment-only.", $time);
        expected_count = predict_next_count(previous_index, 1, 0);
        assert (count_binary == expected_count)
          else $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count_binary, expected_count);
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%0tns] Gray mapping mismatch during full-cycle increment.", $time);
      end
      // Should be back to COUNT_MIN after full cycle
      assert (count_binary == COUNT_MIN)
        else $error("[%0tns] Counter should be back to minimum '%0d' after full cycle but is at '%0d'.", $time, COUNT_MIN, count_binary);
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
        previous_index = count_binary;
        previous_gray  = count_gray;
        @(posedge clock);
        @(negedge clock);
        #(1);
        assert ( (previous_index == COUNT_MIN) ? underflow : !underflow )
          else $error("[%0tns] Underflow pulse mismatch during full-cycle decrement.", $time);
        assert (!overflow)
          else $error("[%0tns] Overflow should be low during decrement-only.", $time);
        expected_count = predict_next_count(previous_index, 0, 1);
        assert (count_binary == expected_count)
          else $error("[%0tns] Counter value is '%0d' instead of expected value '%0d'.", $time, count_binary, expected_count);
        check_bit_difference(previous_gray, count_gray);
        assert (count_gray == reference_binary_to_gray(count_binary))
          else $error("[%0tns] Gray mapping mismatch during full-cycle decrement.", $time);
      end
      // Should be back to COUNT_MIN after full cycle
      assert (count_binary == COUNT_MIN)
        else $error("[%0tns] Counter should be back to minimum '%0d' after full cycle but is at '%0d'.", $time, COUNT_MIN, count_binary);
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
    previous_index = count_binary;
    previous_gray  = count_gray;
    @(posedge clock);
    @(negedge clock);
    #(1);
    begin
      logic expected_overflow;
      logic expected_underflow;
      expected_overflow  = (increment && !decrement && previous_index == COUNT_MAX);
      expected_underflow = (decrement && !increment && previous_index == COUNT_MIN);
      assert (overflow  == expected_overflow)  else $error("[%0tns] Overflow pulse mismatch in random test.",  $time);
      assert (underflow == expected_underflow) else $error("[%0tns] Underflow pulse mismatch in random test.", $time);
      if (increment ^ decrement) begin
        check_bit_difference(previous_gray, count_gray);
      end else begin
        // No change expected
        assert (count_gray === previous_gray) else $error("[%0tns] Gray code changed without a step.", $time);
      end
    end
    expected_count = predict_next_count(previous_index, increment, decrement);
    assert (count_binary == expected_count) else $error("[%0tns] Counter value mismatch in random test.", $time);
    assert (minimum == (expected_count == COUNT_MIN)) else $error("[%0tns] Minimum flag mismatch in random test.", $time);
    assert (maximum == (expected_count == COUNT_MAX)) else $error("[%0tns] Maximum flag mismatch in random test.", $time);
    assert (count_gray == reference_binary_to_gray(count_binary)) else $error("[%0tns] Gray mapping mismatch in random test.", $time);
  end
  decrement = 0;
  increment = 0;

  // Check 9 : Load feature
  $display("CHECK 9 : Load feature.");
  @(negedge clock);
  if (LOAD_BINARY) load_count = COUNT_MAX; else load_count = reference_binary_to_gray(COUNT_MAX);
  load_enable = 1;
  @(posedge clock);
  assert (!(overflow || underflow)) else $error("[%0tns] Overflow/Underflow should be low on load.", $time);
  @(negedge clock);
  assert (maximum && !minimum) else $error("[%0tns] Maximum should be high and minimum low after load to COUNT_MAX.", $time);
  assert (count_binary == COUNT_MAX) else $error("[%0tns] Load to maximum failed.", $time);
  assert (count_gray == reference_binary_to_gray(count_binary)) else $error("[%0tns] Gray mapping mismatch after load.", $time);
  load_enable = 0;

  // End of test
  $finish;
end

endmodule