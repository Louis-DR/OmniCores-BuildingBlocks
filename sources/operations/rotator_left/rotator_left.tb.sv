// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        rotator_left.tb.sv                                           ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Top-level testbench for the static left rotator.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module rotator_left_tb ();

logic start__rotator_left_tc__width_4__rotation_0;
logic start__rotator_left_tc__width_4__rotation_1;
logic start__rotator_left_tc__width_4__rotation_2;
logic start__rotator_left_tc__width_4__rotation_3;
logic start__rotator_left_tc__width_4__rotation_4;

logic start__rotator_left_tc__width_8__rotation_0;
logic start__rotator_left_tc__width_8__rotation_1;
logic start__rotator_left_tc__width_8__rotation_2;
logic start__rotator_left_tc__width_8__rotation_3;
logic start__rotator_left_tc__width_8__rotation_4;
logic start__rotator_left_tc__width_8__rotation_5;
logic start__rotator_left_tc__width_8__rotation_6;
logic start__rotator_left_tc__width_8__rotation_7;
logic start__rotator_left_tc__width_8__rotation_8;

rotator_left_tc #(.WIDTH(4), .ROTATION(0)) rotator_left_tc__width_4__rotation_0 (.start(start__rotator_left_tc__width_4__rotation_0));
rotator_left_tc #(.WIDTH(4), .ROTATION(1)) rotator_left_tc__width_4__rotation_1 (.start(start__rotator_left_tc__width_4__rotation_1));
rotator_left_tc #(.WIDTH(4), .ROTATION(2)) rotator_left_tc__width_4__rotation_2 (.start(start__rotator_left_tc__width_4__rotation_2));
rotator_left_tc #(.WIDTH(4), .ROTATION(3)) rotator_left_tc__width_4__rotation_3 (.start(start__rotator_left_tc__width_4__rotation_3));
rotator_left_tc #(.WIDTH(4), .ROTATION(4)) rotator_left_tc__width_4__rotation_4 (.start(start__rotator_left_tc__width_4__rotation_4));

rotator_left_tc #(.WIDTH(8), .ROTATION(0)) rotator_left_tc__width_8__rotation_0 (.start(start__rotator_left_tc__width_8__rotation_0));
rotator_left_tc #(.WIDTH(8), .ROTATION(1)) rotator_left_tc__width_8__rotation_1 (.start(start__rotator_left_tc__width_8__rotation_1));
rotator_left_tc #(.WIDTH(8), .ROTATION(2)) rotator_left_tc__width_8__rotation_2 (.start(start__rotator_left_tc__width_8__rotation_2));
rotator_left_tc #(.WIDTH(8), .ROTATION(3)) rotator_left_tc__width_8__rotation_3 (.start(start__rotator_left_tc__width_8__rotation_3));
rotator_left_tc #(.WIDTH(8), .ROTATION(4)) rotator_left_tc__width_8__rotation_4 (.start(start__rotator_left_tc__width_8__rotation_4));
rotator_left_tc #(.WIDTH(8), .ROTATION(5)) rotator_left_tc__width_8__rotation_5 (.start(start__rotator_left_tc__width_8__rotation_5));
rotator_left_tc #(.WIDTH(8), .ROTATION(6)) rotator_left_tc__width_8__rotation_6 (.start(start__rotator_left_tc__width_8__rotation_6));
rotator_left_tc #(.WIDTH(8), .ROTATION(7)) rotator_left_tc__width_8__rotation_7 (.start(start__rotator_left_tc__width_8__rotation_7));
rotator_left_tc #(.WIDTH(8), .ROTATION(8)) rotator_left_tc__width_8__rotation_8 (.start(start__rotator_left_tc__width_8__rotation_8));

