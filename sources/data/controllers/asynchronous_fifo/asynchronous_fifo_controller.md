# Asynchronous FIFO Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Asynchronous FIFO Controller                                                     |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![asynchronous_fifo_controller](asynchronous_fifo_controller.symbol.svg)

Controller for asynchronous First-In First-Out queue for safe clock domain crossing. The controller manages separate read and write pointers in their respective clock domains, implements Gray-code conversion and synchronization for CDC-safe pointer transfer, generates memory interface signals, and calculates domain-specific full/empty status flags.

The controller is designed to be integrated with an asynchronous simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for pointers in each clock domain and CDC synchronizers.

## Parameters

| Name         | Type    | Allowed Values    | Default       | Description                                         |
| ------------ | ------- | ----------------- | ------------- | --------------------------------------------------- |
| `WIDTH`      | integer | `≥1`              | `8`           | Bit width of the data vector.                       |
| `DEPTH`      | integer | `≥2` power-of-two | `4`           | Number of entries in the queue. Must be power of 2. |
| `STAGES`     | integer | `≥2`              | `2`           | Number of synchronizer stages for CDC.              |
| `DEPTH_LOG2` | integer | `≥1`              | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated).     |

## Ports

| Name                   | Direction | Width        | Clock         | Reset          | Reset value | Description                                                                |
| ---------------------- | --------- | ------------ | ------------- | -------------- | ----------- | -------------------------------------------------------------------------- |
| `write_clock`          | input     | 1            | self          |                |             | Write clock signal.                                                        |
| `write_resetn`         | input     | 1            | asynchronous  | self           | active-low  | Asynchronous active-low reset for write domain.                            |
| `write_enable`         | input     | 1            | `write_clock` |                |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to queue.        |
| `write_data`           | input     | `WIDTH`      | `write_clock` |                |             | Data to be written to the queue.                                           |
| `write_full`           | output    | 1            | `write_clock` | `write_resetn` | `0`         | Queue full status in write domain.<br/>`0`: free space.<br/>`1`: full.     |
| `read_clock`           | input     | 1            | self          |                |             | Read clock signal.                                                         |
| `read_resetn`          | input     | 1            | asynchronous  | self           | active-low  | Asynchronous active-low reset for read domain.                             |
| `read_enable`          | input     | 1            | `read_clock`  |                |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from queue.         |
| `read_data`            | output    | `WIDTH`      | `read_clock`  | `read_resetn`  | `0`         | Data read from the queue head.                                             |
| `read_empty`           | output    | 1            | `read_clock`  | `read_resetn`  | `1`         | Queue empty status in read domain.<br/>`0`: contains data.<br/>`1`: empty. |
| `memory_write_enable`  | output    | 1            | `write_clock` |                |             | Memory write enable signal.                                                |
| `memory_write_address` | output    | `DEPTH_LOG2` | `write_clock` |                |             | Memory write address.                                                      |
| `memory_write_data`    | output    | `WIDTH`      | `write_clock` |                |             | Memory write data.                                                         |
| `memory_read_enable`   | output    | 1            | `read_clock`  |                |             | Memory read enable signal.                                                 |
| `memory_read_address`  | output    | `DEPTH_LOG2` | `read_clock`  |                |             | Memory read address.                                                       |
| `memory_read_data`     | input     | `WIDTH`      | `read_clock`  |                |             | Memory read data.                                                          |

## Operation

The controller maintains separate read and write pointers in their respective clock domains. It implements Gray-code conversion and synchronization for safe clock domain crossing, and calculates domain-specific full/empty flags. The controller doesn't store any data, only control state.

For **write operation** (in write clock domain), when `write_enable` is asserted, the controller generates `memory_write_enable`, provides the write address from the write pointer, and forwards `write_data` to `memory_write_data`. The write pointer is then incremented and converted to Gray code. The Gray-coded write pointer is synchronized to the read clock domain for empty flag calculation.

There is no safety mechanism against writing when full. The write pointer will advance and potentially overwrite unread data, corrupting the FIFO state.

