# FIFO Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | FIFO Controller                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![fifo_controller](fifo_controller.symbol.svg)

Controller for synchronous First-In First-Out queue pointer management and status logic. The controller manages separate read and write pointers with wrap bits for correct full/empty detection, generates memory interface signals, and calculates status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefully.

The controller is designed to be integrated with a simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for pointers and status flags.

## Parameters

| Name         | Type    | Allowed Values    | Default       | Description                                     |
| ------------ | ------- | ----------------- | ------------- | ----------------------------------------------- |
| `WIDTH`      | integer | `≥1`              | `8`           | Bit width of the data vector.                   |
| `DEPTH`      | integer | `≥2` power-of-two | `4`           | Number of entries in the queue.                 |
| `DEPTH_LOG2` | integer | `≥1`              | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated). |

## Ports

| Name                   | Direction | Width        | Clock        | Reset    | Reset value | Description                                                                    |
| ---------------------- | --------- | ------------ | ------------ | -------- | ----------- | ------------------------------------------------------------------------------ |
| `clock`                | input     | 1            | self         |          |             | Clock signal.                                                                  |
| `resetn`               | input     | 1            | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                 |
| `full`                 | output    | 1            | `clock`      | `resetn` | `0`         | Queue full status.<br/>• `0`: queue has free space.<br/>• `1`: queue is full.  |
| `empty`                | output    | 1            | `clock`      | `resetn` | `1`         | Queue empty status.<br/>• `0`: queue contains data.<br/>• `1`: queue is empty. |
| `write_enable`         | input     | 1            | `clock`      |          |             | Write enable signal.<br/>• `0`: idle.<br/>• `1`: write (push) to queue.        |
| `write_data`           | input     | `WIDTH`      | `clock`      |          |             | Data to be written to the queue.                                               |
| `read_enable`          | input     | 1            | `clock`      |          |             | Read enable signal.<br/>• `0`: idle.<br/>• `1`: read (pop) from queue.         |
| `read_data`            | output    | `WIDTH`      | `clock`      | `resetn` | `0`         | Data read from the queue head.                                                 |
| `memory_clock`         | output    | 1            |              |          |             | Clock for synchronous RAM.                                                     |
| `memory_write_enable`  | output    | 1            | `clock`      |          |             | Memory write enable signal.                                                    |
| `memory_write_address` | output    | `DEPTH_LOG2` | `clock`      |          |             | Memory write address.                                                          |
| `memory_write_data`    | output    | `WIDTH`      | `clock`      |          |             | Memory write data.                                                             |
| `memory_read_enable`   | output    | 1            | `clock`      |          |             | Memory read enable signal.                                                     |
| `memory_read_address`  | output    | `DEPTH_LOG2` | `clock`      |          |             | Memory read address.                                                           |
| `memory_read_data`     | input     | `WIDTH`      | `clock`      |          |             | Memory read data.                                                              |

## Operation

The controller maintains separate read and write pointers, each with an additional wrap bit for correct full/empty detection. It generates the memory interface signals and calculates the status flags. The controller doesn't store any data, only control state.

For **write operation**, when `write_enable` is asserted, the controller generates `memory_write_enable`, provides the write address from the write pointer, and forwards `write_data` to `memory_write_data`. The write pointer is then incremented.

There is no safety mechanism against writing when full. The write pointer will be incremented and surpass the read pointer, overwriting the data at the head, corrupting the full and empty flags, and breaking the FIFO.

For **read operation**, the controller continuously provides the read address from the read pointer to `memory_read_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, `memory_read_enable` is generated and the read pointer is incremented to advance to the next entry.

There is no safety mechanism against reading when empty. The read pointer will be incremented and surpass the write pointer, causing the next data written to be lost, corrupting the full and empty flags, and breaking the FIFO.

If the queue is empty, data written can be read in the next cycle. When the queue is not empty nor full, it can be written to and read from at the same time with back-to-back transactions at full throughput.

The status flags are calculated based on the read and write pointers. The queue is full if the read and write pointers are the same but the wrap bits are different. The queue is empty if the read and write pointers are the same and the wrap bits are equal.

The **memory interface** provides separate write and read channels with enable, address, and data signals. The interface expects combinational reads from the memory, where the data at the read address appears immediately on the read data output without additional latency.

## Paths

| From               | To                     | Type          | Comment                                      |
| ------------------ | ---------------------- | ------------- | -------------------------------------------- |
| `write_data`       | `memory_write_data`    | combinational | Direct pass-through.                         |
| `write_enable`     | `memory_write_enable`  | combinational | Direct pass-through.                         |
| `write_enable`     | `memory_write_address` | combinational | Address from write pointer.                  |
| `write_enable`     | `full`                 | sequential    | Control path through internal write pointer. |
| `write_enable`     | `empty`                | sequential    | Control path through internal write pointer. |
| `read_enable`      | `memory_read_enable`   | combinational | Direct pass-through.                         |
| `read_enable`      | `memory_read_address`  | combinational | Address from read pointer.                   |
| `read_enable`      | `full`                 | sequential    | Control path through internal read pointer.  |
| `read_enable`      | `empty`                | sequential    | Control path through internal read pointer.  |
| `memory_read_data` | `read_data`            | combinational | Direct pass-through.                         |

## Complexity

| Delay           | Gates           | Comment |
| --------------- | --------------- | ------- |
| `O(log₂ DEPTH)` | `O(log₂ DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `2×(log₂DEPTH+1)` flip-flops for the read and write pointers with wrap bits.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the pointer incrementation during read and write operation, and the pointer comparison for the full and empty flags.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`fifo_controller.v`](fifo_controller.v)                         | Verilog design.                                     |
| Symbol descriptor | [`fifo_controller.symbol.sss`](fifo_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`fifo_controller.symbol.svg`](fifo_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`fifo_controller.symbol.drawio`](fifo_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`fifo_controller.md`](fifo_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                                 | Path                                                                  | Comment                                                        |
| -------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------------------------------------------------------------- |
| [`fifo`](../../access_enable/fifo/fifo.md)                                             | `omnicores-buildingblocks/sources/data/access_enable/fifo`            | Access-enable wrapper integrating this controller with RAM.    |
| [`advanced_fifo_controller`](../advanced_fifo/advanced_fifo_controller.md)             | `omnicores-buildingblocks/sources/data/controllers/advanced_fifo`     | Controller with additional features and protection mechanisms. |
| [`lifo_controller`](../lifo/lifo_controller.md)                                        | `omnicores-buildingblocks/sources/data/controllers/lifo`              | Last-In First-Out controller with similar architecture.        |
| [`asynchronous_fifo_controller`](../asynchronous_fifo/asynchronous_fifo_controller.md) | `omnicores-buildingblocks/sources/data/controllers/asynchronous_fifo` | Asynchronous FIFO controller for clock domain crossing.        |
