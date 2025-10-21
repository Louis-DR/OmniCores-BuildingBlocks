# Asynchronous Advanced FIFO Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Asynchronous Advanced FIFO Controller                                            |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![asynchronous_advanced_fifo_controller](asynchronous_advanced_fifo_controller.symbol.svg)

Controller for asynchronous First-In First-Out queue for safe clock domain crossing with advanced features including protection mechanisms, error reporting, extended status flags, level monitoring in both domains, and dynamic thresholds. The controller manages separate read and write pointers with Gray-code conversion and CDC synchronization, implements protection logic, calculates domain-specific status flags and levels, and generates error notifications.

The controller is designed to be integrated with an asynchronous simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for pointers, status flags, level calculations, and CDC synchronizers in each domain.

## Parameters

| Name           | Type    | Allowed Values | Default       | Description                                         |
| -------------- | ------- | -------------- | ------------- | --------------------------------------------------- |
| `WIDTH`        | integer | `≥1`           | `8`           | Bit width of the data vector.                       |
| `DEPTH`        | integer | `≥2` even      | `4`           | Number of entries in the queue.                     |
| `DEPTH_LOG2`   | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated).     |
| `STAGES_WRITE` | integer | `≥2`           | `2`           | Number of synchronizer stages for write domain CDC. |
| `STAGES_READ`  | integer | `≥2`           | `2`           | Number of synchronizer stages for read domain CDC.  |

## Ports

