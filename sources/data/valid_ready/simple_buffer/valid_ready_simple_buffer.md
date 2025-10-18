# Valid-Ready Simple Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Simple Buffer                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_simple_buffer](valid_ready_simple_buffer.symbol.svg)

Single-entry data buffer for storage with valid-ready handshake flow control. The buffer provides full and empty status flags and implements a handshake protocol where transfers only occur when both valid and ready signals are asserted. The handshake protocol prevents simultaneous read and write operations that could cause data corruption.

When used for bus pipelining, back-to-back transactions work on a period of two cycles - one for write then one for read - and the throughput is half of the clock frequency. The handshake protocol eliminates the need for external control logic to manage enable signals, unlike the read-write enable variant.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector. |

## Ports

| Name          | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                             |
| ------------- | --------- | ------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------- |
| `clock`       | input     | 1       | self         |          |             | Clock signal.                                                                           |
| `resetn`      | input     | 1       | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                          |
| `full`        | output    | 1       | `clock`      | `resetn` | `0`         | Buffer full status.<br/>• `0`: buffer is empty.<br/>• `1`: buffer contains valid data.  |
| `empty`       | output    | 1       | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>• `0`: buffer contains valid data.<br/>• `1`: buffer is empty. |
| `write_data`  | input     | `WIDTH` | `clock`      |          |             | Data to be written to the buffer.                                                       |
| `write_valid` | input     | 1       | `clock`      |          |             | Write valid signal.<br/>• `0`: no write transaction.<br/>• `1`: write data is valid.    |
| `write_ready` | output    | 1       | `clock`      | `resetn` | `1`         | Write ready signal.<br/>• `0`: buffer is full.<br/>• `1`: buffer can accept write data. |
| `read_data`   | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the buffer.                                                              |
| `read_valid`  | output    | 1       | `clock`      | `resetn` | `0`         | Read valid signal.<br/>• `0`: no read data available.<br/>• `1`: read data is valid.    |
| `read_ready`  | input     | 1       | `clock`      |          |             | Read ready signal.<br/>• `0`: not ready to receive.<br/>• `1`: ready to receive data.   |

## Operation

The valid-ready simple buffer is a wrapper around the read-write enable simple buffer that implements the valid-ready handshake protocol. It stores a single data entry and maintains internal state using the underlying buffer.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The `write_data` is then stored in the buffer and `write_ready` goes low while `read_valid` goes high to indicate the data has been written. The `full` flag goes high and the `empty` flag goes low.

For **read operation**, a read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The data stored in the buffer is available on the `read_data` port, and after the transfer, `read_valid` goes low while `write_ready` goes high to indicate the data has been read. The `empty` flag goes high and the `full` flag goes low.

## Paths

| From          | To            | Type       | Comment                                              |
| ------------- | ------------- | ---------- | ---------------------------------------------------- |
| `write_data`  | `read_data`   | sequential | Data path through internal buffer register.          |
| `write_valid` | `read_valid`  | sequential | Control path through internal buffer_valid register. |
| `write_valid` | `write_ready` | sequential | Control path through internal buffer_valid register. |
| `read_ready`  | `read_valid`  | sequential | Control path through internal buffer_valid register. |
| `read_ready`  | `write_ready` | sequential | Control path through internal buffer_valid register. |

## Complexity

| Delay  | Gates      | Comment |
| ------ | ---------- | ------- |
| `O(1)` | `O(WIDTH)` |         |

The module requires `WIDTH` flip-flops for the data buffer and one flip-flop for the buffer_valid state. The wrapper adds minimal logic for the valid-ready protocol conversion.

## Verification

The valid-ready simple buffer is verified using a SystemVerilog testbench with four check sequences that validate the basic buffer operations and handshake protocol compliance.

The following table lists the checks performed by the testbench.

| Number | Check                | Description                                                                                                              |
| ------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| 1      | Writing to full      | Verifies that writing to an empty buffer sets the `full` flag and clears the `empty` flag correctly.                     |
| 2      | Reading to empty     | Verifies that reading from a full buffer provides correct data and sets the `empty` flag while clearing the `full` flag. |
| 3      | Successive transfers | Performs alternating write and read operations to verify proper data transfer and flag management.                       |
| 4      | Random stimulus      | Performs random write and read operations and verifies data integrity and handshake protocol compliance.                 |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_simple_buffer.v`](valid_ready_simple_buffer.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_simple_buffer.testbench.sv`](valid_ready_simple_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_simple_buffer.testbench.gtkw`](valid_ready_simple_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_simple_buffer.symbol.sss`](valid_ready_simple_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_simple_buffer.symbol.svg`](valid_ready_simple_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_simple_buffer.symbol.drawio`](valid_ready_simple_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_simple_buffer.md`](valid_ready_simple_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                                | Path                                                                | Comment                           |
| --------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------- |
| [`simple_buffer`](../../access_enable/simple_buffer/simple_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/simple_buffer` | Underlying buffer implementation. |

## Related modules

| Module                                                                       | Path                                                                | Comment                                               |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| [`simple_buffer`](../../access_enable/simple_buffer/simple_buffer.md)        | `omnicores-buildingblocks/sources/data/access_enable/simple_buffer` | Base variant with read-write enable flow control.     |
| [`valid_ready_bypass_buffer`](../bypass_buffer/valid_ready_bypass_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/bypass_buffer`   | Single-entry buffer aimed at relieving back-pressure. |
| [`valid_ready_skid_buffer`](../skid_buffer/valid_ready_skid_buffer.md)       | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`     | Two-entry buffer more suited to bus pipelining.       |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                            | `omnicores-buildingblocks/sources/data/valid_ready/fifo`            | Multi-entry first-in-first-out queue.                 |
