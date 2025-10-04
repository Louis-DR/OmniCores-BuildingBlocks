# True Dual-Port RAM

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | True Dual-Port RAM                                                               |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![true_dual_port_ram](true_dual_port_ram.symbol.svg)

A synchronous random access memory with two fully independent read-write ports that can simultaneously access the same memory array. Each port can independently perform read or write operations in any given clock cycle, providing maximum flexibility for multi-master systems or pipelined architectures. The module provides configurable depth and data width with optional registered read and write-through modes for improved timing characteristics and conflict handling. This module can be used as a behavioral model for a generated on-die SRAM, or as a synthesizable flip-flop-based RAM for small widths and depths.

## Parameters

| Name              | Type    | Allowed Values | Default | Description                                                                                                                         |
| ----------------- | ------- | -------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `WIDTH`           | integer | `≥1`           | `8`     | Bit width of the data vector.                                                                                                       |
| `DEPTH`           | integer | `≥2`           | `16`    | Number of entries in the memory.                                                                                                    |
| `WRITE_THROUGH`   | integer | `0`, `1`       | `0`     | Write-through mode selection.<br/>`0`: Read before write.<br/>`1`: Write-through forwarding when addresses match.                   |
| `REGISTERED_READ` | integer | `0`, `1`       | `1`     | Read mode selection.<br/>`0`: Combinational read (data available same cycle).<br/>`1`: Registered read (data available next cycle). |

## Ports

| Name                   | Direction | Width           | Clock   | Reset | Reset value | Description                                                                                      |
| ---------------------- | --------- | --------------- | ------- | ----- | ----------- | ------------------------------------------------------------------------------------------------ |
| `clock`                | input     | 1               | self    |       |             | Clock signal.                                                                                    |
| `port_0_access_enable` | input     | 1               | `clock` |       |             | Port 0 access enable signal.<br/>`0`: Idle.<br/>`1`: Perform read or write operation.            |
| `port_0_write`         | input     | 1               | `clock` |       |             | Port 0 operation mode selector.<br/>`0`: Read operation.<br/>`1`: Write operation.               |
| `port_0_address`       | input     | `ADDRESS_WIDTH` | `clock` |       |             | Port 0 address of the memory location to access.                                                 |
| `port_0_write_data`    | input     | `WIDTH`         | `clock` |       |             | Port 0 data to be written to the memory.                                                         |
| `port_0_read_data`     | output    | `WIDTH`         | `clock` |       |             | Port 0 data read from the memory. Valid same cycle or next cycle depending on `REGISTERED_READ`. |
| `port_1_access_enable` | input     | 1               | `clock` |       |             | Port 1 access enable signal.<br/>`0`: Idle.<br/>`1`: Perform read or write operation.            |
| `port_1_write`         | input     | 1               | `clock` |       |             | Port 1 operation mode selector.<br/>`0`: Read operation.<br/>`1`: Write operation.               |
| `port_1_address`       | input     | `ADDRESS_WIDTH` | `clock` |       |             | Port 1 address of the memory location to access.                                                 |
| `port_1_write_data`    | input     | `WIDTH`         | `clock` |       |             | Port 1 data to be written to the memory.                                                         |
| `port_1_read_data`     | output    | `WIDTH`         | `clock` |       |             | Port 1 data read from the memory. Valid same cycle or next cycle depending on `REGISTERED_READ`. |

## Operation

The true dual-port RAM manages an internal memory array with two fully independent read-write ports, allowing various simultaneous operations: two reads, two writes, or one read and one write to different or the same memory locations in the same clock cycle.

For **write operation** on either port, when the port's `access_enable` and `write` signals are both asserted, the port's `write_data` is stored at the memory location specified by the port's `address` on the rising edge of `clock`.

For **read operation** on either port, when the port's `access_enable` is asserted and `write` is deasserted, the data at the memory location specified by the port's `address` is driven on the port's `read_data`. The timing depends on the `REGISTERED_READ` parameter:
- If `REGISTERED_READ = 0`, the read is combinational and `read_data` is valid in the same clock cycle.
- If `REGISTERED_READ = 1`, the read is registered and `read_data` is valid in the next clock cycle after the read operation is initiated.

