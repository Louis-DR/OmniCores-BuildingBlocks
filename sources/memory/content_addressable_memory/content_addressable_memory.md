# Content-Addressable Memory

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Content-Addressable Memory                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![content_addressable_memory](content_addressable_memory.symbol.svg)

An associative memory that stores key-value pairs, where keys are `tags` and values are `data`. It is addressed by content (the tag) rather than by an explicit address, making it a Content-Addressable Memory (CAM). The module provides interfaces to write (allocate) new tag-data pairs, read (search for) data by tag, and delete (evict) entries by tag.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                      |
| ------------ | ------- | -------------- | ------- | -------------------------------- |
| `TAG_WIDTH`  | integer | `≥1`           | `8`     | Bit width of the tag vector.     |
| `DATA_WIDTH` | integer | `≥1`           | `8`     | Bit width of the data vector.    |
| `DEPTH`      | integer | `≥2`           | `16`    | Number of entries in the memory. |

## Ports

| Name            | Direction | Width        | Clock   | Reset    | Reset value | Description                                                                        |
| --------------- | --------- | ------------ | ------- | -------- | ----------- | ---------------------------------------------------------------------------------- |
| `clock`         | input     | 1            | self    |          |             | Clock signal.                                                                      |
| `resetn`        | input     | 1            | `clock` | self     | active-low  | Asynchronous active-low reset.                                                     |
| `full`          | output    | 1            | `clock` | `resetn` | `0`         | Memory full status.<br/>• `0`: Memory has free space.<br/>• `1`: Memory is full.   |
| `empty`         | output    | 1            | `clock` | `resetn` | `1`         | Memory empty status.<br/>• `0`: Memory contains data.<br/>• `1`: Memory is empty.  |
| `write_enable`  | input     | 1            | `clock` |          |             | Write enable signal.<br/>• `0`: Idle.<br/>• `1`: Write a new tag-data pair.        |
| `write_tag`     | input     | `TAG_WIDTH`  | `clock` |          |             | Tag to be written to the memory.                                                   |
| `write_data`    | input     | `DATA_WIDTH` | `clock` |          |             | Data to be written to the memory.                                                  |
| `read_enable`   | input     | 1            | `clock` |          |             | Read enable signal.<br/>• `0`: Idle.<br/>• `1`: Read data by tag.                  |
| `read_tag`      | input     | `TAG_WIDTH`  | `clock` |          |             | Tag to be searched for in the memory.                                              |
| `read_data`     | output    | `DATA_WIDTH` | `clock` | `resetn` | `X`         | Data corresponding to `read_tag`. Valid one cycle after a hit.                     |
| `read_hit`      | output    | 1            | `clock` |          |             | Read hit status.<br/>• `0`: No match found (miss).<br/>• `1`: Match found (hit).   |
| `delete_enable` | input     | 1            | `clock` |          |             | Delete enable signal.<br/>• `0`: Idle.<br/>• `1`: Delete an entry by tag.          |
| `delete_tag`    | input     | `TAG_WIDTH`  | `clock` |          |             | Tag of the entry to be deleted.                                                    |
| `delete_hit`    | output    | 1            | `clock` |          |             | Delete hit status.<br/>• `0`: No match found (miss).<br/>• `1`: Match found (hit). |

## Operation

The Content-Addressable Memory manages entries by combining a `tag_directory` for tag handling and a `simple_dual_port_ram` for data storage.

For **writing**, when `write_enable` is asserted and the memory is not full, the `tag_directory` allocates the `write_tag` to the first available slot and provides its index. This index is then used to write `write_data` into the RAM.

For **reading**, the `read_tag` is searched in parallel across all valid entries in the `tag_directory`. If a match is found, `read_hit` is asserted combinationally, and the index of the matching tag is used to retrieve the corresponding data from the RAM. The `read_data` is available one clock cycle after the read operation is initiated.

For **deleting**, the `delete_tag` is searched in the `tag_directory`. If a match is found, `delete_hit` is asserted, and the corresponding entry in the `tag_directory` is invalidated, effectively freeing the slot. The data in the RAM is not cleared but becomes inaccessible.

If `read_enable` and `delete_enable` are asserted in the same cycle, the delete operation takes precedence. The shared search logic is used for the `delete_tag`, and `read_hit` will be deasserted.

## Paths

