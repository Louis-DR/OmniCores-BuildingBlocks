// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        programmable_clock_multiplier.sv                             ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Multiplies the frequency of the clock by the programmable    ║
// ║              input multiplication factor plus one.                        ║
// ║                                                                           ║
// ║              This module is not synthesizable and should be used as a     ║
// ║              behavioral model for a simple PLL.                           ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1fs



module programmable_clock_multiplier #(
  parameter MULTIPLICATION_WIDTH = 4
) (
  input                             clock_in,
  input  [MULTIPLICATION_WIDTH-1:0] multiplication,
  output                            clock_out
);

real clock_in_timer_start;
real clock_in_timer_stop;
real clock_in_period;
real clock_out_period;

logic clock_multiplied;

initial begin
  clock_in_timer_start = 0;
  clock_in_timer_stop  = 0;
  clock_in_period      = 0;
  clock_out_period     = 0;
  fork
    // Input clock measurement
    begin
      @(posedge clock_in);
      clock_in_timer_start = $realtime;
      forever begin
        @(posedge clock_in);
        clock_in_timer_stop  = $realtime;
        clock_in_period      = clock_in_timer_stop - clock_in_timer_start;
        clock_in_timer_start = clock_in_timer_stop;
        clock_out_period     = clock_in_period / (multiplication + 1);
      end
    end
    // Output clock generation
    begin
      clock_multiplied = 1;
      forever begin
        if (clock_out_period > 0) begin
          #(clock_out_period/2) clock_multiplied = ~clock_multiplied;
        end else begin
          @(posedge clock_in);
        end
      end
    end
  join
end

assign clock_out = clock_multiplied;

endmodule
