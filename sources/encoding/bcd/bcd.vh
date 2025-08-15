
`ifndef BINARY_TO_BCD_WIDTH
`define BINARY_TO_BCD_WIDTH(BINARY_WIDTH) ( \
  (BINARY_WIDTH <=  3) ?  1 : \
  (BINARY_WIDTH <=  6) ?  2 : \
  (BINARY_WIDTH <=  9) ?  3 : \
  (BINARY_WIDTH <= 13) ?  4 : \
  (BINARY_WIDTH <= 16) ?  5 : \
  (BINARY_WIDTH <= 19) ?  6 : \
  (BINARY_WIDTH <= 23) ?  7 : \
  (BINARY_WIDTH <= 26) ?  8 : \
  (BINARY_WIDTH <= 29) ?  9 : \
  (BINARY_WIDTH <= 33) ? 10 : \
  (BINARY_WIDTH <= 36) ? 11 : \
  (BINARY_WIDTH <= 39) ? 12 : \
  (BINARY_WIDTH <= 43) ? 13 : \
  (BINARY_WIDTH <= 46) ? 14 : \
  (BINARY_WIDTH <= 49) ? 15 : \
  (BINARY_WIDTH <= 53) ? 16 : \
  (BINARY_WIDTH <= 56) ? 17 : \
  (BINARY_WIDTH <= 59) ? 18 : \
  (BINARY_WIDTH <= 63) ? 19 : \
  (BINARY_WIDTH <= 64) ? 20 : \
  -1)
`endif

`ifndef BCD_TO_BINARY_WIDTH
`define BCD_TO_BINARY_WIDTH(BCD_WIDTH) ( \
  (BCD_WIDTH ==   1) ?  4 : \
  (BCD_WIDTH ==   2) ?  7 : \
  (BCD_WIDTH ==   3) ? 10 : \
  (BCD_WIDTH ==   4) ? 14 : \
  (BCD_WIDTH ==   5) ? 17 : \
  (BCD_WIDTH ==   6) ? 20 : \
  (BCD_WIDTH ==   7) ? 24 : \
  (BCD_WIDTH ==   8) ? 27 : \
  (BCD_WIDTH ==   9) ? 30 : \
  (BCD_WIDTH ==  10) ? 34 : \
  (BCD_WIDTH ==  11) ? 37 : \
  (BCD_WIDTH ==  12) ? 40 : \
  (BCD_WIDTH ==  13) ? 44 : \
  (BCD_WIDTH ==  14) ? 47 : \
  (BCD_WIDTH ==  15) ? 50 : \
  (BCD_WIDTH ==  16) ? 54 : \
  (BCD_WIDTH ==  17) ? 57 : \
  (BCD_WIDTH ==  18) ? 60 : \
  (BCD_WIDTH ==  19) ? 64 : \
  -1)
`endif
