# Valid-Ready Advanced FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Advanced FIFO                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_advanced_fifo](valid_ready_advanced_fifo.symbol.svg)

Advanced synchronous First-In First-Out queue with comprehensive monitoring features and valid-ready handshake flow control. This enhanced FIFO provides level monitoring, dynamic threshold flags, flush functionality, and error protection mechanisms. The handshake protocol ensures that transfers only occur when both valid and ready signals are asserted, automatically managing flow control without external enable logic.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily consuming the entry.

## Parameters

| Name         | Type    | Allowed Values | Default       | Description                                     |
| ------------ | ------- | -------------- | ------------- | ----------------------------------------------- |
| `WIDTH`      | integer | `≥1`           | `8`           | Bit width of the data vector.                   |
| `DEPTH`      | integer | `≥2`           | `4`           | Number of entries in the queue.                 |
| `DEPTH_LOG2` | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated). |

## Ports

| Name                     | Direction | Width          | Clock        | Reset    | Reset value | Description                                                                       |
| ------------------------ | --------- | -------------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------- |
| `clock`                  | input     | 1              | self         |          |             | Clock signal.                                                                     |
| `resetn`                 | input     | 1              | asynchronous | self     | `0`         | Asynchronous active-low reset.                                                    |
| `flush`                  | input     | 1              | `clock`      |          |             | Flush control.<br/>`0`: normal operation.<br/>`1`: flush queue to empty state.    |
| `write_data`             | input     | `WIDTH`        | `clock`      |          |             | Data to be written to the queue.                                                  |
| `write_valid`            | input     | 1              | `clock`      |          |             | Write valid signal.<br/>`0`: no write transaction.<br/>`1`: write data is valid.  |
| `write_ready`            | output    | 1              | `clock`      | `resetn` | `1`         | Write ready signal.<br/>`0`: queue is full.<br/>`1`: queue can accept write data. |
| `read_data`              | output    | `WIDTH`        | `clock`      | `resetn` | `0`         | Data read from the queue head.                                                    |
| `read_valid`             | output    | 1              | `clock`      | `resetn` | `0`         | Read valid signal.<br/>`0`: no read data available.<br/>`1`: read data is valid.  |
| `read_ready`             | input     | 1              | `clock`      |          |             | Read ready signal.<br/>`0`: not ready to receive.<br/>`1`: ready to receive data. |
| `full`                   | output    | 1              | `clock`      | `resetn` | `0`         | Queue full status.<br/>`0`: queue has free space.<br/>`1`: queue is full.         |
| `empty`                  | output    | 1              | `clock`      | `resetn` | `1`         | Queue empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty.        |
| `level`                  | output    | `DEPTH_LOG2+1` | `clock`      | `resetn` | `0`         | Current number of entries in the queue.                                           |
| `lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Lower threshold level for comparison.                                             |
| `lower_threshold_status` | output    | 1              | `clock`      | `resetn` | `1`         | Lower threshold status.<br/>`1`: level ≤ threshold.                               |
| `upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Upper threshold level for comparison.                                             |
| `upper_threshold_status` | output    | 1              | `clock`      | `resetn` | `0`         | Upper threshold status.<br/>`1`: level ≥ threshold.                               |

## Operation

The valid-ready advanced FIFO is a wrapper around the read-write enable advanced FIFO that implements the valid-ready handshake protocol. It maintains an internal memory array indexed by separate read and write pointers while providing comprehensive monitoring capabilities.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The `write_data` is stored at the location pointed to by the write pointer, and the write pointer is incremented.

For **read operation**, a read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The `read_data` output continuously provides the data at the read pointer location, and after the transfer, only the read pointer is incremented to advance to the next entry.

**Level monitoring** continuously tracks the number of entries in the queue using the `level` output. This is calculated by comparing the read and write pointers with wrap bit considerations.

**Dynamic thresholds** allow runtime configuration of upper and lower bounds for queue occupancy. The `lower_threshold_status` is asserted when the level is at or below the `lower_threshold_level`, and the `upper_threshold_status` is asserted when the level is at or above the `upper_threshold_level`.

