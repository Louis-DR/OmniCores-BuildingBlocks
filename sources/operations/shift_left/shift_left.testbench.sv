// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        shift_left.testbench.sv                                      ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the static left shifter.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module shift_left__testbench ();

// Device parameters
localparam int WIDTH     = 8;
localparam int SHIFT     = 1;
localparam bit PAD_VALUE = 1'b0;

// Derived parameters
localparam int WIDTH_POW2 = 2 ** WIDTH;

// Test parameters
localparam int RANDOM_CHECK_DURATION = 1000;

// Device ports
logic [WIDTH-1:0] data_in;
logic [WIDTH-1:0] data_out;

// Test signals
logic [WIDTH-1:0] data_out_expected;

// Test variables
int check;

// Device under test
shift_left #(
  .WIDTH     ( WIDTH     ),
  .SHIFT     ( SHIFT     ),
  .PAD_VALUE ( PAD_VALUE )
) shift_left_dut (
  .data_in  ( data_in  ),
  .data_out ( data_out )
);

// Main block
initial begin
  // Log waves
  $dumpfile("shift_left.testbench.vcd");
  $dumpvars(0,shift_left__testbench);
  $timeformat(-9, 0, " ns", 0);

  // Initialization
  data_in = 0;

  #10;

  // Check 1 : Walking one
  $display("CHECK 1 : Walking one."); check = 1;
  for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
    data_in = 1 << bit_index;
    if (SHIFT == 0) begin
      data_out_expected = data_in;
    end else if (SHIFT < WIDTH) begin
      data_out_expected = (data_in << SHIFT) | {SHIFT{PAD_VALUE}};
    end else begin
      data_out_expected = {WIDTH{PAD_VALUE}};
    end
    #1;
    assert (data_out === data_out_expected)
      else $error("[%t] Incorrect output for input data '%b' : expected '%b' but got '%b'.", $realtime, data_in, data_out_expected, data_out);
  end

  #10;

  // Check 2 : Walking zero
  $display("CHECK 2 : Walking zero."); check = 2;
  for (int bit_index = 0; bit_index < WIDTH; bit_index++) begin
    data_in = ~(1 << bit_index);
    if (SHIFT == 0) begin
      data_out_expected = data_in;
    end else if (SHIFT < WIDTH) begin
      data_out_expected = (data_in << SHIFT) | {SHIFT{PAD_VALUE}};
    end else begin
      data_out_expected = {WIDTH{PAD_VALUE}};
    end
    #1;
    assert (data_out === data_out_expected)
      else $error("[%t] Incorrect output for input data '%b' : expected '%b' but got '%b'.", $realtime, data_in, data_out_expected, data_out);
  end

  #10;

  // Check 3 : Random
  $display("CHECK 3 : Random."); check = 3;
  repeat (RANDOM_CHECK_DURATION) begin
    data_in = $urandom_range(0, WIDTH_POW2-1);
    if (SHIFT == 0) begin
      data_out_expected = data_in;
    end else if (SHIFT < WIDTH) begin
      data_out_expected = (data_in << SHIFT) | ({SHIFT{PAD_VALUE}});
    end else begin
      data_out_expected = {WIDTH{PAD_VALUE}};
    end
    #1;
    assert (data_out === data_out_expected)
      else $error("[%t] Incorrect output for input data '%b' : expected '%b' but got '%b'.", $realtime, data_in, data_out_expected, data_out);
    #1;
  end

  #10;

  // End of test
  $finish;
end

endmodule

