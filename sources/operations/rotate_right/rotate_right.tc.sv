// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rotate_right.tc.sv                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testcase for the static rotate right.                        ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module rotate_right_tc #(
  parameter WIDTH    = 8,
  parameter ROTATION = 1
) (
  input  logic start,
  output logic finished
);

// Test parameters
localparam WIDTH_POW2   = 2**WIDTH;
localparam ROTATION_MOD = ROTATION % WIDTH;

// Check parameters
localparam integer FULL_CHECK_MAX_DURATION = 2**10;
localparam integer RANDOM_CHECK_DURATION   = 1024;

// Device ports
logic [WIDTH-1:0] data_in;
logic [WIDTH-1:0] data_out;

// Test signals
logic [WIDTH-1:0] data_out_expected;

// Device under test
rotate_right #(
  .WIDTH    ( WIDTH    ),
  .ROTATION ( ROTATION )
) rotate_right_dut (
  .data_in  ( data_in  ),
  .data_out ( data_out )
);

// Checker task for the code
task automatic check_data_out();
  // Use a different method than the DUT to compute the expected output
  data_out_expected = (data_in >> ROTATION_MOD) | (data_in << (WIDTH - ROTATION_MOD));
  if (data_out !== data_out_expected) begin
    $error("[%0tns] Incorrect data_out for data_in '%b' : expected '%b' but got '%b'.", $time, data_in, data_out_expected, data_out);
  end
endtask

// Main block
initial begin
  // Wait start of testcase
  finished = 0;
  #(1); while (!start) #(1);
  $display("TEST WIDTH=%0d, ROTATION=%0d", WIDTH, ROTATION);

  // Initialization
  data_in  = 0;

  #1;

  // If the data width is small enough, verify all values
  if (WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin
    // Check : full coverage
    $display("CHECK : Full coverage.");
    for (integer data_index = 0; data_index < WIDTH_POW2; data_index++) begin
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
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
`ifdef SIMUMLATOR_NO_RANDOMIZE
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
