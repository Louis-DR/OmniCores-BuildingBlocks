# Asynchronous FIFO

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Asynchronous FIFO                                                                |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![asynchronous_fifo](asynchronous_fifo.symbol.svg)

Asynchronous First-In First-Out queue for crossing clock domains. The FIFO uses a write-enable/read-enable protocol for flow control and provides full and empty status flags. It operates with separate write and read clock domains, using Gray-coded pointer synchronization to safely communicate across clock boundaries. It doesn't implement a safety mechanism against writing when full or reading when empty so the integration must use the status flags and the enable signals carefully.

The read data output continuously shows the value at the head of the queue when not empty, allowing instant data access without necessarily consuming the entry. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

## Parameters

| Name     | Type    | Allowed Values    | Default | Description                                              |
| -------- | ------- | ----------------- | ------- | -------------------------------------------------------- |
| `WIDTH`  | integer | `≥1`              | `8`     | Bit width of the data vector.                            |
| `DEPTH`  | integer | power-of-two `≥2` | `4`     | Number of entries in the queue.                          |
| `STAGES` | integer | `≥1`              | `2`     | Number of synchronizer stages for clock domain crossing. |

## Ports

| Name           | Direction | Width   | Clock         | Reset          | Reset value | Description                                                                      |
| -------------- | --------- | ------- | ------------- | -------------- | ----------- | -------------------------------------------------------------------------------- |
| `write_clock`  | input     | 1       | self          |                |             | Write domain clock signal.                                                       |
| `write_resetn` | input     | 1       | asynchronous  | self           | active-low  | Write domain asynchronous active-low reset.                                      |
| `write_enable` | input     | 1       | `write_clock` |                |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (push) to queue.              |
| `write_data`   | input     | `WIDTH` | `write_clock` |                |             | Data to be written to the queue.                                                 |
| `write_full`   | output    | 1       | `write_clock` | `write_resetn` | `0`         | Write domain full status.<br/>`0`: queue has free space.<br/>`1`: queue is full. |
| `read_clock`   | input     | 1       | self          |                |             | Read domain clock signal.                                                        |
| `read_resetn`  | input     | 1       | asynchronous  | self           | active-low  | Read domain asynchronous active-low reset.                                       |
| `read_enable`  | input     | 1       | `read_clock`  |                |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read (pop) from queue.               |
| `read_data`    | output    | `WIDTH` | `read_clock`  | `read_resetn`  | `0`         | Data read from the queue head.                                                   |
| `read_empty`   | output    | 1       | `read_clock`  | `read_resetn`  | `1`         | Read domain empty status.<br/>`0`: queue contains data.<br/>`1`: queue is empty. |

## Operation

The asynchronous FIFO maintains an internal memory array indexed by separate read and write pointers each operating in their respective clock domain. The pointer each have an additional wrap bit for correct full/empty detection. Data integrity and stability is ensured through careful synchronization using Gray-coding of the pointers.

The **write clock domain** contains a write pointer that indexes the shared memory array. When `write_enable` is asserted, `write_data` is stored at the write pointer location, and both the binary and Gray-coded write pointers are incremented. The Gray-coded write pointer is synchronized to the read domain for empty status generation.

There is no safety mechanism against writing when full ; the write pointer will be incremented and surpass the read pointer, overwriting the data at the head, corrupting the full and empty flags, and breaking the FIFO.

The **read clock domain** contains a read pointer that indexes the shared memory array. The `read_data` output continuously provides data from the read pointer location. When `read_enable` is asserted, both the binary and Gray-coded read pointers are incremented. The Gray-coded read pointer is synchronized to the write domain for full status generation.

There is no safety mechanism against reading when empty ; the read pointer will be incremented and surpass the write pointer, causing the next data written to be lost, corrupting the full and empty flags, and breaking the FIFO.

**Clock domain crossing** is handled by synchronizing Gray-coded pointers between domains using multi-stage synchronizers. Gray coding ensures that only one bit changes at a time, preventing metastability issues during clock domain crossing.

The status flags are calculated based on the Gray-coded read and write pointers in specific domains. The queue is full if the Gray-coded read and write pointers differ only in their two most significant bits, while all other bits are identical. The queue is empty if the Gray-coded read and write pointers in the read domain are the same.

## Paths

