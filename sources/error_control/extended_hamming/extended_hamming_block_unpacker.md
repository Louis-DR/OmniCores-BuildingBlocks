# Extended Hamming Block Unpacker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Block Unpacker                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Block Unpacker extracts data and Extended Hamming parity codes from complete Extended Hamming blocks. It provides a utility function for decomposing properly formatted Extended Hamming blocks into their constituent data and parity components according to Extended Hamming code structure. The unpacker separates the extra parity bit from position 0, uses an internal Hamming block unpacker for the standard portion, and reconstructs the complete Extended Hamming parity code. This module enables consistent block parsing across Extended Hamming error control systems.

## Parameters

| Name          | Type    | Default | Range          | Description                          |
| ------------- | ------- | ------- | -------------- | ------------------------------------ |
| `BLOCK_WIDTH` | integer | `8`     | `4` to `65536` | Width of the complete block in bits. |

## Ports

| Name    | Direction | Width          | Clock | Reset | Reset value | Description                              |
| ------- | --------- | -------------- | ----- | ----- | ----------- | ---------------------------------------- |
| `block` | input     | `BLOCK_WIDTH`  |       |       |             | Complete Extended Hamming block input.   |
| `data`  | output    | `DATA_WIDTH`   |       |       |             | Extracted data bits.                     |
| `code`  | output    | `PARITY_WIDTH` |       |       |             | Extracted Extended Hamming parity codes. |

## Operation

The Extended Hamming Block Unpacker operates by first separating the extra parity bit from position 0 and the standard Hamming block from the remaining positions. It uses an internal Hamming block unpacker to extract the data and standard Hamming code from the standard Hamming block portion. The extra parity bit is then concatenated with the standard Hamming code to reconstruct the complete Extended Hamming parity code. This process maintains the Extended Hamming code structure and enables proper parsing of Extended Hamming blocks for error control operations.

## Paths

| From    | To     | Type          | Comment                      |
| ------- | ------ | ------------- | ---------------------------- |
| `block` | `data` | combinational | Direct bit extraction logic. |
| `block` | `code` | combinational | Direct bit extraction logic. |

## Complexity

| Delay  | Gates  | Comment                                  |
| ------ | ------ | ---------------------------------------- |
| `O(0)` | `O(0)` | Pure wiring with no computational logic. |

The block unpacker performs only bit extraction and concatenation operations without computational logic, resulting in zero delay and gate complexity suitable for high-speed applications.

## Verification

The verification approach tests the Extended Hamming block unpacker across all modules in the Extended Hamming error control suite. The testbench validates block parsing correctness, proper bit extraction, and integration with other Extended Hamming modules.

The following table lists the checks performed by the testbench.

| Number | Check                                 | Description                                                                |
| ------ | ------------------------------------- | -------------------------------------------------------------------------- |
| 1a     | Exhaustive test without error         | Tests all modules for all data values if `DATA_WIDTH` ≤ 9.                 |
| 1b     | Random test without error             | Tests all modules for random data values if `DATA_WIDTH` > 9.              |
| 2a     | Exhaustive test with single-bit error | Tests error correction for all error positions if `DATA_WIDTH` ≤ 9.        |
| 2b     | Random test with single-bit error     | Tests error correction for random error positions if `DATA_WIDTH` > 9.     |
| 3a     | Exhaustive test with double-bit error | Tests error detection for all error position pairs if `DATA_WIDTH` ≤ 9.    |
| 3b     | Random test with double-bit error     | Tests error detection for random error position pairs if `DATA_WIDTH` > 9. |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                                             | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`extended_hamming_block_unpacker.sv`](extended_hamming_block_unpacker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                                 | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)                             | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_block_unpacker.symbol.sss`](extended_hamming_block_unpacker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_block_unpacker.symbol.svg`](extended_hamming_block_unpacker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_block_unpacker.symbol.drawio`](extended_hamming_block_unpacker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_block_unpacker.md`](extended_hamming_block_unpacker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                           | Path                                                     | Comment |
| ---------------------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_unpacker`](../hamming/hamming_block_unpacker.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                                    | Path                                                              | Comment                                   |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------------------------------- |
| [`extended_hamming_block_packer`](extended_hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Inverse operation for block formation.    |
| [`extended_hamming_block_checker`](extended_hamming_block_checker.md)     | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block unpacker for error checking.   |
| [`extended_hamming_block_corrector`](extended_hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block unpacker for error correction. |
| [`extended_hamming_corrector`](extended_hamming_corrector.md)             | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block unpacker for data extraction.  |
