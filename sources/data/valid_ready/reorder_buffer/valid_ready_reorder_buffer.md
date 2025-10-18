# Valid-Ready Reorder Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Reorder Buffer                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_reorder_buffer](valid_ready_reorder_buffer.symbol.svg)

Synchronous buffer that ensures in-order data reading from out-of-order data writes with valid-ready handshake flow control. The buffer operates with a three-stage protocol: in-order reservation of slots, out-of-order writing to reserved slots, and in-order reading of written data. The handshake protocol ensures that transfers only occur when both valid and ready signals are asserted, providing inherent backpressure and safety.

The design is structured as a modular architecture with valid-ready handshake logic wrapping a separate controller for dual-pointer management and validity tracking, and a generic simple dual-port RAM for data storage. This allows easy replacement of the memory with technology-specific implementations during ASIC integration.

The buffer maintains separate reservation and read pointers to track the order of operations. Data can only be read when it becomes available at the head of the queue (read pointer position), ensuring strict in-order delivery even when writes complete out of order.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name            | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                                         |
| --------------- | --------- | ------------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------------------- |
| `clock`         | input     | 1             | self         |          |             | Clock signal.                                                                                       |
| `resetn`        | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                      |
| `reserve_full`  | output    | 1             | `clock`      | `resetn` | `0`         | Reservation full status.<br/>• `0`: buffer has free reservation slots.<br/>• `1`: buffer is full.   |
| `reserve_empty` | output    | 1             | `clock`      | `resetn` | `1`         | Reservation empty status.<br/>• `0`: buffer has reserved slots.<br/>• `1`: buffer is empty.         |
| `data_full`     | output    | 1             | `clock`      | `resetn` | `0`         | Data full status.<br/>• `0`: buffer has unwritten slots.<br/>• `1`: all reserved slots are written. |
| `data_empty`    | output    | 1             | `clock`      | `resetn` | `1`         | Data empty status.<br/>• `0`: buffer has written data.<br/>• `1`: no written data available.        |
| `reserve_valid` | input     | 1             | `clock`      |          |             | Reserve valid signal.<br/>• `0`: no reserve transaction.<br/>• `1`: request slot reservation.       |
| `reserve_index` | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the reserved slot.                                                                         |
| `reserve_ready` | output    | 1             | `clock`      | `resetn` | `1`         | Reserve ready signal.<br/>• `0`: buffer is full.<br/>• `1`: buffer can accept reservation.          |
| `write_valid`   | input     | 1             | `clock`      |          |             | Write valid signal.<br/>• `0`: no write transaction.<br/>• `1`: write data is valid.                |
| `write_index`   | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the slot to write to (must be previously reserved).                                        |
| `write_data`    | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                                                   |
| `write_ready`   | output    | 1             | `clock`      | `resetn` | `1`         | Write ready signal.<br/>• `0`: buffer data is full.<br/>• `1`: buffer can accept write data.        |
| `write_error`   | output    | 1             | `clock`      | `resetn` | `0`         | Write error pulse.<br/>• `0`: no error.<br/>• `1`: invalid index write attempted.                   |
| `read_valid`    | output    | 1             | `clock`      | `resetn` | `0`         | Read valid signal.<br/>• `0`: no data at head.<br/>• `1`: valid data available at head of queue.    |
| `read_data`     | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the head of the queue.                                                               |
| `read_ready`    | input     | 1             | `clock`      |          |             | Read ready signal.<br/>• `0`: not ready to receive.<br/>• `1`: ready to receive data from buffer.   |

## Operation

The valid-ready reorder buffer consists of three main components: handshake logic that implements the valid-ready protocol, a controller that manages dual pointers and validity tracking, and a simple dual-port RAM for data storage.

The **handshake logic** derives enable signals from the valid-ready protocol. A reserve enable is generated when both `reserve_valid` and `reserve_ready` are asserted. A write enable is generated when both `write_valid` and `write_ready` are asserted. A read enable is generated when both `read_valid` and `read_ready` are asserted. The `reserve_ready` signal is driven by the inverse of the `reserve_full` flag. The `write_ready` signal is driven by the inverse of the `data_full` flag. The `read_valid` signal is driven by the inverse of the `data_empty` flag, providing inherent safety.

The **controller** maintains separate reservation and read pointers, tracks validity bits for each slot (reserved and written states), generates the memory interface signals, and calculates the status flags. The controller doesn't store any data, only control state.

The **simple dual-port RAM** provides independent read and write ports with combinational reads, allowing the data at the read address to appear immediately on the read data output.

The buffer operates through a three-stage protocol that maintains strict ordering guarantees:

**Stage 1: Reservation** - A reservation transfer occurs when both `reserve_valid` and `reserve_ready` are asserted (high) on the same clock rising edge. The controller reserves a slot in program order using the next available index from the reserve pointer and provides this index on `reserve_index`. The reservation advances the reserve pointer to maintain ordering. When the reservation buffer is full, `reserve_ready` is deasserted, preventing further reservations and providing safety.

**Stage 2: Out-of-order Writing** - A write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The controller directs the RAM to store `write_data` in the specified `write_index` slot (from previous reservation) and marks it as valid. Writes can complete in any order as long as they target previously reserved slots. When all reserved slots are written (data full), `write_ready` is deasserted, preventing write transfers until slots are freed. The `write_error` output pulses for one cycle when a write transfer occurs with an index that was not previously reserved or was already written, extending the valid-ready protocol to indicate incorrect usage.

