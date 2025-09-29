# Skid Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Skid Buffer                                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![skid_buffer](skid_buffer.symbol.svg)

Two-entry data buffer for bus pipelining. The buffer uses a write-enable/read-enable protocol for flow control and provides full and empty status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefuly.

The buffer uses two internal buffer entries with rotating write and read pointers, allowing simultaneous operations of independant read and write sides to both support maximum throughput and break the timing paths for data and control signals.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector. |

## Ports

| Name           | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                   |
| -------------- | --------- | ------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------- |
| `clock`        | input     | 1       | self         |          |             | Clock signal.                                                                 |
| `resetn`       | input     | 1       | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                |
| `write_enable` | input     | 1       | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write `write_data` to buffer.    |
| `write_data`   | input     | `WIDTH` | `clock`      |          |             | Data to be written to the buffer.                                             |
| `full`         | output    | 1       | `clock`      | `resetn` | `0`         | Buffer full status.<br/>`0`: buffer has space.<br/>`1`: buffer is full.       |
| `read_enable`  | input     | 1       | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read data from buffer.            |
| `read_data`    | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the buffer.                                                    |
| `empty`        | output    | 1       | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>`0`: buffer contains data.<br/>`1`: buffer is empty. |

## Operation

The skid buffer maintains two internal buffer entries, `buffer[0]` and `buffer[1]`, with separate write and read pointers that toggles independently. This design enables simultaneous and independant read and write operations in the same cycle, supporting full throughput back-to-back transfers.

For **write operation**, when `write_enable` is asserted, `write_data` is stored in the buffer entry pointed to by `write_buffer_selector`, the entry is marked as valid, and the write pointer toggles to the other entry.

For **read operation**, when `read_enable` is asserted, the buffer entry pointed to by `read_buffer_selector` is marked as invalid, and the read pointer toggles to the other entry. The `read_data` output continuously provides the data from the current read buffer entry.

The `full` flag is asserted when the current write buffer entry already contains valid data, and the `empty` flag is asserted when the current read buffer entry contains no valid data.

## Paths

| From           | To          | Type       | Comment                                                 |
| -------------- | ----------- | ---------- | ------------------------------------------------------- |
| `write_data`   | `read_data` | sequential | Data path through internal `buffer` array.              |
| `write_enable` | `full`      | sequential | Control path through internal `buffer_valid` registers. |
| `write_enable` | `empty`     | sequential | Control path through internal `buffer_valid` registers. |
| `read_enable`  | `full`      | sequential | Control path through internal `buffer_valid` registers. |
| `read_enable`  | `empty`     | sequential | Control path through internal `buffer_valid` registers. |

## Complexity

| Delay  | Gates      | Comment |
| ------ | ---------- | ------- |
| `O(1)` | `O(WIDTH)` |         |

The module requires `2×WIDTH` flip-flops for the dual data buffers, 2 flip-flops for the `buffer_valid` flags, and 2 flip-flops for the buffer selectors.

## Verification

The skid buffer is verified using a SystemVerilog testbench with four check sequences that validate the dual-entry buffer operations and full-throughput capability.

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

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                       | Description                                         |
| ----------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`skid_buffer.v`](skid_buffer.v)                           | Verilog design.                                     |
| Testbench         | [`skid_buffer.testbench.sv`](skid_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`skid_buffer.testbench.gtkw`](skid_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`skid_buffer.symbol.sss`](skid_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`skid_buffer.symbol.svg`](skid_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`skid_buffer.symbol.drawio`](skid_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`skid_buffer.md`](skid_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                    | Path                                                                | Comment                                                         |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_skid_buffer`](../../valid_ready/skid_buffer/skid_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`     | Variant of this module with valid-ready handshake flow control. |
| [`simple_buffer`](../simple_buffer/simple_buffer.md)                      | `omnicores-buildingblocks/sources/data/access_enable/simple_buffer` | Single-entry buffer for storage.                                |
| [`bypass_buffer`](../bypass_buffer/bypass_buffer.md)                      | `omnicores-buildingblocks/sources/data/access_enable/bypass_buffer` | Single-entry buffer aimed at relieving back-pressure.           |
| [`fifo`](../fifo/fifo.md)                                                 | `omnicores-buildingblocks/sources/data/access_enable/fifo`          | Multi-entry first-in-first-out queue.                           |
