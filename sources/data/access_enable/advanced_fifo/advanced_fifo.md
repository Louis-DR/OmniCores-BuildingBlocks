# Advanced FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Advanced FIFO                                                                    |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![advanced_fifo](advanced_fifo.symbol.svg)

Advanced synchronous First-In First-Out queue with enhanced features including protection mechanisms, error reporting, extended status flags, level monitoring, and dynamic thresholds.

The design is structured as a modular architecture with a separate controller for pointer management, status logic, and protection mechanisms, and a generic simple dual-port RAM for data storage. This allows easy replacement of the memory with technology-specific implementations during ASIC integration.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily consuming the entry. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name         | Type    | Allowed Values | Default       | Description                                                 |
| ------------ | ------- | -------------- | ------------- | ----------------------------------------------------------- |
| `WIDTH`      | integer | `≥1`           | `8`           | Bit width of the data vector.                               |
| `DEPTH`      | integer | `≥2`           | `4`           | Number of entries in the queue. Non-power-of-two supported. |
| `DEPTH_LOG2` | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated).             |

## Ports

| Name                     | Direction | Width          | Clock        | Reset    | Reset value | Description                                                                                                                      |
| ------------------------ | --------- | -------------- | ------------ | -------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `clock`                  | input     | 1              | self         |          |             | Clock signal.                                                                                                                    |
| `resetn`                 | input     | 1              | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                                                   |
| `flush`                  | input     | 1              | `clock`      |          |             | Flush control.<br/>• `0`: idle.<br/>• `1`: empty FIFO by advancing read to write pointer.                                        |
| `write_enable`           | input     | 1              | `clock`      |          |             | Write enable signal.<br/>• `0`: idle.<br/>• `1`: write (push) to queue.                                                          |
| `write_data`             | input     | `WIDTH`        | `clock`      |          |             | Data to be written to the queue.                                                                                                 |
| `write_miss`             | output    | 1              | `clock`      | `resetn` | `0`         | Write protection pulse notification.<br/>• `0`: no error.<br/>• `1`: write attempted when full.                                  |
| `read_enable`            | input     | 1              | `clock`      |          |             | Read enable signal.<br/>• `0`: idle.<br/>• `1`: read (pop) from queue.                                                           |
| `read_data`              | output    | `WIDTH`        | `clock`      | `resetn` | `0`         | Data read from the queue head.                                                                                                   |
| `read_error`             | output    | 1              | `clock`      | `resetn` | `0`         | Read protection pulse notification.<br/>• `0`: no error.<br/>• `1`: read attempted when empty.                                   |
| `empty`                  | output    | 1              | `clock`      | `resetn` | `1`         | Queue empty status.<br/>• `0`: queue contains data.<br/>• `1`: queue is empty.                                                   |
| `almost_empty`           | output    | 1              | `clock`      | `resetn` | `0`         | Queue almost empty status.<br/>• `0`: queue is empty or has more than one entry.<br/>• `1`: queue has exactly one entry.         |
| `half_empty`             | output    | 1              | `clock`      | `resetn` | `0`         | Queue half empty status.<br/>• `0`: queue half full.<br/>• `1`: queue half empty.                                                |
| `not_empty`              | output    | 1              | `clock`      | `resetn` | `0`         | Queue not empty status.<br/>• `0`: queue is empty.<br/>• `1`: queue contains data.                                               |
| `not_full`               | output    | 1              | `clock`      | `resetn` | `1`         | Queue not full status.<br/>• `0`: queue is full.<br/>• `1`: queue has free space.                                                |
| `half_full`              | output    | 1              | `clock`      | `resetn` | `0`         | Queue half full status.<br/>• `0`: queue half empty.<br/>• `1`: queue half full.                                                 |
| `almost_full`            | output    | 1              | `clock`      | `resetn` | `0`         | Queue almost full status.<br/>• `0`: queue is full or has more than one free space.<br/>• `1`: queue has exactly one free space. |
| `full`                   | output    | 1              | `clock`      | `resetn` | `0`         | Queue full status.<br/>• `0`: queue has free space.<br/>• `1`: queue is full.                                                    |
| `level`                  | output    | `DEPTH_LOG2+1` | `clock`      | `resetn` | `0`         | Current number of entries in the queue.                                                                                          |
| `space`                  | output    | `DEPTH_LOG2+1` | `clock`      | `resetn` | `0`         | Current number of free entries in the queue.                                                                                     |
| `lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Lower threshold level for comparison.                                                                                            |
| `lower_threshold_status` | output    | 1              | `clock`      | `resetn` | `1`         | Lower threshold status.<br/>• `0`: level > threshold.<br/>• `1`: level ≤ threshold.                                              |
| `upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Upper threshold level for comparison.                                                                                            |
| `upper_threshold_status` | output    | 1              | `clock`      | `resetn` | `0`         | Upper threshold status.<br/>• `0`: level < threshold.<br/>• `1`: level ≥ threshold.                                              |

## Operation

The FIFO consists of two main components: a controller that manages pointers, status logic, and protection mechanisms, and a simple dual-port RAM for data storage.

The **controller** maintains separate read and write pointers, each with an additional lap bit for correct level calculation, implemented with `advanced_wrapping_counter`. It generates the memory interface signals, calculates all status flags and thresholds, implements protection mechanisms, and generates error notifications. The controller doesn't store any data, only control state.

