# Reorder Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Reorder Buffer                                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![reorder_buffer](reorder_buffer.symbol.svg)

Synchronous buffer that ensures in-order data reading from out-of-order data writes. The buffer operates with a three-stage protocol: in-order reservation of slots, out-of-order writing to reserved slots, and in-order reading of written data. The reserve operation provides an index that should be carried through the system for the corresponding write operation. Data can only be read in-order when the corresponding writes have occurred. This design is essential for systems that require program order to be maintained despite out-of-order execution or completion.

The design is structured as a modular architecture with a separate controller for reservation tracking, dual pointer management, validity bits, and control logic, and a generic simple dual-port RAM for data storage. This allows easy replacement of the memory with technology-specific implementations during ASIC integration.

The buffer uses a reserve-enable/write-enable/read-enable protocol for flow control. It does not implement safety mechanisms against incorrect usage, so the integration is responsible for ensuring correct operation by checking status flags before enabling operations. Specifically, the integration must check `reserve_full` before asserting `reserve_enable`, only write to previously reserved indices once per slot, and ensure data has been written to the head slot before asserting `read_enable`. Note that `data_empty` being low does not guarantee the next in-order data is available—only that some reserved slot contains valid data.

The read data output continuously shows the value at the head of the buffer, allowing instant data access without necessarily popping the entry. The internal memory array is not reset, so it will contain invalid data in silicon and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name             | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                                     |
| ---------------- | --------- | ------------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------------------- |
| `clock`          | input     | 1             | self         |          |             | Clock signal.                                                                                   |
| `resetn`         | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                  |
| `reserve_full`   | output    | 1             | `clock`      | `resetn` | `0`         | Reservation full status.<br/>`0`: buffer has free reservation slots.<br/>`1`: buffer is full.   |
| `reserve_empty`  | output    | 1             | `clock`      | `resetn` | `1`         | Reservation empty status.<br/>`0`: buffer has reserved slots.<br/>`1`: buffer is empty.         |
| `data_full`      | output    | 1             | `clock`      | `resetn` | `0`         | Data full status.<br/>`0`: buffer has unwritten slots.<br/>`1`: all reserved slots are written. |
| `data_empty`     | output    | 1             | `clock`      | `resetn` | `1`         | Data empty status.<br/>`0`: buffer has written data.<br/>`1`: no written data available.        |
| `reserve_enable` | input     | 1             | `clock`      |          |             | Reserve enable signal.<br/>`0`: idle.<br/>`1`: reserve slot and get index. |
| `reserve_index`  | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the reserved slot.                                                |
| `write_enable`   | input     | 1             | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write data to reserved slot.  |
| `write_index`    | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the slot to write to (must be previously reserved).               |
| `write_data`     | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                          |
| `read_enable`    | input     | 1             | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read data from head of queue.  |
| `read_data`      | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the head of the queue.                                      |

## Operation

The reorder buffer operates through a three-stage protocol that maintains strict ordering guarantees:

**Stage 1: Reservation** - When `reserve_enable` is asserted, a slot is reserved in program order using the next available index from the reserve pointer. The `reserve_index` output provides the index that should be used for the subsequent write operation. The reservation advances the reserve pointer to maintain ordering. The integration must ensure `reserve_full` is not asserted before asserting `reserve_enable`.

**Stage 2: Out-of-order Writing** - When `write_enable` is asserted with a previously reserved `write_index`, the `write_data` is stored in the specified slot and marked as valid. Writes can complete in any order as long as they target previously reserved slots. The integration must only write to reserved indices and write to each index exactly once.

**Stage 3: In-order Reading** - When `read_enable` is asserted, data is read from the head of the queue (read pointer position) and the slot is freed for future reservations. The read pointer advances to the next slot. The integration must ensure the slot at the read pointer contains valid data before asserting `read_enable`, ensuring in-order delivery.

The buffer maintains separate tracking for reserved slots (allocated but potentially unwritten) and valid slots (written and ready for reading). This allows the buffer to distinguish between reservations and actual data availability.

