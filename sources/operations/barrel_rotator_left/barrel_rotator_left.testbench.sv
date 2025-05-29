// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        barrel_rotator_left__testbench.sv                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the barrel left rotator.                       ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module barrel_rotator_left__testbench ();

// Test parameters
localparam CLOCK_PERIOD = 10;
localparam WIDTH        =  8;
localparam WIDTH_LOG2   = $clog2(WIDTH);

// Device ports
logic                  clock;
logic      [WIDTH-1:0] data_in;
logic [WIDTH_LOG2-1:0] rotation;
logic      [WIDTH-1:0] data_out;

// Test signals
logic [WIDTH-1:0] data_out_expected;

// Device under test
barrel_rotator_left #(
  .WIDTH    ( WIDTH    )
) barrel_rotator_left_dut (
  .data_in  ( data_in  ),
  .rotation ( rotation ),
  .data_out ( data_out )
);

// Clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("barrel_rotator_left__testbench.vcd");
  $dumpvars(0,barrel_rotator_left__testbench);

  // Initialization
  data_in  = 0;
  rotation = 0;

  #(CLOCK_PERIOD);

  for (integer rotation_index = 0; rotation_index < WIDTH; rotation_index++) begin
    rotation = rotation_index;
    data_in  = 8'b10011001;
    #(CLOCK_PERIOD);
  end

  // // Check 1 : low-to-high at 25% of clock cycle
  // $display("CHECK 1 : Low-to-high at 25%% of clock cycle.");
  // fork
  //   // Stimulus
  //   begin
  //     #(CLOCK_PERIOD*0.25);
  //     data_in = 1;
  //   end
  //   // Check
  //   begin
  //     @(posedge clock);
  //     data_out_expected = MAX_TEST_STAGES'(0);
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //     for (integer check_step = 0; check_step < MAX_TEST_STAGES; check_step++) begin
  //       data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b1 };
  //       check_data_out(data_out_expected);
  //       @(posedge clock);
  //     end
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //   end
  // join

  // // Check 2 : high-to-low at 25% of clock cycle
  // $display("CHECK 2 : High-to-low at 25%% of clock cycle.");
  // fork
  //   // Stimulus
  //   begin
  //     #(CLOCK_PERIOD*0.25);
  //     data_in = 0;
  //   end
  //   // Check
  //   begin
  //     @(posedge clock);
  //     data_out_expected = ~MAX_TEST_STAGES'(0);
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //     for (integer check_step = 0; check_step < MAX_TEST_STAGES; check_step++) begin
  //       data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b0 };
  //       check_data_out(data_out_expected);
  //       @(posedge clock);
  //     end
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //   end
  // join

  // // Check 3 : low-to-high at 75% of clock cycle
  // $display("CHECK 3 : Low-to-high at 75%% of clock cycle.");
  // fork
  //   // Stimulus
  //   begin
  //     #(CLOCK_PERIOD*0.75);
  //     data_in = 1;
  //   end
  //   // Check
  //   begin
  //     @(posedge clock);
  //     data_out_expected = MAX_TEST_STAGES'(0);
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //     for (integer check_step = 0; check_step < MAX_TEST_STAGES; check_step++) begin
  //       data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b1 };
  //       check_data_out(data_out_expected);
  //       @(posedge clock);
  //     end
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //   end
  // join

  // // Check 4 : high-to-low at 75% of clock cycle
  // $display("CHECK 4 : High-to-low at 75%% of clock cycle.");
  // fork
  //   // Stimulus
  //   begin
  //     #(CLOCK_PERIOD*0.75);
  //     data_in = 0;
  //   end
  //   // Check
  //   begin
  //     @(posedge clock);
  //     data_out_expected = ~MAX_TEST_STAGES'(0);
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //     for (integer check_step = 0; check_step < MAX_TEST_STAGES; check_step++) begin
  //       data_out_expected = { data_out_expected[MAX_TEST_STAGES-1:1] , 1'b0 };
  //       check_data_out(data_out_expected);
  //       @(posedge clock);
  //     end
  //     check_data_out(data_out_expected);
  //     @(posedge clock);
  //   end
  // join

  // End of test
  $finish;
end

endmodule
