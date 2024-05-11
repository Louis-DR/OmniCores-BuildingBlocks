// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     AnyV-Generics                                                ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        vector_synchronizer.v                                        ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Resynchronize a vector of signals to a clock with flip-flop  ║
// ║              stages.                                                      ║
// ║                                                                           ║
// ║              If the default two stages of flip-flops are not enough to    ║
// ║              prevent metastable outputs, three or more stages can be      ║
// ║              used.                                                        ║
// ║                                                                           ║
// ║              The synchronized signal must last at least one clock cycle   ║
// ║              of the synchronizing clock. In practice, this synchronizer   ║
// ║              should be used between clock domains of the same frequency   ║
// ║              or when moving to to a faster clock domain.                  ║
// ║                                                                           ║
// ║              The synchronized signal must only change by one bit between  ║
// ║              two clock cycles of the synchronization clock. In practice,  ║
// ║              this module may be used for grey-coded incremental counters  ║
// ║              or for bit fields in certain cases.                          ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module vector_synchronizer #(
  parameter WIDTH  = 8,
  parameter STAGES = 2
) (
  input              clock,
  input              resetn,
  input  [WIDTH-1:0] data_in,
  output [WIDTH-1:0] data_out
);

genvar data_bit;
generate
  for (data_bit=0; data_bit<WIDTH; data_bit=data_bit+1) begin : gen_data_bit
    synchronizer #(
      .STAGES   ( STAGES             )
    ) synchronizer (
      .clock    ( clock              ),
      .resetn   ( resetn             ),
      .data_in  ( data_in[data_bit]  ),
      .data_out ( data_out[data_bit] )
    );
  end
endgenerate

endmodule
