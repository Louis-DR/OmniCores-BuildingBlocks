// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        shift_left.tc.sv                                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testcase for the static shift left.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module shift_left_tc #(
  parameter WIDTH     = 8,
  parameter SHIFT  = 1,
  parameter PAD_VALUE = 1'b0
) (
  input  logic start,
  output logic finished
);

// Test parameters
localparam int WIDTH_POW2 = 2**WIDTH;

// Check parameters
localparam int FULL_CHECK_MAX_DURATION = 2**10;
localparam int RANDOM_CHECK_DURATION   = 1024;

// Device ports
logic [WIDTH-1:0] data_in;
logic [WIDTH-1:0] data_out;

// Test signals
logic [WIDTH-1:0] data_out_expected;

// Device under test
shift_left #(
  .WIDTH     ( WIDTH     ),
  .SHIFT     ( SHIFT     ),
  .PAD_VALUE ( PAD_VALUE )
) shift_left_dut (
  .data_in   ( data_in   ),
  .data_out  ( data_out  )
);

// Checker task for the code
task automatic check_data_out();
  // Use a different method than the DUT to compute the expected output
  if (SHIFT == 0) begin
    data_out_expected = data_in;
  end else if (SHIFT < WIDTH) begin
    data_out_expected = (data_in << SHIFT) | {SHIFT{PAD_VALUE[0]}};
  end else begin
    data_out_expected = {WIDTH{PAD_VALUE[0]}};
  end
  if (data_out !== data_out_expected) begin
    $error("[%0tns] Incorrect data_out for data_in '%b' : expected '%b' but got '%b'.", $time, data_in, data_out_expected, data_out);
  end
endtask

// Main block
initial begin
  // Wait start of testcase
  finished = 0;
  #(1); while (!start) #(1);
  $display("TEST WIDTH=%0d, SHIFT=%0d, PAD_VALUE=%0d", WIDTH, SHIFT, PAD_VALUE);

  // Initialization
  data_in  = 0;

  #1;

  // If the data width is small enough, verify all values
  if (WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin
    // Check : full coverage
    $display("CHECK : Full coverage.");
    for (int data_index = 0; data_index < WIDTH_POW2; data_index++) begin
      data_in = data_index;
      #(1);
      check_data_out();
      #(1);
    end
  end
  // Else only perform a random check
  else begin
    // Check : random stimulus
    $display("CHECK : Random stimulus.");
    for (int random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
`ifdef SIMULATOR_NO_RANDOMIZE
      // Alternative to std:randomize() up to 1024 bits
      data_in = {$urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom(),
                 $urandom(), $urandom(), $urandom(), $urandom()};
`else
      std:randomize(data_in);
`endif
      #(1);
      check_data_out();
      #(1);
    end
  end

  // Finish testcase
  finished = 1;
end

endmodule
