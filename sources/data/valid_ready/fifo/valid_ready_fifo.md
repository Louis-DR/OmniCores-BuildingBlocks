# Valid-Ready FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready FIFO                                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_fifo](valid_ready_fifo.symbol.svg)

Synchronous First-In First-Out queue for data buffering and flow control with configurable depth and valid-ready handshake flow control. The FIFO provides full and empty status flags and implements a handshake protocol where transfers only occur when both valid and ready signals are asserted. The handshake protocol manages and protects flow control, eliminating the need for external enable logic.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily popping the entry. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                     |
| ------- | ------- | -------------- | ------- | ------------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector.   |
| `DEPTH` | integer | `≥2`           | `4`     | Number of entries in the queue. |

## Ports

| Name          | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                       |
| ------------- | --------- | ------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------- |
| `clock`       | input     | 1       | self         |          |             | Clock signal.                                                                     |
| `resetn`      | input     | 1       | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                    |
| `write_data`  | input     | `WIDTH` | `clock`      |          |             | Data to be written to the queue.                                                  |
| `write_valid` | input     | 1       | `clock`      |          |             | Write valid signal.<br/>`0`: no write transaction.<br/>`1`: write data is valid.  |
| `write_ready` | output    | 1       | `clock`      | `resetn` | `1`         | Write ready signal.<br/>`0`: queue is full.<br/>`1`: queue can accept write data. |
| `full`        | output    | 1       | `clock`      | `resetn` | `0`         | Queue full status.<br/>`0`: queue has free space.<br/>`1`: queue is full.         |
| `read_data`   | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the queue head.                                                    |
| `read_valid`  | output    | 1       | `clock`      | `resetn` | `0`         | Read valid signal.<br/>`0`: no read data available.<br/>`1`: read data is valid.  |
| `read_ready`  | input     | 1       | `clock`      |          |             | Read ready signal.<br/>`0`: not ready to receive.<br/>`1`: ready to receive data. |
| `empty`       | output    | 1       | `clock`      | `resetn` | `1`         | Queue empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty.        |

## Operation

The valid-ready FIFO is a wrapper around the read-write enable FIFO that implements the valid-ready handshake protocol. It maintains an internal memory array indexed by separate read and write pointers.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The `write_data` is stored at the location pointed to by the write pointer, and the write pointer is incremented.

For **read operation**, a read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The `read_data` output continuously provides the data at the read pointer location, and after the transfer, only the read pointer is incremented to advance to the next entry.

If the queue is empty, data written can be read in the next cycle. When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

The status flags are calculated based on the read and write pointers. The queue is full if the read and write pointers are the same but the wrap bits are different. The queue is empty if the read and write pointers are the same and the wrap bits are equal.

## Paths

| From          | To            | Type       | Comment                                               |
| ------------- | ------------- | ---------- | ----------------------------------------------------- |
| `write_data`  | `read_data`   | sequential | Data path through internal memory array and pointers. |
| `write_valid` | `read_valid`  | sequential | Control path through internal pointers.               |
| `write_valid` | `write_ready` | sequential | Control path through internal pointers.               |
| `read_ready`  | `read_valid`  | sequential | Control path through internal pointers.               |
| `read_ready`  | `write_ready` | sequential | Control path through internal pointers.               |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array and `2×(log₂DEPTH+1)` flip-flops for the read and write pointers with wrap bits. The wrapper adds minimal logic for the valid-ready protocol conversion.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the memory array indexing with the pointers, the pointer incrementation during read and write operation, and the pointer comparison for the full and empty flags.

## Verification

The valid-ready FIFO is verified using a SystemVerilog testbench with four check sequences that validate the queue operations and data integrity with a handshake protocol compliance.

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

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_fifo.v`](valid_ready_fifo.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_fifo.testbench.sv`](valid_ready_fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_fifo.testbench.gtkw`](valid_ready_fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_fifo.symbol.sss`](valid_ready_fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_fifo.symbol.svg`](valid_ready_fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_fifo.symbol.drawio`](valid_ready_fifo.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_fifo.md`](valid_ready_fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                         | Path                                                           | Comment                         |
| ---------------------------------------------- | -------------------------------------------------------------- | ------------------------------- |
| [`fifo`](../../read_write_enable/fifo/fifo.md) | `omnicores-buildingblocks/sources/data/read_write_enable/fifo` | Underlying FIFO implementation. |

## Related modules

| Module                                                                                   | Path                                                                  | Comment                                                  |
| ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------------------------------------------------------- |
| [`fifo`](../../read_write_enable/fifo/fifo.md)                                           | `omnicores-buildingblocks/sources/data/read_write_enable/fifo`        | Base variant with read-write enable flow control.        |
| [`valid_ready_advanced_fifo`](../advanced_fifo/valid_ready_advanced_fifo.md)             | `omnicores-buildingblocks/sources/data/valid_ready/advanced_fifo`     | FIFO with additional features and protection mechanisms. |
| [`valid_ready_asynchronous_fifo`](../asynchronous_fifo/valid_ready_asynchronous_fifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/asynchronous_fifo` | Asynchronous FIFO for crossing clock domains.            |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md)             | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`     | Single-entry buffer for storage.                         |
| [`valid_ready_skid_buffer`](../skid_buffer/valid_ready_skid_buffer.md)                   | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`       | Two-entry buffer for simple bus pipelining.              |
