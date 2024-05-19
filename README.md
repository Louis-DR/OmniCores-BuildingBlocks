# AnyV-Generics

A collection of useful generic Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                         | Directory                           | Description                         |
| ------------------------------ | ----------------------------------- | ----------------------------------- |
| `clock_divider`                  | data/clock_divider                | Static clock divider                |
| `clock_gater`                  | data/clock_gater                    | Clock gater behavioral model        |
| `clock_multiplexer`            | data/clock_multiplexer              | Glitch-free clock multiplexer       |
| `fast_clock_multiplexer`       | data/fast_clock_multiplexer         | Glitch-free fast clock multiplexer  |
| `buffer`                       | data/buffer                         | Data buffer                         |
| `fifo`                         | data/fifo                           | Synchronous FIFO queue              |
| `asynchronous_fifo`            | data/asynchronous_fifo              | Asynchronous FIFO queue             |
| `lifo`                         | data/lifo                           | Synchronous LIFO stack              |
| `single_port_ram`              | memory/single_port_ram              | Single-port RAM                     |
| `dual_port_ram`                | memory/dual_port_ram                | Dual-port RAM                       |
| `asynchronous_dual_port_ram`   | memory/asynchronous_dual_port_ram   | Asynchronous dual-port RAM          |
| `edge_detector`                | pulse/edge_detector                 | Edge detector                       |
| `rising_edge_detector`         | pulse/rising_edge_detector          | Rising edge detector                |
| `falling_edge_detector`        | pulse/falling_edge_detector         | Falling edge detector               |
| `multi_edge_detector`          | pulse/multi_edge_detector           | Falling and falling edge detector   |
| `synchronizer`                 | timing/synchronizer                 | Flip-flop synchronizer              |
| `fast_synchronizer`            | timing/fast_synchronizer            | Flip-flop fast synchronizer         |
| `vector_synchronizer`          | timing/vector_synchronizer          | Vector synchronizer                 |
| `pulse_synchronizer`           | timing/pulse_synchronizer           | Pulse synchronizer                  |
| `pulse_synchronizer_with_busy` | timing/pulse_synchronizer_with_busy | Pulse synchronizer with busy signal |

Modules planned or in development :

- Data structures
  - Advanced FIFO queue
  - Advanced LIFO queue
- Memories
  - Content addressable memory
  - Set-associative memory
- Pulse logic
  - Debounce
  - Pulse filter
  - Pulse gater
  - Pulse extender
  - Random pulse generator
- Clock logic
  - Programmable clock gater
  - Programmable clock shaper
- Timing
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
