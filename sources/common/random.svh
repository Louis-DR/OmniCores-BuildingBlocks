`ifndef __OMNICORES_RANDOM__
`define __OMNICORES_RANDOM__

`include "boolean.svh"
`include "constants.svh"

// Random real between 0 and 1
function real random_ratio();
  return $urandom / real'(INT_UNSIGNED_MAX);
endfunction

// Random true or false according to the input probability of returning true
function bool random_boolean(input real probability);
  return random_ratio() < probability;
endfunction

// Random bit index in a one-hot mask (returns -1 if no bit is high)
function automatic int random_in_mask(input longint unsigned mask);
  int unsigned number_high_bits;
  int unsigned random_target;
  int unsigned high_bit_count;
  // Count high bits in mask
  number_high_bits = $countones(mask);
  // If none, return -1
  if (number_high_bits == 0) return -1;
  // Select random index within high bits
  random_target = $urandom_range(number_high_bits - 1);
  // Convert to mask index
  high_bit_count = 0;
  foreach (mask[index]) begin
    if (mask[index]) begin
      if (high_bit_count == random_target) begin
        return index;
      end
      high_bit_count++;
    end
  end
  // Fallback
  return -1;
endfunction

// Random index in an associative memory
// This cannot be a task or a function because the return value must be of the
// type of the key of the array, which is not possible in SystemVerilog.
`ifndef SIMULATOR_NO_ASSOCIATIVE_MEMORY
int __associative_array_size__;
int __associative_array_target__;
int __associative_array_index__;
`define RANDOM_KEY(associative_array, random_key)                                \
  begin                                                                          \
    __associative_array_size__   = associative_array.size();                     \
    __associative_array_target__ = $urandom_range(__associative_array_size__-1); \
    __associative_array_index__  = 0;                                            \
    if (__associative_array_size__ > 0) begin                                    \
      associative_array.first(random_key);                                       \
      while (__associative_array_index__ < __associative_array_target__) begin   \
        associative_array.next(random_key);                                      \
        __associative_array_index__++;                                           \
      end                                                                        \
    end                                                                          \
  end
`endif

`endif