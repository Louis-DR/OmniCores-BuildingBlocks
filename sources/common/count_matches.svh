`ifndef __OMNICORES_COUNT_MATCHES__
`define __OMNICORES_COUNT_MATCHES__

// Macro to count the number of matching bits between two values
`define COUNT_BIT_MATCHES(width, value1, value2, result) \
  begin \
    logic [width-1:0] __count_bit_matches_xor__; \
    result = 0; \
    __count_bit_matches_xor__ = value1 ^ value2; \
    for (integer bit_index_temp = 0; bit_index_temp < width; bit_index_temp++) begin \
      if (!__count_bit_matches_xor__[bit_index_temp]) begin \
        result++; \
      end \
    end \
  end

`endif