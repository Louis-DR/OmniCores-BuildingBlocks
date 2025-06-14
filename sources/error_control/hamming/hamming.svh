
`ifndef GET_HAMMING_PARITY_WIDTH
`define GET_HAMMING_PARITY_WIDTH(DATA_WIDTH) \
  (DATA_WIDTH <=     1) ?  2 : \
  (DATA_WIDTH <=     4) ?  3 : \
  (DATA_WIDTH <=    11) ?  4 : \
  (DATA_WIDTH <=    26) ?  5 : \
  (DATA_WIDTH <=    57) ?  6 : \
  (DATA_WIDTH <=   120) ?  7 : \
  (DATA_WIDTH <=   247) ?  8 : \
  (DATA_WIDTH <=   502) ?  9 : \
  (DATA_WIDTH <=  1013) ? 10 : \
  (DATA_WIDTH <=  2036) ? 11 : \
  (DATA_WIDTH <=  4083) ? 12 : \
  (DATA_WIDTH <=  8178) ? 13 : \
  (DATA_WIDTH <= 16369) ? 14 : \
  (DATA_WIDTH <= 32752) ? 15 : \
  (DATA_WIDTH <= 65519) ? 16 : \
  -1
`endif

`ifndef GET_HAMMING_DATA_WIDTH
`define GET_HAMMING_DATA_WIDTH(PARITY_WIDTH) \
  (PARITY_WIDTH ==  2) ?     1 : \
  (PARITY_WIDTH ==  3) ?     4 : \
  (PARITY_WIDTH ==  4) ?    11 : \
  (PARITY_WIDTH ==  5) ?    26 : \
  (PARITY_WIDTH ==  6) ?    57 : \
  (PARITY_WIDTH ==  7) ?   120 : \
  (PARITY_WIDTH ==  8) ?   247 : \
  (PARITY_WIDTH ==  9) ?   502 : \
  (PARITY_WIDTH == 10) ?  1013 : \
  (PARITY_WIDTH == 11) ?  2036 : \
  (PARITY_WIDTH == 12) ?  4083 : \
  (PARITY_WIDTH == 13) ?  8178 : \
  (PARITY_WIDTH == 14) ? 16369 : \
  (PARITY_WIDTH == 15) ? 32752 : \
  (PARITY_WIDTH == 16) ? 65519 : \
  -1
`endif

`ifndef GET_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH
`define GET_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     3) ?  2 : \
  (BLOCK_WIDTH <=     7) ?  3 : \
  (BLOCK_WIDTH <=    15) ?  4 : \
  (BLOCK_WIDTH <=    31) ?  5 : \
  (BLOCK_WIDTH <=    63) ?  6 : \
  (BLOCK_WIDTH <=   127) ?  7 : \
  (BLOCK_WIDTH <=   255) ?  8 : \
  (BLOCK_WIDTH <=   511) ?  9 : \
  (BLOCK_WIDTH <=  1023) ? 10 : \
  (BLOCK_WIDTH <=  2047) ? 11 : \
  (BLOCK_WIDTH <=  4095) ? 12 : \
  (BLOCK_WIDTH <=  8191) ? 13 : \
  (BLOCK_WIDTH <= 16383) ? 14 : \
  (BLOCK_WIDTH <= 32767) ? 15 : \
  (BLOCK_WIDTH <= 65535) ? 16 : \
  -1
`endif

`ifndef GET_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH
`define GET_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     3) ? (BLOCK_WIDTH -  2) : \
  (BLOCK_WIDTH <=     7) ? (BLOCK_WIDTH -  3) : \
  (BLOCK_WIDTH <=    15) ? (BLOCK_WIDTH -  4) : \
  (BLOCK_WIDTH <=    31) ? (BLOCK_WIDTH -  5) : \
  (BLOCK_WIDTH <=    63) ? (BLOCK_WIDTH -  6) : \
  (BLOCK_WIDTH <=   127) ? (BLOCK_WIDTH -  7) : \
  (BLOCK_WIDTH <=   255) ? (BLOCK_WIDTH -  8) : \
  (BLOCK_WIDTH <=   511) ? (BLOCK_WIDTH -  9) : \
  (BLOCK_WIDTH <=  1023) ? (BLOCK_WIDTH - 10) : \
  (BLOCK_WIDTH <=  2047) ? (BLOCK_WIDTH - 11) : \
  (BLOCK_WIDTH <=  4095) ? (BLOCK_WIDTH - 12) : \
  (BLOCK_WIDTH <=  8191) ? (BLOCK_WIDTH - 13) : \
  (BLOCK_WIDTH <= 16383) ? (BLOCK_WIDTH - 14) : \
  (BLOCK_WIDTH <= 32767) ? (BLOCK_WIDTH - 15) : \
  (BLOCK_WIDTH <= 65535) ? (BLOCK_WIDTH - 16) : \
  -1
`endif

`ifndef GET_HAMMING_UPPER_BLOCK_WIDTH
`define GET_HAMMING_UPPER_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     3) ?     3 : \
  (BLOCK_WIDTH <=     7) ?     7 : \
  (BLOCK_WIDTH <=    15) ?    15 : \
  (BLOCK_WIDTH <=    31) ?    31 : \
  (BLOCK_WIDTH <=    63) ?    63 : \
  (BLOCK_WIDTH <=   127) ?   127 : \
  (BLOCK_WIDTH <=   255) ?   255 : \
  (BLOCK_WIDTH <=   511) ?   511 : \
  (BLOCK_WIDTH <=  1023) ?  1023 : \
  (BLOCK_WIDTH <=  2047) ?  2047 : \
  (BLOCK_WIDTH <=  4095) ?  4095 : \
  (BLOCK_WIDTH <=  8191) ?  8191 : \
  (BLOCK_WIDTH <= 16383) ? 16383 : \
  (BLOCK_WIDTH <= 32767) ? 32767 : \
  (BLOCK_WIDTH <= 65535) ? 65535 : \
  -1
`endif
