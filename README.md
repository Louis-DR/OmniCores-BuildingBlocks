# OmniCores-BuildingBlocks

A collection of useful Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                                                                                                                  | Categories     | Description                                                                       | Progress*                                                     |
| ----------------------------------------------------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| [`static_priority_arbiter`](sources/arbiter/static_priority_arbiter/static_priority_arbiter.md)                         | arbiter        | Static priority arbiter                                                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`timeout_static_priority_arbiter`](sources/arbiter/timeout_static_priority_arbiter/timeout_static_priority_arbiter.md) | arbiter        | Static priority arbiter with timeout                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`dynamic_priority_arbiter`](sources/arbiter/dynamic_priority_arbiter/dynamic_priority_arbiter.md)                      | arbiter        | Dynamic priority arbiter                                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`small_round_robin_arbiter`](sources/arbiter/small_round_robin_arbiter/small_round_robin_arbiter.md)                   | arbiter        | Round-robin arbiter (small variant)                                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`balanced_round_robin_arbiter`](sources/arbiter/balanced_round_robin_arbiter/balanced_round_robin_arbiter.md)          | arbiter        | Round-robin arbiter (balanced variant)                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_round_robin_arbiter`](sources/arbiter/fast_round_robin_arbiter/fast_round_robin_arbiter.md)                      | arbiter        | Round-robin arbiter (fast variant)                                                | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`round_robin_arbiter`](sources/arbiter/round_robin_arbiter/round_robin_arbiter.md)                                     | arbiter        | Round-robin arbiter (variant wrapper)                                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`clock_gater`](sources/clock/clock_gater/clock_gater.md)                                                               | clock          | Clock gater behavioral model                                                      | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`clock_divider`](sources/clock/clock_divider/clock_divider.md)                                                         | clock          | Static clock divider                                                              | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`clock_multiplexer`](sources/clock/clock_multiplexer/clock_multiplexer.md)                                             | clock          | Glitch-free clock multiplexer                                                     | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`fast_clock_multiplexer`](sources/clock/fast_clock_multiplexer/fast_clock_multiplexer.md)                              | clock          | Glitch-free fast clock multiplexer                                                | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| `nonstop_clock_multiplexer`                                                                                             | clock          | Glitch-free clock multiplexer that works with stopped clocks                      | :orange_circle: :orange_circle: :red_circle:   :red_circle:   |
| `saturating_counter`                                                                                                    | counter        | Saturating counter                                                                | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `hysteresis_saturating_counter`                                                                                         | counter        | Hysteresis saturating counter                                                     | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `probabilistic_saturating_counter`                                                                                      | counter        | Probabilistic saturating counter                                                  | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `wrapping_counter`                                                                                                      | counter        | Wrapping bidirectional counter                                                    | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `wrapping_increment_counter`                                                                                            | counter        | Wrapping increment counter                                                        | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `wrapping_decrement_counter`                                                                                            | counter        | Wrapping decrement counter                                                        | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`simple_buffer`](sources/data/read_write_enable/simple_buffer/simple_buffer.md)                                        | data           | Single-entry data buffer for storage                                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`skid_buffer`](sources/data/read_write_enable/skid_buffer/skid_buffer.md)                                              | data           | Two-entry data buffer for bus pipelining                                          | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`bypass_buffer`](sources/data/read_write_enable/bypass_buffer/bypass_buffer.md)                                        | data           | Single-entry data buffer for back-pressure relief                                 | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `out_of_order_buffer`                                                                                                   | data           | Buffer with in-order write and out-of-order read access                           | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `reorder_buffer`                                                                                                        | data           | Buffer with out-of-order write and in-order read access                           | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`fifo`](sources/data/read_write_enable/fifo/fifo.md)                                                                   | data           | Synchronous FIFO queue                                                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`advanced_fifo`](sources/data/read_write_enable/advanced_fifo/advanced_fifo.md)                                        | data           | Synchronous FIFO queue with additional features                                   | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| [`asynchronous_fifo`](sources/data/read_write_enable/asynchronous_fifo/asynchronous_fifo.md)                            | data, timing   | Asynchronous FIFO queue                                                           | :green_circle:  :green_circle:  :green_circle: :red_circle:   |
| [`asynchronous_advanced_fifo`](sources/data/read_write_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | data, timing   | Asynchronous FIFO queue with additional features                                  | :green_circle:  :green_circle:  :red_circle:   :red_circle:   |
| `lifo`                                                                                                                  | data           | Synchronous LIFO stack                                                            | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `valid_ready_simple_buffer`                                                                                             | data           | Single-entry data buffer with valid-ready flow control                            | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_skid_buffer`                                                                                               | data           | Two-entry data buffer with valid-ready flow control                               | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_bypass_buffer`                                                                                             | data           | Single-entry data buffer with valid-ready flow control                            | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_out_of_order_buffer`                                                                                       | data           | Buffer with in-order write, out-of-order read access and valid-ready flow control | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_reorder_buffer`                                                                                            | data           | Buffer with out-of-order write, in-order read access and valid-ready flow control | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_fifo`                                                                                                      | data           | Synchronous FIFO queue with valid-ready flow control                              | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_advanced_fifo`                                                                                             | data           | Advanced synchronous FIFO queue with valid-ready flow control                     | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `valid_ready_asynchronous_fifo`                                                                                         | data, timing   | Asynchronous FIFO queue with valid-ready flow control                             | :green_circle:  :green_circle:  :red_circle:   :red_circle:   |
| `valid_ready_asynchronous_advanced_fifo`                                                                                | data, timing   | Asynchronous advanced FIFO queue with valid-ready flow control                    | :green_circle:  :green_circle:  :red_circle:   :red_circle:   |
| `valid_ready_lifo`                                                                                                      | data           | Synchronous LIFO stack with valid-ready flow control                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `credit_based_fifo`                                                                                                     | data           | Synchronous FIFO queue with credit-based flow control                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `binary_to_onehot`                                                                                                      | encoding       | Binary to one-hot encoder                                                         | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `onehot_to_binary`                                                                                                      | encoding       | One-hot to binary decoder                                                         | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `binary_to_grey`                                                                                                        | encoding       | Binary to Grey encoder                                                            | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `grey_to_binary`                                                                                                        | encoding       | Grey to binary decoder                                                            | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `parity_encoder`                                                                                                        | error control  | Parity encoder                                                                    | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `parity_checker`                                                                                                        | error control  | Parity checker                                                                    | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `parity_block_checker`                                                                                                  | error control  | Parity checker with block input                                                   | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `repetition_encoder`                                                                                                    | error control  | Repetition encoder                                                                | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `repetition_checker`                                                                                                    | error control  | Repetition checker                                                                | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `repetition_corrector`                                                                                                  | error control  | Repetition corrector                                                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `repetition_block_checker`                                                                                              | error control  | Repetition checker with block input                                               | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `repetition_block_corrector`                                                                                            | error control  | Repetition corrector with block input                                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `hamming_encoder`                                                                                                       | error control  | Hamming encoder                                                                   | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `hamming_checker`                                                                                                       | error control  | Hamming checker                                                                   | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `hamming_corrector`                                                                                                     | error control  | Hamming corrector                                                                 | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `hamming_block_checker`                                                                                                 | error control  | Hamming checker with block input                                                  | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `hamming_block_corrector`                                                                                               | error control  | Hamming corrector with block input                                                | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `hamming_block_packer`                                                                                                  | error control  | Hamming block packer                                                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `hamming_block_extractor`                                                                                               | error control  | Hamming block extractor                                                           | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_encoder`                                                                                              | error control  | Extended Hamming encoder                                                          | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_checker`                                                                                              | error control  | Extended Hamming checker                                                          | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_corrector`                                                                                            | error control  | Extended Hamming corrector                                                        | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_block_checker`                                                                                        | error control  | Extended Hamming checker with block input                                         | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_block_corrector`                                                                                      | error control  | Extended Hamming corrector with block input                                       | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_block_packer`                                                                                         | error control  | Extended Hamming block packer                                                     | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `extended_hamming_block_extractor`                                                                                      | error control  | Extended Hamming block extractor                                                  | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| `jk_flip_flop`                                                                                                          | flip_flop      | JK flip-flop                                                                      | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `jk_flip_flop_with_asynchronous_reset`                                                                                  | flip_flop      | JK flip-flop with asynchronous reset                                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `set_reset_flip_flop`                                                                                                   | flip_flop      | Set-reset flip-flop                                                               | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `set_reset_flip_flop_with_asynchronous_reset`                                                                           | flip_flop      | Set-reset flip-flop with asynchronous reset                                       | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `toggle_flip_flop`                                                                                                      | flip_flop      | Toggle flip-flop                                                                  | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `toggle_flip_flop_with_asynchronous_reset`                                                                              | flip_flop      | Toggle flip-flop with asynchronous reset                                          | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `single_port_ram`                                                                                                       | memory         | Single-port RAM                                                                   | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `dual_port_ram`                                                                                                         | memory         | Dual-port RAM                                                                     | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `asynchronous_dual_port_ram`                                                                                            | memory         | Asynchronous dual-port RAM                                                        | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `tag_directory`                                                                                                         | memory         | Tag directory with manual eviction                                                | :green_circle:  :orange_circle: :red_circle:   :white_circle: |
| `content_addressable_memory`                                                                                            | memory         | Content addressable memory                                                        | :orange_circle: :red_circle:    :red_circle:   :white_circle: |
| [`rotate_left`](sources/operations/rotate_left/rotate_left.md)                                                          | operations     | Rotate a vector left with wrapping by a static amount                             | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`rotate_right`](sources/operations/rotate_right/rotate_right.md)                                                       | operations     | Rotate a vector right with wrapping by a static amount                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`shift_left`](sources/operations/shift_left/shift_left.md)                                                             | operations     | Shift a vector left with padding by a static amount                               | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`shift_right`](sources/operations/shift_right/shift_right.md)                                                          | operations     | Shift a vector right with padding by a static amount                              | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `barrel_rotator_left`                                                                                                   | operations     | Rotate a vector left with wrapping by a dynamic amount                            | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_rotator_right`                                                                                                  | operations     | Rotate a vector right with wrapping by a dynamic amount                           | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_shifter_left`                                                                                                   | operations     | Shift a vector left with padding by a dynamic amount                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `barrel_shifter_right`                                                                                                  | operations     | Shift a vector right with padding by a dynamic amount                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `count_ones`                                                                                                            | operations     | Count the number of ones                                                          | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`small_first_one`](sources/operations/small_first_one/small_first_one.md)                                              | operations     | Determine the position of the first one (small variant)                           | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`fast_first_one`](sources/operations/fast_first_one/fast_first_one.md)                                                 | operations     | Determine the position of the first one (fast variant)                            | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| [`first_one`](sources/operations/first_one/first_one.md)                                                                | operations     | Determine the position of the first one (variant wrapper)                         | :green_circle:  :green_circle:  :green_circle: :white_circle: |
| `edge_detector`                                                                                                         | pulse          | Edge detector                                                                     | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `rising_edge_detector`                                                                                                  | pulse          | Rising edge detector                                                              | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `falling_edge_detector`                                                                                                 | pulse          | Falling edge detector                                                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `multi_edge_detector`                                                                                                   | pulse          | Rising and falling edge detector                                                  | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `pulse_separator`                                                                                                       | pulse          | Pulse separator                                                                   | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `fast_pulse_separator`                                                                                                  | pulse          | Fast pulse separator                                                              | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `pulse_extender`                                                                                                        | pulse          | Pulse extender                                                                    | :green_circle:  :green_circle:  :red_circle:   :white_circle: |
| `fibonacci_lfsr`                                                                                                        | shift register | Fibonacci linear feedback shift register                                          | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| `galois_lfsr`                                                                                                           | shift register | Galois linear feedback shift register                                             | :green_circle:  :red_circle:    :red_circle:   :white_circle: |
| [`synchronizer`](sources/timing/synchronizer/synchronizer.md)                                                           | timing         | Simple synchronizer                                                               | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| [`fast_synchronizer`](sources/timing/fast_synchronizer/fast_synchronizer.md)                                            | timing         | Fast synchronizer                                                                 | :green_circle:  :green_circle:  :green_circle: :green_circle: |
| `registered_synchronizer`                                                                                               | timing         | Registered synchronizer                                                           | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `reset_synchronizer`                                                                                                    | timing         | Reset de-assertion synchronizer                                                   | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `vector_synchronizer`                                                                                                   | timing         | Vector synchronizer that transmits the bits independently                         | :green_circle:  :orange_circle: :red_circle:   :red_circle:   |
| `closed_loop_vector_synchronizer`                                                                                       | timing         | Vector synchronizer that transmits all bits at once                               | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `registered_vector_synchronizer`                                                                                        | timing         | Registered vector synchronizer                                                    | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `grey_vector_synchronizer`                                                                                              | timing         | Registered vector synchronizer with Grey encoding                                 | :green_circle:  :red_circle:    :red_circle:   :red_circle:   |
| `feedback_pulse_synchronizer`                                                                                           | timing, pulse  | Pulse synchronizer using feedback                                                 | :green_circle:  :green_circle:  :red_circle:   :red_circle:   |
| `toggle_pulse_synchronizer`                                                                                             | timing, pulse  | Pulse synchronizer using toggle flip-flop                                         | :green_circle:  :green_circle:  :red_circle:   :red_circle:   |

*Progress is in order : design, verification, documentation, and constraints.

Modules planned or in development :

- Data structures
  - RAM-based FIFOs
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
  - True dual-port RAM
- Pulse logic
  - Debounce
  - Pulse filter
  - Pulse separator with different high and low time
- Clock logic
  - Programmable clock gater
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
- Transformation
  - Interleaver
  - Deinterleaver
  - Bit stripper
- Encoding
  - Binary-coded-decimal encoder and decoder
  - Seven-segment encoder and decoder
  - ASCII encoder and decoder
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
  - Random arbiter
  - Weighted round robin arbiter
- Predictors
  - Bimodal predictor
  - Two-level predictor
