// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        bypass_buffer_tb.sv                                          ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the bypass buffer.                             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module bypass_buffer_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 8;
localparam integer WIDTH_POW2   = 2**WIDTH;

// Check parameters
localparam integer THROUGHPUT_CHECK_DURATION          = 100;
localparam integer RANDOM_CHECK_DURATION              = 100;
localparam integer RANDOM_CHECK_INJECTION_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_RECEPTION_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_TIMEOUT               = 1000;

// Device ports
logic             clock;
logic             resetn;
logic             write_enable;
logic [WIDTH-1:0] write_data;
logic             full;
logic             read_enable;
logic [WIDTH-1:0] read_data;
logic             empty;

// Test variables
integer data_expected;
integer transfer_count;
integer timeout_countdown;

// Device under test
bypass_buffer #(
  .WIDTH ( WIDTH )
) bypass_buffer_dut (
  .clock        ( clock        ),
  .resetn       ( resetn       ),
  .write_enable ( write_enable ),
  .write_data   ( write_data   ),
  .full         ( full         ),
  .read_enable  ( read_enable  ),
  .read_data    ( read_data    ),
  .empty        ( empty        )
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
  $dumpfile("bypass_buffer_tb.vcd");
  $dumpvars(0,bypass_buffer_tb);

  // Initialization
  write_data   = 0;
  write_enable = 0;
  read_enable  = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Bypass path
  @(negedge clock);
  $display("CHECK 1 : Bypass path.");
  // Initial state
  if (!empty) $error("[%0tns] Empty flag is deasserted after reset with data '%0h'. The buffer should be empty.", $time, read_data);
  if ( full ) $error("[%0tns] Full flag is asserted after reset with data '%0h'. The buffer should be empty.", $time, read_data);
  // Write and read
  @(negedge clock);
  read_enable  = 1;
  write_enable = 1;
  write_data   = 8'b10101010;
  @(posedge clock);
  if ( empty) $error("[%0tns] Empty flag is asserted.", $time, read_data);
  if ( full ) $error("[%0tns] Full flag is asserted.", $time, read_data);
  if (read_data != write_data) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
  @(negedge clock);
  read_enable  = 0;
  write_enable = 0;
  write_data   = 0;
  @(posedge clock);
  if (!empty) $error("[%0tns] Empty flag is deasserted after a transfer bypassing the buffer. The buffer should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after a transfer bypassing the buffer. The buffer should be empty.", $time);

  // Check 2 : Writing to full
  @(negedge clock);
  read_enable = 0;
  $display("CHECK 2 : Writing to full.");
  // Write
  @(negedge clock); write_enable = 1; write_data = 8'b10101010; data_expected = write_data;
  @(negedge clock); write_enable = 0; write_data = 0;
  if ( empty) $error("[%0tns] Empty flag is asserted after write. The buffer should be full.", $time);
  if (!full ) $error("[%0tns] Full flag is deasserted after write. The buffer should be full.", $time);

  repeat(10) @(posedge clock);

  // Check 3 : Reading to empty
  $display("CHECK 3 : Reading to empty.");
  // Read
  @(negedge clock); read_enable = 1;
  if (read_data !== data_expected) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
  @(negedge clock); read_enable = 0; data_expected = 'x;
  if (!empty) $error("[%0tns] Empty flag is deasserted after read with data '%0h'. The buffer should be empty.", $time, read_data);
  if ( full ) $error("[%0tns] Full flag is asserted after read with data '%0h'. The buffer should be empty.", $time, read_data);

  repeat(10) @(posedge clock);

  // Check 4 : Successive transfers
  $display("CHECK 4 : Successive transfers.");
  @(negedge clock);
  write_data = 0;
  for (integer iteration=0 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    // Write
    @(negedge clock);
    if (!empty) $error("[%0tns] Empty flag is deasserted with data '%0h'. The buffer should be empty.", $time, read_data);
    if ( full ) $error("[%0tns] Full flag is asserted with data '%0h'. The buffer should be empty.", $time, read_data);
    write_enable = 1;
    read_enable  = 0;
    @(posedge clock);
    data_expected = write_data;
    // Read
    @(negedge clock);
    if ( empty) $error("[%0tns] Empty flag is asserted. The buffer should be full.", $time, read_data);
    if (!full ) $error("[%0tns] Full flag is deasserted. The buffer should be full.", $time, read_data);
    write_data   = write_data+1;
    write_enable = 0;
    read_enable  = 1;
    if (read_data !== data_expected) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
    @(posedge clock);
    data_expected = 'x;
  end
  write_data   = 0;
  write_enable = 0;
  // Last read
  @(negedge clock);
  read_enable = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 4. The buffer should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 4. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 5 : Continuous flow with buffer empty
  $display("CHECK 5 : Continuous flow with buffer empty.");
  @(negedge clock);
  read_enable  = 1;
  write_enable = 1;
  write_data   = 0;
  for (integer iteration=0 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    @(posedge clock);
    if ( empty) $error("[%0tns] Empty flag is asserted.", $time, read_data);
    if ( full ) $error("[%0tns] Full flag is asserted.", $time, read_data);
    if (read_data != write_data) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
    @(negedge clock);
    write_data   = write_data+1;
  end
  write_data   = 0;
  write_enable = 0;
  // Last read
  @(negedge clock);
  read_enable = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 5. The buffer should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 5. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 6 : Continuous flow with buffer full
  $display("CHECK 6 : Continuous flow with buffer full.");
  @(negedge clock);
  write_enable = 1;
  write_data   = 0;
  @(posedge clock);
  data_expected = write_data;
  @(negedge clock);
  read_enable  = 1;
  write_data   = write_data+1;
  for (integer iteration=0 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    @(posedge clock);
    if ( empty) $error("[%0tns] Empty flag is asserted.", $time, read_data);
    if ( full ) $error("[%0tns] Full flag is asserted.", $time, read_data);
    if (read_data !== data_expected) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
    data_expected = write_data;
    @(negedge clock);
    write_data   = write_data+1;
  end
  write_data   = 0;
  write_enable = 0;
  // Last read
  @(negedge clock);
  read_enable = 0;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 6. The buffer should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 6. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 7 : Random stimulus
  $display("CHECK 7 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (!full && $random < RANDOM_CHECK_INJECTION_PROBABILITY) begin
          write_enable = 1;
          write_data   = $urandom_range(WIDTH_POW2);
        end else begin
          write_enable = 0;
          write_data   = 0;
        end
        // Check
        @(posedge clock);
        if (write_enable) begin
          data_expected = write_data;
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if (!empty && $random < RANDOM_CHECK_RECEPTION_PROBABILITY) begin
          read_enable = 1;
        end else begin
          read_enable = 0;
        end
        // Check
        @(posedge clock);
        if (read_enable) begin
          if (read_data !== data_expected) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected);
          data_expected = 'x;
        end
      end
    end
    // Stop condition
    begin
      // Transfer count
      while (transfer_count < RANDOM_CHECK_DURATION) begin
        @(negedge clock);
      end
      // Read until empty
      while (!empty) begin
        @(negedge clock);
      end
    end
    // Timeout
    begin
      while (timeout_countdown > 0) begin
        @(negedge clock);
        timeout_countdown--;
      end
      $error("[%0tns] Timeout.", $time);
    end
  join_any
  disable fork;
  // Final state
  if (!empty) $error("[%0tns] Empty flag is deasserted after check 7. The buffer should be empty.", $time);
  if ( full ) $error("[%0tns] Full flag is asserted after check 7. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
