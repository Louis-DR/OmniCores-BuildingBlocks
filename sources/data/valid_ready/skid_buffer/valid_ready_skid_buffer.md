# Valid-Ready Skid Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Skid Buffer                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_skid_buffer](valid_ready_skid_buffer.symbol.svg)

Two-entry data buffer for bus pipelining with valid-ready handshake flow control. The buffer provides full and empty status flags and implements a handshake protocol where transfers only occur when both valid and ready signals are asserted. The handshake protocol manages and protects flow control, eliminating the need for external enable logic.

The buffer uses two internal buffer entries with rotating write and read pointers, allowing simultaneous operations of independent read and write sides to both support maximum throughput and maintain proper sequential data paths.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector. |

## Ports

| Name          | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                         |
| ------------- | --------- | ------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------- |
| `clock`       | input     | 1       | self         |          |             | Clock signal.                                                                       |
| `resetn`      | input     | 1       | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                      |
| `write_data`  | input     | `WIDTH` | `clock`      |          |             | Data to be written to the buffer.                                                   |
| `write_valid` | input     | 1       | `clock`      |          |             | Write valid signal.<br/>`0`: no write transaction.<br/>`1`: write data is valid.    |
| `write_ready` | output    | 1       | `clock`      | `resetn` | `1`         | Write ready signal.<br/>`0`: buffer is full.<br/>`1`: buffer can accept write data. |
| `full`        | output    | 1       | `clock`      | `resetn` | `0`         | Buffer full status.<br/>`0`: buffer has space.<br/>`1`: buffer is full.             |
| `read_data`   | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the buffer.                                                          |
| `read_valid`  | output    | 1       | `clock`      | `resetn` | `0`         | Read valid signal.<br/>`0`: no read data available.<br/>`1`: read data is valid.    |
| `read_ready`  | input     | 1       | `clock`      |          |             | Read ready signal.<br/>`0`: not ready to receive.<br/>`1`: ready to receive data.   |
| `empty`       | output    | 1       | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>`0`: buffer contains data.<br/>`1`: buffer is empty.       |

## Operation

The valid-ready skid buffer is a wrapper around the read-write enable skid buffer that implements the valid-ready handshake protocol. It maintains two internal buffer entries with separate write and read pointers that toggle independently.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The `write_data` is stored in the buffer entry pointed to by the write buffer selector, the entry is marked as valid, and the write pointer toggles to the other entry.

For **read operation**, a read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The buffer entry pointed to by the read buffer selector is marked as invalid, and the read pointer toggles to the other entry. The `read_data` output continuously provides the data from the current read buffer entry.

This design enables simultaneous and independent read and write operations in the same cycle, supporting full throughput back-to-back transfers. The `full` flag is asserted when the current write buffer entry already contains valid data, and the `empty` flag is asserted when the current read buffer entry contains no valid data.

## Paths

| From          | To            | Type       | Comment                                              |
| ------------- | ------------- | ---------- | ---------------------------------------------------- |
| `write_data`  | `read_data`   | sequential | Data path through internal buffer array.             |
| `write_valid` | `read_valid`  | sequential | Control path through internal buffer_valid register. |
| `write_valid` | `write_ready` | sequential | Control path through internal buffer_valid register. |
| `read_ready`  | `read_valid`  | sequential | Control path through internal buffer_valid register. |
| `read_ready`  | `write_ready` | sequential | Control path through internal buffer_valid register. |

## Complexity

| Delay  | Gates      | Comment |
| ------ | ---------- | ------- |
| `O(1)` | `O(WIDTH)` |         |

The module requires `2×WIDTH` flip-flops for the dual data buffers, 2 flip-flops for the buffer_valid flags, and 2 flip-flops for the buffer selectors. The wrapper adds minimal logic for the valid-ready protocol conversion.

## Verification

The valid-ready skid buffer is verified using a SystemVerilog testbench with four check sequences that validate the dual-entry buffer operations and full-throughput capability with a handshake protocol compliance.

The following table lists the checks performed by the testbench.

| Number | Check                                      | Description                                                                                             |
| ------ | ------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| 1      | Writing to full                            | Verifies that two writes fill the buffer correctly and updates the flags.                               |
| 2      | Reading to empty                           | Verifies that two reads empty the buffer correctly, updates the flags, and provide the correct data.    |
| 3      | Back-to-back transfers for full throughput | Performs simultaneous read and write operations to verify full throughput capability without data loss. |
| 4      | Random stimulus                            | Performs random write and read operations and verifies data integrity.                                  |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_skid_buffer.v`](valid_ready_skid_buffer.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_skid_buffer.testbench.sv`](valid_ready_skid_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_skid_buffer.testbench.gtkw`](valid_ready_skid_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_skid_buffer.symbol.sss`](valid_ready_skid_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_skid_buffer.symbol.svg`](valid_ready_skid_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_skid_buffer.symbol.drawio`](valid_ready_skid_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_skid_buffer.md`](valid_ready_skid_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                          | Path                                                              | Comment                           |
| --------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------------------- |
| [`skid_buffer`](../../access_enable/skid_buffer/skid_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/skid_buffer` | Underlying buffer implementation. |

## Related modules

| Module                                                                       | Path                                                              | Comment                                               |
| ---------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------- |
| [`skid_buffer`](../../access_enable/skid_buffer/skid_buffer.md)              | `omnicores-buildingblocks/sources/data/access_enable/skid_buffer` | Base variant with read-write enable flow control.     |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer` | Single-entry buffer for storage.                      |
| [`valid_ready_bypass_buffer`](../bypass_buffer/valid_ready_bypass_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/bypass_buffer` | Single-entry buffer aimed at relieving back-pressure. |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                            | `omnicores-buildingblocks/sources/data/valid_ready/fifo`          | Multi-entry first-in-first-out queue.                 |
