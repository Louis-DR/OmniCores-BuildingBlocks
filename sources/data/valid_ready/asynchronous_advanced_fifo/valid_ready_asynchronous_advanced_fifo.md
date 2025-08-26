# Valid-Ready Asynchronous Advanced FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Asynchronous Advanced FIFO                                           |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_asynchronous_advanced_fifo](valid_ready_asynchronous_advanced_fifo.symbol.svg)

Advanced asynchronous First-In First-Out queue that combines clock domain crossing capabilities with comprehensive monitoring features and valid-ready handshake flow control. The FIFO operates with separate write and read clock domains while providing enhanced status information, level monitoring, dynamic thresholds, and flush functionality in both domains. The handshake protocol ensures that transfers only occur when both valid and ready signals are asserted, automatically managing flow control in each clock domain.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily consuming the entry. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name           | Type    | Allowed Values | Default       | Description                                     |
| -------------- | ------- | -------------- | ------------- | ----------------------------------------------- |
| `WIDTH`        | integer | `≥1`           | `8`           | Bit width of the data vector.                   |
| `DEPTH`        | integer | `≥2`           | `4`           | Number of entries in the queue.                 |
| `DEPTH_LOG2`   | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated). |
| `STAGES_WRITE` | integer | `≥1`           | `2`           | Number of synchronizer stages for write domain. |
| `STAGES_READ`  | integer | `≥1`           | `2`           | Number of synchronizer stages for read domain.  |

## Ports

| Name                           | Direction | Width          | Clock         | Reset          | Reset value | Description                                                                                |
| ------------------------------ | --------- | -------------- | ------------- | -------------- | ----------- | ------------------------------------------------------------------------------------------ |
| `write_clock`                  | input     | 1              | self          |                |             | Write domain clock signal.                                                                 |
| `write_resetn`                 | input     | 1              | asynchronous  | self           | active-low  | Write domain asynchronous active-low reset.                                                |
| `write_flush`                  | input     | 1              | `write_clock` |                |             | Write domain flush control.<br/>`0`: normal operation.<br/>`1`: flush queue to read state. |
| `write_data`                   | input     | `WIDTH`        | `write_clock` |                |             | Data to be written to the queue.                                                           |
| `write_valid`                  | input     | 1              | `write_clock` |                |             | Write valid signal.<br/>`0`: no write transaction.<br/>`1`: write data is valid.           |
| `write_ready`                  | output    | 1              | `write_clock` | `write_resetn` | `1`         | Write ready signal.<br/>`0`: queue is full.<br/>`1`: queue can accept write data.          |
| `write_full`                   | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain full status.<br/>`0`: queue has space.<br/>`1`: queue is full.                |
| `write_level`                  | output    | `DEPTH_LOG2+1` | `write_clock` | `write_resetn` | `0`         | Write domain current number of entries in the queue.                                       |
| `write_lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Write domain lower threshold level for comparison.                                         |
| `write_lower_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `1`         | Write domain lower threshold status.<br/>`1`: level ≤ threshold.                           |
| `write_upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Write domain upper threshold level for comparison.                                         |
| `write_upper_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain upper threshold status.<br/>`1`: level ≥ threshold.                           |
| `read_clock`                   | input     | 1              | self          |                |             | Read domain clock signal.                                                                  |
| `read_resetn`                  | input     | 1              | asynchronous  | self           | active-low  | Read domain asynchronous active-low reset.                                                 |
| `read_flush`                   | input     | 1              | `read_clock`  |                |             | Read domain flush control.<br/>`0`: normal operation.<br/>`1`: flush queue to write state. |
| `read_data`                    | output    | `WIDTH`        | `read_clock`  | `read_resetn`  | `0`         | Data read from the queue head.                                                             |
| `read_valid`                   | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read valid signal.<br/>`0`: no read data available.<br/>`1`: read data is valid.           |
| `read_ready`                   | input     | 1              | `read_clock`  |                |             | Read ready signal.<br/>`0`: not ready to receive.<br/>`1`: ready to receive data.          |
| `read_empty`                   | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Read domain empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty.           |
| `read_level`                   | output    | `DEPTH_LOG2+1` | `read_clock`  | `read_resetn`  | `0`         | Read domain current number of entries in the queue.                                        |
| `read_lower_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Read domain lower threshold level for comparison.                                          |
| `read_lower_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Read domain lower threshold status.<br/>`1`: level ≤ threshold.                            |
| `read_upper_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Read domain upper threshold level for comparison.                                          |
| `read_upper_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain upper threshold status.<br/>`1`: level ≥ threshold.                            |

