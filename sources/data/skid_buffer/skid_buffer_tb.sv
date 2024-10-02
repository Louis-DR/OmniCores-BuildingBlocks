// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        skid_buffer_tb.sv                                            ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the skid buffer.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module skid_buffer_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 8;
localparam integer WIDTH_POW2   = 2**WIDTH;

// Check parameters
localparam integer THROUGHPUT_CHECK_DURATION          = 100;
localparam integer RANDOM_CHECK_DURATION              = 100;
localparam integer RANDOM_CHECK_INJECTION_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_RECEPTION_PROBABILITY = 0.5;

// Device ports
logic             clock;
logic             resetn;
logic [WIDTH-1:0] upstream_data;
logic             upstream_valid;
logic             upstream_ready;
logic [WIDTH-1:0] downstream_data;
logic             downstream_valid;
logic             downstream_ready;

// Test variables
integer data_expected[$];
integer pop_trash;
integer injection_count;
bool    injecting;

// Device under test
skid_buffer #(
  .WIDTH ( WIDTH )
) skid_buffer_dut (
  .clock            ( clock            ),
  .resetn           ( resetn           ),
  .upstream_data    ( upstream_data    ),
  .upstream_valid   ( upstream_valid   ),
  .upstream_ready   ( upstream_ready   ),
  .downstream_data  ( downstream_data  ),
  .downstream_valid ( downstream_valid ),
  .downstream_ready ( downstream_ready )
);

// Source clock generation
initial begin
  clock = 1;
  forever begin
    #(CLOCK_PERIOD/2) clock = ~clock;
  end
end

// Main block
initial begin
  // Log waves
  $dumpfile("skid_buffer_tb.vcd");
  $dumpvars(0,skid_buffer_tb);

  // Initialization
  upstream_data    = 0;
  upstream_valid   = 0;
  downstream_ready = 0;

  // Reset
  resetn = 0;
  #(CLOCK_PERIOD);
  resetn = 1;
  #(CLOCK_PERIOD);

  // Check 1 : Saturating
  downstream_ready = 0;
  $display("CHECK 1 : Saturating.");
  if (downstream_valid != 0) $error("[%0tns] Downstream valid is asserted after reset with data '%0h'. It shouldn't be sending data.", $time, downstream_data);
  if (upstream_ready   != 1) $error("[%0tns] Upstream ready is deasserted after reset. It should be accepting tranfers.", $time);
  @(negedge clock); upstream_valid = 1; upstream_data = 8'b10101010; data_expected.push_back(upstream_data);
  @(negedge clock); upstream_valid = 0; upstream_data = 0;
  if (downstream_valid != 1) $error("[%0tns] Downstream valid is deasserted after the first transfer. It should be sending the first transfer.", $time);
  if (upstream_ready   != 1) $error("[%0tns] Upstream ready is deasserted after the first transfer. It should be accepting tranfers.", $time);
  @(negedge clock); upstream_valid = 1; upstream_data = 8'b01010101; data_expected.push_back(upstream_data);
  @(negedge clock); upstream_valid = 0; upstream_data = 0;
  if (downstream_valid != 1) $error("[%0tns] Downstream valid is deasserted after the second transfer. It should be sending the first transfer.", $time);
  if (upstream_ready   != 0) $error("[%0tns] Upstream ready is asserted after the second transfer. It shouldn't be accepting transfers.", $time);

  // Check 2 : Clearing
  $display("CHECK 2 : Clearing.");
  @(negedge clock); downstream_ready = 1;
  if (downstream_data != data_expected[0]) $error("[%0tns] First data returned '%0h' is not as expected '%0h'.", $time, downstream_data, data_expected[0]);
  @(negedge clock); downstream_ready = 0; pop_trash = data_expected.pop_front();
  if (downstream_valid != 1) $error("[%0tns] Downstream valid is deasserted after the first reception. It should be sending the second transfer.", $time);
  if (upstream_ready   != 1) $error("[%0tns] Upstream ready is deasserted after the first reception. It should be accepting tranfers.", $time);
  @(negedge clock); downstream_ready = 1;
  if (downstream_data != data_expected[0]) $error("[%0tns] Second data returned '%0h' is not as expected '%0h'.", $time, downstream_data, data_expected[0]);
  @(negedge clock); downstream_ready = 0; pop_trash = data_expected.pop_front();
  if (downstream_valid != 0) $error("[%0tns] Downstream valid is asserted after the second reception with data '%0h'. It shouldn't be sending data.", $time, downstream_data);
  if (upstream_ready   != 1) $error("[%0tns] Upstream ready is deasserted after the second reception. It should be accepting tranfers.", $time);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  upstream_valid   = 1;
  upstream_data    = 0;
  downstream_ready = 1;
  for (integer iteration=1 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    data_expected.push_back(upstream_data);
    @(negedge clock);
    if (downstream_valid != 1)                $error("[%0tns] Downstream valid is deasserted. It should be sending transfers.", $time);
    if (upstream_ready   != 1)                $error("[%0tns] Upstream ready is deasserted. It should be accepting tranfers.", $time);
    if (downstream_data  != data_expected[0]) $error("[%0tns] Data returned '%0h' is not as expected '%0h'.", $time, downstream_data, data_expected[0]);
    pop_trash = data_expected.pop_front();
    upstream_data = upstream_data+1;
  end
  upstream_valid = 0;
  upstream_data  = 0;

  repeat(10) @(posedge clock);

  // Check 4 : Random stimulus
  $display("CHECK 4 : Random stimulus.");
  downstream_ready = 0;
  injection_count  = 0;
  injecting        = 0;
  @(negedge clock);
  fork
    // Injection
    begin
      forever begin
        @(negedge clock);
        if (!injecting) begin
          if ($random < RANDOM_CHECK_INJECTION_PROBABILITY) begin
            injecting      = 1;
            upstream_valid = 1;
            upstream_data  = $urandom_range(WIDTH_POW2);
          end else begin
            upstream_valid = 0;
            upstream_data  = 0;
          end
        end
        @(posedge clock);
        if (injecting) begin
          if (upstream_ready) begin
            data_expected.push_back(upstream_data);
            injection_count++;
            injecting = 0;
          end
        end
      end
    end
    // Reception
    begin
      forever begin
        @(negedge clock);
        if ($random < RANDOM_CHECK_RECEPTION_PROBABILITY) begin
          downstream_ready = 1;
        end else begin
          downstream_ready = 0;
        end
        @(posedge clock);
        if (downstream_ready && downstream_valid) begin
          if (downstream_data != data_expected[0]) $error("[%0tns] Data returned '%0h' is not as expected '%0h'.", $time, downstream_data, data_expected[0]);
          pop_trash = data_expected.pop_front();
        end
      end
    end
    // Stop condition
    begin
      while (injection_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
      end
    end
  join_any
  disable fork;

  // End of test
  $finish;
end

endmodule
