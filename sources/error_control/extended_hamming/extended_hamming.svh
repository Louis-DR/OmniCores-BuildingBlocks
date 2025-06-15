
`ifndef GET_EXTENDED_HAMMING_PARITY_WIDTH
`define GET_EXTENDED_HAMMING_PARITY_WIDTH(DATA_WIDTH) \
  (DATA_WIDTH <=     1) ?  3 : \
  (DATA_WIDTH <=     4) ?  4 : \
  (DATA_WIDTH <=    11) ?  5 : \
  (DATA_WIDTH <=    26) ?  6 : \
  (DATA_WIDTH <=    57) ?  7 : \
  (DATA_WIDTH <=   120) ?  8 : \
  (DATA_WIDTH <=   247) ?  9 : \
  (DATA_WIDTH <=   502) ? 10 : \
  (DATA_WIDTH <=  1013) ? 11 : \
  (DATA_WIDTH <=  2036) ? 12 : \
  (DATA_WIDTH <=  4083) ? 13 : \
  (DATA_WIDTH <=  8178) ? 14 : \
  (DATA_WIDTH <= 16369) ? 15 : \
  (DATA_WIDTH <= 32752) ? 16 : \
  (DATA_WIDTH <= 65519) ? 17 : \
  -1
`endif

`ifndef GET_EXTENDED_HAMMING_DATA_WIDTH
`define GET_EXTENDED_HAMMING_DATA_WIDTH(PARITY_WIDTH) \
  (PARITY_WIDTH ==  3) ?     1 : \
  (PARITY_WIDTH ==  4) ?     4 : \
  (PARITY_WIDTH ==  5) ?    11 : \
  (PARITY_WIDTH ==  6) ?    26 : \
  (PARITY_WIDTH ==  7) ?    57 : \
  (PARITY_WIDTH ==  8) ?   120 : \
  (PARITY_WIDTH ==  9) ?   247 : \
  (PARITY_WIDTH == 10) ?   502 : \
  (PARITY_WIDTH == 11) ?  1013 : \
  (PARITY_WIDTH == 12) ?  2036 : \
  (PARITY_WIDTH == 13) ?  4083 : \
  (PARITY_WIDTH == 14) ?  8178 : \
  (PARITY_WIDTH == 15) ? 16369 : \
  (PARITY_WIDTH == 16) ? 32752 : \
  (PARITY_WIDTH == 17) ? 65519 : \
  -1
`endif

`ifndef GET_EXTENDED_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH
`define GET_EXTENDED_HAMMING_PARITY_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     4) ?  3 : \
  (BLOCK_WIDTH <=     8) ?  4 : \
  (BLOCK_WIDTH <=    16) ?  5 : \
  (BLOCK_WIDTH <=    32) ?  6 : \
  (BLOCK_WIDTH <=    64) ?  7 : \
  (BLOCK_WIDTH <=   128) ?  8 : \
  (BLOCK_WIDTH <=   256) ?  9 : \
  (BLOCK_WIDTH <=   512) ? 10 : \
  (BLOCK_WIDTH <=  1024) ? 11 : \
  (BLOCK_WIDTH <=  2048) ? 12 : \
  (BLOCK_WIDTH <=  4096) ? 13 : \
  (BLOCK_WIDTH <=  8192) ? 14 : \
  (BLOCK_WIDTH <= 16384) ? 15 : \
  (BLOCK_WIDTH <= 32768) ? 16 : \
  (BLOCK_WIDTH <= 65536) ? 17 : \
  -1
`endif

`ifndef GET_EXTENDED_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH
`define GET_EXTENDED_HAMMING_DATA_WIDTH_FROM_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     4) ? (BLOCK_WIDTH -  2) : \
  (BLOCK_WIDTH <=     8) ? (BLOCK_WIDTH -  3) : \
  (BLOCK_WIDTH <=    16) ? (BLOCK_WIDTH -  4) : \
  (BLOCK_WIDTH <=    32) ? (BLOCK_WIDTH -  5) : \
  (BLOCK_WIDTH <=    64) ? (BLOCK_WIDTH -  6) : \
  (BLOCK_WIDTH <=   128) ? (BLOCK_WIDTH -  7) : \
  (BLOCK_WIDTH <=   256) ? (BLOCK_WIDTH -  8) : \
  (BLOCK_WIDTH <=   512) ? (BLOCK_WIDTH -  9) : \
  (BLOCK_WIDTH <=  1024) ? (BLOCK_WIDTH - 10) : \
  (BLOCK_WIDTH <=  2048) ? (BLOCK_WIDTH - 11) : \
  (BLOCK_WIDTH <=  4096) ? (BLOCK_WIDTH - 12) : \
  (BLOCK_WIDTH <=  8192) ? (BLOCK_WIDTH - 13) : \
  (BLOCK_WIDTH <= 16384) ? (BLOCK_WIDTH - 14) : \
  (BLOCK_WIDTH <= 32768) ? (BLOCK_WIDTH - 15) : \
  (BLOCK_WIDTH <= 65536) ? (BLOCK_WIDTH - 16) : \
  -1
`endif

`ifndef GET_EXTENDED_HAMMING_UPPER_BLOCK_WIDTH
`define GET_EXTENDED_HAMMING_UPPER_BLOCK_WIDTH(BLOCK_WIDTH) \
  (BLOCK_WIDTH <=     4) ?     4 : \
  (BLOCK_WIDTH <=     8) ?     8 : \
  (BLOCK_WIDTH <=    16) ?    16 : \
  (BLOCK_WIDTH <=    32) ?    32 : \
  (BLOCK_WIDTH <=    64) ?    64 : \
  (BLOCK_WIDTH <=   128) ?   128 : \
  (BLOCK_WIDTH <=   256) ?   256 : \
  (BLOCK_WIDTH <=   512) ?   512 : \
  (BLOCK_WIDTH <=  1024) ?  1024 : \
  (BLOCK_WIDTH <=  2048) ?  2048 : \
  (BLOCK_WIDTH <=  4096) ?  4096 : \
  (BLOCK_WIDTH <=  8192) ?  8192 : \
  (BLOCK_WIDTH <= 16384) ? 16384 : \
  (BLOCK_WIDTH <= 32768) ? 32768 : \
  (BLOCK_WIDTH <= 65536) ? 65536 : \
  -1
`endif