Separate flags are used for notifying filling level for slot reservation (`reserve_full`, `reserve_empty`) and for data reading (`data_full`, `data_empty`).

## Paths

| From             | To                                                         | Type          | Comment                                                   |
| ---------------- | ---------------------------------------------------------- | ------------- | --------------------------------------------------------- |
| `reserve_enable` | `reserve_index`                                            | combinational | Index output from reserve pointer.                        |
| `write_data`     | `read_data`                                                | sequential    | Data path through internal memory array and read pointer. |
| `reserve_enable` | `reserve_full`, `reserve_empty`                            | sequential    | Control path through internal reservation bits.           |
| `write_enable`   | `reserve_full`, `reserve_empty`, `data_full`, `data_empty` | sequential    | Control path through internal reservation and valid bits. |
| `read_enable`    | `reserve_full`, `reserve_empty`, `data_full`, `data_empty` | sequential    | Control path through internal reservation and valid bits. |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `2×DEPTH` flip-flops for the reservation and validity tracking bits, and `2×(INDEX_WIDTH+1)` flip-flops for the reserve and read pointers (including wrap bits).

The critical path includes memory array access and address decoding logic, which has `O(log₂ DEPTH)` delay complexity. Additional delay comes from multi-bit pointer comparisons and status flag generation.

## Verification

The reorder buffer is verified using a SystemVerilog testbench with comprehensive check sequences that validate the three-stage protocol and ordering guarantees.

The following table lists the checks performed by the testbench.

| Number | Check                | Description                                                                          |
| ------ | -------------------- | ------------------------------------------------------------------------------------ |
| 1      | Reserve once         | Verifies single reservation operation and status flag updates.                       |
| 2      | Write once           | Verifies writing to a reserved slot and proper data storage.                         |
| 3      | Read once            | Verifies in-order reading of written data and slot cleanup.                          |
| 4      | Reserve all          | Reserve all slots in the buffer.                                                     |
| 5      | Write in-order       | Writes to all the reserved slots in order of reservation.                            |
| 6      | Read in-order        | Read the whole buffer in-order.                                                      |
| 7      | Reserve all again    | Reserve all slots in the buffer again.                                               |
| 8      | Write reverse-order  | Writes to all the reserved slots in reverse order of reservation.                    |
| 9      | Read in-order again  | Read the whole buffer in-order again.                                                |
| 10     | Successive operation | Tests successive reserve, write, and read operations.                                |
| 11     | Random stimulus      | Performs random operations and verifies data integrity and ordering against a model. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`reorder_buffer.sv`](reorder_buffer.sv)                         | SystemVerilog design.                               |
| Testbench         | [`reorder_buffer.testbench.sv`](reorder_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`reorder_buffer.testbench.gtkw`](reorder_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`reorder_buffer.symbol.sss`](reorder_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`reorder_buffer.symbol.svg`](reorder_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`reorder_buffer.symbol.drawio`](reorder_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`reorder_buffer.md`](reorder_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                         | Path                                                                   | Comment                                                    |
| ------------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------------------- |
| `reorder_buffer_controller` | `omnicores-buildingblocks/sources/data/controllers/reorder_buffer` | Controller for reservation tracking and pointer management logic. |
| `simple_dual_port_ram`         | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram`         | Simpledual-port RAM for data storage.                            |


## Related modules

| Module                                                                             | Path                                                                      | Comment                                                         |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------- |
| [`valid_ready_reorder_buffer`](../../valid_ready/reorder_buffer/reorder_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/reorder_buffer`        | Variant of this module with valid-ready handshake flow control. |
| [`out_of_order_buffer`](../out_of_order_buffer/out_of_order_buffer.md)             | `omnicores-buildingblocks/sources/data/access_enable/out_of_order_buffer` | Buffer that allows random access without ordering constraints.  |
| [`fifo`](../fifo/fifo.md)                                                          | `omnicores-buildingblocks/sources/data/access_enable/fifo`                | Traditional first-in-first-out queue with strict ordering.      |
