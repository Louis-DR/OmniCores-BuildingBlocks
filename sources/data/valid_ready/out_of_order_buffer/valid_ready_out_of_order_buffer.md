# Valid-Ready Out-of-Order Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Valid-Ready Out-of-Order Buffer                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![valid_ready_out_of_order_buffer](valid_ready_out_of_order_buffer.symbol.svg)

Synchronous buffer that allows out-of-order reading of stored data entries with valid-ready handshake flow control. The buffer stores data in the first available slot and returns the corresponding index, allowing data to be read back using that same index at any time. The handshake protocol ensures that transfers only occur when both valid and ready signals are asserted, automatically managing flow control for both write and read operations.

When writing, the data is stored in the first free slot and the corresponding index is returned on the same cycle. The data becomes available for reading in the next cycle. The read operation is fully combinational and data can be optionally cleared during the read operation to free the slot for future writes. The internal memory array is not reset, so it will contain invalid data in silicon and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

The buffer provides automatic flow control through the handshake protocol, with `write_ready` indicating space availability and `read_ready` indicating valid data at the specified index.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name          | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                                           |
| ------------- | --------- | ------------- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `clock`       | input     | 1             | self         |          |             | Clock signal.                                                                                         |
| `resetn`      | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                                        |
| `full`        | output    | 1             | `clock`      | `resetn` | `0`         | Buffer full status.<br/>`0`: buffer has free space.<br/>`1`: buffer is full.                          |
| `empty`       | output    | 1             | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>`0`: buffer contains data.<br/>`1`: buffer is empty.                         |
| `write_valid` | input     | 1             | `clock`      |          |             | Write valid signal.<br/>`0`: no write transaction.<br/>`1`: write data is valid.                      |
| `write_data`  | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                                                     |
| `write_index` | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the allocated slot for the written data.                                                     |
| `write_ready` | output    | 1             | `clock`      | `resetn` | `1`         | Write ready signal.<br/>`0`: buffer is full.<br/>`1`: buffer can accept write data.                   |
| `read_valid`  | input     | 1             | `clock`      |          |             | Read valid signal.<br/>`0`: no read transaction.<br/>`1`: read data from buffer at specified index.   |
| `read_clear`  | input     | 1             | `clock`      |          |             | Clear enable signal.<br/>`0`: read only.<br/>`1`: clear slot after reading.                           |
| `read_index`  | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the slot to read from.                                                                       |
| `read_data`   | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the buffer at the specified index.                                                     |
| `read_ready`  | output    | 1             | `clock`      | `resetn` | `0`         | Read ready signal.<br/>`0`: no valid data at index.<br/>`1`: valid data available at specified index. |

## Operation

The valid-ready out-of-order buffer is a wrapper around the read-write enable out-of-order buffer that implements the valid-ready handshake protocol. It maintains an internal memory array with a validity bit for each slot. Unlike traditional FIFOs that enforce first-in-first-out order, this buffer allows random access to stored data using indices.

For **write operation**, a write transfer occurs when both `write_valid` and `write_ready` are asserted (high) on the same clock rising edge. The `write_data` is stored in the first available free slot found by scanning the validity bits. The `write_index` output provides the index of the allocated slot on the same cycle. The slot becomes valid and available for reading in the next cycle.

The handshake protocol prevents writing when the buffer is full - when `write_ready` is low, any write attempt is ignored and `write_valid` will have no effect until space becomes available.

For **read operation**, the `read_data` output continuously provides the data stored at the location specified by `read_index`. A read transfer occurs when both `read_valid` and `read_ready` are asserted (high) on the same clock rising edge. When both `read_valid` and `read_clear` are asserted during a valid transfer, the slot is marked as invalid, thus freed for future writes.

The `read_ready` signal is automatically asserted when the slot at `read_index` contains valid data, enabling the handshake. When `read_ready` is low, it indicates that the specified index contains no valid data, and any read attempt will be ignored.

The status flags are calculated based on the vector of valid bits. The buffer is full when there are no free slots (cannot write), and empty when all the slots are free (cannot read).

## Paths