## Operation

The valid-ready asynchronous advanced FIFO is a wrapper around the read-write enable asynchronous advanced FIFO that implements the valid-ready handshake protocol. It maintains an internal memory array indexed by separate read and write pointers operating in their respective clock domains while providing comprehensive monitoring capabilities.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same `write_clock` rising edge. The `write_data` is stored at the location pointed to by the write pointer, and the write pointer is incremented. The Gray-coded write pointer is synchronized to the read domain for safe clock domain crossing and level calculations.

For **read operation**, a read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same `read_clock` rising edge. The `read_data` output continuously provides the data at the read pointer location, and after the transfer, only the read pointer is incremented to advance to the next entry. The Gray-coded read pointer is synchronized to the write domain.

**Clock domain crossing** is handled by synchronizing Gray-coded pointers between domains using multi-stage synchronizers. Gray coding ensures that only one bit changes at a time, preventing metastability issues during clock domain crossing.

**Level monitoring** continuously tracks the number of entries in the queue using separate `write_level` and `read_level` outputs. Each domain calculates its level based on local pointers and synchronized pointers from the other domain.

**Dynamic thresholds** allow runtime configuration of upper and lower bounds for queue occupancy in each domain. The threshold status outputs are asserted when the level meets the threshold conditions, enabling advanced flow control strategies.

**Flush functionality** allows immediate queue control from either domain. Write domain flush synchronizes the write pointer to the read pointer state, while read domain flush synchronizes the read pointer to the write pointer state.

The status outputs are calculated based on the local pointers and the synchronized pointers from the other domain. The `write_full` flag prevents further writes, and the `read_empty` flag indicates no data availability.

## Paths

| From                          | To                             | Type           | Comment                                                              |
| ----------------------------- | ------------------------------ | -------------- | -------------------------------------------------------------------- |
| `write_data`                  | `read_data`                    | sequential     | Data path through shared memory array.                               |
| `write_valid`                 | `write_ready`                  | sequential     | Control path through write domain write pointer.                     |
| `write_valid`                 | `read_valid`                   | sequential CDC | Control path through read domain write pointer with synchronization. |
| `read_ready`                  | `read_valid`                   | sequential     | Control path through read domain read pointer.                       |
| `read_ready`                  | `write_ready`                  | sequential CDC | Control path through write domain read pointer with synchronization. |
| `write_valid`                 | `write_level`                  | sequential     | Control path through write domain pointers.                          |
| `read_ready`                  | `read_level`                   | sequential     | Control path through read domain pointers.                           |
| `write_flush`                 | `write_level`                  | sequential     | Control path through write domain pointers.                          |
| `read_flush`                  | `read_level`                   | sequential     | Control path through read domain pointers.                           |
| `write_lower_threshold_level` | `write_lower_threshold_status` | combinational  | Direct comparison with write domain level.                           |
| `write_upper_threshold_level` | `write_upper_threshold_status` | combinational  | Direct comparison with write domain level.                           |
| `read_lower_threshold_level`  | `read_lower_threshold_status`  | combinational  | Direct comparison with read domain level.                            |
| `read_upper_threshold_level`  | `read_upper_threshold_status`  | combinational  | Direct comparison with read domain level.                            |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `4×(log₂DEPTH+1)` flip-flops for binary and Gray pointers in both domains, and `2×(log₂DEPTH+1)×(STAGES_WRITE+STAGES_READ)` flip-flops for the synchronizers, plus additional logic for advanced features. The wrapper adds minimal logic for the valid-ready protocol conversion.

## Verification

