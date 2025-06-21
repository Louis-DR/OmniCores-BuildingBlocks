# FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | FIFO                                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![fifo](fifo.symbol.svg)

Synchronous First-In First-Out queue for data buffering and flow control with configurable depth. The FIFO uses a write-enable/read-enable protocol for flow control and provides full and empty status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefuly.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily popping the entry.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                     |
| ------- | ------- | -------------- | ------- | ------------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector.   |
| `DEPTH` | integer | `≥2`           | `4`     | Number of entries in the queue. |

## Ports

| Name           | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                |
| -------------- | --------- | ------- | ------------ | -------- | ----------- | -------------------------------------------------------------------------- |
| `clock`        | input     | 1       | self         |          |             | Clock signal.                                                              |
| `resetn`       | input     | 1       | asynchronous | self     | active-low  | Asynchronous active-low reset.                                             |
| `write_enable` | input     | 1       | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to queue.        |
| `write_data`   | input     | `WIDTH` | `clock`      |          |             | Data to be written to the queue.                                           |
| `full`         | output    | 1       | `clock`      | `resetn` | `0`         | Queue full status.<br/>`0`: queue has free space.<br/>`1`: queue is full.  |
| `read_enable`  | input     | 1       | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from queue.         |
| `read_data`    | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the queue head.                                             |
| `empty`        | output    | 1       | `clock`      | `resetn` | `1`         | Queue empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty. |

## Operation

The FIFO maintains an internal memory array indexed by separate read and write pointers, each with an additional wrap bit for correct full/empty detection.

For **write operation**, when `write_enable` is asserted, `write_data` is stored at the location pointed to by the write pointer, and the write pointer is incremented.

There is no safety mechanism against writing when full. The write pointer will be incremented and surpass the read pointer, overwriting the data at the head, corrupting the full and empty flags, and breaking the FIFO.

For **read operation**, the `read_data` output continuously provides the data at the read pointer location. When `read_enable` is asserted, only the read pointer is incremented to advance to the next entry.

There is no safety mechanism against reading when empty. The read pointer will be incremented and surpass the write pointer, causing the next data written to be lost, corrupting the full and empty flags, and breaking the FIFO.

If the queue is empty, data written can be read in the next cycle. When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

The status flags are calculated based on the read and write pointers. The queue is full if the read and write pointers are the same but the wrap bits are different. The queue is empty if the read and write pointers are the same and the wrap bits are equal.

## Paths

| From           | To          | Type       | Comment                                               |
| -------------- | ----------- | ---------- | ----------------------------------------------------- |
| `write_data`   | `read_data` | sequential | Data path through internal memory array and pointers. |
| `write_enable` | `read_data` | sequential | Data path through internal memory array and pointers. |
| `write_enable` | `full`      | sequential | Control path through internal write pointer.          |
| `write_enable` | `empty`     | sequential | Control path through internal write pointer.          |
| `read_enable`  | `full`      | sequential | Control path through internal read pointer.           |
| `read_enable`  | `empty`     | sequential | Control path through internal read pointer.           |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array and `2×(log₂DEPTH+1)` flip-flops for the read and write pointers with wrap bits.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the memory array indexing with the pointers, the pointer incrementation during read and write operation, and the pointer comparison for the full and empty flags.

## Verification

The FIFO is verified using a SystemVerilog testbench with four check sequences that validate the queue operations and data integrity.

The following table lists the checks performed by the testbench.

| Number | Check                  | Description                                                                                             |
| ------ | ---------------------- | ------------------------------------------------------------------------------------------------------- |
| 1      | Writing to full        | Fills the FIFO completely and verifies the flags.                                                       |
| 2      | Reading to empty       | Empties the FIFO completely and verifies data integrity and the flags.                                  |
| 3      | Back-to-back transfers | Performs simultaneous read and write operations to verify full throughput capability without data loss. |
| 4      | Random stimulus        | Performs random write and read operations and verifies data integrity against a reference queue model.  |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 4       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                         | Description                                         |
| ----------------- | -------------------------------------------- | --------------------------------------------------- |
| Design            | [`fifo.v`](fifo.v)                           | Verilog design.                                     |
| Testbench         | [`fifo.testbench.sv`](fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`fifo.testbench.gtkw`](fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`fifo.symbol.sss`](fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`fifo.symbol.svg`](fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`fifo.md`](fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                           | Path                                                                        | Comment                                                         |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_fifo`](../../valid_ready/fifo/valid_ready_fifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/fifo`                    | Variant of this module with valid-ready handshake flow control. |
| [`asynchronous_fifo`](../asynchronous_fifo/asynchronous_fifo.md) | `omnicores-buildingblocks/sources/data/read_write_enable/asynchronous_fifo` | Asynchronous FIFO for crossing clock domains.                   |
| [`advanced_fifo`](../advanced_fifo/advanced_fifo.md)             | `omnicores-buildingblocks/sources/data/read_write_enable/advanced_fifo`     | FIFO with additional features and protection mechanisms.        |
| [`simple_buffer`](../simple_buffer/simple_buffer.md)             | `omnicores-buildingblocks/sources/data/read_write_enable/simple_buffer`     | Single-entry buffer for storage.                                |
| [`skid_buffer`](../skid_buffer/skid_buffer.md)                   | `omnicores-buildingblocks/sources/data/read_write_enable/skid_buffer`       | Two-entry buffer for simple bus pipelining.                     |
