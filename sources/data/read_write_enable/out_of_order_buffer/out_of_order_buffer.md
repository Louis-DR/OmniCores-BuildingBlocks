# Out-of-Order Buffer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Out-of-Order Buffer                                                              |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![out_of_order_buffer](out_of_order_buffer.symbol.svg)

Synchronous buffer that allows out-of-order reading of stored data entries. The buffer stores data in the first available slot and returns the corresponding index, allowing data to be read back using that same index at any time. The buffer uses a write-enable/read-enable protocol for flow control and provides full and empty status flags.

When writing, the data is stored in the first free slot and the corresponding index is returned on the same cycle. The data becomes available for reading in the next cycle. The read operation is fully combinational and data can be optionally cleared during the read operation to free the slot for future writes. The internal memory array is not reset, so it will contain invalid data in silicium and Xs that could propagate in simulation if the integration doesn't handle control flow correctly.

The buffer provides error detection for invalid read operations (reading from invalid indices) but does not implement safety mechanisms against writing when full, so the integration must use the status flags and enable signals carefully.

## Parameters

| Name          | Type    | Allowed Values | Default       | Description                                        |
| ------------- | ------- | -------------- | ------------- | -------------------------------------------------- |
| `WIDTH`       | integer | `≥1`           | `8`           | Bit width of the data vector.                      |
| `DEPTH`       | integer | `≥2`           | `8`           | Number of entries in the buffer.                   |
| `INDEX_WIDTH` | integer | `≥1`           | `log₂(DEPTH)` | Bit width of the index (automatically calculated). |

## Ports

| Name           | Direction | Width         | Clock        | Reset    | Reset value | Description                                                                           |
| -------------- | --------- | ------------- | ------------ | -------- | ----------- | ------------------------------------------------------------------------------------- |
| `clock`        | input     | 1             | self         |          |             | Clock signal.                                                                         |
| `resetn`       | input     | 1             | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                        |
| `full`         | output    | 1             | `clock`      | `resetn` | `0`         | Buffer full status.<br/>`0`: buffer has free space.<br/>`1`: buffer is full.          |
| `empty`        | output    | 1             | `clock`      | `resetn` | `1`         | Buffer empty status.<br/>`0`: buffer contains data.<br/>`1`: buffer is empty.         |
| `write_enable` | input     | 1             | `clock`      |          |             | Write enable signal.<br/>`0`: idle.<br/>`1`: write (allocate) data to buffer.         |
| `write_data`   | input     | `WIDTH`       | `clock`      |          |             | Data to be written to the buffer.                                                     |
| `write_index`  | output    | `INDEX_WIDTH` | `clock`      |          |             | Index of the allocated slot for the written data.                                     |
| `read_enable`  | input     | 1             | `clock`      |          |             | Read enable signal.<br/>`0`: idle.<br/>`1`: read data from buffer at specified index. |
| `read_clear`   | input     | 1             | `clock`      |          |             | Clear enable signal.<br/>`0`: read only.<br/>`1`: clear slot after reading.           |
| `read_index`   | input     | `INDEX_WIDTH` | `clock`      |          |             | Index of the slot to read from.                                                       |
| `read_data`    | output    | `WIDTH`       | `clock`      | `resetn` | `0`         | Data read from the buffer at the specified index.                                     |
| `read_error`   | output    | 1             | `clock`      | `resetn` | `0`         | Read error flag.<br/>`0`: no error.<br/>`1`: read attempted from invalid index.       |

## Operation

The out-of-order buffer maintains an internal memory array with a validity bit for each slot. Unlike traditional FIFOs that enforce first-in-first-out order, this buffer allows random access to stored data using indices.

For **write operation**, when `write_enable` is asserted, the `write_data` is stored in the first available free slot found by scanning the validity bits. The `write_index` output provides the index of the allocated slot on the same cycle. The slot becomes valid and available for reading in the next cycle.

There is no safety mechanism against writing when full ; if attempted, the write operation will override the first entry of the buffer (index 0) and the buffer will continue to function correctly but with corrupted data.

For **read operation**, the `read_data` output continuously provides the data stored at the location specified by `read_index`. When `read_enable` and `read_clear` are both asserted, the slot is marked as invalid, thus freed for future writes.

When `read_enable` is asserted but the entry at index `read_index` is invalid, the `read_error` flag is asserted. The `read_data` may be data previously stored at this index, as it is not cleared when the entry is invalidated. The buffer can continue operating normally after an invalid read.

Asserting `read_clear` but not `read_enable` is not expected, but will not break the buffer. The clear will simply be ignored.

The status flags are calculated based on the vector of valid bits. The buffer is full when there are no free slots (cannot write), and empty when all the slots are free (cannot read).

## Paths

