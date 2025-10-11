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

| Name           | Type    | Allowed Values | Default       | Description                                                 |
| -------------- | ------- | -------------- | ------------- | ----------------------------------------------------------- |
| `WIDTH`        | integer | `≥1`           | `8`           | Bit width of the data vector.                               |
| `DEPTH`        | integer | `≥2`           | `4`           | Number of entries in the queue. Non-power-of-two supported. |
| `DEPTH_LOG2`   | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated).             |
| `STAGES_WRITE` | integer | `≥2`           | `2`           | Number of synchronizer stages for write domain CDC.         |
| `STAGES_READ`  | integer | `≥2`           | `2`           | Number of synchronizer stages for read domain CDC.          |

## Ports

| Name                           | Direction | Width          | Clock         | Reset          | Reset value | Description                                                                                                       |
| ------------------------------ | --------- | -------------- | ------------- | -------------- | ----------- | ----------------------------------------------------------------------------------------------------------------- |
| `write_clock`                  | input     | 1              | self          |                |             | Write clock signal.                                                                                               |
| `write_resetn`                 | input     | 1              | asynchronous  | self           | active-low  | Asynchronous active-low reset for write domain.                                                                   |
| `write_flush`                  | input     | 1              | `write_clock` |                |             | Flush control from write domain.<br/>`0`: idle.<br/>`1`: empty FIFO.                                              |
| `write_enable`                 | input     | 1              | `write_clock` |                |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to queue.                                               |
| `write_data`                   | input     | `WIDTH`        | `write_clock` |                |             | Data to be written to the queue.                                                                                  |
| `write_empty`                  | output    | 1              | `write_clock` | `write_resetn` | `1`         | Queue empty status in write domain.<br/>`0`: contains data.<br/>`1`: empty.                                       |
| `write_not_empty`              | output    | 1              | `write_clock` | `write_resetn` | `0`         | Queue not empty status in write domain.<br/>`0`: empty.<br/>`1`: contains data.                                   |
| `write_almost_empty`           | output    | 1              | `write_clock` | `write_resetn` | `1`         | Queue almost empty status in write domain.<br/>`0`: level > 1.<br/>`1`: level ≤ 1.                                |
| `write_full`                   | output    | 1              | `write_clock` | `write_resetn` | `0`         | Queue full status in write domain.<br/>`0`: free space.<br/>`1`: full.                                            |
| `write_not_full`               | output    | 1              | `write_clock` | `write_resetn` | `1`         | Queue not full status in write domain.<br/>`0`: full.<br/>`1`: free space.                                        |
| `write_almost_full`            | output    | 1              | `write_clock` | `write_resetn` | `0`         | Queue almost full status in write domain.<br/>`0`: level < DEPTH-1.<br/>`1`: level ≥ DEPTH-1.                     |
| `write_miss`                   | output    | 1              | `write_clock` | `write_resetn` | `0`         | Write protection pulse notification.<br/>`0`: no error.<br/>`1`: write attempted when full (pulse for one cycle). |
| `write_level`                  | output    | `DEPTH_LOG2+1` | `write_clock` | `write_resetn` | `0`         | Current number of entries in write domain.                                                                        |
| `write_lower_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Lower threshold level for write domain comparison.                                                                |
| `write_lower_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `1`         | Lower threshold status in write domain.<br/>`0`: level > threshold.<br/>`1`: level ≤ threshold.                   |
| `write_upper_threshold_level`  | input     | `DEPTH_LOG2+1` | `write_clock` |                |             | Upper threshold level for write domain comparison.                                                                |
| `write_upper_threshold_status` | output    | 1              | `write_clock` | `write_resetn` | `0`         | Upper threshold status in write domain.<br/>`0`: level < threshold.<br/>`1`: level ≥ threshold.                   |
| `read_clock`                   | input     | 1              | self          |                |             | Read clock signal.                                                                                                |
| `read_resetn`                  | input     | 1              | asynchronous  | self           | active-low  | Asynchronous active-low reset for read domain.                                                                    |
| `read_flush`                   | input     | 1              | `read_clock`  |                |             | Flush control from read domain.<br/>`0`: idle.<br/>`1`: empty FIFO.                                               |
| `read_enable`                  | input     | 1              | `read_clock`  |                |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from queue.                                                |
| `read_data`                    | output    | `WIDTH`        | `read_clock`  | `read_resetn`  | `0`         | Data read from the queue head.                                                                                    |
| `read_empty`                   | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Queue empty status in read domain.<br/>`0`: contains data.<br/>`1`: empty.                                        |
| `read_not_empty`               | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Queue not empty status in read domain.<br/>`0`: empty.<br/>`1`: contains data.                                    |
| `read_almost_empty`            | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Queue almost empty status in read domain.<br/>`0`: level > 1.<br/>`1`: level ≤ 1.                                 |
| `read_full`                    | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Queue full status in read domain.<br/>`0`: free space.<br/>`1`: full.                                             |
| `read_not_full`                | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Queue not full status in read domain.<br/>`0`: full.<br/>`1`: free space.                                         |
| `read_almost_full`             | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Queue almost full status in read domain.<br/>`0`: level < DEPTH-1.<br/>`1`: level ≥ DEPTH-1.                      |
| `read_error`                   | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Read protection pulse notification.<br/>`0`: no error.<br/>`1`: read attempted when empty (pulse for one cycle).  |
| `read_level`                   | output    | `DEPTH_LOG2+1` | `read_clock`  | `read_resetn`  | `0`         | Current number of entries in read domain.                                                                         |
| `read_lower_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Lower threshold level for read domain comparison.                                                                 |
| `read_lower_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `1`         | Lower threshold status in read domain.<br/>`0`: level > threshold.<br/>`1`: level ≤ threshold.                    |
| `read_upper_threshold_level`   | input     | `DEPTH_LOG2+1` | `read_clock`  |                |             | Upper threshold level for read domain comparison.                                                                 |
| `read_upper_threshold_status`  | output    | 1              | `read_clock`  | `read_resetn`  | `0`         | Upper threshold status in read domain.<br/>`0`: level < threshold.<br/>`1`: level ≥ threshold.                    |
| `memory_write_clock`           | output    | 1              |               |                |             | Write clock for asynchronous dual-port memory.                                                                    |
| `memory_write_enable`          | output    | 1              | `write_clock` |                |             | Memory write enable signal.                                                                                       |
| `memory_write_address`         | output    | `DEPTH_LOG2`   | `write_clock` |                |             | Memory write address.                                                                                             |
| `memory_write_data`            | output    | `WIDTH`        | `write_clock` |                |             | Memory write data.                                                                                                |
| `memory_read_clock`            | output    | 1              |               |                |             | Read clock for asynchronous dual-port memory.                                                                     |
| `memory_read_enable`           | output    | 1              | `read_clock`  |                |             | Memory read enable signal.                                                                                        |
| `memory_read_address`          | output    | `DEPTH_LOG2`   | `read_clock`  |                |             | Memory read address.                                                                                              |
| `memory_read_data`             | input     | `WIDTH`        | `read_clock`  |                |             | Memory read data.                                                                                                 |

