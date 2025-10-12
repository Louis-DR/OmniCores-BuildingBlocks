# Reorder Buffer Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Reorder Buffer Controller                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![reorder_buffer_controller](reorder_buffer_controller.symbol.svg)

Controller for synchronous buffer with in-order reservation, out-of-order writing, and in-order reading. The controller manages reservation tracking, dual pointer management (reservation and read), validity bits for tracking written data, generates memory interface signals, and calculates status flags. It doesn't implement safety mechanisms against incorrect usage, so the integration is responsible for ensuring correct operation.

The controller is designed to be integrated with a simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for reservation tracking, pointers, validity bits, and status flags.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name                   | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                                         |
| ---------------------- | --------- | ------------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------------------- |
| `clock`                | input     | 1             | self         |          |             | Clock signal.                                                                                       |
| `resetn`               | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                      |
| `reserve_full`         | output    | 1             | `clock`      | `resetn` | `0`         | Reservation full status.<br/>`0`: slots available for reservation.<br/>`1`: all slots reserved.     |
| `reserve_empty`        | output    | 1             | `clock`      | `resetn` | `1`         | Reservation empty status.<br/>`0`: slots are reserved.<br/>`1`: no slots reserved.                  |
| `data_full`            | output    | 1             | `clock`      | `resetn` | `0`         | Data full status.<br/>`0`: not all reserved slots have data.<br/>`1`: all reserved slots have data. |
| `data_empty`           | output    | 1             | `clock`      | `resetn` | `1`         | Data empty status.<br/>`0`: some slots have valid data.<br/>`1`: no slots have valid data.          |
| `reserve_enable`       | input     | 1             | `clock`      |          |             | Reservation enable signal.<br/>`0`: idle.<br/>`1`: reserve next slot in order.                      |
| `reserve_index`        | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the reserved slot.                                                                         |
| `write_enable`         | input     | 1             | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write data to specified reserved index.                |
| `write_index`          | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the reserved slot to write to.                                                             |
| `write_data`           | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                                                   |
| `read_enable`          | input     | 1             | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read next data in order.                                |
| `read_data`            | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the buffer in order.                                                                 |
| `memory_clock`         | output    | 1             |              |          |             | Clock for synchronous RAM.                                                                          |
| `memory_write_enable`  | output    | 1             | `clock`      |          |             | Memory write enable signal.                                                                         |
| `memory_write_address` | output    | `INDEX_WIDTH` | `clock`      |          |             | Memory write address.                                                                               |
| `memory_write_data`    | output    | `WIDTH`       | `clock`      |          |             | Memory write data.                                                                                  |
| `memory_read_enable`   | output    | 1             | `clock`      |          |             | Memory read enable signal.                                                                          |
| `memory_read_address`  | output    | `INDEX_WIDTH` | `clock`      |          |             | Memory read address.                                                                                |
| `memory_read_data`     | input     | `WIDTH`       | `clock`      |          |             | Memory read data.                                                                                   |

## Operation

The controller maintains separate reservation and read pointers, a validity bit vector tracking which slots contain written data, and a reserved bit vector tracking which slots have been reserved. It generates the memory interface signals and calculates the status flags. The controller doesn't store any data, only control state.

For **reservation operation**, when `reserve_enable` is asserted, the controller allocates the next slot in order by advancing the reservation pointer. The `reserve_index` output provides the index of the reserved slot on the same cycle. The slot is marked as reserved and available for writing.

The integration must check the `reserve_full` flag before asserting `reserve_enable`. If a reservation is attempted when full, the reservation pointer will advance beyond valid entries, causing undefined behavior.

For **write operation**, when `write_enable` is asserted, the controller generates `memory_write_enable`, provides the write address from `write_index` to `memory_write_address`, and forwards `write_data` to `memory_write_data`. The slot at the specified index is marked as valid (containing data). Writes can occur out-of-order to any previously reserved index.

The integration must only write to indices that have been reserved. Writing to an unreserved index may cause undefined behavior.

For **read operation**, the controller continuously provides the read address from the read pointer to `memory_read_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, the controller checks if the next slot in order has valid data. If valid, `memory_read_enable` is generated, the slot is marked as no longer reserved or valid, and the read pointer advances to the next slot.

The integration must check the `data_empty` flag before asserting `read_enable` to ensure data is available at the next read position.

The status flags are calculated based on the pointers and validity vectors:
- **Reservation status**: `reserve_full` when reservation pointer catches read pointer (different lap bits), `reserve_empty` when pointers are equal.
- **Data status**: `data_full` when all validity bits are set, `data_empty` when no validity bits are set.

The **memory interface** provides separate write and read channels with enable, address, and data signals. The interface expects combinational reads from the memory, where the data at the read address appears immediately on the read data output without additional latency.

## Paths

| From               | To                     | Type          | Comment                                            |
| ------------------ | ---------------------- | ------------- | -------------------------------------------------- |
| `reserve_enable`   | `reserve_index`        | combinational | Index from reservation pointer.                    |
| `reserve_enable`   | `reserve_full`         | sequential    | Control path through internal reservation pointer. |
| `reserve_enable`   | `reserve_empty`        | sequential    | Control path through internal reservation pointer. |
| `write_index`      | `memory_write_address` | combinational | Direct pass-through.                               |
| `write_data`       | `memory_write_data`    | combinational | Direct pass-through.                               |
| `write_enable`     | `memory_write_enable`  | combinational | Direct pass-through.                               |
| `write_enable`     | `data_full`            | sequential    | Control path through internal validity bits.       |
| `write_enable`     | `data_empty`           | sequential    | Control path through internal validity bits.       |
| `read_enable`      | `memory_read_enable`   | combinational | Gated by validity check.                           |
| `read_enable`      | `memory_read_address`  | combinational | Address from read pointer.                         |
| `read_enable`      | `reserve_full`         | sequential    | Control path through internal read pointer.        |
| `read_enable`      | `reserve_empty`        | sequential    | Control path through internal read pointer.        |
| `read_enable`      | `data_full`            | sequential    | Control path through internal validity bits.       |
| `read_enable`      | `data_empty`           | sequential    | Control path through internal validity bits.       |
| `memory_read_data` | `read_data`            | combinational | Direct pass-through.                               |

## Complexity

| Delay           | Gates      | Comment |
| --------------- | ---------- | ------- |
| `O(log₂ DEPTH)` | `O(DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `2×(log₂DEPTH+1)` flip-flops for the reservation and read pointers with wrap bits, plus `DEPTH` flip-flops for the validity bits and `DEPTH` flip-flops for the reservation bits.

The critical path includes pointer comparison and validity checking logic.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                 | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`reorder_buffer_controller.sv`](reorder_buffer_controller.sv)                       | SystemVerilog design.                               |
| Symbol descriptor | [`reorder_buffer_controller.symbol.sss`](reorder_buffer_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`reorder_buffer_controller.symbol.svg`](reorder_buffer_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`reorder_buffer_controller.symbol.drawio`](reorder_buffer_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`reorder_buffer_controller.md`](reorder_buffer_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                                       | Path                                                                    | Comment                                                       |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------- |
| [`reorder_buffer`](../../access_enable/reorder_buffer/reorder_buffer.md)                     | `omnicores-buildingblocks/sources/data/access_enable/reorder_buffer`    | Access-enable wrapper integrating this controller with RAM.   |
| [`out_of_order_buffer_controller`](../out_of_order_buffer/out_of_order_buffer_controller.md) | `omnicores-buildingblocks/sources/data/controllers/out_of_order_buffer` | Controller for out-of-order buffer with similar architecture. |
