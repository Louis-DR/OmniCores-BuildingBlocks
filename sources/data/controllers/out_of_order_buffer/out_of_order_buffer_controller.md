# Out-of-Order Buffer Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Out-of-Order Buffer Controller                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![out_of_order_buffer_controller](out_of_order_buffer_controller.symbol.svg)

Controller for synchronous buffer that allows out-of-order reading of stored data entries. The controller manages validity tracking for each slot, implements first-free-slot allocation logic to assign write indices, generates memory interface signals, and calculates status flags. It doesn't implement safety mechanisms against incorrect usage, so the integration is responsible for ensuring correct operation.

The controller is designed to be integrated with a simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for validity bits and status flags.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name                   | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                               |
| ---------------------- | --------- | ------------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------------- |
| `clock`                | input     | 1             | self         |          |             | Clock signal.                                                                             |
| `resetn`               | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                            |
| `full`                 | output    | 1             | `clock`      | `resetn` | `0`         | Buffer full status.<br/>• `0`: buffer has free slots.<br/>• `1`: buffer is full.          |
| `empty`                | output    | 1             | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>• `0`: buffer contains data.<br/>• `1`: buffer is empty.         |
| `write_enable`         | input     | 1             | `clock`      |          |             | Write enable signal.<br/>• `0`: idle.<br/>• `1`: write data to buffer.                    |
| `write_data`           | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                                         |
| `write_index`          | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the allocated slot for the written data.                                         |
| `read_enable`          | input     | 1             | `clock`      |          |             | Read enable signal.<br/>• `0`: idle.<br/>• `1`: read data from buffer at specified index. |
| `read_clear`           | input     | 1             | `clock`      |          |             | Clear enable signal.<br/>• `0`: read only.<br/>• `1`: clear slot after reading.           |
| `read_index`           | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the slot to read from.                                                           |
| `read_data`            | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the buffer at the specified index.                                         |
| `memory_clock`         | output    | 1             |              |          |             | Clock for synchronous RAM.                                                                |
| `memory_write_enable`  | output    | 1             | `clock`      |          |             | Memory write enable signal.                                                               |
| `memory_write_address` | output    | `INDEX_WIDTH` | `clock`      |          |             | Memory write address.                                                                     |
| `memory_write_data`    | output    | `WIDTH`       | `clock`      |          |             | Memory write data.                                                                        |
| `memory_read_enable`   | output    | 1             | `clock`      |          |             | Memory read enable signal.                                                                |
| `memory_read_address`  | output    | `INDEX_WIDTH` | `clock`      |          |             | Memory read address.                                                                      |
| `memory_read_data`     | input     | `WIDTH`       | `clock`      |          |             | Memory read data.                                                                         |

## Operation

The controller maintains a validity bit for each slot and implements first-free-slot logic to allocate write indices. It generates the memory interface signals and calculates the status flags. The controller doesn't store any data, only control state.

For **write operation**, when `write_enable` is asserted, the controller identifies the first available free slot by scanning the validity bits using the `first_one` module. It generates `memory_write_enable`, provides the allocated slot index as `memory_write_address`, and forwards `write_data` to `memory_write_data`. The `write_index` output provides the index of the allocated slot on the same cycle. The slot becomes valid and available for reading in the next cycle.

The integration must check the `full` flag before asserting `write_enable`. If a write is attempted when full, the write operation will override the first entry of the buffer (index 0) and the buffer will continue to function but with corrupted data.

For **read operation**, the controller continuously provides the read address from `read_index` to `memory_read_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, `memory_read_enable` is generated. When both `read_enable` and `read_clear` are asserted, the slot is marked as invalid, thus freed for future writes.

The integration must only read from indices that contain valid data. The `read_data` may contain data previously stored at an invalid index, as the data is not cleared when an entry is invalidated.

The status flags are calculated based on the vector of valid bits. The buffer is full when there are no free slots (all validity bits set), and empty when all the slots are free (no validity bits set).

The **memory interface** provides separate write and read channels with enable, address, and data signals. The interface expects combinational reads from the memory, where the data at the read address appears immediately on the read data output without additional latency.

## Paths

| From               | To                     | Type          | Comment                                                    |
| ------------------ | ---------------------- | ------------- | ---------------------------------------------------------- |
| `write_data`       | `memory_write_data`    | combinational | Direct pass-through.                                       |
| `write_enable`     | `memory_write_enable`  | combinational | Direct pass-through.                                       |
| `write_enable`     | `memory_write_address` | combinational | Address from first-free-slot logic.                        |
| `write_enable`     | `write_index`          | combinational | Index from first-free-slot logic.                          |
| `write_enable`     | `full`                 | sequential    | Control path through internal validity bits.               |
| `write_enable`     | `empty`                | sequential    | Control path through internal validity bits.               |
| `read_index`       | `memory_read_address`  | combinational | Direct pass-through.                                       |
| `read_enable`      | `memory_read_enable`   | combinational | Direct pass-through.                                       |
| `read_enable`      | `full`                 | sequential    | Control path through internal validity bits (if clearing). |
| `read_enable`      | `empty`                | sequential    | Control path through internal validity bits (if clearing). |
| `read_clear`       | `full`                 | sequential    | Control path through internal validity bits.               |
| `read_clear`       | `empty`                | sequential    | Control path through internal validity bits.               |
| `memory_read_data` | `read_data`            | combinational | Direct pass-through.                                       |

## Complexity

| Delay          | Gates      | Comment |
| -------------- | ---------- | ------- |
| `O(log DEPTH)` | `O(DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `DEPTH` flip-flops for the validity bits.

The critical path includes the first-free-slot finding logic which has logarithmic delay complexity depending on the implementation variant selected in the `first_one` module.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                           | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`out_of_order_buffer_controller.sv`](out_of_order_buffer_controller.sv)                       | SystemVerilog design.                               |
| Symbol descriptor | [`out_of_order_buffer_controller.symbol.sss`](out_of_order_buffer_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`out_of_order_buffer_controller.symbol.svg`](out_of_order_buffer_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`out_of_order_buffer_controller.symbol.drawio`](out_of_order_buffer_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`out_of_order_buffer_controller.md`](out_of_order_buffer_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module             | Path                                                    | Comment                                      |
| ------------------ | ------------------------------------------------------- | -------------------------------------------- |
| `first_one`        | `omnicores-buildingblocks/sources/operations/first_one` | Used for finding the first free slot.        |
| `onehot_to_binary` | `omnicores-buildingblocks/sources/encoding/onehot`      | Used for converting one-hot to binary index. |

## Related modules

| Module                                                                                  | Path                                                                      | Comment                                                     |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [`out_of_order_buffer`](../../access_enable/out_of_order_buffer/out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/out_of_order_buffer` | Access-enable wrapper integrating this controller with RAM. |
| [`reorder_buffer_controller`](../reorder_buffer/reorder_buffer_controller.md)           | `omnicores-buildingblocks/sources/data/controllers/reorder_buffer`        | Controller for reorder buffer with similar indexing logic.  |
