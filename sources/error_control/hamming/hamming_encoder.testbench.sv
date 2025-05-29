// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_encoder.testbench.sv                                 ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Top-level testbench for the Hamming encoder. It instantiates ║
// ║              and runs the sub-level testbench for multiple data widths.   ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module hamming_encoder__testbench ();

logic start__hamming_encoder_tb__data_width_4;
logic start__hamming_encoder_tb__data_width_11;
logic start__hamming_encoder_tb__data_width_26;
logic start__hamming_encoder_tb__data_width_57;
logic start__hamming_encoder_tb__data_width_120;

hamming_encoder__testcase #(.DATA_WIDTH(  4)) hamming_encoder_tb__data_width_4   (.start(start__hamming_encoder_tb__data_width_4));
hamming_encoder__testcase #(.DATA_WIDTH( 11)) hamming_encoder_tb__data_width_11  (.start(start__hamming_encoder_tb__data_width_11));
hamming_encoder__testcase #(.DATA_WIDTH( 26)) hamming_encoder_tb__data_width_26  (.start(start__hamming_encoder_tb__data_width_26));
hamming_encoder__testcase #(.DATA_WIDTH( 57)) hamming_encoder_tb__data_width_57  (.start(start__hamming_encoder_tb__data_width_57));
hamming_encoder__testcase #(.DATA_WIDTH(120)) hamming_encoder_tb__data_width_120 (.start(start__hamming_encoder_tb__data_width_120));

initial begin
  // Log waves
  $dumpfile("hamming_encoder_tb.vcd");
  $dumpvars(0,hamming_encoder_tb__data_width_4);
  $dumpvars(0,hamming_encoder_tb__data_width_11);
  $dumpvars(0,hamming_encoder_tb__data_width_26);
  $dumpvars(0,hamming_encoder_tb__data_width_57);
  $dumpvars(0,hamming_encoder_tb__data_width_120);

  // Initialization
  start__hamming_encoder_tb__data_width_4   = 0;
  start__hamming_encoder_tb__data_width_11  = 0;
  start__hamming_encoder_tb__data_width_26  = 0;
  start__hamming_encoder_tb__data_width_57  = 0;
  start__hamming_encoder_tb__data_width_120 = 0;

  // Start testbenches
  start__hamming_encoder_tb__data_width_4 = 1;
  while(!hamming_encoder_tb__data_width_4.finished) #(1);

  start__hamming_encoder_tb__data_width_11 = 1;
  while(!hamming_encoder_tb__data_width_11.finished) #(1);

  start__hamming_encoder_tb__data_width_26 = 1;
  while(!hamming_encoder_tb__data_width_26.finished) #(1);

  start__hamming_encoder_tb__data_width_57 = 1;
  while(!hamming_encoder_tb__data_width_57.finished) #(1);

  start__hamming_encoder_tb__data_width_120 = 1;
  while(!hamming_encoder_tb__data_width_120.finished) #(1);

  // Finish
  $finish();
end

endmodule