The valid-ready asynchronous advanced FIFO is verified using a SystemVerilog testbench with comprehensive check sequences that validate all advanced features including level monitoring, threshold operations, flush functionality, and clock domain crossing with handshake protocol compliance in both domains.

The following table lists the checks performed by the testbench.

| Number | Check                                            | Description                                                                                    |
| ------ | ------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| 1      | Writing to full                                  | Fills the FIFO completely and verifies level tracking and flags in both domains.               |
| 2      | Write miss protection                            | Attempts write when full and verifies handshake protocol prevents invalid operations.          |
| 3      | Reading to empty                                 | Empties the FIFO completely and verifies data integrity, level tracking, and flags.            |
| 4      | Read error protection                            | Attempts read when empty and verifies handshake protocol prevents invalid operations.          |
| 5      | Write domain flush                               | Verifies flush functionality from write domain with proper level updates.                      |
| 6      | Read domain flush                                | Verifies flush functionality from read domain with proper level updates.                       |
| 7      | Maximal throughput with same frequencies         | Performs read and write operations as fast as possible with both clocks at the same frequency. |
| 8      | Maximal throughput with fast write and slow read | Performs read and write operations as fast as possible with a faster write clock.              |
| 9      | Maximal throughput with slow write and fast read | Performs read and write operations as fast as possible with a faster read clock.               |
| 10     | Random stimulus with same frequencies            | Performs random read and write operations with both clocks at the same frequency.              |
| 11     | Random stimulus with fast write and slow read    | Performs random read and write operations with a faster write clock.                           |
| 12     | Random stimulus with slow write and fast read    | Performs random read and write operations with a faster read clock.                            |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` | `STAGES_WRITE` | `STAGES_READ` |           |
| ------- | ------- | -------------- | ------------- | --------- |
| 8       | 4       | 2              | 2             | (default) |

## Constraints

Clock domain crossing constraints should be applied to all Gray pointer synchronizers. The design assumes the FIFO depth is a power of 2 for optimal Gray code operation.

## Deliverables

| Type              | File                                                                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_asynchronous_advanced_fifo.v`](valid_ready_asynchronous_advanced_fifo.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_asynchronous_advanced_fifo.testbench.sv`](valid_ready_asynchronous_advanced_fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_asynchronous_advanced_fifo.testbench.gtkw`](valid_ready_asynchronous_advanced_fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_asynchronous_advanced_fifo.symbol.sss`](valid_ready_asynchronous_advanced_fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_asynchronous_advanced_fifo.symbol.svg`](valid_ready_asynchronous_advanced_fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`valid_ready_asynchronous_advanced_fifo.md`](valid_ready_asynchronous_advanced_fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                                                                           | Path                                                                                 | Comment                                               |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------- |
| [`asynchronous_advanced_fifo`](../../read_write_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/read_write_enable/asynchronous_advanced_fifo` | Underlying asynchronous advanced FIFO implementation. |

## Related modules

| Module                                                                                                           | Path                                                                                 | Comment                                                       |
| ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| [`asynchronous_advanced_fifo`](../../read_write_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/read_write_enable/asynchronous_advanced_fifo` | Base variant with read-write enable flow control.             |
| [`valid_ready_advanced_fifo`](../advanced_fifo/valid_ready_advanced_fifo.md)                                     | `omnicores-buildingblocks/sources/data/valid_ready/advanced_fifo`                    | Synchronous advanced FIFO without clock domain crossing.      |
| [`valid_ready_asynchronous_fifo`](../asynchronous_fifo/valid_ready_asynchronous_fifo.md)                         | `omnicores-buildingblocks/sources/data/valid_ready/asynchronous_fifo`                | Basic asynchronous FIFO without advanced monitoring features. |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                                                                | `omnicores-buildingblocks/sources/data/valid_ready/fifo`                             | Basic synchronous FIFO for single clock domain use.           |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md)                                     | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`                    | Single-entry buffer for storage.                              |
| [`valid_ready_skid_buffer`](../skid_buffer/valid_ready_skid_buffer.md)                                           | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`                      | Two-entry buffer for simple bus pipelining.                   |
