# AnyV-Generics

A collection of useful generic Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a list of the modules currently available in this collection. More modules are coming, and feel free to suggest or submit ones you think should be added.

| Module                  | File                          | Description                       |
| ----------------------- | ----------------------------- | --------------------------------- |
| `buffer`                | data/buffer.v                 | Data buffer                       |
| `fifo`                  | data/fifo.v                   | Synchronous FIFO queue            |
| `fifo_async`            | data/fifo_async.v             | Asynchronous FIFO queue           |
| `lifo`                  | data/lifo.v                   | Synchronous LIFO stack            |
| `ram_single_port`       | data/ram_single_port.v        | Single-port RAM                   |
| `ram_dual_port`         | data/ram_dual_port.v          | Dual-port RAM                     |
| `ram_dual_port_async`   | data/ram_dual_port_async.v    | Asynchronous dual-port RAM        |
| `edge_detector`         | pulse/edge_detector.v         | Edge detector                     |
| `rising_edge_detector`  | pulse/rising_edge_detector.v  | Rising edge detector              |
| `falling_edge_detector` | pulse/falling_edge_detector.v | Falling edge detector             |
| `multi_edge_detector`   | pulse/multi_edge_detector.v   | Falling and falling edge detector |
| `sync`                  | timing/sync.v                 | Flip-flop synchronizer            |
| `sync_vec`              | timing/sync_vec.v             | Flip-flop vector synchronizer     |
| `sync_fast`             | timing/sync_fast.v            | Flip-flop fast synchronizer       |

Modules planned or in development :

- Data structures
  - Advanced FIFO queue
  - Advanced LIFO queue
  - Content addressable memory
  - Set-associative memory
- Pulse logic
  - Debounce
  - Pulse filter
  - Pulse gater
  - Pulse extender
  - Random pulse generator
- Clock logic
  - Clock dividers
  - Programmable clock gater
  - Programmable clock shaper
  - Glitch-less clock multiplexer
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
