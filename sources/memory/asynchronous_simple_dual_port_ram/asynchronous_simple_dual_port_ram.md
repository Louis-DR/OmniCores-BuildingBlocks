# Asynchronous Simple Dual-Port RAM

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Asynchronous Simple Dual-Port RAM                                                |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![asynchronous_simple_dual_port_ram](asynchronous_simple_dual_port_ram.symbol.svg)

A random access memory with separate read and write ports operating in independent clock domains. The write port operates on the write clock domain while the read port operates on the read clock domain, enabling safe clock domain crossing for memory operations. The module provides configurable depth and data width with an optional registered read mode. This module can be used as a behavioral model for a generated on-die SRAM, or as a synthesizable flip-flop-based RAM for small widths and depths.

## Parameters

| Name              | Type    | Allowed Values | Default | Description                                                                                                                         |
| ----------------- | ------- | -------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `WIDTH`           | integer | `≥1`           | `8`     | Bit width of the data vector.                                                                                                       |
| `DEPTH`           | integer | `≥2`           | `16`    | Number of entries in the memory.                                                                                                    |
| `REGISTERED_READ` | integer | `0`, `1`       | `1`     | Read mode selection.<br/>`0`: Combinational read (data available same cycle).<br/>`1`: Registered read (data available next cycle). |

## Ports

| Name            | Direction | Width           | Clock         | Reset | Reset value | Description                                                                                       |
| --------------- | --------- | --------------- | ------------- | ----- | ----------- | ------------------------------------------------------------------------------------------------- |
| `write_clock`   | input     | 1               | self          |       |             | Write clock signal.                                                                               |
| `write_enable`  | input     | 1               | `write_clock` |       |             | Write enable signal.<br/>`0`: Idle.<br/>`1`: Write operation.                                     |
| `write_address` | input     | `ADDRESS_WIDTH` | `write_clock` |       |             | Address of the memory location to write.                                                          |
| `write_data`    | input     | `WIDTH`         | `write_clock` |       |             | Data to be written to the memory.                                                                 |
| `read_clock`    | input     | 1               | self          |       |             | Read clock signal.                                                                                |
| `read_enable`   | input     | 1               | `read_clock`  |       |             | Read enable signal.<br/>`0`: Idle.<br/>`1`: Read operation.                                       |
| `read_address`  | input     | `ADDRESS_WIDTH` | `read_clock`  |       |             | Address of the memory location to read.                                                           |
| `read_data`     | output    | `WIDTH`         | `read_clock`  |       |             | Data read from the memory. Valid same cycle or next cycle depending on `REGISTERED_READ` setting. |

## Operation

The asynchronous simple dual-port RAM manages an internal memory array with independent read and write ports operating in separate clock domains, allowing simultaneous read and write operations at different clock rates to different memory locations.

For **write operation**, when `write_enable` is asserted, `write_data` is stored at the memory location specified by `write_address` on the rising edge of `write_clock`.

For **read operation**, when `read_enable` is asserted, the data at the memory location specified by `read_address` is driven on `read_data`. The timing depends on the `REGISTERED_READ` parameter:
- If `REGISTERED_READ = 0`, the read is combinational and `read_data` is valid in the same clock cycle.
- If `REGISTERED_READ = 1`, the read is registered and `read_data` is valid in the next clock cycle after the read operation is initiated.

Since the read and write ports operate in independent clock domains, there is no write-through functionality. When both ports access the same address simultaneously (in different clock domains), the behavior depends on the relative timing of the clock edges and should be avoided for predictable operation. The integration logic should manage address conflicts at the system level.

The memory contents are not initialized and will contain unpredictable values after power-up or reset.

## Paths

| From                                          | To          | Type          | Comment                                                       |
| --------------------------------------------- | ----------- | ------------- | ------------------------------------------------------------- |
| `write_enable`, `write_address`, `write_data` | `read_data` | asynchronous  | Data path through internal memory array across clock domains. |
| `read_enable`, `read_address`                 | `read_data` | combinational | Address decoding (if `REGISTERED_READ = 0`).                  |
| `read_enable`, `read_address`                 | `read_data` | sequential    | Address decoding through register (if `REGISTERED_READ = 1`). |

## Complexity

