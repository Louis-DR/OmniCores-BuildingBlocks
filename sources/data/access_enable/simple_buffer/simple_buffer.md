# Simple Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Simple Buffer                                                                    |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![simple_buffer](simple_buffer.symbol.svg)

Single-entry data buffer for storage. The buffer uses a write-enable/read-enable protocol for flow control and provides full and empty status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefuly.

When used for bus pipelining, either back-to-back transactions work on a period of two cycles - one for write then one for read - and the throughput is half of the clock frequency, or the write agent only writes when the buffer is empty or full and being read - thus creating a combinational path on the control signals.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector. |

## Ports

| Name           | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                             |
| -------------- | --------- | ------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------- |
| `clock`        | input     | 1       | self         |          |             | Clock signal.                                                                           |
| `resetn`       | input     | 1       | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                          |
| `full`         | output    | 1       | `clock`      | `resetn` | `0`         | Buffer full status.<br/>• `0`: buffer is empty.<br/>• `1`: buffer contains valid data.  |
| `empty`        | output    | 1       | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>• `0`: buffer contains valid data.<br/>• `1`: buffer is empty. |
| `write_enable` | input     | 1       | `clock`      |          |             | Write enable signal.<br/>• `0`: idle.<br/>• `1`: write `write_data` to buffer.          |
| `write_data`   | input     | `WIDTH` | `clock`      |          |             | Data to be written to the buffer.                                                       |
| `read_enable`  | input     | 1       | `clock`      |          |             | Read enable signal.<br/>• `0`: idle.<br/>• `1`: read data from buffer.                  |
| `read_data`    | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the buffer.                                                              |

## Operation

The simple buffer stores a single data entry and maintains internal state using a `buffer_valid` flag. The `full` and `empty` status flags are complementary and derived from `buffer_valid`.

For **write operation**, when `write_enable` is asserted (high), the `write_data` is stored in the `buffer` register and `buffer_valid` is set to high. The `full` flag goes high and the `empty` flag goes low to indicate the data has been written. There is no safety mechanism to

There is no safety mechanism against writing when full, the data stored in the buffer will be overwritten and the buffer will continue working as expected.

For **read operation**, the data stored in the `buffer` register is always output on the `read_data` port, and when `read_enable` is asserted (high), the `buffer_valid` is set to low. The `empty` flag goes high and the `full` flag goes low to indicate the data has been read.

There is no safety mechanism against reading when empty, and the actual `buffer` register is not cleared after a read so the last stored data is still on the output. Reading when empty will thus be ignored and the buffer will continue working as expected.

If the buffer is full and both `write_enable` and `read_enable` are asserted in the same cycle, then the data stored is replaced at the next clock rising edge and the buffer stays full. However, for a datapath, that means there must be a combinational path from `read_enable` to `write_enable` to ensure the data is not overwritten. For a buffer that breaks the timing path between read and write and supports back-to-back transactions, the `skid_buffer` can be used instead.

## Paths

| From           | To          | Type       | Comment                                                |
| -------------- | ----------- | ---------- | ------------------------------------------------------ |
| `write_data`   | `read_data` | sequential | Data path through internal `buffer` register.          |
| `write_enable` | `full`      | sequential | Control path through internal `buffer_valid` register. |
| `write_enable` | `empty`     | sequential | Control path through internal `buffer_valid` register. |
| `read_enable`  | `full`      | sequential | Control path through internal `buffer_valid` register. |
| `read_enable`  | `empty`     | sequential | Control path through internal `buffer_valid` register. |

## Complexity

| Delay  | Gates        | Comment |
| ------ | ------------ | ------- |
| `O(1)` | `O(WIDTH+1)` |         |

The module requires `WIDTH` flip-flops for the data buffer and one flip-flop for the `buffer_valid` state.

## Verification

The simple buffer is verified using a SystemVerilog testbench with four check sequences that validate the basic buffer operations and protocol compliance.

The following table lists the checks performed by the testbench.

| Number | Check                | Description                                                                                                              |
| ------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| 1      | Writing to full      | Verifies that writing to an empty buffer sets the `full` flag and clears the `empty` flag correctly.                     |
| 2      | Reading to empty     | Verifies that reading from a full buffer provides correct data and sets the `empty` flag while clearing the `full` flag. |
| 3      | Successive transfers | Performs alternating write and read operations to verify proper data transfer and flag management.                       |
| 4      | Random stimulus      | Performs random write and read operations and verifies data integrity and protocol compliance.                           |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                           | Description                                         |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`simple_buffer.v`](simple_buffer.v)                           | Verilog design.                                     |
| Testbench         | [`simple_buffer.testbench.sv`](simple_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`simple_buffer.testbench.gtkw`](simple_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`simple_buffer.symbol.sss`](simple_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`simple_buffer.symbol.svg`](simple_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`simple_buffer.symbol.drawio`](simple_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`simple_buffer.md`](simple_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                          | Path                                                                | Comment                                                         |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_simple_buffer`](../../valid_ready/simple_buffer/simple_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`   | Variant of this module with valid-ready handshake flow control. |
| [`bypass_buffer`](../bypass_buffer/bypass_buffer.md)                            | `omnicores-buildingblocks/sources/data/access_enable/bypass_buffer` | Single-entry buffer aimed at relieving back-pressure.           |
| [`skid_buffer`](../skid_buffer/skid_buffer.md)                                  | `omnicores-buildingblocks/sources/data/access_enable/skid_buffer`   | Two-entry buffer more suited to bus pipelining.                 |
| [`fifo`](../fifo/fifo.md)                                                       | `omnicores-buildingblocks/sources/data/access_enable/fifo`          | Multi-entry first-in-first-out queue.                           |