| From           | To           | Type           | Comment                                      |
| -------------- | ------------ | -------------- | -------------------------------------------- |
| `write_data`   | `read_data`  | sequential CDC | Data path through shared memory array.       |
| `write_enable` | `read_data`  | sequential CDC | Data path through shared memory array.       |
| `write_enable` | `write_full` | sequential     | Control path through internal write pointer. |
| `write_enable` | `read_empty` | sequential CDC | Control path through internal write pointer. |
| `read_enable`  | `write_full` | sequential     | Control path through internal read pointer.  |
| `read_enable`  | `read_empty` | sequential CDC | Control path through internal read pointer.  |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `4×(log₂DEPTH+1)` flip-flops for binary and Gray pointers, and `2×(log₂DEPTH+1)×STAGES` flip-flops for the synchronizers.

## Verification

The asynchronous FIFO is verified using a SystemVerilog testbench with multiple check sequences that validate cross-domain operations and data integrity.

The following table lists the checks performed by the testbench.

| Number | Check                                            | Description                                                                                    |
| ------ | ------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| 1      | Writing to full                                  | Fills the FIFO completely and verifies the flags.                                              |
| 2      | Reading to empty                                 | Empties the FIFO completely and verifies data integrity and the flags.                         |
| 3      | Maximal throughput with same frequencies         | Performs read and write operations as fast as possible with both clocks at the same frequency. |
| 4      | Maximal throughput with fast write and slow read | Performs read and write operations as fast as possible with a faster write clock.              |
| 5      | Maximal throughput with slow write and fast read | Performs read and write operations as fast as possible with a faster read clock.               |
| 6      | Random stimulus with same frequencies            | Performs random read and write operations with both clocks at the same frequency.              |
| 7      | Random stimulus with fast write and slow read    | Performs random read and write operations with a faster write clock.                           |
| 8      | Random stimulus with slow write and fast read    | Performs random read and write operations with a faster read clock.                            |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` | `STAGES` |           |
| ------- | ------- | -------- | --------- |
| 8       | 4       | 2        | (default) |

The following table lists the clock frequencies verified by the testbench.

| `write_clock` | `read_clock` | Ratio | Checks     |
| ------------- | ------------ | ----- | ---------- |
| 100MHz        | 100MHz       | 1     | 1, 2, 3, 6 |
| 100MHz        | 314.1593MHz  | π     | 4, 7       |
| 314.1593MHz   | 100MHz       | 1/π   | 5, 8       |

## Constraints

Clock domain crossing constraints should be applied to the Gray pointer synchronizers. The design assumes the FIFO depth is a power of 2 for optimal Gray code operation.

## Deliverables

| Type              | File                                                                   | Description                                         |
| ----------------- | ---------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`asynchronous_fifo.v`](asynchronous_fifo.v)                           | Verilog design.                                     |
| Testbench         | [`asynchronous_fifo.testbench.sv`](asynchronous_fifo.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`asynchronous_fifo.testbench.gtkw`](asynchronous_fifo.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`asynchronous_fifo.symbol.sss`](asynchronous_fifo.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`asynchronous_fifo.symbol.svg`](asynchronous_fifo.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`asynchronous_fifo.symbol.drawio`](asynchronous_fifo.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`asynchronous_fifo.md`](asynchronous_fifo.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                              | Path                                                          | Comment                                 |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------- | --------------------------------------- |
| [`vector_synchronizer`](../../../timing/vector_synchronizer/vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/vector_synchronizer` | For Gray pointer clock domain crossing. |
| [`binary_to_gray`](../../../encoding/gray/binary_to_gray.md)                        | `omnicores-buildingblocks/sources/encoding/gray`              | For converting binary pointers to Gray. |

## Related modules

| Module                                                                                                  | Path                                                                                 | Comment                                                             |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| [`valid_ready_asynchronous_fifo`](../../valid_ready/asynchronous_fifo/valid_ready_asynchronous_fifo.md) | `omnicores-buildingblocks/sources/data/valid_ready/asynchronous_fifo`                | Variant of this module with valid-ready handshake flow control.     |
| [`fifo`](../fifo/fifo.md)                                                                               | `omnicores-buildingblocks/sources/data/read_write_enable/fifo`                       | Synchronous variant of this module for single clock domain.         |
| [`advanced_fifo`](../advanced_fifo/advanced_fifo.md)                                                    | `omnicores-buildingblocks/sources/data/read_write_enable/advanced_fifo`              | Synchronous FIFO with additional features and protection.           |
| [`asynchronous_advanced_fifo`](../asynchronous_advanced_fifo/asynchronous_advanced_fifo.md)             | `omnicores-buildingblocks/sources/data/read_write_enable/asynchronous_advanced_fifo` | Advanced asynchronous FIFO with additional features and protection. |