**Flush functionality** allows immediate emptying of the queue by asserting the `flush` input. This moves the read pointer to match the write pointer, effectively discarding all stored data.

When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

## Paths

| From                    | To                       | Type          | Comment                                               |
| ----------------------- | ------------------------ | ------------- | ----------------------------------------------------- |
| `write_data`            | `read_data`              | sequential    | Data path through internal memory array and pointers. |
| `write_valid`           | `read_valid`             | sequential    | Control path through internal pointers.               |
| `write_valid`           | `write_ready`            | sequential    | Control path through internal pointers.               |
| `read_ready`            | `read_valid`             | sequential    | Control path through internal pointers.               |
| `read_ready`            | `write_ready`            | sequential    | Control path through internal pointers.               |
| `write_valid`           | `level`                  | sequential    | Control path through internal pointers.               |
| `read_ready`            | `level`                  | sequential    | Control path through internal pointers.               |
| `flush`                 | `level`                  | sequential    | Control path through internal pointers.               |
| `lower_threshold_level` | `lower_threshold_status` | combinational | Direct comparison with level.                         |
| `upper_threshold_level` | `upper_threshold_status` | combinational | Direct comparison with level.                         |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `2×(log₂DEPTH+1)` flip-flops for the read and write pointers with wrap bits, and additional logic for level calculation and threshold comparisons. The wrapper adds minimal logic for the valid-ready protocol conversion.

## Verification

The valid-ready advanced FIFO is verified using a SystemVerilog testbench with comprehensive check sequences that validate all advanced features including level monitoring, threshold operations, and flush functionality with a handshake protocol compliance.

The following table lists the checks performed by the testbench.

| Number | Check                  | Description                                                                                              |
| ------ | ---------------------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Writing to full        | Fills the FIFO completely and verifies level tracking and flags.                                         |
| 2      | Reading to empty       | Empties the FIFO completely and verifies data integrity, level tracking, and flags.                      |
| 3      | Back-to-back transfers | Performs simultaneous read and write operations to verify full throughput capability and level accuracy. |
| 4      | Upper threshold        | Tests upper threshold detection at various fill levels.                                                  |
| 5      | Lower threshold        | Tests lower threshold detection at various fill levels.                                                  |
| 6      | Flush functionality    | Verifies that flush immediately empties the queue and updates all status outputs correctly.              |
| 7      | Random stimulus        | Performs random write, read, and threshold operations and verifies data integrity and level accuracy.    |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 4       | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_advanced_fifo.v`](valid_ready_advanced_fifo.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_advanced_fifo.testbench.sv`](valid_ready_advanced_fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_advanced_fifo.testbench.gtkw`](valid_ready_advanced_fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_advanced_fifo.symbol.sss`](valid_ready_advanced_fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_advanced_fifo.symbol.svg`](valid_ready_advanced_fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`valid_ready_advanced_fifo.md`](valid_ready_advanced_fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                                    | Path                                                                    | Comment                                  |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------- |
| [`advanced_fifo`](../../read_write_enable/advanced_fifo/advanced_fifo.md) | `omnicores-buildingblocks/sources/data/read_write_enable/advanced_fifo` | Underlying advanced FIFO implementation. |

## Related modules

| Module                                                                                                              | Path                                                                           | Comment                                                |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------------ |
| [`advanced_fifo`](../../read_write_enable/advanced_fifo/advanced_fifo.md)                                           | `omnicores-buildingblocks/sources/data/read_write_enable/advanced_fifo`        | Base variant with read-write enable flow control.      |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                                                                   | `omnicores-buildingblocks/sources/data/valid_ready/fifo`                       | Basic FIFO without advanced monitoring features.       |
| [`valid_ready_asynchronous_advanced_fifo`](../asynchronous_advanced_fifo/valid_ready_asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/asynchronous_advanced_fifo` | Asynchronous advanced FIFO for crossing clock domains. |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md)                                        | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`              | Single-entry buffer for storage.                       |
| [`valid_ready_skid_buffer`](../skid_buffer/valid_ready_skid_buffer.md)                                              | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`                | Two-entry buffer for simple bus pipelining.            |