initial begin
  // Log waves
  $dumpfile("rotator_left.tb.vcd");
  $dumpvars(0,rotator_left_tc__width_4__rotation_0);
  $dumpvars(0,rotator_left_tc__width_4__rotation_1);
  $dumpvars(0,rotator_left_tc__width_4__rotation_2);
  $dumpvars(0,rotator_left_tc__width_4__rotation_3);
  $dumpvars(0,rotator_left_tc__width_4__rotation_4);
  $dumpvars(0,rotator_left_tc__width_8__rotation_0);
  $dumpvars(0,rotator_left_tc__width_8__rotation_1);
  $dumpvars(0,rotator_left_tc__width_8__rotation_2);
  $dumpvars(0,rotator_left_tc__width_8__rotation_3);
  $dumpvars(0,rotator_left_tc__width_8__rotation_4);
  $dumpvars(0,rotator_left_tc__width_8__rotation_5);
  $dumpvars(0,rotator_left_tc__width_8__rotation_6);
  $dumpvars(0,rotator_left_tc__width_8__rotation_7);
  $dumpvars(0,rotator_left_tc__width_8__rotation_8);

  // Initialization
  start__rotator_left_tc__width_4__rotation_0 = 0;
  start__rotator_left_tc__width_4__rotation_1 = 0;
  start__rotator_left_tc__width_4__rotation_2 = 0;
  start__rotator_left_tc__width_4__rotation_3 = 0;
  start__rotator_left_tc__width_4__rotation_4 = 0;
  start__rotator_left_tc__width_8__rotation_0 = 0;
  start__rotator_left_tc__width_8__rotation_1 = 0;
  start__rotator_left_tc__width_8__rotation_2 = 0;
  start__rotator_left_tc__width_8__rotation_3 = 0;
  start__rotator_left_tc__width_8__rotation_4 = 0;
  start__rotator_left_tc__width_8__rotation_5 = 0;
  start__rotator_left_tc__width_8__rotation_6 = 0;
  start__rotator_left_tc__width_8__rotation_7 = 0;
  start__rotator_left_tc__width_8__rotation_8 = 0;

  // Start testbenches
  start__rotator_left_tc__width_4__rotation_0 = 1;
  while(!rotator_left_tc__width_4__rotation_0.finished) #(1);

  start__rotator_left_tc__width_4__rotation_1 = 1;
  while(!rotator_left_tc__width_4__rotation_1.finished) #(1);

  start__rotator_left_tc__width_4__rotation_2 = 1;
  while(!rotator_left_tc__width_4__rotation_2.finished) #(1);

  start__rotator_left_tc__width_4__rotation_3 = 1;
  while(!rotator_left_tc__width_4__rotation_3.finished) #(1);

  start__rotator_left_tc__width_4__rotation_4 = 1;
  while(!rotator_left_tc__width_4__rotation_4.finished) #(1);

  start__rotator_left_tc__width_8__rotation_0 = 1;
  while(!rotator_left_tc__width_8__rotation_0.finished) #(1);

  start__rotator_left_tc__width_8__rotation_1 = 1;
  while(!rotator_left_tc__width_8__rotation_1.finished) #(1);

  start__rotator_left_tc__width_8__rotation_2 = 1;
  while(!rotator_left_tc__width_8__rotation_2.finished) #(1);

  start__rotator_left_tc__width_8__rotation_3 = 1;
  while(!rotator_left_tc__width_8__rotation_3.finished) #(1);

  start__rotator_left_tc__width_8__rotation_4 = 1;
  while(!rotator_left_tc__width_8__rotation_4.finished) #(1);

  start__rotator_left_tc__width_8__rotation_5 = 1;
  while(!rotator_left_tc__width_8__rotation_5.finished) #(1);

  start__rotator_left_tc__width_8__rotation_6 = 1;
  while(!rotator_left_tc__width_8__rotation_6.finished) #(1);

  start__rotator_left_tc__width_8__rotation_7 = 1;
  while(!rotator_left_tc__width_8__rotation_7.finished) #(1);

  start__rotator_left_tc__width_8__rotation_8 = 1;
  while(!rotator_left_tc__width_8__rotation_8.finished) #(1);

  // Finish
  $finish();
end

endmodule
