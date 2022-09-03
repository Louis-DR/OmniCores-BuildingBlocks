# AnyV-Generics

A collection of useful generic Verilog modules that can be used as building blocks for projects, or to learn basic Verilog concepts.

Below is a is of the modules currently available in this collection. More modules are coming and feel free to suggest or submit ones you think should be added.

| Module       | File              | Description                   |
| ------------ | ----------------- | ----------------------------- |
| `fifo`       | data/fifo.v       | Synchronous FIFO queue        |
| `fifo_async` | data/fifo_async.v | Asynchronous FIFO queue       |
| `lifo`       | data/lifo.v       | Synchronous LIFO stack        |
| `sync`       | timing/sync.v     | Flip-flop synchronizer        |
| `sync_vec`   | timing/sync_vec.v | Flip-flop vector synchronizer |

Modules planned or in development :

- Data structures
  - Advanced FIFO queue
  - Asynchronous LIFO stack
  - Advanced LIFO queue
  - Content addressable memory
  - Behavioral memory
- Pulse logic
  - Edge detector
  - Debounce
  - Pulse filter
  - Pulse gater
  - Pulse extender
  - Pulse clock domain crossing
  - Random pulse generator
- Clock logic
  - Clock dividers
  - Programmable clock gater
  - Programmable clock shaper
  - Glitch-less clock multiplexer
- Timing
  - Req-ack handshake-based register slice
  - Valid-ready handshake-based register slice
  - Credit-based register slice
- Transformation
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
  - MD5
  - BLAKE2
  - SHA1
  - SHA256, SHA384, SHA512
  - AES128, AES256
- Arbiters
  - Random arbiter
  - Priority arbiter
  - Round robin arbiter
  - Weighted round robin arbiter
  - Matrix robin arbiter
  - Dynamic priority arbiter
