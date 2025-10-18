# Simple Dual-Port RAM

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Simple Dual-Port RAM                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![simple_dual_port_ram](simple_dual_port_ram.symbol.svg)

A synchronous random access memory with separate read and write ports for simultaneous access to different memory locations. The module provides configurable depth and data width with optional registered read and write-through modes for improved timing characteristics and conflict handling. This module can be used as a behavioral model for a generated on-die SRAM, or as a synthesizable flip-flop-based RAM for small widths and depths.

## Parameters

| Name              | Type    | Allowed Values | Default | Description                                                                                                                             |
| ----------------- | ------- | -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `WIDTH`           | integer | `≥1`           | `8`     | Bit width of the data vector.                                                                                                           |
| `DEPTH`           | integer | `≥2`           | `16`    | Number of entries in the memory.                                                                                                        |
| `WRITE_THROUGH`   | integer | `0`, `1`       | `0`     | Write-through mode selection.<br/>• `0`: Read before write.<br/>• `1`: Write-through forwarding when addresses match.                   |
| `REGISTERED_READ` | integer | `0`, `1`       | `1`     | Read mode selection.<br/>• `0`: Combinational read (data available same cycle).<br/>• `1`: Registered read (data available next cycle). |

## Ports

| Name            | Direction | Width           | Clock   | Reset | Reset value | Description                                                                                       |
| --------------- | --------- | --------------- | ------- | ----- | ----------- | ------------------------------------------------------------------------------------------------- |
| `clock`         | input     | 1               | self    |       |             | Clock signal.                                                                                     |
| `write_enable`  | input     | 1               | `clock` |       |             | Write enable signal.<br/>• `0`: Idle.<br/>• `1`: Write operation.                                 |
| `write_address` | input     | `ADDRESS_WIDTH` | `clock` |       |             | Address of the memory location to write.                                                          |
| `write_data`    | input     | `WIDTH`         | `clock` |       |             | Data to be written to the memory.                                                                 |
| `read_enable`   | input     | 1               | `clock` |       |             | Read enable signal.<br/>• `0`: Idle.<br/>• `1`: Read operation.                                   |
| `read_address`  | input     | `ADDRESS_WIDTH` | `clock` |       |             | Address of the memory location to read.                                                           |
| `read_data`     | output    | `WIDTH`         | `clock` |       |             | Data read from the memory. Valid same cycle or next cycle depending on `REGISTERED_READ` setting. |

## Operation

The simple dual-port RAM manages an internal memory array with independent read and write ports, allowing simultaneous read and write operations to different memory locations in the same clock cycle.

For **write operation**, when `write_enable` is asserted, `write_data` is stored at the memory location specified by `write_address` on the rising edge of `clock`.

For **read operation**, when `read_enable` is asserted, the data at the memory location specified by `read_address` is driven on `read_data`. The timing depends on the `REGISTERED_READ` parameter:
- If `REGISTERED_READ = 0`, the read is combinational and `read_data` is valid in the same clock cycle.
- If `REGISTERED_READ = 1`, the read is registered and `read_data` is valid in the next clock cycle after the read operation is initiated.

When both read and write operations occur in the same cycle and target the same address (`write_address == read_address`), the behavior depends on the `WRITE_THROUGH` parameter:
- If `WRITE_THROUGH = 0`, the read operation returns the old data before the write (read-before-write behavior).
- If `WRITE_THROUGH = 1`, the read operation returns the new data being written (write-through forwarding).

The memory contents are not initialized and will contain unpredictable values after power-up or reset.

## Paths

| From                                          | To          | Type          | Comment                                                                     |
| --------------------------------------------- | ----------- | ------------- | --------------------------------------------------------------------------- |
| `write_enable`, `write_address`, `write_data` | `read_data` | sequential    | Data path through internal memory array.                                    |
| `read_enable`, `read_address`                 | `read_data` | combinational | Address decoding (if `REGISTERED_READ = 0`).                                |
| `read_enable`, `read_address`                 | `read_data` | sequential    | Address decoding through register (if `REGISTERED_READ = 1`).               |
| `write_enable`, `write_data`                  | `read_data` | combinational | Write-through forwarding path (if `WRITE_THROUGH = 1` and addresses match). |