When both ports access the same address simultaneously, the behavior depends on the operation types and the `WRITE_THROUGH` parameter:
- **Two simultaneous writes** to the same address: The behavior is unspecified and should be avoided. The integration logic must ensure that both ports do not write to the same address in the same cycle.
- **One read and one write** to the same address: The read port's behavior depends on `WRITE_THROUGH`:
  - If `WRITE_THROUGH = 0`, the read returns the old data before the write (read-before-write behavior).
  - If `WRITE_THROUGH = 1`, the read returns the new data being written by the other port (write-through forwarding).

The memory contents are not initialized and will contain unpredictable values after power-up or reset.

## Paths

| From                                                                          | To                                     | Type          | Comment                                                                     |
| ----------------------------------------------------------------------------- | -------------------------------------- | ------------- | --------------------------------------------------------------------------- |
| `port_0_access_enable`, `port_0_write`, `port_0_address`, `port_0_write_data` | `port_0_read_data`, `port_1_read_data` | sequential    | Data path through internal memory array.                                    |
| `port_1_access_enable`, `port_1_write`, `port_1_address`, `port_1_write_data` | `port_0_read_data`, `port_1_read_data` | sequential    | Data path through internal memory array.                                    |
| `port_0_access_enable`, `port_0_write`, `port_0_address`                      | `port_0_read_data`                     | combinational | Address decoding (if `REGISTERED_READ = 0`).                                |
| `port_0_access_enable`, `port_0_write`, `port_0_address`                      | `port_0_read_data`                     | sequential    | Address decoding through register (if `REGISTERED_READ = 1`).               |
| `port_1_access_enable`, `port_1_write`, `port_1_address`                      | `port_1_read_data`                     | combinational | Address decoding (if `REGISTERED_READ = 0`).                                |
| `port_1_access_enable`, `port_1_write`, `port_1_address`                      | `port_1_read_data`                     | sequential    | Address decoding through register (if `REGISTERED_READ = 1`).               |
| `port_0_write_data`                                                           | `port_1_read_data`                     | combinational | Write-through forwarding path (if `WRITE_THROUGH = 1` and addresses match). |
| `port_1_write_data`                                                           | `port_0_read_data`                     | combinational | Write-through forwarding path (if `WRITE_THROUGH = 1` and addresses match). |

## Complexity

| Delay           | Gates            | Comment                                                          |
| --------------- | ---------------- | ---------------------------------------------------------------- |
| `O(log₂ DEPTH)` | `O(WIDTH×DEPTH)` | Critical path is the address decoding and memory array indexing. |

The module requires `WIDTH×DEPTH` flip-flops for the memory array. When `REGISTERED_READ = 1`, an additional `2×WIDTH` flip-flops are required for the read data registers of both ports.

## Verification

The true dual-port RAM is verified using a SystemVerilog testbench with fifteen check sequences that validate all operations and data integrity under various conditions.

The following table lists the checks performed by the testbench.