| From            | To                      | Type          | Comment                                                                                    |
| --------------- | ----------------------- | ------------- | ------------------------------------------------------------------------------------------ |
| `write_enable`  | `full`, `empty`         | sequential    | Control path through the `tag_directory`.                                                  |
| `write_tag`     | `read_hit`, `read_data` | sequential    | Data path through `tag_directory` and `simple_dual_port_ram`.                              |
| `write_data`    | `read_data`             | sequential    | Data path through `simple_dual_port_ram`.                                                  |
| `read_tag`      | `read_hit`              | combinational | Combinational search through the `tag_directory`.                                          |
| `read_tag`      | `read_data`             | sequential    | Path through `tag_directory` (combinational) and then `simple_dual_port_ram` (sequential). |
| `delete_enable` | `full`, `empty`         | sequential    | Control path through the `tag_directory`.                                                  |
| `delete_tag`    | `delete_hit`            | combinational | Combinational search through `tag_directory`.                                              |

## Complexity

| Delay           | Gates                                 | Comment                                                 |
| --------------- | ------------------------------------- | ------------------------------------------------------- |
| `O(log₂ DEPTH)` | `O(DEPTH × (TAG_WIDTH + DATA_WIDTH))` | Critical path is the search logic in the tag directory. |

The module requires `DEPTH × TAG_WIDTH` flip-flops for the tag memory, `DEPTH` flip-flops for valid bits in the tag directory, and `DEPTH × DATA_WIDTH` flip-flops for the data memory RAM.

## Verification

The content-addressable memory is verified using a SystemVerilog testbench with six check sequences that validate all operations and data integrity under various conditions.

The following table lists the checks performed by the testbench.

| Number | Check                   | Description                                                                                                   |
| ------ | ----------------------- | ------------------------------------------------------------------------------------------------------------- |
| 1      | Write once              | Writes a single entry, verifies flags, and performs a full search to check hit/miss logic and data integrity. |
| 2      | Delete once             | Deletes the single entry, verifies flags, and performs a full search to confirm it is gone.                   |
| 3      | Write all               | Fills the memory completely and verifies flags, search functionality and data integrity.                      |
| 4      | Delete all              | Empties the memory completely and verifies flags and search functionality.                                    |
| 5      | Simultaneous operations | Concurrently writes, reads, and deletes entries to test for race conditions and correct prioritization.       |
| 6      | Random stimulus         | Performs a randomized sequence of all operations to verify robustness.                                        |

The following table lists the parameter values verified by the testbench.

| `TAG_WIDTH` | `DATA_WIDTH` | `DEPTH` |           |
| ----------- | ------------ | ------- | --------- |
| 8           | 8            | 16      | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                     | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`content_addressable_memory.sv`](content_addressable_memory.sv)                         | Verilog design file.                                |
| Testbench         | [`content_addressable_memory.testbench.sv`](content_addressable_memory.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`content_addressable_memory.testbench.gtkw`](content_addressable_memory.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`content_addressable_memory.symbol.sss`](content_addressable_memory.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`content_addressable_memory.symbol.svg`](content_addressable_memory.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`content_addressable_memory.symbol.drawio`](content_addressable_memory.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`content_addressable_memory.md`](content_addressable_memory.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                    | Path                                                           | Comment                  |
| ------------------------------------------------------------------------- | -------------------------------------------------------------- | ------------------------ |
| [`tag_directory`](../tag_directory/tag_directory.md)                      | `omnicores-buildingblocks/sources/memory/tag_directory`        | Used for tag management. |
| [`simple_dual_port_ram`](../simple_dual_port_ram/simple_dual_port_ram.md) | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram` | Used for data storage.   |

## Related modules

| Module                                                                                       | Path                                                                      | Comment                                                                                   |
| -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [`tag_directory`](../tag_directory/tag_directory.md)                                         | `omnicores-buildingblocks/sources/memory/tag_directory`                   | A core component of this CAM, can be used to build custom associative memories or caches. |
| [`simple_dual_port_ram`](../simple_dual_port_ram/simple_dual_port_ram.md)                    | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram`            | Standard memory module, accessed by address instead of content.                           |
| [`reorder_buffer`](../../data/valid_ready/reorder_buffer/valid_ready_reorder_buffer.md)      | `omnicores-buildingblocks/sources/data/valid_ready/reorder_buffer`        | Buffer with in-order allocation, out-of-order writing, and in-order reading.              |
| [`out_of_order_buffer`](../../data/access_enable/out_of_order_buffer/out_of_order_buffer.md) | `omnicores-buildingblocks/sources/data/access_enable/out_of_order_buffer` | Buffer with in-order writing and out-of-order reading.                                    |
