// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        valid_ready_skid_buffer_tb.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the skid buffer.                               ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns



module valid_ready_skid_buffer_tb ();

// Test parameters
localparam real    CLOCK_PERIOD = 10;
localparam integer WIDTH        = 8;
localparam integer WIDTH_POW2   = 2**WIDTH;

// Check parameters
localparam integer THROUGHPUT_CHECK_DURATION      = 100;
localparam integer RANDOM_CHECK_DURATION          = 100;
localparam integer RANDOM_CHECK_WRITE_PROBABILITY = 0.5;
localparam integer RANDOM_CHECK_READ_PROBABILITY  = 0.5;
localparam integer RANDOM_CHECK_TIMEOUT           = 1000;

// Device ports
logic             clock;
logic             resetn;
logic [WIDTH-1:0] write_data;
logic             write_valid;
logic             write_ready;
logic             full;
logic [WIDTH-1:0] read_data;
logic             read_valid;
logic             read_ready;
logic             empty;

// Test variables
integer data_expected[$];
integer pop_trash;
integer transfer_count;
integer timeout_countdown;

// Device under test
valid_ready_skid_buffer #(
  .WIDTH ( WIDTH )
) valid_ready_skid_buffer_dut (
  .clock       ( clock       ),
  .resetn      ( resetn      ),
  .write_data  ( write_data  ),
  .write_valid ( write_valid ),
  .write_ready ( write_ready ),
  .full        ( full        ),
  .read_data   ( read_data   ),
  .read_valid  ( read_valid  ),
  .read_ready  ( read_ready  ),
  .empty       ( empty       )
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
  $dumpfile("valid_ready_skid_buffer_tb.vcd");
  $dumpvars(0,valid_ready_skid_buffer_tb);

  // Initialization
  write_data  = 0;
  write_valid = 0;
  read_ready  = 0;

  // Reset
  resetn = 0;
  @(posedge clock);
  resetn = 1;
  @(posedge clock);

  // Check 1 : Writing to full
  $display("CHECK 1 : Writing to full.");
  // Initial state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after reset with data '%0h'. The buffer should be empty.", $time, read_data);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after reset. The buffer should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after reset with data '%0h'. The buffer should be empty.", $time, read_data);
  if ( full       ) $error("[%0tns] Full flag is asserted after reset. The buffer should be empty.", $time);
  // First write
  @(negedge clock); write_valid = 1; write_data = 8'b10101010; data_expected.push_back(write_data);
  @(negedge clock); write_valid = 0; write_data = 0;
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after the first write. The buffer should contain the first transfer.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after the first write. The buffer should still have one free slot.", $time);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after the first write. The buffer should contain the first transfer.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after the first write. The buffer should still have one free slot.", $time);
  // Second write
  @(negedge clock); write_valid = 1; write_data = 8'b01010101; data_expected.push_back(write_data);
  @(negedge clock); write_valid = 0; write_data = 0;
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after the second write. The buffer should contain the first transfer.", $time);
  if ( write_ready) $error("[%0tns] Write ready is asserted after the second write. The buffer should be full.", $time);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after the second write. The buffer should contain the first transfer.", $time);
  if (!full       ) $error("[%0tns] Full flag is deasserted after the second write. The buffer should be full.", $time);

  repeat(10) @(posedge clock);

  // Check 2 : Reading to empty
  $display("CHECK 2 : Reading to empty.");
  // First read
  @(negedge clock); read_ready = 1;
  if (data_expected.size() != 0) begin
    if (read_data !== data_expected[0]) $error("[%0tns] First read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
  end else begin
    $error("[%0tns] Read valid while FIFO should be empty.", $time);
  end
  @(negedge clock); read_ready = 0; pop_trash = data_expected.pop_front();
  if (!read_valid ) $error("[%0tns] Read valid is deasserted after the first read. The buffer should contain the second transfer.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after the first read. The buffer should have one free slot.", $time);
  if ( empty      ) $error("[%0tns] Empty flag is asserted after the first read. The buffer should contain the second transfer.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after the first read. The buffer should have one free slot.", $time);
  // Second read
  @(negedge clock); read_ready = 1;
  if (data_expected.size() != 0) begin
    if (read_data !== data_expected[0]) $error("[%0tns] Second read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
  end else begin
    $error("[%0tns] Read valid while FIFO should be empty.", $time);
  end
  @(negedge clock); read_ready = 0; pop_trash = data_expected.pop_front();
  if ( read_valid ) $error("[%0tns] Read valid is asserted after the second read with data '%0h'. The buffer should be empty.", $time, read_data);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after the second read. The buffer should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after the second read with data '%0h'. The buffer should be empty.", $time, read_data);
  if ( full       ) $error("[%0tns] Full flag is asserted after the second read. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 3 : Back-to-back transfers for full throughput
  $display("CHECK 3 : Back-to-back transfers for full throughput.");
  @(negedge clock);
  // Write
  write_valid = 1;
  write_data  = 0;
  for (integer iteration=1 ; iteration<THROUGHPUT_CHECK_DURATION ; iteration++) begin
    data_expected.push_back(write_data);
    @(negedge clock);
    if (!read_valid ) $error("[%0tns] Read valid is deasserted. The buffer should be sending transfers.", $time);
    if (!write_ready) $error("[%0tns] Write ready is deasserted. The buffer should be accepting tranfers.", $time);
    if ( empty      ) $error("[%0tns] Empty flag is asserted. The buffer should be sending transfers.", $time);
    if ( full       ) $error("[%0tns] Full flag is asserted. The buffer should be accepting tranfers.", $time);
    // Read when not empty
    read_ready = 1;
    if (read_valid) begin
      if (data_expected.size() != 0) begin
        if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
      end else begin
        $error("[%0tns] Read valid while FIFO should be empty.", $time);
      end
      pop_trash = data_expected.pop_front();
    end
    // Increment write data
    write_data = write_data+1;
  end
  write_valid = 0;
  write_data  = 0;
  // Last read
  @(negedge clock);
  read_ready = 0;
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 3. The buffer should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 3. The buffer should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 3. The buffer should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 3. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // Check 4 : Random stimulus
  $display("CHECK 4 : Random stimulus.");
  @(negedge clock);
  transfer_count    = 0;
  timeout_countdown = RANDOM_CHECK_TIMEOUT;
  fork
    // Writing
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if ($random < RANDOM_CHECK_WRITE_PROBABILITY) begin
          write_valid = 1;
          write_data  = $urandom_range(WIDTH_POW2);
        end else begin
          write_valid = 0;
          write_data  = 0;
        end
        // Check
        @(posedge clock);
        if (write_valid && write_ready) begin
          data_expected.push_back(write_data);
          transfer_count++;
        end
      end
    end
    // Reading
    begin
      forever begin
        // Stimulus
        @(negedge clock);
        if ($random < RANDOM_CHECK_READ_PROBABILITY) begin
          read_ready = 1;
        end else begin
          read_ready = 0;
        end
        // Check
        @(posedge clock);
        if (read_valid && read_ready) begin
          if (data_expected.size() != 0) begin
            if (read_data !== data_expected[0]) $error("[%0tns] Read data '%0h' is not as expected '%0h'.", $time, read_data, data_expected[0]);
            pop_trash = data_expected.pop_front();
          end else begin
            $error("[%0tns] Read valid while FIFO should be empty.", $time);
          end
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
  // Safety
  write_valid = 0;
  read_ready  = 0;
  // Final state
  if ( read_valid ) $error("[%0tns] Read valid is asserted after check 4. The buffer should be empty.", $time);
  if (!write_ready) $error("[%0tns] Write ready is deasserted after check 4. The buffer should be empty.", $time);
  if (!empty      ) $error("[%0tns] Empty flag is deasserted after check 4. The buffer should be empty.", $time);
  if ( full       ) $error("[%0tns] Full flag is asserted after check 4. The buffer should be empty.", $time);

  repeat(10) @(posedge clock);

  // End of test
  $finish;
end

endmodule
