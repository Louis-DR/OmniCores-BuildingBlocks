# LIFO Controller

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | LIFO Controller                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![lifo_controller](lifo_controller.symbol.svg)

Controller for synchronous Last-In First-Out stack pointer management and status logic. The controller manages a single stack pointer that tracks the top of the stack, generates memory interface signals, and calculates status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefully.

The controller is designed to be integrated with a simple dual-port RAM for data storage. It provides a clean separation between control logic and data storage, allowing easy replacement of the memory with technology-specific implementations during ASIC integration. The dual-port interface allows the read port to continuously provide the top-of-stack value, ensuring combinational read access with zero latency.

The controller passes data through without storing it. The `write_data` is forwarded to the memory write interface, and the `read_data` is provided directly from the memory read interface. The controller only maintains state for the stack pointer and status flags. When simultaneous read and write occur, the memory access targets the same location (top of stack), effectively replacing the top element.

## Parameters

| Name         | Type    | Allowed Values | Default       | Description                                     |
| ------------ | ------- | -------------- | ------------- | ----------------------------------------------- |
| `WIDTH`      | integer | `≥1`           | `8`           | Bit width of the data vector.                   |
| `DEPTH`      | integer | `≥2`           | `4`           | Number of entries in the stack.                 |
| `DEPTH_LOG2` | integer | `≥1`           | `log₂(DEPTH)` | Log base 2 of depth (automatically calculated). |

## Ports

| Name                  | Direction | Width        | Clock        | Reset    | Reset value | Description                                                                |
| --------------------- | --------- | ------------ | ------------ | -------- | ----------- | -------------------------------------------------------------------------- |
| `clock`               | input     | 1            | self         |          |             | Clock signal.                                                              |
| `resetn`              | input     | 1            | asynchronous | self     | active-low  | Asynchronous active-low reset.                                             |
| `full`                | output    | 1            | `clock`      | `resetn` | `0`         | Stack full status.<br/>`0`: stack has free space.<br/>`1`: stack is full.  |
| `empty`               | output    | 1            | `clock`      | `resetn` | `1`         | Stack empty status.<br/>`0`: stack contains data.<br/>`1`: stack is empty. |
| `write_enable`        | input     | 1            | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to stack.        |
| `write_data`          | input     | `WIDTH`      | `clock`      |          |             | Data to be written to the stack.                                           |
| `read_enable`         | input     | 1            | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from stack.         |
| `read_data`           | output    | `WIDTH`      | `clock`      | `resetn` | `0`         | Data read from the stack top.                                              |
| `memory_enable`       | output    | 1            | `clock`      |          |             | Memory access enable signal.                                               |
| `memory_write_enable` | output    | 1            | `clock`      |          |             | Memory write enable signal.                                                |
| `memory_address`      | output    | `DEPTH_LOG2` | `clock`      |          |             | Memory access address.                                                     |
| `memory_write_data`   | output    | `WIDTH`      | `clock`      |          |             | Memory write data.                                                         |
| `memory_read_data`    | input     | `WIDTH`      | `clock`      |          |             | Memory read data.                                                          |

## Operation

The controller maintains a single stack pointer that tracks the current top of the stack. It generates the memory interface signals and calculates the status flags. The controller doesn't store any data, only control state.

For **write operation**, when `write_enable` is asserted, the controller generates `memory_enable` and `memory_write_enable`, provides the write address from the stack pointer, and forwards `write_data` to `memory_write_data`. The stack pointer is then incremented to point to the next available position.

There is no safety mechanism against writing when full. The stack pointer will be incremented beyond the valid range, potentially overwriting data and corrupting the full and empty flags, breaking the LIFO.

For **read operation**, the controller continuously provides the read address (stack pointer minus one) to `memory_address`, and the `read_data` output directly reflects `memory_read_data`. When `read_enable` is asserted, `memory_enable` is generated and the stack pointer is decremented to expose the previous entry as the new top.

There is no safety mechanism against reading when empty. The stack pointer will be decremented below zero, causing undefined behavior and corrupting the full and empty flags, breaking the LIFO.

If the stack is empty, data written can be read in the next cycle. When the stack is not empty nor full, it can be written to and read from at the same time. In this case, the memory address points to the top of the stack (read address), effectively replacing the current top item without changing the stack depth.

The status flags are calculated based on the stack pointer value. The stack is full when the pointer equals the maximum depth. The stack is empty when the pointer equals zero.

The **memory interface** uses a dual-port RAM with separate write and read ports. The write port is used for push operations, and the read port continuously reads from pointer - 1 to provide combinational access to the current top-of-stack value. The interface expects combinational reads from the memory, where the data at the read address appears immediately on the read data output without additional latency.

## Paths

| From               | To                    | Type          | Comment                                      |
| ------------------ | --------------------- | ------------- | -------------------------------------------- |
| `write_data`       | `memory_write_data`   | combinational | Direct pass-through.                         |
| `write_enable`     | `memory_enable`       | combinational | Direct pass-through (combined with read).    |
| `write_enable`     | `memory_write_enable` | combinational | Direct pass-through.                         |
| `write_enable`     | `memory_address`      | combinational | Address from stack pointer logic.            |
| `write_enable`     | `full`                | sequential    | Control path through internal stack pointer. |
| `write_enable`     | `empty`               | sequential    | Control path through internal stack pointer. |
| `read_enable`      | `memory_enable`       | combinational | Direct pass-through (combined with write).   |
| `read_enable`      | `memory_address`      | combinational | Address from stack pointer logic.            |
| `read_enable`      | `full`                | sequential    | Control path through internal stack pointer. |
| `read_enable`      | `empty`               | sequential    | Control path through internal stack pointer. |
| `memory_read_data` | `read_data`           | combinational | Direct pass-through.                         |

## Complexity

| Delay           | Gates           | Comment |
| --------------- | --------------- | ------- |
| `O(log₂ DEPTH)` | `O(log₂ DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The controller requires `log₂DEPTH+1` flip-flops for the stack pointer.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the pointer incrementation and decrementation during write and read operations, and the pointer comparison for the full and empty flags.

## Verification

The controller does not have a standalone testbench as its functionality is fully exercised and verified through the testbenches of the modules that integrate it.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`lifo_controller.v`](lifo_controller.v)                         | Verilog design.                                     |
| Symbol descriptor | [`lifo_controller.symbol.sss`](lifo_controller.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`lifo_controller.symbol.svg`](lifo_controller.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`lifo_controller.symbol.drawio`](lifo_controller.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`lifo_controller.md`](lifo_controller.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                                 | Path                                                                  | Comment                                                        |
| -------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------------------------------------------------------------- |
| [`lifo`](../../access_enable/lifo/lifo.md)                                             | `omnicores-buildingblocks/sources/data/access_enable/lifo`            | Access-enable wrapper integrating this controller with RAM.    |
| [`fifo_controller`](../fifo/fifo_controller.md)                                        | `omnicores-buildingblocks/sources/data/controllers/fifo`              | First-In First-Out controller with similar architecture.       |
| [`advanced_fifo_controller`](../advanced_fifo/advanced_fifo_controller.md)             | `omnicores-buildingblocks/sources/data/controllers/advanced_fifo`     | Controller with additional features and protection mechanisms. |
| [`asynchronous_fifo_controller`](../asynchronous_fifo/asynchronous_fifo_controller.md) | `omnicores-buildingblocks/sources/data/controllers/asynchronous_fifo` | Asynchronous FIFO controller for clock domain crossing.        |
