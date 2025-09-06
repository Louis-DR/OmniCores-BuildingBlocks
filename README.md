# OmniCores-BuildingBlocks

A collection of useful Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                                                                                                                                    | Categories     | Description                                                                       | Progress*                                                     |
| ----------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| [`static_priority_arbiter`](sources/arbiter/static_priority_arbiter/static_priority_arbiter.md)                                           | arbiter        | Static priority arbiter                                                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`timeout_static_priority_arbiter`](sources/arbiter/timeout_static_priority_arbiter/timeout_static_priority_arbiter.md)                   | arbiter        | Static priority arbiter with timeout                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`dynamic_priority_arbiter`](sources/arbiter/dynamic_priority_arbiter/dynamic_priority_arbiter.md)                                        | arbiter        | Dynamic priority arbiter                                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`small_round_robin_arbiter`](sources/arbiter/small_round_robin_arbiter/small_round_robin_arbiter.md)                                     | arbiter        | Round-robin arbiter (small variant)                                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`balanced_round_robin_arbiter`](sources/arbiter/balanced_round_robin_arbiter/balanced_round_robin_arbiter.md)                            | arbiter        | Round-robin arbiter (balanced variant)                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_round_robin_arbiter`](sources/arbiter/fast_round_robin_arbiter/fast_round_robin_arbiter.md)                                        | arbiter        | Round-robin arbiter (fast variant)                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`round_robin_arbiter`](sources/arbiter/round_robin_arbiter/round_robin_arbiter.md)                                                       | arbiter        | Round-robin arbiter (variant wrapper)                                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`clock_gater`](sources/clock/clock_gater/clock_gater.md)                                                                                 | clock          | Clock gater behavioral model                                                      | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`static_clock_divider`](sources/clock/static_clock_divider/static_clock_divider.md)                                                      | clock          | Static clock divider                                                              | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`programmable_clock_divider`](sources/clock/programmable_clock_divider/programmable_clock_divider.md)                                    | clock          | Programmable clock divider                                                        | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`clock_multiplier`](sources/clock/clock_multiplier/clock_multiplier.md)                                                                  | clock          | Static clock multiplier behavioral model                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`clock_multiplexer`](sources/clock/clock_multiplexer/clock_multiplexer.md)                                                               | clock          | Glitch-free clock multiplexer                                                     | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`fast_clock_multiplexer`](sources/clock/fast_clock_multiplexer/fast_clock_multiplexer.md)                                                | clock          | Glitch-free fast clock multiplexer                                                | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`nonstop_clock_multiplexer`](sources/clock/nonstop_clock_multiplexer/nonstop_clock_multiplexer.md)                                       | clock          | Glitch-free clock multiplexer that works with stopped clocks                      | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`wide_clock_multiplexer`](sources/clock/wide_clock_multiplexer/wide_clock_multiplexer.md)                                                | clock          | Glitch-free wide clock multiplexer                                                | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`switchover_clock_selector`](sources/clock/switchover_clock_selector/switchover_clock_selector.md)                                       | clock          | Glitch-free clock switch-over from a first clock to a second clock when it starts | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`priority_clock_selector`](sources/clock/priority_clock_selector/priority_clock_selector.md)                                             | clock          | Glitch-free clock switch to a fallback clock if the primary is not running        | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`saturating_counter`](sources/counter/saturating_counter/saturating_counter.md)                                                          | counter        | Saturating counter                                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hysteresis_saturating_counter`](sources/counter/hysteresis_saturating_counter/hysteresis_saturating_counter.md)                         | counter        | Hysteresis saturating counter                                                     | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`probabilistic_saturating_counter`](sources/counter/probabilistic_saturating_counter/probabilistic_saturating_counter.md)                | counter        | Probabilistic saturating counter                                                  | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`wrapping_counter`](sources/counter/wrapping_counter/wrapping_counter.md)                                                                | counter        | Wrapping bidirectional counter                                                    | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`wrapping_increment_counter`](sources/counter/wrapping_increment_counter/wrapping_increment_counter.md)                                  | counter        | Wrapping increment counter                                                        | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`wrapping_decrement_counter`](sources/counter/wrapping_decrement_counter/wrapping_decrement_counter.md)                                  | counter        | Wrapping decrement counter                                                        | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`simple_buffer`](sources/data/read_write_enable/simple_buffer/simple_buffer.md)                                                          | data           | Single-entry data buffer for storage                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`skid_buffer`](sources/data/read_write_enable/skid_buffer/skid_buffer.md)                                                                | data           | Two-entry data buffer for bus pipelining                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`bypass_buffer`](sources/data/read_write_enable/bypass_buffer/bypass_buffer.md)                                                          | data           | Single-entry data buffer for back-pressure relief                                 | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`out_of_order_buffer`](sources/data/read_write_enable/out_of_order_buffer/out_of_order_buffer.md)                                        | data           | Buffer with in-order write and out-of-order read access                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`reorder_buffer`](sources/data/read_write_enable/reorder_buffer/reorder_buffer.md)                                                       | data           | Buffer with out-of-order write and in-order read access                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fifo`](sources/data/read_write_enable/fifo/fifo.md)                                                                                     | data           | Synchronous FIFO queue                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`advanced_fifo`](sources/data/read_write_enable/advanced_fifo/advanced_fifo.md)                                                          | data           | Synchronous FIFO queue with additional features                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`asynchronous_fifo`](sources/data/read_write_enable/asynchronous_fifo/asynchronous_fifo.md)                                              | data, timing   | Asynchronous FIFO queue                                                           | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`asynchronous_advanced_fifo`](sources/data/read_write_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md)                   | data, timing   | Asynchronous FIFO queue with additional features                                  | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`lifo`](sources/data/read_write_enable/lifo/lifo.md)                                                                                     | data           | Synchronous LIFO stack                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_simple_buffer`](sources/data/valid_ready/simple_buffer/valid_ready_simple_buffer.md)                                        | data           | Single-entry data buffer with valid-ready flow control                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_skid_buffer`](sources/data/valid_ready/skid_buffer/valid_ready_skid_buffer.md)                                              | data           | Two-entry data buffer with valid-ready flow control                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_bypass_buffer`](sources/data/valid_ready/bypass_buffer/valid_ready_bypass_buffer.md)                                        | data           | Single-entry data buffer with valid-ready flow control                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_out_of_order_buffer`](sources/data/valid_ready/out_of_order_buffer/valid_ready_out_of_order_buffer.md)                      | data           | Buffer with in-order write, out-of-order read access and valid-ready flow control | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `valid_ready_reorder_buffer`                                                                                                              | data           | Buffer with out-of-order write, in-order read access and valid-ready flow control | :green_circle:  :orange_circle: :red_circle:   :white_circle: |
| [`valid_ready_fifo`](sources/data/valid_ready/fifo/valid_ready_fifo.md)                                                                   | data           | Synchronous FIFO queue with valid-ready flow control                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_advanced_fifo`](sources/data/valid_ready/advanced_fifo/valid_ready_advanced_fifo.md)                                        | data           | Advanced synchronous FIFO queue with valid-ready flow control                     | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`valid_ready_asynchronous_fifo`](sources/data/valid_ready/asynchronous_fifo/valid_ready_asynchronous_fifo.md)                            | data, timing   | Asynchronous FIFO queue with valid-ready flow control                             | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`valid_ready_asynchronous_advanced_fifo`](sources/data/valid_ready/asynchronous_advanced_fifo/valid_ready_asynchronous_advanced_fifo.md) | data, timing   | Asynchronous advanced FIFO queue with valid-ready flow control                    | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`valid_ready_lifo`](sources/data/valid_ready/lifo/valid_ready_lifo.md)                                                                   | data           | Synchronous LIFO stack with valid-ready flow control                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `credit_based_fifo`                                                                                                                       | data           | Synchronous FIFO queue with credit-based flow control                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`binary_to_onehot`](sources/encoding/onehot/binary_to_onehot.md)                                                                         | encoding       | Binary to one-hot encoder                                                         | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`onehot_to_binary`](sources/encoding/onehot/onehot_to_binary.md)                                                                         | encoding       | One-hot to binary decoder                                                         | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`binary_to_grey`](sources/encoding/grey/binary_to_grey.md)                                                                               | encoding       | Binary to Grey encoder                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`grey_to_binary`](sources/encoding/grey/grey_to_binary.md)                                                                               | encoding       | Grey to binary decoder                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`binary_to_bcd`](sources/encoding/bcd/binary_to_bcd.md)                                                                                  | encoding       | Binary to Binary-Coded Decimal encoder                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`bcd_to_binary`](sources/encoding/bcd/bcd_to_binary.md)                                                                                  | encoding       | Binary-Coded Decimal to binary decoder                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`parity_encoder`](sources/error_control/parity/parity_encoder.md)                                                                        | error control  | Parity encoder                                                                    | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`parity_checker`](sources/error_control/parity/parity_checker.md)                                                                        | error control  | Parity checker                                                                    | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`parity_block_checker`](sources/error_control/parity/parity_block_checker.md)                                                            | error control  | Parity checker with block input                                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`repetition_encoder`](sources/error_control/repetition/repetition_encoder.md)                                                            | error control  | Repetition encoder                                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`repetition_checker`](sources/error_control/repetition/repetition_checker.md)                                                            | error control  | Repetition checker                                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`repetition_corrector`](sources/error_control/repetition/repetition_corrector.md)                                                        | error control  | Repetition corrector                                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`repetition_block_checker`](sources/error_control/repetition/repetition_block_checker.md)                                                | error control  | Repetition checker with block input                                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`repetition_block_corrector`](sources/error_control/repetition/repetition_block_corrector.md)                                            | error control  | Repetition corrector with block input                                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_encoder`](sources/error_control/hamming/hamming_encoder.md)                                                                     | error control  | Hamming encoder                                                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_checker`](sources/error_control/hamming/hamming_checker.md)                                                                     | error control  | Hamming checker                                                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_corrector`](sources/error_control/hamming/hamming_corrector.md)                                                                 | error control  | Hamming corrector                                                                 | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_block_checker`](sources/error_control/hamming/hamming_block_checker.md)                                                         | error control  | Hamming checker with block input                                                  | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_block_corrector`](sources/error_control/hamming/hamming_block_corrector.md)                                                     | error control  | Hamming corrector with block input                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_block_packer`](sources/error_control/hamming/hamming_block_packer.md)                                                           | error control  | Hamming block packer                                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`hamming_block_unpacker`](sources/error_control/hamming/hamming_block_unpacker.md)                                                       | error control  | Hamming block unpacker                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_encoder`](sources/error_control/extended_hamming/extended_hamming_encoder.md)                                          | error control  | Extended Hamming encoder                                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_checker`](sources/error_control/extended_hamming/extended_hamming_checker.md)                                          | error control  | Extended Hamming checker                                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_corrector`](sources/error_control/extended_hamming/extended_hamming_corrector.md)                                      | error control  | Extended Hamming corrector                                                        | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_block_checker`](sources/error_control/extended_hamming/extended_hamming_block_checker.md)                              | error control  | Extended Hamming checker with block input                                         | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_block_corrector`](sources/error_control/extended_hamming/extended_hamming_block_corrector.md)                          | error control  | Extended Hamming corrector with block input                                       | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_block_packer`](sources/error_control/extended_hamming/extended_hamming_block_packer.md)                                | error control  | Extended Hamming block packer                                                     | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`extended_hamming_block_unpacker`](sources/error_control/extended_hamming/extended_hamming_block_unpacker.md)                            | error control  | Extended Hamming block unpacker                                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`jk_flip_flop`](sources/flip_flop/jk_flip_flop/jk_flip_flop.md)                                                                          | flip_flop      | JK flip-flop                                                                      | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`jk_flip_flop_with_reset`](sources/flip_flop/jk_flip_flop_with_reset/jk_flip_flop_with_reset.md)                                         | flip_flop      | JK flip-flop with asynchronous reset                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`set_reset_flip_flop`](sources/flip_flop/set_reset_flip_flop/set_reset_flip_flop.md)                                                     | flip_flop      | Set-reset flip-flop                                                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`set_reset_flip_flop_with_reset`](sources/flip_flop/set_reset_flip_flop_with_reset/set_reset_flip_flop_with_reset.md)                    | flip_flop      | Set-reset flip-flop with asynchronous reset                                       | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`toggle_flip_flop`](sources/flip_flop/toggle_flip_flop/toggle_flip_flop.md)                                                              | flip_flop      | Toggle flip-flop                                                                  | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`toggle_flip_flop_with_reset`](sources/flip_flop/toggle_flip_flop_with_reset/toggle_flip_flop_with_reset.md)                             | flip_flop      | Toggle flip-flop with asynchronous reset                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `single_port_ram`                                                                                                                         | memory         | Single-port RAM                                                                   | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `simple_dual_port_ram`                                                                                                                    | memory         | Simple Dual-port RAM                                                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `asynchronous_simple_dual_port_ram`                                                                                                       | memory         | Asynchronous simple dual-port RAM                                                 | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `true_dual_port_ram`                                                                                                                      | memory         | True Dual-port RAM                                                                | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `asynchronous_true_dual_port_ram`                                                                                                         | memory         | Asynchronous true dual-port RAM                                                   | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `tag_directory`                                                                                                                           | memory         | Tag directory with manual eviction                                                | :green_circle:  :orange_circle: :red_circle:   :white_circle: |
| `content_addressable_memory`                                                                                                              | memory         | Content addressable memory                                                        | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| [`rotate_left`](sources/operations/rotate_left/rotate_left.md)                                                                            | operations     | Rotate a vector left with wrapping by a static amount                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`rotate_right`](sources/operations/rotate_right/rotate_right.md)                                                                         | operations     | Rotate a vector right with wrapping by a static amount                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`shift_left`](sources/operations/shift_left/shift_left.md)                                                                               | operations     | Shift a vector left with padding by a static amount                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`shift_right`](sources/operations/shift_right/shift_right.md)                                                                            | operations     | Shift a vector right with padding by a static amount                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `barrel_rotator_left`                                                                                                                     | operations     | Rotate a vector left with wrapping by a dynamic amount                            | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_rotator_right`                                                                                                                    | operations     | Rotate a vector right with wrapping by a dynamic amount                           | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_shifter_left`                                                                                                                     | operations     | Shift a vector left with padding by a dynamic amount                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_shifter_right`                                                                                                                    | operations     | Shift a vector right with padding by a dynamic amount                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`count_ones`](sources/operations/count_ones/count_ones.md)                                                                               | operations     | Count the number of ones                                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`small_first_one`](sources/operations/small_first_one/small_first_one.md)                                                                | operations     | Determine the position of the first one (small variant)                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_first_one`](sources/operations/fast_first_one/fast_first_one.md)                                                                   | operations     | Determine the position of the first one (fast variant)                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`first_one`](sources/operations/first_one/first_one.md)                                                                                  | operations     | Determine the position of the first one (variant wrapper)                         | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`edge_detector`](sources/pulse/edge_detector/edge_detector.md)                                                                           | pulse          | Edge detector                                                                     | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`rising_edge_detector`](sources/pulse/rising_edge_detector/rising_edge_detector.md)                                                      | pulse          | Rising edge detector                                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`falling_edge_detector`](sources/pulse/falling_edge_detector/falling_edge_detector.md)                                                   | pulse          | Falling edge detector                                                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`multi_edge_detector`](sources/pulse/multi_edge_detector/multi_edge_detector.md)                                                         | pulse          | Rising and falling edge detector                                                  | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`pulse_separator`](sources/pulse/pulse_separator/pulse_separator.md)                                                                     | pulse          | Pulse separator                                                                   | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_pulse_separator`](sources/pulse/fast_pulse_separator/fast_pulse_separator.md)                                                      | pulse          | Fast pulse separator                                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`pulse_extender`](sources/pulse/pulse_extender/pulse_extender.md)                                                                        | pulse          | Pulse extender                                                                    | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_pulse_extender`](sources/pulse/fast_pulse_extender/fast_pulse_extender.md)                                                         | pulse          | Fast pulse extender                                                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `fibonacci_lfsr`                                                                                                                          | shift register | Fibonacci linear feedback shift register                                          | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `galois_lfsr`                                                                                                                             | shift register | Galois linear feedback shift register                                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`synchronizer`](sources/timing/synchronizer/synchronizer.md)                                                                             | timing         | Simple synchronizer                                                               | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`fast_synchronizer`](sources/timing/fast_synchronizer/fast_synchronizer.md)                                                              | timing         | Fast synchronizer                                                                 | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`registered_synchronizer`](sources/timing/registered_synchronizer/registered_synchronizer.md)                                            | timing         | Registered synchronizer                                                           | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`reset_synchronizer`](sources/timing/reset_synchronizer/reset_synchronizer.md)                                                           | timing         | Reset de-assertion synchronizer                                                   | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`vector_synchronizer`](sources/timing/vector_synchronizer/vector_synchronizer.md)                                                        | timing         | Vector synchronizer that transmits the bits independently                         | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`closed_loop_vector_synchronizer`](sources/timing/closed_loop_vector_synchronizer/closed_loop_vector_synchronizer.md)                    | timing         | Vector synchronizer that transmits all bits at once                               | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`registered_vector_synchronizer`](sources/timing/registered_vector_synchronizer/registered_vector_synchronizer.md)                       | timing         | Registered vector synchronizer                                                    | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`grey_vector_synchronizer`](sources/timing/grey_vector_synchronizer/grey_vector_synchronizer.md)                                         | timing         | Registered vector synchronizer with Grey encoding                                 | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`feedback_pulse_synchronizer`](sources/timing/feedback_pulse_synchronizer/feedback_pulse_synchronizer.md)                                | timing, pulse  | Pulse synchronizer using feedback                                                 | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`toggle_pulse_synchronizer`](sources/timing/toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)                                      | timing, pulse  | Pulse synchronizer using toggle flip-flop                                         | :green_circle:  :green_circle:  :green_circle: :green_circle: |