For **read operation** (in read clock domain), the controller continuously provides the read address from the read pointer to `memory_read_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, `memory_read_enable` is generated and the read pointer is incremented and converted to Gray code. The Gray-coded read pointer is synchronized to the write clock domain for full flag calculation.

There is no safety mechanism against reading when empty. The read pointer will advance and potentially read invalid data, corrupting the FIFO state.

The **status flags** are calculated in each domain:
- **Full flag** (write domain): Compares write pointer with synchronized read pointer. Full when they differ only in the two MSBs (in Gray code).
- **Empty flag** (read domain): Compares read pointer with synchronized write pointer. Empty when they are equal (in Gray code).

The **clock domain crossing** uses Gray-code encoding to ensure only one bit changes at a time, preventing metastability issues. The Gray-coded pointers are synchronized using multi-stage synchronizers (`vector_synchronizer`) before being used in the opposite domain.

The **memory interface** provides separate write and read channels in their respective clock domains with enable, address, and data signals. The interface expects combinational reads from the asynchronous RAM.

## Paths

| From               | To                     | Type          | Comment                                    |
| ------------------ | ---------------------- | ------------- | ------------------------------------------ |
| `write_data`       | `memory_write_data`    | combinational | Direct pass-through (write domain).        |
| `write_enable`     | `memory_write_enable`  | combinational | Direct pass-through (write domain).        |
| `write_enable`     | `memory_write_address` | combinational | Address from write pointer (write domain). |
| `write_enable`     | `write_full`           | sequential    | Control path through write pointer (CDC).  |
| `read_enable`      | `memory_read_enable`   | combinational | Direct pass-through (read domain).         |
| `read_enable`      | `memory_read_address`  | combinational | Address from read pointer (read domain).   |
| `read_enable`      | `read_empty`           | sequential    | Control path through read pointer (CDC).   |
| `memory_read_data` | `read_data`            | combinational | Direct pass-through (read domain).         |

## Complexity

| Delay           | Gates           | Comment |
| --------------- | --------------- | ------- |
| `O(log₂ DEPTH)` | `O(log₂ DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `2×(log₂DEPTH+1)` flip-flops for the binary pointers, `2×(log₂DEPTH+1)` flip-flops for Gray-coded pointers, plus `2×STAGES×(log₂DEPTH+1)` flip-flops for the CDC synchronizers in each domain.

The critical path includes pointer incrementation, binary-to-Gray conversion, and Gray-code comparison for status flags. The CDC synchronizers add latency but not combinational delay within each domain.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

The module requires proper timing constraints for clock domain crossing:
- Define asynchronous clock groups between `write_clock` and `read_clock`
- Set maximum delay constraints on the Gray-coded pointer paths between domains
- Ensure synchronizer stages are properly constrained to allow metastability resolution

## Deliverables

| Type              | File                                                                                       | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`asynchronous_fifo_controller.v`](asynchronous_fifo_controller.v)                         | Verilog design.                                     |
| Symbol descriptor | [`asynchronous_fifo_controller.symbol.sss`](asynchronous_fifo_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`asynchronous_fifo_controller.symbol.svg`](asynchronous_fifo_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`asynchronous_fifo_controller.symbol.drawio`](asynchronous_fifo_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`asynchronous_fifo_controller.md`](asynchronous_fifo_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                | Path                                                          | Comment                                 |
| --------------------- | ------------------------------------------------------------- | --------------------------------------- |
| `binary_to_gray`      | `omnicores-buildingblocks/sources/encoding/gray`              | For converting pointers to Gray code.   |
| `gray_to_binary`      | `omnicores-buildingblocks/sources/encoding/gray`              | For converting pointers from Gray code. |
| `vector_synchronizer` | `omnicores-buildingblocks/sources/timing/vector_synchronizer` | For CDC-safe pointer synchronization.   |

## Related modules

| Module                                                                                                            | Path                                                                           | Comment                                                           |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| [`asynchronous_fifo`](../../access_enable/asynchronous_fifo/asynchronous_fifo.md)                                 | `omnicores-buildingblocks/sources/data/access_enable/asynchronous_fifo`        | Access-enable wrapper integrating this controller with async RAM. |
| [`fifo_controller`](../fifo/fifo_controller.md)                                                                   | `omnicores-buildingblocks/sources/data/controllers/fifo`                       | Synchronous FIFO controller for single clock domain.              |
| [`asynchronous_advanced_fifo_controller`](../asynchronous_advanced_fifo/asynchronous_advanced_fifo_controller.md) | `omnicores-buildingblocks/sources/data/controllers/asynchronous_advanced_fifo` | Advanced asynchronous FIFO with additional features.              |