| From          | To            | Type          | Comment                                          |
| ------------- | ------------- | ------------- | ------------------------------------------------ |
| `write_valid` | `write_index` | combinational | Index calculation through first-free-slot logic. |
| `write_data`  | `read_data`   | sequential    | Data path through internal memory array.         |
| `write_valid` | `full`        | sequential    | Control path through internal validity bits.     |
| `write_valid` | `empty`       | sequential    | Control path through internal validity bits.     |
| `write_valid` | `read_ready`  | sequential    | Control path through internal validity bits.     |
| `read_index`  | `read_data`   | combinational | Direct memory array access.                      |
| `read_index`  | `read_ready`  | combinational | Validity bit check for handshake.                |
| `read_valid`  | `full`        | sequential    | Control path through internal validity bits.     |
| `read_valid`  | `empty`       | sequential    | Control path through internal validity bits.     |
| `read_valid`  | `read_ready`  | sequential    | Control path through internal validity bits.     |
| `read_clear`  | `full`        | sequential    | Control path through internal validity bits.     |
| `read_clear`  | `empty`       | sequential    | Control path through internal validity bits.     |
| `read_clear`  | `read_ready`  | sequential    | Control path through internal validity bits.     |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `DEPTH` flip-flops for the validity bits, and additional logic for the first-free-slot detection using a `first_one` module and one-hot to binary conversion. The wrapper adds minimal logic for the valid-ready protocol conversion.

The critical path includes the first-free-slot detection logic for write index generation, and index decoding logic, which both have `O(log₂ DEPTH)` critical path delay complexity.

## Verification

The valid-ready out-of-order buffer is verified using a SystemVerilog testbench with comprehensive check sequences that validate all buffer operations, handshake protocol compliance, and edge cases.

The following table lists the checks performed by the testbench.

| Number | Check                                 | Description                                                                                   |
| ------ | ------------------------------------- | --------------------------------------------------------------------------------------------- |
| 1      | Write once                            | Verifies single write operation, handshake protocol, and status flag updates.                 |
| 2      | Read once without clearing            | Verifies data integrity and read operation with handshake without clearing the slot.          |
| 3      | Read once and clear                   | Verifies read operation with slot clearing, handshake, and proper status flag updates.        |
| 4      | Read while empty                      | Verifies handshake protection when reading from cleared/invalid indices.                      |
| 5      | Writing to full                       | Fills the buffer completely and verifies the full flag behavior and handshake protection.     |
| 6      | Writing when full                     | Verifies handshake protection when attempting to write to a full buffer.                      |
| 7      | Read all without clearing             | Reads all valid slots without clearing and verifies data integrity and handshake behavior.    |
| 8      | Read and clear to empty               | Clears all slots and verifies empty flag behavior, handshake, and proper cleanup.             |
| 9      | Continuous write & clear almost empty | Tests continuous write and clear operations with handshake when the buffer is almost empty.   |
| 10     | Continuous write & clear almost full  | Tests continuous write and clear operations with handshake when the buffer is almost full.    |
| 11     | Random stimulus                       | Performs random write, read, and clear operations with handshake and verifies data integrity. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                               | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`valid_ready_out_of_order_buffer.sv`](valid_ready_out_of_order_buffer.sv)                         | SystemVerilog design.                               |
| Testbench         | [`valid_ready_out_of_order_buffer.testbench.sv`](valid_ready_out_of_order_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`valid_ready_out_of_order_buffer.testbench.gtkw`](valid_ready_out_of_order_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`valid_ready_out_of_order_buffer.symbol.sss`](valid_ready_out_of_order_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`valid_ready_out_of_order_buffer.symbol.svg`](valid_ready_out_of_order_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`valid_ready_out_of_order_buffer.symbol.drawio`](valid_ready_out_of_order_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`valid_ready_out_of_order_buffer.md`](valid_ready_out_of_order_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following modules:

| Module                                                                                  | Path                                                                      | Comment                                        |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------- |
| [`out_of_order_buffer`](../../access_enable/out_of_order_buffer/out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/out_of_order_buffer` | Underlying out-of-order buffer implementation. |

## Related modules

| Module                                                                                  | Path                                                                      | Comment                                                     |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [`out_of_order_buffer`](../../access_enable/out_of_order_buffer/out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/out_of_order_buffer` | Base variant with read-write enable flow control.           |
| [`valid_ready_reorder_buffer`](../reorder_buffer/valid_ready_reorder_buffer.md)         | `omnicores-buildingblocks/sources/data/valid_ready/reorder_buffer`        | Buffer that ensures in-order read from out-of-order writes. |
| [`valid_ready_fifo`](../fifo/valid_ready_fifo.md)                                       | `omnicores-buildingblocks/sources/data/valid_ready/fifo`                  | Traditional first-in-first-out queue with ordered access.   |
| [`valid_ready_simple_buffer`](../simple_buffer/valid_ready_simple_buffer.md)            | `omnicores-buildingblocks/sources/data/valid_ready/simple_buffer`         | Single-entry buffer for storage.                            |