## Complexity

| Delay           | Gates            | Comment                                                          |
| --------------- | ---------------- | ---------------------------------------------------------------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` | Critical path is the address decoding and memory array indexing. |

The module requires `WIDTH×DEPTH` flip-flops for the memory array. When `REGISTERED_READ = 1`, an additional `WIDTH` flip-flops are required for the read data register.

## Verification

The simple dual-port RAM is verified using a SystemVerilog testbench with seven check sequences that validate all operations and data integrity under various conditions.

The following table lists the checks performed by the testbench.

| Number | Check                       | Description                                                                                                |
| ------ | --------------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1      | All zero                    | Writes zero to all memory locations and reads back to verify correct operation.                            |
| 2      | Address walking ones        | Walks a vector of all ones through memory addresses to detect address aliasing issues.                     |
| 3      | Address walking zeros       | Walks a vector of all zeros through memory addresses to detect address aliasing issues.                    |
| 4      | Data walking one            | For each address, walks a single one through data bits to detect data line stuck-at or coupling faults.    |
| 5      | Data walking zero           | For each address, walks a single zero through data bits to detect data line stuck-at or coupling faults.   |
| 6      | Concurrent reads and writes | Performs simultaneous read and write operations to verify dual-port capability and write-through behavior. |
| 7      | Random stimulus             | Performs randomized write and read operations to verify robustness and data integrity against a reference. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` | `WRITE_THROUGH` | `REGISTERED_READ` |           |
| ------- | ------- | --------------- | ----------------- | --------- |
| 8       | 16      | 0               | 1                 | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                         | Description                                         |
| ----------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`simple_dual_port_ram.v`](simple_dual_port_ram.v)                           | Verilog design file.                                |
| Testbench         | [`simple_dual_port_ram.testbench.sv`](simple_dual_port_ram.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`simple_dual_port_ram.testbench.gtkw`](simple_dual_port_ram.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`simple_dual_port_ram.symbol.sss`](simple_dual_port_ram.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`simple_dual_port_ram.symbol.svg`](simple_dual_port_ram.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`simple_dual_port_ram.symbol.drawio`](simple_dual_port_ram.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`simple_dual_port_ram.md`](simple_dual_port_ram.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                              | Path                                      | Comment                       |
| ----------------------------------- | ----------------------------------------- | ----------------------------- |
| [`clog2.vh`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | For computing `CLOG2(DEPTH)`. |

## Related modules

| Module                                                                                                           | Path                                                                        | Comment                                                            |
| ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [`single_port_ram`](../single_port_ram/single_port_ram.md)                                                       | `omnicores-buildingblocks/sources/memory/single_port_ram`                   | RAM with a single shared port for read and write operations.       |
| [`true_dual_port_ram`](../true_dual_port_ram/true_dual_port_ram.md)                                              | `omnicores-buildingblocks/sources/memory/true_dual_port_ram`                | RAM with two fully independent read-write ports.                   |
| [`asynchronous_simple_dual_port_ram`](../asynchronous_simple_dual_port_ram/asynchronous_simple_dual_port_ram.md) | `omnicores-buildingblocks/sources/memory/asynchronous_simple_dual_port_ram` | Asynchronous dual-port RAM for crossing clock domains.             |
| [`asynchronous_true_dual_port_ram`](../asynchronous_true_dual_port_ram/asynchronous_true_dual_port_ram.md)       | `omnicores-buildingblocks/sources/memory/asynchronous_true_dual_port_ram`   | Asynchronous true dual-port RAM for crossing clock domains.        |
| [`content_addressable_memory`](../content_addressable_memory/content_addressable_memory.md)                      | `omnicores-buildingblocks/sources/memory/content_addressable_memory`        | Associative memory accessed by content rather than address.        |
| [`tag_directory`](../tag_directory/tag_directory.md)                                                             | `omnicores-buildingblocks/sources/memory/tag_directory`                     | Directory for managing tags with allocation, search, and eviction. |

