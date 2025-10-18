# Valid-Ready LIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready LIFO                                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_lifo](valid_ready_lifo.symbol.svg)

Synchronous Last-In First-Out stack for data buffering and temporary storage with configurable depth and valid-ready handshake flow control. The LIFO provides full and empty status flags and implements a handshake protocol where transfers only occur when both valid and ready signals are asserted. The handshake protocol manages and protects flow control, providing inherent backpressure and safety.

The design is structured as a modular architecture with valid-ready handshake logic wrapping a separate controller for pointer management and control logic, and a generic single-port RAM for data storage. This allows easy replacement of the memory with technology-specific implementations during ASIC integration. The single-port RAM is sufficient because the LIFO accesses the same location for both reads and writes at the top of the stack, and simultaneous read/write operations simply replace the top element.

The read data output continuously shows the value at the top of the stack when not empty, allowing instant data access without necessarily popping the entry. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                     |
| ------- | ------- | -------------- | ------- | ------------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector.   |
| `DEPTH` | integer | `≥2`           | `4`     | Number of entries in the stack. |

## Ports

| Name          | Direction | Width   | Clock        | Reset    | Reset value | Description                                                                           |
| ------------- | --------- | ------- | ------------ | -------- | ----------- | ------------------------------------------------------------------------------------- |
| `clock`       | input     | 1       | self         |          |             | Clock signal.                                                                         |
| `resetn`      | input     | 1       | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                        |
| `full`        | output    | 1       | `clock`      | `resetn` | `0`         | Stack full status.<br/>• `0`: stack has free space.<br/>• `1`: stack is full.         |
| `empty`       | output    | 1       | `clock`      | `resetn` | `1`         | Stack empty status.<br/>• `0`: stack contains data.<br/>• `1`: stack is empty.        |
| `write_data`  | input     | `WIDTH` | `clock`      |          |             | Data to be written to the stack.                                                      |
| `write_valid` | input     | 1       | `clock`      |          |             | Write valid signal.<br/>• `0`: no write transaction.<br/>• `1`: write data is valid.  |
| `write_ready` | output    | 1       | `clock`      | `resetn` | `1`         | Write ready signal.<br/>• `0`: stack is full.<br/>• `1`: stack can accept write data. |
| `read_data`   | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Data read from the stack head.                                                        |
| `read_valid`  | output    | 1       | `clock`      | `resetn` | `0`         | Read valid signal.<br/>• `0`: no read data available.<br/>• `1`: read data is valid.  |
| `read_ready`  | input     | 1       | `clock`      |          |             | Read ready signal.<br/>• `0`: not ready to receive.<br/>• `1`: ready to receive data. |

## Operation

The valid-ready LIFO consists of three main components: handshake logic that implements the valid-ready protocol, a controller that manages the pointer and status flags, and a single-port RAM for data storage.

The **handshake logic** derives enable signals from the valid-ready protocol. A write enable is generated when both `write_valid` and `write_ready` are asserted. A read enable is generated when both `read_valid` and `read_ready` are asserted. The `write_ready` signal is driven by the inverse of the `full` flag, providing inherent backpressure when the stack is full. The `read_valid` signal is driven by the inverse of the `empty` flag, preventing reads from an empty stack.

The **controller** maintains a single stack pointer that tracks the current top of the stack. It generates the memory interface signals and calculates the status flags. The controller doesn't store any data, only control state. When simultaneous read and write occur, the controller implements a combinational bypass to provide the written data directly to the read output, since the single-port RAM would not support simultaneous access to different addresses.

The **single-port RAM** provides a single access port with combinational reads. The use of a single-port RAM is efficient for LIFO because reads and writes always target adjacent locations (top of stack), and simultaneous operations can be handled by the controller's bypass logic.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The controller directs the RAM to store `write_data` at the location pointed to by the stack pointer, and the stack pointer is incremented to point to the next available position. When the stack is full, `write_ready` is deasserted, preventing write transfers and providing safety.

For **read operation**, the `read_data` output continuously provides the data at the top of the stack (stack pointer minus one) from the RAM. A read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The stack pointer is decremented to expose the previous entry as the new top. When the stack is empty, `read_valid` is deasserted, preventing read transfers and providing safety.

If the stack is empty, data written can be read in the next cycle. When the stack is not empty nor full, it can be written to and read from at the same time, with the simultaneous operation replacing the current top item without changing the stack depth.

The status flags are calculated based on the stack pointer value. The stack is full when the pointer equals the maximum depth. The stack is empty when the pointer equals zero.

## Paths

| From          | To            | Type       | Comment                                               |
| ------------- | ------------- | ---------- | ----------------------------------------------------- |
| `write_data`  | `read_data`   | sequential | Data path through internal memory array and pointers. |
| `write_valid` | `read_valid`  | sequential | Control path through internal pointers.               |
| `write_valid` | `write_ready` | sequential | Control path through internal pointers.               |
| `read_ready`  | `read_valid`  | sequential | Control path through internal pointers.               |
| `read_ready`  | `write_ready` | sequential | Control path through internal pointers.               |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The RAM requires `WIDTH×DEPTH` flip-flops for the memory array. The controller requires `log₂DEPTH+1` flip-flops for the stack pointer. The handshake wrapper adds minimal logic for the valid-ready protocol conversion.

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

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_lifo.v`](valid_ready_lifo.v)                           | Verilog design.                                     |
| Testbench         | [`valid_ready_lifo.testbench.sv`](valid_ready_lifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_lifo.testbench.gtkw`](valid_ready_lifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_lifo.symbol.sss`](valid_ready_lifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_lifo.symbol.svg`](valid_ready_lifo.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_lifo.symbol.drawio`](valid_ready_lifo.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_lifo.md`](valid_ready_lifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module            | Path                                                      | Comment                                  |
| ----------------- | --------------------------------------------------------- | ---------------------------------------- |
| `lifo_controller` | `omnicores-buildingblocks/sources/data/controllers/lifo`  | Controller for pointer and status logic. |
| `single_port_ram` | `omnicores-buildingblocks/sources/memory/single_port_ram` | Single-port RAM for data storage.        |

## Related modules

| Module                                                                                   | Path                                                              | Comment                                                               |
| ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| [`lifo`](../../access_enable/lifo/lifo.md)                                               | `omnicores-buildingblocks/sources/data/access_enable/lifo`        | Variant of this module with read-write-enable handshake flow control. |
| [`valid_ready_fifo`](../valid_ready/fifo/valid_ready_fifo.md)                            | `omnicores-buildingblocks/sources/data/valid_ready/fifo`          | First-In First-Out queue with opposite ordering behavior.             |
| [`valid_ready_simple_buffer`](../valid_ready/simple_buffer/valid_ready_simple_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer` | Single-entry buffer for storage.                                      |
| [`valid_ready_skid_buffer`](../valid_ready/skid_buffer/valid_ready_skid_buffer.md)       | `omnicores-buildingblocks/sources/data/valid_ready/skid_buffer`   | Two-entry buffer for simple bus pipelining.                           |