The **simple dual-port RAM** provides independent read and write ports with combinational reads, allowing the data at the read address to appear immediately on the read data output.

For **write operation**, when `write_enable` is asserted, the controller directs the RAM to store `write_data` at the location pointed to by the write pointer, and the write pointer is incremented. Writing when full is ignored and the data is lost.

The write safety mechanism prevents writing when full. The write will be ignored, the pointers will not be updated, and the data will be lost. The `write_miss` pulse notification will assert for one clock cycle to signal the error, then automatically clear. The FIFO can continue operating normally.

For **read operation**, the `read_data` output continuously provides the data at the read pointer location from the RAM. When `read_enable` is asserted, only the read pointer is incremented to advance to the next entry.

The read safety mechanism prevents reading when empty. The `read_data` will be invalid and the pointers will not be updated. The `read_error` pulse notification will assert for one clock cycle to signal the error, then automatically clear. The FIFO can continue operating normally.

If the queue is empty, data written can be read in the next cycle. When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

The level, status, and threshold outputs are calculated based on the read and write pointers.

Asserting the `flush` input empties the whole FIFO at the next rising edge of the clock by advancing the read pointer to the write pointer. During a flush cycle, read and write pointer increments are gated so no entry is consumed or written concurrently.

## Paths

| From                    | To                                                                                                                                   | Type          | Comment                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------- | ---------------------------------------- |
| `write_data`            | `read_data`                                                                                                                          | sequential    | Data path through internal memory array. |
| `write_enable`          | `read_data`                                                                                                                          | sequential    | Data path through internal memory array. |
| `write_enable`          | `write_miss`                                                                                                                         | sequential    | Control path for protection mechanism.   |
| `write_enable`          | `level`, `empty`, `not_empty`, `almost_empty`, `full`, `not_full`, `almost_full`, `lower_threshold_status`, `upper_threshold_status` | sequential    | Control path through internal pointers.  |
| `read_enable`           | `read_error`                                                                                                                         | sequential    | Control path for protection mechanism.   |
| `read_enable`           | `level`, `empty`, `not_empty`, `almost_empty`, `full`, `not_full`, `almost_full`, `lower_threshold_status`, `upper_threshold_status` | sequential    | Control path through internal pointers.  |
| `flush`                 | `level`, `empty`, `not_empty`, `almost_empty`, `full`, `not_full`, `almost_full`, `lower_threshold_status`, `upper_threshold_status` | sequential    | Control path through internal pointers.  |
| `lower_threshold_level` | `lower_threshold_status`                                                                                                             | combinational | Direct comparison with current level.    |
| `upper_threshold_level` | `upper_threshold_status`                                                                                                             | combinational | Direct comparison with current level.    |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `2×(log₂DEPTH+1)` flip-flops for pointers, and additional flip-flops for error flags and protection logic.

## Verification

The advanced FIFO is verified using a SystemVerilog testbench with comprehensive check sequences that validate all enhanced features.

The following table lists the checks performed by the testbench.

| Number | Check                  | Description                                                                                             |
| ------ | ---------------------- | ------------------------------------------------------------------------------------------------------- |
| 1      | Writing to full        | Fills the FIFO completely and verifies the flags.                                                       |
| 2      | Write miss             | Write when full and check the write protection mechanism.                                               |
| 3      | Reading to empty       | Empties the FIFO completely and verifies data integrity and the flags.                                  |
| 4      | Read error             | Read when empty and check the read protection mechanism.                                                |
| 5      | Flushing               | Verifies flush functionality.                                                                           |
| 6      | Back-to-back transfers | Performs simultaneous read and write operations to verify full throughput capability without data loss. |
| 7      | Random stimulus        | Performs random write and read operations and verifies data integrity against a reference queue model.  |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 4       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                           | Description                                         |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`advanced_fifo.v`](advanced_fifo.v)                           | Verilog design.                                     |
| Testbench         | [`advanced_fifo.testbench.sv`](advanced_fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`advanced_fifo.testbench.gtkw`](advanced_fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`advanced_fifo.symbol.sss`](advanced_fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`advanced_fifo.symbol.svg`](advanced_fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`advanced_fifo.symbol.drawio`](advanced_fifo.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`advanced_fifo.md`](advanced_fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                     | Path                                                              | Comment                                                      |
| -------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------ |
| `advanced_fifo_controller` | `omnicores-buildingblocks/sources/data/controllers/advanced_fifo` | Controller for pointers, status flags, and protection logic. |
| `simple_dual_port_ram`     | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram`    | Dual-port RAM for data storage.                              |

## Related modules

| Module                                                                                      | Path                                                                             | Comment                                                         |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_advanced_fifo`](../../valid_ready/advanced_fifo/valid_ready_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/advanced_fifo`                | Variant of this module with valid-ready handshake flow control. |
| [`fifo`](../fifo/fifo.md)                                                                   | `omnicores-buildingblocks/sources/data/access_enable/fifo`                       | Basic FIFO without advanced features or protection.             |
| [`asynchronous_fifo`](../asynchronous_fifo/asynchronous_fifo.md)                            | `omnicores-buildingblocks/sources/data/access_enable/asynchronous_fifo`          | Basic asynchronous FIFO for clock domain crossing.              |
| [`asynchronous_advanced_fifo`](../asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/access_enable/asynchronous_advanced_fifo` | Advanced asynchronous FIFO for crossing clock domains.          |
