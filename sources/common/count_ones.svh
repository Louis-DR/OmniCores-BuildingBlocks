`ifndef __OMNICORES_COUNT_ONES__
`define __OMNICORES_COUNT_ONES__

// Macro to count the number of ones (set bits) in a value
`define COUNT_ONES(width, value, result) \
  begin \
    result = 0; \
    for (int bit_index_temp = 0; bit_index_temp < width; bit_index_temp++) begin \
      if (value[bit_index_temp]) begin \
        result++; \
      end \
    end \
  end

`endif