**Stage 3: In-order Reading** - The `read_data` output continuously provides the data at the read pointer location from the RAM. A read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. The controller frees the slot for future reservations and advances the read pointer to the next slot. The `read_valid` signal is automatically asserted when the slot at the read pointer contains valid written data, ensuring in-order delivery. When no written data is available at the head, `read_valid` is deasserted, preventing read transfers.

The controller maintains separate tracking for reserved slots (allocated but potentially unwritten) and valid slots (written and ready for reading). This allows the buffer to distinguish between reservations and actual data availability.

Separate flags are used for notifying filling level for slot reservation (`reserve_full`, `reserve_empty`) and for data reading (`data_full`, `data_empty`).

The handshake protocol provides automatic flow control protection:
- Reservation operations are blocked when the reservation buffer is full
- Write operations are blocked when the data buffer is full
- Read operations only present data when the head entry contains valid data

## Paths

| From            | To                                                         | Type          | Comment                                                   |
| --------------- | ---------------------------------------------------------- | ------------- | --------------------------------------------------------- |
| `reserve_valid` | `reserve_index`                                            | combinational | Index output from reserve pointer.                        |
| `write_data`    | `read_data`                                                | sequential    | Data path through internal memory array and read pointer. |
| `reserve_valid` | `reserve_full`, `reserve_empty`                            | sequential    | Control path through internal reservation bits.           |
| `write_valid`   | `reserve_full`, `reserve_empty`, `data_full`, `data_empty` | sequential    | Control path through internal reservation and valid bits. |
| `read_ready`    | `reserve_full`, `reserve_empty`, `data_full`, `data_empty` | sequential    | Control path through internal reservation and valid bits. |
| `reserve_full`  | `reserve_ready`                                            | combinational | Handshake protocol based on buffer status.                |
| `data_full`     | `write_ready`                                              | combinational | Handshake protocol based on buffer status.                |
| `read_pointer`  | `read_valid`                                               | combinational | Handshake protocol based on head slot validity.           |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `2×DEPTH` flip-flops for the reservation and validity tracking bits, and `2×INDEX_WIDTH` flip-flops for the reserve and read pointers. The wrapper adds minimal logic for the valid-ready protocol conversion.

The critical path includes the first-free-slot detection logic for reserve index generation, which has `O(log₂ DEPTH)` delay complexity. Additional logic is required for pointer management, status flag generation, and handshake protocol management.

## Verification

The valid-ready reorder buffer is verified using a SystemVerilog testbench with comprehensive check sequences that validate the three-stage protocol, ordering guarantees, handshake protocol compliance, and automatic flow control protection.

The following table lists the checks performed by the testbench.

| Number | Check                | Description                                                                                         |
| ------ | -------------------- | --------------------------------------------------------------------------------------------------- |
| 1      | Reserve once         | Verifies single reservation operation with handshake protocol and status flag updates.              |
| 2      | Write once           | Verifies writing to a reserved slot with handshake protocol and proper data storage.                |
| 3      | Read once            | Verifies in-order reading of written data with handshake protocol and slot cleanup.                 |
| 4      | Reserve all          | Reserve all slots in the buffer and verifies handshake compliance.                                  |
| 5      | Write in-order       | Writes to all the reserved slots in order of reservation with handshake protocol.                   |
| 6      | Read in-order        | Read the whole buffer in-order with handshake protocol.                                             |
| 7      | Reserve all again    | Reserve all slots in the buffer again and verifies handshake compliance.                            |
| 8      | Write reverse-order  | Writes to all the reserved slots in reverse order of reservation with handshake protocol.           |
| 9      | Read in-order again  | Read the whole buffer in-order again with handshake protocol.                                       |
| 10     | Successive operation | Tests successive reserve, write, and read operations with handshake protocol compliance.            |
| 11     | Random stimulus      | Performs random operations with handshake and verifies data integrity and ordering against a model. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                     | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_reorder_buffer.sv`](valid_ready_reorder_buffer.sv)                         | SystemVerilog design.                               |
| Testbench         | [`valid_ready_reorder_buffer.testbench.sv`](valid_ready_reorder_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_reorder_buffer.testbench.gtkw`](valid_ready_reorder_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_reorder_buffer.symbol.sss`](valid_ready_reorder_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_reorder_buffer.symbol.svg`](valid_ready_reorder_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_reorder_buffer.symbol.drawio`](valid_ready_reorder_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_reorder_buffer.md`](valid_ready_reorder_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                                   | Path                                                                 | Comment                                   |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------------- |
| [`reorder_buffer`](../../access_enable/reorder_buffer/reorder_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/reorder_buffer` | Underlying reorder buffer implementation. |

## Related modules

| Module                                                                                         | Path                                                                    | Comment                                                        |
| ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------- |
| [`reorder_buffer`](../../access_enable/reorder_buffer/reorder_buffer.md)                       | `omnicores-buildingblocks/sources/data/access_enable/reorder_buffer`    | Base variant with read-write enable flow control.              |
| [`valid_ready_out_of_order_buffer`](../out_of_order_buffer/valid_ready_out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/out_of_order_buffer` | Buffer that allows random access without ordering constraints. |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                                              | `omnicores-buildingblocks/sources/data/valid_ready/fifo`                | Traditional first-in-first-out queue with ordered access.      |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md)                   | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`       | Single-entry buffer for storage.                               |
