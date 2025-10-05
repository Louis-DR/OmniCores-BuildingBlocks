# Advanced FIFO Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Advanced FIFO Controller                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![advanced_fifo_controller](advanced_fifo_controller.symbol.svg)

Controller for synchronous First-In First-Out queue with advanced features including protection mechanisms, error reporting, extended status flags, level monitoring, and dynamic thresholds. The controller manages separate read and write pointers with wrap bits, generates memory interface signals, implements protection logic, calculates status flags, monitors level and thresholds, and generates error notifications.

The controller is designed to be integrated with a simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for pointers, status flags, and error notifications.

## Parameters

| Name         | Type    | Allowed Values | Default       | Description                                                 |
| ------------ | ------- | -------------- | ------------- | ----------------------------------------------------------- |
| `WIDTH`      | integer | `≥1`           | `8`           | Bit width of the data vector.                               |
| `DEPTH`      | integer | `≥2`           | `4`           | Number of entries in the queue. Non-power-of-two supported. |
| `DEPTH_LOG2` | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated).             |

## Ports

| Name                     | Direction | Width          | Clock        | Reset    | Reset value | Description                                                                                                       |
| ------------------------ | --------- | -------------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------------------------------------- |
| `clock`                  | input     | 1              | self         |          |             | Clock signal.                                                                                                     |
| `resetn`                 | input     | 1              | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                                    |
| `flush`                  | input     | 1              | `clock`      |          |             | Flush control.<br/>`0`: idle.<br/>`1`: empty FIFO by advancing read to write pointer.                             |
| `empty`                  | output    | 1              | `clock`      | `resetn` | `1`         | Queue empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty.                                        |
| `not_empty`              | output    | 1              | `clock`      | `resetn` | `0`         | Queue not empty status.<br/>`0`: queue is empty.<br/>`1`: queue contains data.                                    |
| `almost_empty`           | output    | 1              | `clock`      | `resetn` | `1`         | Queue almost empty status.<br/>`0`: level > 1.<br/>`1`: level ≤ 1.                                                |
| `full`                   | output    | 1              | `clock`      | `resetn` | `0`         | Queue full status.<br/>`0`: queue has free space.<br/>`1`: queue is full.                                         |
| `not_full`               | output    | 1              | `clock`      | `resetn` | `1`         | Queue not full status.<br/>`0`: queue is full.<br/>`1`: queue has free space.                                     |
| `almost_full`            | output    | 1              | `clock`      | `resetn` | `0`         | Queue almost full status.<br/>`0`: level < DEPTH-1.<br/>`1`: level ≥ DEPTH-1.                                     |
| `write_miss`             | output    | 1              | `clock`      | `resetn` | `0`         | Write protection pulse notification.<br/>`0`: no error.<br/>`1`: write attempted when full (pulse for one cycle). |
| `read_error`             | output    | 1              | `clock`      | `resetn` | `0`         | Read protection pulse notification.<br/>`0`: no error.<br/>`1`: read attempted when empty (pulse for one cycle).  |
| `write_enable`           | input     | 1              | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to queue.                                               |
| `write_data`             | input     | `WIDTH`        | `clock`      |          |             | Data to be written to the queue.                                                                                  |
| `read_enable`            | input     | 1              | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from queue.                                                |
| `read_data`              | output    | `WIDTH`        | `clock`      | `resetn` | `0`         | Data read from the queue head.                                                                                    |
| `level`                  | output    | `DEPTH_LOG2+1` | `clock`      | `resetn` | `0`         | Current number of entries in the queue.                                                                           |
| `lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Lower threshold level for comparison.                                                                             |
| `lower_threshold_status` | output    | 1              | `clock`      | `resetn` | `1`         | Lower threshold status.<br/>`0`: level > threshold.<br/>`1`: level ≤ threshold.                                   |
| `upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `clock`      |          |             | Upper threshold level for comparison.                                                                             |
| `upper_threshold_status` | output    | 1              | `clock`      | `resetn` | `0`         | Upper threshold status.<br/>`0`: level < threshold.<br/>`1`: level ≥ threshold.                                   |
| `memory_write_enable`    | output    | 1              | `clock`      |          |             | Memory write enable signal.                                                                                       |
| `memory_write_address`   | output    | `DEPTH_LOG2`   | `clock`      |          |             | Memory write address.                                                                                             |
| `memory_write_data`      | output    | `WIDTH`        | `clock`      |          |             | Memory write data.                                                                                                |
| `memory_read_enable`     | output    | 1              | `clock`      |          |             | Memory read enable signal.                                                                                        |
| `memory_read_address`    | output    | `DEPTH_LOG2`   | `clock`      |          |             | Memory read address.                                                                                              |
| `memory_read_data`       | input     | `WIDTH`        | `clock`      |          |             | Memory read data.                                                                                                 |

## Operation

