# OmniCores-BuildingBlocks

A collection of useful Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                         | Categories    | Description                                                  |     Design      |    Testbench    | Documentation |
| ------------------------------ | ------------- | ------------------------------------------------------------ | :-------------: | :-------------: | :-----------: |
| `clock_divider`                | clock         | Static clock divider                                         | :green_circle:  | :green_circle:  | :red_circle:  |
| `clock_gater`                  | clock         | Clock gater behavioral model                                 | :green_circle:  | :green_circle:  | :red_circle:  |
| `clock_multiplexer`            | clock         | Glitch-free clock multiplexer                                | :green_circle:  | :green_circle:  | :red_circle:  |
| `fast_clock_multiplexer`       | clock         | Glitch-free fast clock multiplexer                           | :green_circle:  | :green_circle:  | :red_circle:  |
| `nonstop_clock_multiplexer`    | clock         | Glitch-free clock multiplexer that works with stopped clocks | :orange_circle: | :orange_circle: | :red_circle:  |
| `buffer`                       | data          | Data buffer                                                  | :green_circle:  |  :red_circle:   | :red_circle:  |
| `fifo`                         | data          | Synchronous FIFO queue                                       | :green_circle:  |  :red_circle:   | :red_circle:  |
| `asynchronous_fifo`            | data, timing  | Asynchronous FIFO queue                                      | :green_circle:  |  :red_circle:   | :red_circle:  |
| `lifo`                         | data          | Synchronous LIFO stack                                       | :green_circle:  |  :red_circle:   | :red_circle:  |
| `single_port_ram`              | memory        | Single-port RAM                                              | :green_circle:  |  :red_circle:   | :red_circle:  |
| `dual_port_ram`                | memory        | Dual-port RAM                                                | :green_circle:  |  :red_circle:   | :red_circle:  |
| `asynchronous_dual_port_ram`   | memory        | Asynchronous dual-port RAM                                   | :green_circle:  |  :red_circle:   | :red_circle:  |
| `tag_directory`                | memory        | Tag directory with manual eviction                           | :green_circle:  | :orange_circle: | :red_circle:  |
| `content_addressable_memory`   | memory        | Content addressable memory                                   | :orange_circle: |  :red_circle:   | :red_circle:  |
| `edge_detector`                | pulse         | Edge detector                                                | :green_circle:  |  :red_circle:   | :red_circle:  |
| `rising_edge_detector`         | pulse         | Rising edge detector                                         | :green_circle:  |  :red_circle:   | :red_circle:  |
| `falling_edge_detector`        | pulse         | Falling edge detector                                        | :green_circle:  |  :red_circle:   | :red_circle:  |
| `multi_edge_detector`          | pulse         | Rising and falling edge detector                             | :green_circle:  |  :red_circle:   | :red_circle:  |
| `synchronizer`                 | timing        | Multi-stage synchronizer                                     | :green_circle:  | :green_circle:  | :red_circle:  |
| `fast_synchronizer`            | timing        | Multi-stage fast synchronizer                                | :green_circle:  | :green_circle:  | :red_circle:  |
| `vector_synchronizer`          | timing        | Vector synchronizer                                          | :green_circle:  | :orange_circle: | :red_circle:  |
| `pulse_synchronizer`           | timing, pulse | Pulse synchronizer                                           | :green_circle:  | :green_circle:  | :red_circle:  |
| `pulse_synchronizer_with_busy` | timing, pulse | Pulse synchronizer with busy signal                          | :green_circle:  | :green_circle:  | :red_circle:  |

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
  - Pulse separator
  - Pulse extender
- Clock logic
  - Programmable clock gater
  - Programmable clock shaper
- Timing
  - Reset synchronizer
  - Pre-registering synchronizer
  - Two-phase Req-ack handshake-based skid buffer
  - Four-phase Req-ack handshake-based skid buffer
  - Valid-ready handshake-based skid buffer
  - Credit-based buffer
- Encoding
  - Binary to grey-code
  - Grey-code to binary
  - Binary to one-hot
  - One-hot to binary
  - Binary to binary-coded-decimal
  - Binary-coded-decimal to binary
  - Binary-coded-decimal to 7-segment
- Error correction
  - Parity code
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
- Arbiters
  - Random arbiter
  - Priority arbiter
  - Round robin arbiter
  - Weighted round robin arbiter
  - Matrix robin arbiter
  - Dynamic priority arbiter
