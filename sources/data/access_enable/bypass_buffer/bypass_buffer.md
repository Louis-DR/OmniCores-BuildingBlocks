# Bypass Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Bypass Buffer                                                                    |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![bypass_buffer](bypass_buffer.symbol.svg)

Single-entry data buffer that is bypassed when it is read and written to in the same cycle. The buffer is aimed at relieving back-pressure in data flow systems while maintaining zero-latency pass-through capability. Unlike other buffers, this design doesn't break timing paths when operating in bypass mode.

When both read and write operations occur simultaneously on an empty buffer, data flows directly from input to output via the bypass path. When only writing occurs, data is stored in the internal buffer for later retrieval.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector. |

## Ports

| Name           | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                                                          |
| -------------- | --------- | ------- | ------------ | -------- | ----------- | -------------------------------------------------------------------------------------------------------------------- |
| `clock`        | input     | 1       | self         |          |             | Clock signal.                                                                                                        |
| `resetn`       | input     | 1       | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                                                       |
| `write_enable` | input     | 1       | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write `write_data` to buffer.                                           |
| `write_data`   | input     | `WIDTH` | `clock`      |          |             | Data to be written to the buffer.                                                                                    |
| `full`         | output    | 1       | `clock`      | `resetn` | `0`         | Buffer full status.<br/>`0`: buffer has space or being read.<br/>`1`: buffer is full and not being read.             |
| `read_enable`  | input     | 1       | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read data from buffer.                                                   |
| `read_data`    | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the buffer or bypass path.                                                                            |
| `empty`        | output    | 1       | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>`0`: buffer contains data or being written.<br/>`1`: buffer is empty and not being written. |

## Operation

The bypass buffer operates in two primary modes: bypass mode and storage mode.

**Bypass mode** occurs when both `write_enable` and `read_enable` are asserted simultaneously while the buffer is empty. In this case, `write_data` flows directly to `read_data` without being stored in the internal buffer. The buffer remains empty, and both `full` and `empty` flags are deasserted during the transfer.

**Storage mode** occurs when only writing is performed (`write_enable` asserted, `read_enable` deasserted) or when reading from a buffer that contains stored data. When writing without reading, data is stored in the internal `buffer` register and `buffer_valid` is set. When reading stored data, the buffer is emptied and `buffer_valid` is cleared.

The status flags are dynamically adjusted based on the buffer storage and the current operations. The `full` signal is asserted when the buffer contains valid data and is not being read. The `empty` signal is asserted when the buffer is empty and is not being written.

This design provides combinational paths in bypass mode, enabling zero-latency data flow when back-pressure relief is not needed.

## Paths

| From           | To          | Type          | Comment                                                                      |
| -------------- | ----------- | ------------- | ---------------------------------------------------------------------------- |
| `write_data`   | `read_data` | combinational | Direct bypass path when buffer is empty and both enable signals are active.  |
| `write_data`   | `read_data` | sequential    | Storage path through internal `buffer` register when there is back-pressure. |
| `write_enable` | `full`      | combinational | Dynamic status flag based on current buffer state and read operation.        |
| `write_enable` | `empty`     | combinational | Dynamic status flag based on current buffer state and write operation.       |
| `read_enable`  | `full`      | combinational | Dynamic status flag based on current buffer state and read operation.        |
| `read_enable`  | `empty`     | combinational | Dynamic status flag based on current buffer state and write operation.       |

## Complexity

| Delay  | Gates        | Comment |
| ------ | ------------ | ------- |
| `O(1)` | `O(WIDTH+1)` |         |

The module requires `WIDTH` flip-flops for the data buffer and one flip-flop for the `buffer_valid` state. Additional combinational logic is needed for the bypass multiplexer and dynamic status flag generation.

## Verification

The bypass buffer is verified using a SystemVerilog testbench with six check sequences that validate both bypass and storage operations.

The following table lists the checks performed by the testbench.

| Number | Check                             | Description                                                                                              |
| ------ | --------------------------------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Bypass path                       | Verifies that simultaneous read/write on an empty buffer bypasses storage and provides direct data flow. |
| 2      | Writing to full                   | Verifies that writing to an empty buffer stores data correctly and sets status flags.                    |
| 3      | Reading to empty                  | Verifies that reading from a full buffer provides correct data and clears status flags.                  |
| 4      | Successive transfers              | Performs alternating write and read operations to verify proper data transfer and flag management.       |
| 5      | Continuous flow with buffer empty | Performs simultaneous write and read operations while the buffer is empty and check the data and flags.  |
| 6      | Continuous flow with buffer full  | Performs simultaneous write and read operations while the buffer is full and check the data and flags.   |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                           | Description                                         |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`bypass_buffer.v`](bypass_buffer.v)                           | Verilog design.                                     |
| Testbench         | [`bypass_buffer.testbench.sv`](bypass_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`bypass_buffer.testbench.gtkw`](bypass_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`bypass_buffer.symbol.sss`](bypass_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`bypass_buffer.symbol.svg`](bypass_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`bypass_buffer.symbol.drawio`](bypass_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`bypass_buffer.md`](bypass_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                          | Path                                                                | Comment                                                         |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_bypass_buffer`](../../valid_ready/bypass_buffer/bypass_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/bypass_buffer`   | Variant of this module with valid-ready handshake flow control. |
| [`simple_buffer`](../simple_buffer/simple_buffer.md)                            | `omnicores-buildingblocks/sources/data/access_enable/simple_buffer` | Single-entry buffer for storage.                                |
| [`skid_buffer`](../skid_buffer/skid_buffer.md)                                  | `omnicores-buildingblocks/sources/data/access_enable/skid_buffer`   | Two-entry buffer more suited to bus pipelining.                 |
| [`fifo`](../fifo/fifo.md)                                                       | `omnicores-buildingblocks/sources/data/access_enable/fifo`          | Multi-entry first-in-first-out queue.                           |