| Name                           | Direction | Width          | Clock         | Reset          | Reset value | Description                                                                                                                                   |
| ------------------------------ | --------- | -------------- | ------------- | -------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `write_clock`                  | input     | 1              | self          |                |             | Write clock signal.                                                                                                                           |
| `write_resetn`                 | input     | 1              | asynchronous  | self           | active-low  | Asynchronous active-low reset for write domain.                                                                                               |
| `write_flush`                  | input     | 1              | `write_clock` |                |             | Flush control from write domain.<br/>• `0`: idle.<br/>• `1`: empty FIFO.                                                                      |
| `write_enable`                 | input     | 1              | `write_clock` |                |             | Write enable signal.<br/>• `0`: idle.<br/>• `1`: write (push) to queue.                                                                       |
| `write_data`                   | input     | `WIDTH`        | `write_clock` |                |             | Data to be written to the queue.                                                                                                              |
| `write_empty`                  | output    | 1              | `write_clock` | `write_resetn` | `1`         | Write domain queue empty status.<br/>• `0`: queue contains data.<br/>• `1`: queue is empty.                                                   |
| `write_almost_empty`           | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue almost empty status.<br/>• `0`: queue is empty or has more than one entry.<br/>• `1`: queue has exactly one entry.         |
| `write_half_empty`             | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue half empty status.<br/>• `0`: queue half full.<br/>• `1`: queue half empty.                                                |
| `write_not_empty`              | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue not empty status.<br/>• `0`: queue is empty.<br/>• `1`: queue contains data.                                               |
| `write_not_full`               | output    | 1              | `write_clock` | `write_resetn` | `1`         | Write domain queue not full status.<br/>• `0`: queue is full.<br/>• `1`: queue has free space.                                                |
| `write_half_full`              | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue half full status.<br/>• `0`: queue half empty.<br/>• `1`: queue half full.                                                 |
| `write_almost_full`            | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue almost full status.<br/>• `0`: queue is full or has more than one free space.<br/>• `1`: queue has exactly one free space. |
| `write_full`                   | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain queue full status.<br/>• `0`: queue has free space.<br/>• `1`: queue is full.                                                    |
| `write_miss`                   | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write protection pulse notification.<br/>• `0`: no error.<br/>• `1`: write attempted when full.                                               |
| `write_level`                  | output    | `DEPTH_LOG2+1` | `write_clock` | `write_resetn` | `0`         | Write domain current number of entries in the queue.                                                                                          |
| `write_space`                  | output    | `DEPTH_LOG2+1` | `write_clock` | `write_resetn` | `0`         | Write domain number of free entries.                                                                                                          |
| `write_lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Write domain lower threshold level for comparison.                                                                                            |
| `write_lower_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `1`         | Write domain lower threshold status.<br/>• `0`: level > threshold.<br/>• `1`: level ≤ threshold.                                              |
| `write_upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Write domain upper threshold level for comparison.                                                                                            |
| `write_upper_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write domain upper threshold status.<br/>• `0`: level < threshold.<br/>• `1`: level ≥ threshold.                                              |
| `read_clock`                   | input     | 1              | self          |                |             | Read clock signal.                                                                                                                            |
| `read_resetn`                  | input     | 1              | asynchronous  | self           | active-low  | Asynchronous active-low reset for read domain.                                                                                                |
| `read_flush`                   | input     | 1              | `read_clock`  |                |             | Flush control from read domain.<br/>• `0`: idle.<br/>• `1`: empty FIFO.                                                                       |
| `read_enable`                  | input     | 1              | `read_clock`  |                |             | Read enable signal.<br/>• `0`: idle.<br/>• `1`: read (pop) from queue.                                                                        |
| `read_data`                    | output    | `WIDTH`        | `read_clock`  | `read_resetn`  | `0`         | Data read from the queue head.                                                                                                                |
| `read_empty`                   | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Read domain queue empty status.<br/>• `0`: queue contains data.<br/>• `1`: queue is empty.                                                    |
| `read_almost_empty`            | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue almost empty status.<br/>• `0`: queue is empty or has more than one entry.<br/>• `1`: queue has exactly one entry.          |
| `read_half_empty`              | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue half empty status.<br/>• `0`: queue half full.<br/>• `1`: queue half empty.                                                 |
| `read_not_empty`               | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue not empty status.<br/>• `0`: queue is empty.<br/>• `1`: queue contains data.                                                |
| `read_not_full`                | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Read domain queue not full status.<br/>• `0`: queue is full.<br/>• `1`: queue has free space.                                                 |
| `read_half_full`               | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue half full status.<br/>• `0`: queue half empty.<br/>• `1`: queue half full.                                                  |
| `read_almost_full`             | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue almost full status.<br/>• `0`: queue is full or has more than one free space.<br/>• `1`: queue has exactly one free space.  |
| `read_full`                    | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain queue full status.<br/>• `0`: queue has free space.<br/>• `1`: queue is full.                                                     |
| `read_error`                   | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read protection pulse notification.<br/>• `0`: no error.<br/>• `1`: read attempted when empty.                                                |
| `read_level`                   | output    | `DEPTH_LOG2+1` | `read_clock`  | `read_resetn`  | `0`         | Read domain current number of entries in the queue.                                                                                           |
| `read_space`                   | output    | `DEPTH_LOG2+1` | `read_clock`  | `read_resetn`  | `0`         | Read domain number of free entries.                                                                                                           |
| `read_lower_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Read domain lower threshold level for comparison.                                                                                             |
| `read_lower_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Read domain lower threshold status.<br/>• `0`: level > threshold.<br/>• `1`: level ≤ threshold.                                               |
| `read_upper_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Read domain upper threshold level for comparison.                                                                                             |
| `read_upper_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read domain upper threshold status.<br/>• `0`: level < threshold.<br/>• `1`: level ≥ threshold.                                               |
| `memory_write_clock`           | output    | 1              |               |                |             | Write clock for asynchronous dual-port memory.                                                                                                |
| `memory_write_enable`          | output    | 1              | `write_clock` |                |             | Memory write enable signal.                                                                                                                   |
| `memory_write_address`         | output    | `DEPTH_LOG2`   | `write_clock` |                |             | Memory write address.                                                                                                                         |
| `memory_write_data`            | output    | `WIDTH`        | `write_clock` |                |             | Memory write data.                                                                                                                            |
| `memory_read_clock`            | output    | 1              |               |                |             | Read clock for asynchronous dual-port memory.                                                                                                 |
| `memory_read_enable`           | output    | 1              | `read_clock`  |                |             | Memory read enable signal.                                                                                                                    |
| `memory_read_address`          | output    | `DEPTH_LOG2`   | `read_clock`  |                |             | Memory read address.                                                                                                                          |
| `memory_read_data`             | input     | `WIDTH`        | `read_clock`  |                |             | Memory read data.                                                                                                                             |

## Operation

The controller maintains separate read and write pointers in their respective clock domains, implements Gray-code conversion and synchronization using `gray_advanced_wrapping_counter` for CDC-safe pointer transfer, calculates all status flags, levels, and thresholds in both domains, implements protection mechanisms, and generates error notifications. The controller doesn't store any data, only control state.

For **write operation** (in write clock domain), when `write_enable` is asserted, the controller checks if the queue is full. If not full and not flushing, it generates `memory_write_enable`, provides the write address from the write pointer, and forwards `write_data` to `memory_write_data`. The write pointer counter advances and automatically converts to Gray code. If full, the write is ignored and `write_miss` pulses for one clock cycle.

