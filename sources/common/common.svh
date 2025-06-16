`ifndef __OMNICORES_COMMON_HEADER__
`define __OMNICORES_COMMON_HEADER__

`ifndef INFINITE
`define INFINITE (1/0)
`endif

`ifdef SIMUMLATOR_NO_BOOL
typedef bit bool;
`endif

localparam bool true  = 1'b1;
localparam bool false = 1'b0;

// Function to sample N elements from range [0, M-1] without replacement
function automatic integer random_range_sample_2 (input integer M);
  integer sample[2];
  integer range[];
  integer temporary;

  // Allocate and initialize range array with range [0, M-1]
  range = new[M];
  for (int range_index = 0; range_index < M; range_index++) begin
    range[range_index] = range_index;
  end

  // Partial Fisher-Yates shuffle - only shuffle first N elements
  for (int shuffle_index = 0; shuffle_index < 2; shuffle_index++) begin
    int random_index = $urandom_range(shuffle_index, M-1);

    // Swap range[shuffle_index] with range[random_index]
    temporary = range[shuffle_index];
    range[shuffle_index] = range[random_index];
    range[random_index] = temporary;

    // Store shuffled element in sample
    sample[shuffle_index] = range[shuffle_index];
  end

  return sample;
endfunction

`endif