The controller maintains separate read and write pointers, each with an additional wrap bit for correct level calculation, implemented with `advanced_wrapping_counter`. It generates the memory interface signals, calculates all status flags and thresholds, implements protection mechanisms, and generates error notifications. The controller doesn't store any data, only control state.

For **write operation**, when `write_enable` is asserted, the controller checks if the queue is full. If not full and not flushing, it generates `memory_write_enable`, provides the write address from the write pointer, and forwards `write_data` to `memory_write_data`. The write pointer is then incremented. If full, the write is ignored and `write_miss` pulses for one clock cycle.

The write safety mechanism prevents writing when full. The write will be ignored, the pointers will not be updated, and the data will be lost. The `write_miss` pulse notification will assert for one clock cycle to signal the error, then automatically clear. The FIFO can continue operating normally.

For **read operation**, the controller continuously provides the read address from the read pointer to `memory_read_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, the controller checks if the queue is empty. If not empty, `memory_read_enable` is generated and the read pointer is incremented. If empty, the read is ignored and `read_error` pulses for one clock cycle.

The read safety mechanism prevents reading when empty. The `read_data` will be invalid and the pointers will not be updated. The `read_error` pulse notification will assert for one clock cycle to signal the error, then automatically clear. The FIFO can continue operating normally.

If the queue is empty, data written can be read in the next cycle. When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

The level, status, and threshold outputs are calculated based on the read and write pointers. The level represents the current number of entries in the queue. The threshold statuses are calculated by comparing the current level with the programmable threshold levels.

Asserting the `flush` input empties the whole FIFO at the next rising edge of the clock by advancing the read pointer to the write pointer. During a flush cycle, read and write pointer increments are gated so no entry is consumed or written concurrently.

The **memory interface** provides separate write and read channels with enable, address, and data signals. The interface expects combinational reads from the memory, where the data at the read address appears immediately on the read data output without additional latency.

## Paths

| From                    | To                       | Type          | Comment                                      |
| ----------------------- | ------------------------ | ------------- | -------------------------------------------- |
| `write_data`            | `memory_write_data`      | combinational | Direct pass-through.                         |
| `write_enable`          | `memory_write_enable`    | combinational | Gated by full flag.                          |
| `write_enable`          | `memory_write_address`   | combinational | Address from write pointer.                  |
| `write_enable`          | `write_miss`             | sequential    | Error flag generation.                       |
| `write_enable`          | status/level flags       | sequential    | Control path through internal write pointer. |
| `read_enable`           | `memory_read_enable`     | combinational | Gated by empty flag.                         |
| `read_enable`           | `memory_read_address`    | combinational | Address from read pointer.                   |
| `read_enable`           | `read_error`             | sequential    | Error flag generation.                       |
| `read_enable`           | status/level flags       | sequential    | Control path through internal read pointer.  |
| `flush`                 | status/level flags       | sequential    | Control path through internal pointers.      |
| `lower_threshold_level` | `lower_threshold_status` | combinational | Direct comparison with current level.        |
| `upper_threshold_level` | `upper_threshold_status` | combinational | Direct comparison with current level.        |
| `memory_read_data`      | `read_data`              | combinational | Direct pass-through.                         |

## Complexity

| Delay           | Gates           | Comment |
| --------------- | --------------- | ------- |
| `O(log₂ DEPTH)` | `O(log₂ DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `2×(log₂DEPTH+1)` flip-flops for the read and write pointers with wrap bits, plus additional state for error flags.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the pointer incrementation, pointer comparison, level calculation, and threshold comparisons.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`advanced_fifo_controller.v`](advanced_fifo_controller.v)                         | Verilog design.                                     |
| Symbol descriptor | [`advanced_fifo_controller.symbol.sss`](advanced_fifo_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`advanced_fifo_controller.symbol.svg`](advanced_fifo_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`advanced_fifo_controller.symbol.drawio`](advanced_fifo_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`advanced_fifo_controller.md`](advanced_fifo_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                      | Path                                                                 | Comment                 |
| --------------------------- | -------------------------------------------------------------------- | ----------------------- |
| `advanced_wrapping_counter` | `omnicores-buildingblocks/sources/counter/advanced_wrapping_counter` | For pointer management. |

## Related modules

| Module                                                                                                            | Path                                                                           | Comment                                                          |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| [`advanced_fifo`](../../access_enable/advanced_fifo/advanced_fifo.md)                                             | `omnicores-buildingblocks/sources/data/access_enable/advanced_fifo`            | Access-enable wrapper integrating this controller with RAM.      |
| [`fifo_controller`](../fifo/fifo_controller.md)                                                                   | `omnicores-buildingblocks/sources/data/controllers/fifo`                       | Basic FIFO controller without advanced features or protection.   |
| [`asynchronous_advanced_fifo_controller`](../asynchronous_advanced_fifo/asynchronous_advanced_fifo_controller.md) | `omnicores-buildingblocks/sources/data/controllers/asynchronous_advanced_fifo` | Advanced asynchronous FIFO controller for clock domain crossing. |