*Progress is in order : design, verification, documentation, and constraints.

Modules planned or in development :

- Data structures
  - Advanced LIFO queue
  - Credit-based structures
  - On-off based structures
  - Request-accept/deny based structures
  - Two-phase request-acknowledge handshake-based structures
  - Four-phase request-acknowledge handshake-based structures
  - Struct-based data structures
  - Priority FIFO bank
- Path flow
  - Multiplexer-router
  - Fork-join
- Memories
  - Tag directory with eviction policy
  - Content addressable memory
  - Set-associative memory
  - True dual-port RAM (TDP, and rename the other to simple dual port (SDP))
- Pulse logic
  - Debounce
  - Pulse filter
  - Pulse separator with different high and low time
  - Long pulse synchronizer
- Clock logic
  - Programmable clock pulse filter
  - Programmable clock shaper
- Shift registers
  - Programmable LFSR
  - SISR signature generator
  - MISR signature generator
- Array and vector operations
  - Min and max of packed array
- Arithmetic
  - Adder
  - Staged adder
  - Multiplier
  - Staged multiplier
  - Divider
  - Staged divider
  - Modulo
  - Constant modulo
- Transformation
  - Interleaver
  - Deinterleaver
  - Bit stripper
- Encoding
  - Seven-segment encoder and decoder
  - Alphabet 5-bit encoder and decoder
  - Alphanumerical 6-bit encoder and decoder
  - ASCII 7-bit encoder and decoder
- Error control
  - Golay codes
  - Extended Golay codes
  - Reed-Solomon codes
  - Bose–Chaudhuri–Hocquenghem codes
  - Modular redundancy
- Cryptography and hashing
  - MD2, MD4, MD5, MD6
  - BLAKE, BLAKE2, BLAKE3
  - SHA1, SHA2, SHA3
  - SHA256, SHA384, SHA512
  - AES128, AES256
  - ShangMi 2, SM3, SM4
- Arbiters
  - Timeout dynamic priority arbiter
  - Weighted round robin arbiter
- Predictors
  - Bimodal predictor
  - Two-level predictor
- Counters
  - Asynchronous saturating counter
  - Asynchronous wrapping counter