For **read operation** (in read clock domain), when `read_enable` is asserted, the controller checks if the queue is empty. If not empty, `memory_read_enable` is generated, the read address is provided from the read pointer, and the read pointer counter advances with automatic Gray code conversion. If empty, the read is ignored and `read_error` pulses for one clock cycle.

The **status flags and levels** are calculated independently in each domain:
- **Write domain**: Level calculated from write pointer and synchronized read pointer. All status flags derived from this level.
- **Read domain**: Level calculated from read pointer and synchronized write pointer. All status flags derived from this level.

The levels in each domain may differ temporarily due to CDC synchronization latency, which is inherent to asynchronous FIFO operation.

The **flushing** can be initiated from either domain:
- **Write flush**: Synchronizes to read domain and forces read pointer to match write pointer.
- **Read flush**: Synchronizes to write domain and forces read pointer to match write pointer.

The **clock domain crossing** uses Gray-code counters (`gray_advanced_wrapping_counter`) that maintain both binary and Gray-coded representations. The Gray-coded pointers are synchronized using multi-stage synchronizers (`vector_synchronizer`) before being converted back to binary in the opposite domain for level calculation.

The **memory interface** provides separate write and read channels in their respective clock domains with independent clocks, enable, address, and data signals for asynchronous dual-port RAM. The controller forwards the write and read clocks (`memory_write_clock` and `memory_read_clock`) to the memory to clearly indicate the asynchronous nature of the interface. The write port operates in the write clock domain, and the read port operates in the read clock domain. The interface expects combinational reads from the asynchronous RAM.

## Paths

Similar to asynchronous_fifo_controller but with additional paths for protection logic, level calculation, and threshold comparisons in both domains. CDC paths exist between write and read pointers through Gray-code synchronizers.

## Complexity

| Delay           | Gates           | Comment |
| --------------- | --------------- | ------- |
| `O(log₂ DEPTH)` | `O(log₂ DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires substantial flip-flop resources for:
- Gray-wrapping counters in each domain
- CDC synchronizers for pointer transfer between domains
- Flush synchronizers between domains
- Error flag registers

The critical path includes pointer comparison, level calculation, threshold comparison, and status flag generation. The CDC synchronizers add latency but not combinational delay within each domain.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

The module requires proper timing constraints for clock domain crossing:
- Define asynchronous clock groups between `write_clock` and `read_clock`
- Set maximum delay constraints on the Gray-coded pointer paths between domains
- Set maximum delay constraints on flush synchronizer paths
- Ensure synchronizer stages are properly constrained to allow metastability resolution

## Deliverables

| Type              | File                                                                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`asynchronous_advanced_fifo_controller.v`](asynchronous_advanced_fifo_controller.v)                         | Verilog design.                                     |
| Symbol descriptor | [`asynchronous_advanced_fifo_controller.symbol.sss`](asynchronous_advanced_fifo_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`asynchronous_advanced_fifo_controller.symbol.svg`](asynchronous_advanced_fifo_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`asynchronous_advanced_fifo_controller.symbol.drawio`](asynchronous_advanced_fifo_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`asynchronous_advanced_fifo_controller.md`](asynchronous_advanced_fifo_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                           | Path                                                                      | Comment                                             |
| -------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------- |
| `gray_advanced_wrapping_counter` | `omnicores-buildingblocks/sources/counter/gray_advanced_wrapping_counter` | For CDC-safe pointer management with Gray encoding. |
| `binary_to_gray`                 | `omnicores-buildingblocks/sources/encoding/gray`                          | For converting values to Gray code.                 |
| `gray_to_binary`                 | `omnicores-buildingblocks/sources/encoding/gray`                          | For converting values from Gray code.               |
| `vector_synchronizer`            | `omnicores-buildingblocks/sources/timing/vector_synchronizer`             | For CDC-safe pointer and signal synchronization.    |

## Related modules

| Module                                                                                                       | Path                                                                             | Comment                                                           |
| ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| [`asynchronous_advanced_fifo`](../../access_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/access_enable/asynchronous_advanced_fifo` | Access-enable wrapper integrating this controller with async RAM. |
| [`advanced_fifo_controller`](../advanced_fifo/advanced_fifo_controller.md)                                   | `omnicores-buildingblocks/sources/data/controllers/advanced_fifo`                | Synchronous advanced FIFO controller for single clock domain.     |
| [`asynchronous_fifo_controller`](../asynchronous_fifo/asynchronous_fifo_controller.md)                       | `omnicores-buildingblocks/sources/data/controllers/asynchronous_fifo`            | Basic asynchronous FIFO without advanced features.                |
