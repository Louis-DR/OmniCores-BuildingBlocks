`ifndef __OMNICORES_MEASURE_FREQUENCY__
`define __OMNICORES_MEASURE_FREQUENCY__

// Macro to measure the frequency of a clock
// This cannot be a task because of Icarus Verilog bug #1103
// The duration is the number of clock cycles to measure the frequency (default: 10 cycles)
// The timeout is the time to wait for the frequency to be measured (default: 10000 steps)
// The multiplier is the multiplier of the duration to get the frequency (default: 1000 for MHz)
real __measure_frequenc_time_start__;
real __measure_frequenc_time_stop__;
`define measure_frequency(clock, frequency, duration=10, timeout=1e4, multiplier=1e3) \
  fork                                                   \
    begin                                                \
      @(posedge clock)                                   \
      __measure_frequenc_time_start__ = $realtime;           \
      repeat (duration) @(posedge clock)                  \
      __measure_frequenc_time_stop__ = $realtime;            \
      frequency = multiplier * duration                  \
                  / (  __measure_frequenc_time_stop__    \
                     - __measure_frequenc_time_start__); \
    end                                                  \
    begin                                                \
      #timeout;                                          \
      frequency = 0;                                     \
    end                                                  \
  join_any                                               \
  disable fork;

`endif