## Operation

The controller maintains separate read and write pointers in their respective clock domains, implements Gray-code conversion and synchronization using `gray_wrapping_counter` for CDC-safe pointer transfer, calculates all status flags, levels, and thresholds in both domains, implements protection mechanisms, and generates error notifications. The controller doesn't store any data, only control state.

For **write operation** (in write clock domain), when `write_enable` is asserted, the controller checks if the queue is full. If not full and not flushing, it generates `memory_write_enable`, provides the write address from the write pointer, and forwards `write_data` to `memory_write_data`. The write pointer counter advances and automatically converts to Gray code. If full, the write is ignored and `write_miss` pulses for one clock cycle.

For **read operation** (in read clock domain), when `read_enable` is asserted, the controller checks if the queue is empty. If not empty, `memory_read_enable` is generated, the read address is provided from the read pointer, and the read pointer counter advances with automatic Gray code conversion. If empty, the read is ignored and `read_error` pulses for one clock cycle.

The **status flags and levels** are calculated independently in each domain:
- **Write domain**: Level calculated from write pointer and synchronized read pointer. All status flags derived from this level.
- **Read domain**: Level calculated from read pointer and synchronized write pointer. All status flags derived from this level.

The levels in each domain may differ temporarily due to CDC synchronization latency, which is inherent to asynchronous FIFO operation.

The **flushing** can be initiated from either domain:
- **Write flush**: Synchronizes to read domain and forces read pointer to match write pointer.
- **Read flush**: Synchronizes to write domain and forces read pointer to match write pointer.

The **clock domain crossing** uses Gray-code counters (`gray_wrapping_counter`) that maintain both binary and Gray-coded representations. The Gray-coded pointers are synchronized using multi-stage synchronizers (`vector_synchronizer`) before being converted back to binary in the opposite domain for level calculation.

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

| Module                  | Path                                                             | Comment                                             |
| ----------------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| `gray_wrapping_counter` | `omnicores-buildingblocks/sources/counter/gray_wrapping_counter` | For CDC-safe pointer management with Gray encoding. |
| `binary_to_gray`        | `omnicores-buildingblocks/sources/encoding/gray`                 | For converting values to Gray code.                 |
| `gray_to_binary`        | `omnicores-buildingblocks/sources/encoding/gray`                 | For converting values from Gray code.               |
| `vector_synchronizer`   | `omnicores-buildingblocks/sources/timing/vector_synchronizer`    | For CDC-safe pointer and signal synchronization.    |

## Related modules

| Module                                                                                                       | Path                                                                             | Comment                                                           |
| ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| [`asynchronous_advanced_fifo`](../../access_enable/asynchronous_advanced_fifo/asynchronous_advanced_fifo.md) | `omnicores-buildingblocks/sources/data/access_enable/asynchronous_advanced_fifo` | Access-enable wrapper integrating this controller with async RAM. |
| [`advanced_fifo_controller`](../advanced_fifo/advanced_fifo_controller.md)                                   | `omnicores-buildingblocks/sources/data/controllers/advanced_fifo`                | Synchronous advanced FIFO controller for single clock domain.     |
| [`asynchronous_fifo_controller`](../asynchronous_fifo/asynchronous_fifo_controller.md)                       | `omnicores-buildingblocks/sources/data/controllers/asynchronous_fifo`            | Basic asynchronous FIFO without advanced features.                |
