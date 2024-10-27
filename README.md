# OmniCores-BuildingBlocks

A collection of useful Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                             | Categories     | Description                                                  | Progress*                                                   |
| ---------------------------------- | -------------- | ------------------------------------------------------------ | ----------------------------------------------------------- |
| `clock_divider`                    | clock          | Static clock divider                                         | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `clock_gater`                      | clock          | Clock gater behavioral model                                 | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `clock_multiplexer`                | clock          | Glitch-free clock multiplexer                                | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `fast_clock_multiplexer`           | clock          | Glitch-free fast clock multiplexer                           | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `nonstop_clock_multiplexer`        | clock          | Glitch-free clock multiplexer that works with stopped clocks | :orange_circle: :orange_circle: :red_circle: :red_circle:   |
| `saturating_counter`               | counter        | Saturating counter                                           | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `hysteresis_saturating_counter`    | counter        | Hysteresis saturating counter                                | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `probabilistic_saturating_counter` | counter        | Probabilistic saturating counter                             | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `simple_buffer`                    | data           | Single-entry data buffer for storage                         | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `skid_buffer`                      | data           | Two-entry data buffer for bus pipelining                     | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `bypass_buffer`                    | data           | Single-entry data buffer for back-pressure relief            | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `fifo`                             | data           | Synchronous FIFO queue                                       | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `advanced_fifo`                    | data           | Synchronous FIFO queue with additional features              | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `asynchronous_fifo`                | data, timing   | Asynchronous FIFO queue                                      | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `asynchronous_advanced_fifo`       | data, timing   | Asynchronous FIFO queue with additional features             | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `lifo`                             | data           | Synchronous LIFO stack                                       | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `binary_to_onehot`                 | encoding       | Binary to one-hot encoder                                    | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `onehot_to_binary`                 | encoding       | One-hot to binary decoder                                    | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `binary_to_grey`                   | encoding       | Binary to Grey encoder                                       | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `grey_to_binary`                   | encoding       | Grey to binary decoder                                       | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `parity_encoder`                   | error control  | Parity encoder                                               | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `parity_checker`                   | error control  | Parity checker                                               | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `repetition_encoder`               | error control  | Repetition encoder                                           | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `repetition_checker`               | error control  | Repetition checker                                           | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `repetition_corrector`             | error control  | Repetition corrector                                         | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `single_port_ram`                  | memory         | Single-port RAM                                              | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `dual_port_ram`                    | memory         | Dual-port RAM                                                | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `asynchronous_dual_port_ram`       | memory         | Asynchronous dual-port RAM                                   | :green_circle:  :red_circle:    :red_circle: :red_circle:   |
| `tag_directory`                    | memory         | Tag directory with manual eviction                           | :green_circle:  :orange_circle: :red_circle: :white_circle: |
| `content_addressable_memory`       | memory         | Content addressable memory                                   | :orange_circle: :red_circle:    :red_circle: :white_circle: |
| `edge_detector`                    | pulse          | Edge detector                                                | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `rising_edge_detector`             | pulse          | Rising edge detector                                         | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `falling_edge_detector`            | pulse          | Falling edge detector                                        | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `multi_edge_detector`              | pulse          | Rising and falling edge detector                             | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `pulse_separator`                  | pulse          | Pulse separator                                              | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `fast_pulse_separator`             | pulse          | Fast pulse separator                                         | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `pulse_extender`                   | pulse          | Pulse extender                                               | :green_circle:  :green_circle:  :red_circle: :white_circle: |
| `fibonacci_lfsr`                   | shift register | Fibonacci linear feedback shift register                     | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `galois_lfsr`                      | shift register | Galois linear feedback shift register                        | :green_circle:  :red_circle:    :red_circle: :white_circle: |
| `synchronizer`                     | timing         | Simple synchronizer                                          | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `fast_synchronizer`                | timing         | Fast synchronizer                                            | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `registered_synchronizer`          | timing         | Registered synchronizer                                      | :green_circle:  :red_circle:    :red_circle: :red_circle:   |
| `reset_synchronizer`               | timing         | Reset de-assertion synchronizer                              | :green_circle:  :red_circle:    :red_circle: :red_circle:   |
| `vector_synchronizer`              | timing         | Vector synchronizer                                          | :green_circle:  :orange_circle: :red_circle: :red_circle:   |
| `registered_vector_synchronizer`   | timing         | Registered vector synchronizer                               | :green_circle:  :red_circle:    :red_circle: :red_circle:   |
| `grey_vector_synchronizer`         | timing         | Registered vector synchronizer with Grey encoding            | :green_circle:  :red_circle:    :red_circle: :red_circle:   |
| `pulse_synchronizer`               | timing, pulse  | Pulse synchronizer                                           | :green_circle:  :green_circle:  :red_circle: :red_circle:   |
| `pulse_synchronizer_with_busy`     | timing, pulse  | Pulse synchronizer with busy signal                          | :green_circle:  :green_circle:  :red_circle: :red_circle:   |

*Progress is in order the design, the verification, the documentation, and the constraints.

Modules planned or in development :

- Data structures
  - Advanced FIFO queue
  - Advanced LIFO queue
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
- Timing
  - Two-phase Req-ack handshake-based skid buffer
  - Four-phase Req-ack handshake-based skid buffer
  - Valid-ready handshake-based skid buffer
  - Credit-based buffer
- Shift registers
  - Programmable LFSR
  - SISR signature generator
  - MISR signature generator
- Transformation
  - Interleaver
  - Deinterleaver
  - Bit stripper
- Encoding
  - Binary to grey-code
  - Grey-code to binary
  - Binary to one-hot
  - One-hot to binary
  - Binary to binary-coded-decimal
  - Binary-coded-decimal to binary
  - Binary-coded-decimal to 7-segment
- Error control
  - Hamming codes
  - Extended Hamming codes
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
  - Priority arbiter
  - Round robin arbiter
  - Weighted round robin arbiter
  - Matrix robin arbiter
  - Dynamic priority arbiter
- Predictors
  - Bimodal predictor
  - Two-level predictor
