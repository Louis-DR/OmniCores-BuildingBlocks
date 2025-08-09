`ifndef __OMNICORES_COUNT_DIFFERENCES__
`define __OMNICORES_COUNT_DIFFERENCES__

// Macro to count the number of differing bits between two values
`define COUNT_BIT_DIFFERENCES(width, value1, value2, result) \
  begin \
    logic [width-1:0] __count_bit_differences_xor__; \
    result = 0; \
    __count_bit_differences_xor__ = value1 ^ value2; \
    for (int bit_index_temp = 0; bit_index_temp < width; bit_index_temp++) begin \
      if (__count_bit_differences_xor__[bit_index_temp]) begin \
        result++; \
      end \
    end \
  end

`endif