| Delay           | Gates            | Comment                                                          |
| --------------- | ---------------- | ---------------------------------------------------------------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` | Critical path is the address decoding and memory array indexing. |

The module requires `WIDTH×DEPTH` flip-flops for the memory array. When `REGISTERED_READ = 1`, an additional `WIDTH` flip-flops are required for the read data register.

## Verification

The asynchronous simple dual-port RAM is verified using a SystemVerilog testbench with seven check sequences that validate all operations and data integrity under various conditions with independent clock domains.

The following table lists the checks performed by the testbench.

| Number | Check                       | Description                                                                                                |
| ------ | --------------------------- | ---------------------------------------------------------------------------------------------------------- |
| 1      | All zero                    | Writes zero to all memory locations and reads back to verify correct operation.                            |
| 2      | Address walking ones        | Walks a vector of all ones through memory addresses to detect address aliasing issues.                     |
| 3      | Address walking zeros       | Walks a vector of all zeros through memory addresses to detect address aliasing issues.                    |
| 4      | Data walking one            | For each address, walks a single one through data bits to detect data line stuck-at or coupling faults.    |
| 5      | Data walking zero           | For each address, walks a single zero through data bits to detect data line stuck-at or coupling faults.   |
| 6      | Concurrent reads and writes | Performs simultaneous read and write operations at different clock rates to verify dual-port capability.   |
| 7      | Random stimulus             | Performs randomized write and read operations to verify robustness and data integrity against a reference. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` | `REGISTERED_READ` |           |
| ------- | ------- | ----------------- | --------- |
| 8       | 16      | 1                 | (default) |

## Constraints

The write and read clocks must be asynchronous or have known phase relationships. For synthesis, ensure proper timing constraints are applied to handle the clock domain crossing within the memory array.

## Deliverables

| Type              | File                                                                                                   | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`asynchronous_simple_dual_port_ram.v`](asynchronous_simple_dual_port_ram.v)                           | Verilog design file.                                |
| Testbench         | [`asynchronous_simple_dual_port_ram.testbench.sv`](asynchronous_simple_dual_port_ram.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`asynchronous_simple_dual_port_ram.testbench.gtkw`](asynchronous_simple_dual_port_ram.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`asynchronous_simple_dual_port_ram.symbol.sss`](asynchronous_simple_dual_port_ram.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`asynchronous_simple_dual_port_ram.symbol.svg`](asynchronous_simple_dual_port_ram.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`asynchronous_simple_dual_port_ram.symbol.drawio`](asynchronous_simple_dual_port_ram.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`asynchronous_simple_dual_port_ram.md`](asynchronous_simple_dual_port_ram.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                              | Path                                      | Comment                       |
| ----------------------------------- | ----------------------------------------- | ----------------------------- |
| [`clog2.vh`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | For computing `CLOG2(DEPTH)`. |

## Related modules

| Module                                                                                                     | Path                                                                      | Comment                                                            |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [`single_port_ram`](../single_port_ram/single_port_ram.md)                                                 | `omnicores-buildingblocks/sources/memory/single_port_ram`                 | RAM with a single shared port for read and write operations.       |
| [`simple_dual_port_ram`](../simple_dual_port_ram/simple_dual_port_ram.md)                                  | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram`            | Synchronous dual-port RAM with single clock domain.                |
| [`true_dual_port_ram`](../true_dual_port_ram/true_dual_port_ram.md)                                        | `omnicores-buildingblocks/sources/memory/true_dual_port_ram`              | Synchronous RAM with two fully independent read-write ports.       |
| [`asynchronous_true_dual_port_ram`](../asynchronous_true_dual_port_ram/asynchronous_true_dual_port_ram.md) | `omnicores-buildingblocks/sources/memory/asynchronous_true_dual_port_ram` | Asynchronous RAM with two independent read-write ports.            |
| [`content_addressable_memory`](../content_addressable_memory/content_addressable_memory.md)                | `omnicores-buildingblocks/sources/memory/content_addressable_memory`      | Associative memory accessed by content rather than address.        |
| [`tag_directory`](../tag_directory/tag_directory.md)                                                       | `omnicores-buildingblocks/sources/memory/tag_directory`                   | Directory for managing tags with allocation, search, and eviction. |

