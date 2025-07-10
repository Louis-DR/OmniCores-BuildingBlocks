# LIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | LIFO                                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![lifo](lifo.symbol.svg)

Synchronous Last-In First-Out stack for data buffering and temporary storage with configurable depth. The LIFO uses a write-enable/read-enable protocol for flow control and provides full and empty status flags. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefully.

The read data output continuously shows the value at the top of the stack when not empty, allowing instant data access without necessarily popping the entry.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                     |
| ------- | ------- | -------------- | ------- | ------------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector.   |
| `DEPTH` | integer | `≥2`           | `4`     | Number of entries in the stack. |

## Ports

| Name           | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                |
| -------------- | --------- | ------- | ------------ | -------- | ----------- | -------------------------------------------------------------------------- |
| `clock`        | input     | 1       | self         |          |             | Clock signal.                                                              |
| `resetn`       | input     | 1       | asynchronous | self     | active-low  | Asynchronous active-low reset.                                             |
| `write_enable` | input     | 1       | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to stack.        |
| `write_data`   | input     | `WIDTH` | `clock`      |          |             | Data to be written to the stack.                                           |
| `full`         | output    | 1       | `clock`      | `resetn` | `0`         | Stack full status.<br/>`0`: stack has free space.<br/>`1`: stack is full.  |
| `read_enable`  | input     | 1       | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from stack.         |
| `read_data`    | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the stack top.                                              |
| `empty`        | output    | 1       | `clock`      | `resetn` | `1`         | Stack empty status.<br/>`0`: stack contains data.<br/>`1`: stack is empty. |

## Operation

The LIFO maintains an internal memory array indexed by a single stack pointer that tracks the current top of the stack.

For **write operation**, when `write_enable` is asserted, `write_data` is stored at the location pointed to by the stack pointer, and the stack pointer is incremented to point to the next available position.

There is no safety mechanism against writing when full. The stack pointer will be incremented beyond the valid range, potentially overwriting data and corrupting the full and empty flags, breaking the LIFO.

For **read operation**, the `read_data` output continuously provides the data at the top of the stack (stack pointer minus one). When `read_enable` is asserted, only the stack pointer is decremented to expose the previous entry as the new top.

There is no safety mechanism against reading when empty. The stack pointer will be decremented below zero, causing undefined behavior and corrupting the full and empty flags, breaking the LIFO.

If the stack is empty, data written can be read in the next cycle. When the stack is not empty nor full, it can be written to and read from at the same time, with the simultaneous operation replacing the current top item without changing the stack depth.

The status flags are calculated based on the stack pointer value. The stack is full when the pointer equals the maximum depth. The stack is empty when the pointer equals zero.

## Paths

| From           | To          | Type       | Comment                                              |
| -------------- | ----------- | ---------- | ---------------------------------------------------- |
| `write_data`   | `read_data` | sequential | Data path through internal memory array and pointer. |
| `write_enable` | `read_data` | sequential | Data path through internal memory array and pointer. |
| `write_enable` | `full`      | sequential | Control path through internal stack pointer.         |
| `write_enable` | `empty`     | sequential | Control path through internal stack pointer.         |
| `read_enable`  | `full`      | sequential | Control path through internal stack pointer.         |
| `read_enable`  | `empty`     | sequential | Control path through internal stack pointer.         |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array and `log₂DEPTH+1` flip-flops for the stack pointer.

Under tight timing constraints, the critical path delay might achieve `O(log₂ log₂ DEPTH)` complexity instead of `O(log₂ DEPTH)`, while sacrificing some area. This depends on how the synthesizer implements and optimizes the memory array indexing with the pointer, the pointer incrementation and decrementation during write and read operations, and the pointer comparison for the full and empty flags.

## Verification

The LIFO is verified using a SystemVerilog testbench with five check sequences that validate the stack operations and data integrity.

The following table lists the checks performed by the testbench.

| Number | Check                                       | Description                                                                                            |
| ------ | ------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1      | Writing to full                             | Fills the LIFO completely and verifies the flags.                                                      |
| 2      | Reading to empty                            | Empties the LIFO completely and verifies data integrity in LIFO order and the flags.                   |
| 3      | Successive read and write when almost empty | Performs simultaneous read and write operations when the stack is almost empty.                        |
| 4      | Successive read and write when almost full  | Performs simultaneous read and write operations when the stack is almost full.                         |
| 5      | Random stimulus                             | Performs random write and read operations and verifies data integrity against a reference stack model. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 4       | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                         | Description                                         |
| ----------------- | -------------------------------------------- | --------------------------------------------------- |
| Design            | [`lifo.v`](lifo.v)                           | Verilog design.                                     |
| Testbench         | [`lifo.testbench.sv`](lifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`lifo.testbench.gtkw`](lifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`lifo.symbol.sss`](lifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`lifo.symbol.svg`](lifo.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`lifo.md`](lifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                           | Path                                                                    | Comment                                                         |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`fifo`](../fifo/fifo.md)                                        | `omnicores-buildingblocks/sources/data/read_write_enable/fifo`          | First-In First-Out queue with opposite ordering behavior.       |
| [`valid_ready_lifo`](../../valid_ready/lifo/valid_ready_lifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/lifo`                | Variant of this module with valid-ready handshake flow control. |
| [`simple_buffer`](../simple_buffer/simple_buffer.md)             | `omnicores-buildingblocks/sources/data/read_write_enable/simple_buffer` | Single-entry buffer for storage.                                |
| [`skid_buffer`](../skid_buffer/skid_buffer.md)                   | `omnicores-buildingblocks/sources/data/read_write_enable/skid_buffer`   | Two-entry buffer for simple bus pipelining.                     |