| Number | Check                                             | Description                                                                                                     |
| ------ | ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 1      | All zero (port 0 write, port 1 read)              | Writes zero to all memory locations on port 0 and reads back on port 1 to verify correct operation.             |
| 2      | All zero (port 1 write, port 0 read)              | Writes zero to all memory locations on port 1 and reads back on port 0 to verify correct operation.             |
| 3      | Address walking ones (port 0 write, port 1 read)  | Walks a vector of all ones through memory addresses using port 0 write and port 1 read to detect aliasing.      |
| 4      | Address walking ones (port 1 write, port 0 read)  | Walks a vector of all ones through memory addresses using port 1 write and port 0 read to detect aliasing.      |
| 5      | Address walking zeros (port 0 write, port 1 read) | Walks a vector of all zeros through memory addresses using port 0 write and port 1 read to detect aliasing.     |
| 6      | Address walking zeros (port 1 write, port 0 read) | Walks a vector of all zeros through memory addresses using port 1 write and port 0 read to detect aliasing.     |
| 7      | Data walking one (port 0 write, port 1 read)      | For each address, walks a single one through data bits using port 0 write and port 1 read.                      |
| 8      | Data walking one (port 1 write, port 0 read)      | For each address, walks a single one through data bits using port 1 write and port 0 read.                      |
| 9      | Data walking zero (port 0 write, port 1 read)     | For each address, walks a single zero through data bits using port 0 write and port 1 read.                     |
| 10     | Data walking zero (port 1 write, port 0 read)     | For each address, walks a single zero through data bits using port 1 write and port 0 read.                     |
| 11     | Concurrent writes                                 | Performs simultaneous write operations on both ports to verify dual-write capability and conflict resolution.   |
| 12     | Concurrent reads                                  | Performs simultaneous read operations on both ports to verify dual-read capability.                             |
| 13     | Concurrent read/write (port 0 read, port 1 write) | Performs simultaneous read on port 0 and write on port 1 to verify write-through behavior.                      |
| 14     | Concurrent read/write (port 0 write, port 1 read) | Performs simultaneous write on port 0 and read on port 1 to verify write-through behavior.                      |
| 15     | Random stimulus                                   | Performs randomized operations on both ports to verify robustness and data integrity against a reference model. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `DEPTH` | `WRITE_THROUGH` | `REGISTERED_READ` |           |
| ------- | ------- | --------------- | ----------------- | --------- |
| 8       | 16      | 0               | 1                 | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                     | Description                                         |
| ----------------- | ------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`true_dual_port_ram.v`](true_dual_port_ram.v)                           | Verilog design file.                                |
| Testbench         | [`true_dual_port_ram.testbench.sv`](true_dual_port_ram.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`true_dual_port_ram.testbench.gtkw`](true_dual_port_ram.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`true_dual_port_ram.symbol.sss`](true_dual_port_ram.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`true_dual_port_ram.symbol.svg`](true_dual_port_ram.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`true_dual_port_ram.symbol.drawio`](true_dual_port_ram.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`true_dual_port_ram.md`](true_dual_port_ram.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                              | Path                                      | Comment                       |
| ----------------------------------- | ----------------------------------------- | ----------------------------- |
| [`clog2.vh`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | For computing `CLOG2(DEPTH)`. |

## Related modules

| Module                                                                                                           | Path                                                                        | Comment                                                            |
| ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [`single_port_ram`](../single_port_ram/single_port_ram.md)                                                       | `omnicores-buildingblocks/sources/memory/single_port_ram`                   | RAM with a single shared port for read and write operations.       |
| [`simple_dual_port_ram`](../simple_dual_port_ram/simple_dual_port_ram.md)                                        | `omnicores-buildingblocks/sources/memory/simple_dual_port_ram`              | RAM with separate read and write ports for simultaneous access.    |
| [`asynchronous_simple_dual_port_ram`](../asynchronous_simple_dual_port_ram/asynchronous_simple_dual_port_ram.md) | `omnicores-buildingblocks/sources/memory/asynchronous_simple_dual_port_ram` | Asynchronous dual-port RAM for crossing clock domains.             |
| [`asynchronous_true_dual_port_ram`](../asynchronous_true_dual_port_ram/asynchronous_true_dual_port_ram.md)       | `omnicores-buildingblocks/sources/memory/asynchronous_true_dual_port_ram`   | Asynchronous true dual-port RAM for crossing clock domains.        |
| [`content_addressable_memory`](../content_addressable_memory/content_addressable_memory.md)                      | `omnicores-buildingblocks/sources/memory/content_addressable_memory`        | Associative memory accessed by content rather than address.        |
| [`tag_directory`](../tag_directory/tag_directory.md)                                                             | `omnicores-buildingblocks/sources/memory/tag_directory`                     | Directory for managing tags with allocation, search, and eviction. |

