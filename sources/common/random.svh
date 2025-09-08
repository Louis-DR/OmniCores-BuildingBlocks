`ifndef __OMNICORES_RANDOM__
`define __OMNICORES_RANDOM__

`include "boolean.svh"
`include "constants.svh"

function real random_ratio();
  return $urandom / real'(INT_UNSIGNED_MAX);
endfunction

function bool random_boolean(input real probability);
  return random_ratio() < probability;
endfunction

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

`endif