| From           | To            | Type          | Comment                                          |
| -------------- | ------------- | ------------- | ------------------------------------------------ |
| `write_enable` | `write_index` | combinational | Index calculation through first-free-slot logic. |
| `write_data`   | `read_data`   | sequential    | Data path through internal memory array.         |
| `write_enable` | `full`        | sequential    | Control path through internal validity bits.     |
| `write_enable` | `empty`       | sequential    | Control path through internal validity bits.     |
| `read_index`   | `read_data`   | combinational | Direct memory array access.                      |
| `read_index`   | `read_error`  | combinational | Error detection through validity bit check.      |
| `read_enable`  | `read_error`  | combinational | Error detection through validity bit check.      |
| `read_enable`  | `full`        | sequential    | Control path through internal validity bits.     |
| `read_enable`  | `empty`       | sequential    | Control path through internal validity bits.     |
| `read_clear`   | `full`        | sequential    | Control path through internal validity bits.     |
| `read_clear`   | `empty`       | sequential    | Control path through internal validity bits.     |

## Complexity

| Delay           | Gates            | Comment |
| --------------- | ---------------- | ------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` |         |

In this table, the delay refers to the timing critical path, which determines the maximal operating frequency.

The module requires `WIDTH×DEPTH` flip-flops for the memory array, `DEPTH` flip-flops for the validity bits, and additional logic for the first-free-slot detection using a `first_one` module and one-hot to binary conversion.

The critical path includes the first-free-slot detection logic for write index generation, and index decoding logic, which both have `O(log₂ DEPTH)` critical path delay complexity.

## Verification

The out-of-order buffer is verified using a SystemVerilog testbench with comprehensive check sequences that validate all buffer operations, error detection, and edge cases.

The following table lists the checks performed by the testbench.

| Number | Check                                 | Description                                                                                    |
| ------ | ------------------------------------- | ---------------------------------------------------------------------------------------------- |
| 1      | Write once                            | Verifies single write operation and status flag updates.                                       |
| 2      | Read once without clearing            | Verifies data integrity and read operation without clearing the slot.                          |
| 3      | Read once and clear                   | Verifies read operation with slot clearing and proper status flag updates.                     |
| 4      | Read while empty                      | Verifies error detection when reading from cleared/invalid indices.                            |
| 5      | Writing to full                       | Fills the buffer completely and verifies the full flag behavior.                               |
| 6      | Read all without clearing             | Reads all valid slots without clearing and verifies data integrity.                            |
| 7      | Read and clear to empty               | Clears all slots and verifies empty flag behavior and proper cleanup.                          |
| 8      | Continuous write & clear almost empty | Tests continuous write and clear operations with the buffer almost empty.                      |
| 9      | Continuous write & clear almost full  | Tests continuous write and clear operations with the buffer almost full.                       |
| 10     | Random stimulus                       | Performs random write, read, and clear operations and verifies data integrity against a model. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` |           |
| ------- | ------- | --------- |
| 8       | 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                       | Description                                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`out_of_order_buffer.sv`](out_of_order_buffer.sv)                         | SystemVerilog design.                               |
| Testbench         | [`out_of_order_buffer.testbench.sv`](out_of_order_buffer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`out_of_order_buffer.testbench.gtkw`](out_of_order_buffer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`out_of_order_buffer.symbol.sss`](out_of_order_buffer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`out_of_order_buffer.symbol.svg`](out_of_order_buffer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`out_of_order_buffer.symbol.drawio`](out_of_order_buffer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`out_of_order_buffer.md`](out_of_order_buffer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                             | Path                                                    | Comment                                      |
| ------------------------------------------------------------------ | ------------------------------------------------------- | -------------------------------------------- |
| [`first_one`](../../../operations/first_one/first_one.md)          | `omnicores-buildingblocks/sources/operations/first_one` | Used for finding the first free slot.        |
| [`onehot_to_binary`](../../../encoding/onehot/onehot_to_binary.md) | `omnicores-buildingblocks/sources/encoding/onehot`      | Used for converting one-hot to binary index. |

## Related modules

| Module                                                                                            | Path                                                                     | Comment                                                         |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------- |
| [`valid_ready_out_of_order_buffer`](../../valid_ready/out_of_order_buffer/out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/valid_ready/out_of_order_buffer`  | Variant of this module with valid-ready handshake flow control. |
| [`reorder_buffer`](../reorder_buffer/reorder_buffer.md)                                           | `omnicores-buildingblocks/sources/data/read_write_enable/reorder_buffer` | Buffer that ensures in-order read from out-of-order writes.     |
| [`fifo`](../fifo/fifo.md)                                                                         | `omnicores-buildingblocks/sources/data/read_write_enable/fifo`           | Traditional first-in-first-out queue with ordered access.       |
