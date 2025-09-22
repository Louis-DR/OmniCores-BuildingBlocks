# Extended Hamming Block Packer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Block Packer                                                    |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Block Packer formats data and Extended Hamming parity codes into complete Extended Hamming blocks. It provides a utility function for constructing properly formatted Extended Hamming blocks by combining data and parity information according to Extended Hamming code structure. The packer separates the extra parity bit from the standard Hamming code, uses an internal Hamming block packer for the standard portion, and appends the extra parity bit at position 0. This module enables consistent block formation across Extended Hamming error control systems.

## Parameters

| Name         | Type    | Default | Range          | Description                      |
| ------------ | ------- | ------- | -------------- | -------------------------------- |
| `DATA_WIDTH` | integer | `4`     | `1` to `65519` | Width of the input data in bits. |

## Ports

| Name    | Direction | Width                     | Clock | Reset | Reset value | Description                             |
| ------- | --------- | ------------------------- | ----- | ----- | ----------- | --------------------------------------- |
| `data`  | input     | `DATA_WIDTH`              |       |       |             | Input data to be packed.                |
| `code`  | input     | `PARITY_WIDTH`            |       |       |             | Input Extended Hamming parity codes.    |
| `block` | output    | `DATA_WIDTH+PARITY_WIDTH` |       |       |             | Complete Extended Hamming block output. |

## Operation

The Extended Hamming Block Packer operates by first separating the extra parity bit (LSB) from the standard Hamming code portion of the input parity codes. It uses an internal Hamming block packer to format the data and standard Hamming code into a standard Hamming block. The extra parity bit is then appended at position 0 to create the complete Extended Hamming block. This process maintains the Extended Hamming code structure where the extra parity bit occupies the least significant position and the standard Hamming portion follows the established power-of-2 positioning rules.

## Paths

| From   | To      | Type          | Comment                       |
| ------ | ------- | ------------- | ----------------------------- |
| `data` | `block` | combinational | Direct bit positioning logic. |
| `code` | `block` | combinational | Direct bit positioning logic. |

## Complexity

| Delay  | Gates  | Comment                                  |
| ------ | ------ | ---------------------------------------- |
| `O(0)` | `O(0)` | Pure wiring with no computational logic. |

The block packer performs only bit positioning and concatenation operations without computational logic, resulting in zero delay and gate complexity suitable for high-speed applications.

## Verification

The verification approach tests the Extended Hamming block packer across all modules in the Extended Hamming error control suite. The testbench validates block formation correctness, proper bit positioning, and integration with other Extended Hamming modules.

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

| Type              | File                                                                                         | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`extended_hamming_block_packer.sv`](extended_hamming_block_packer.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                             | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)                         | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_block_packer.symbol.sss`](extended_hamming_block_packer.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_block_packer.symbol.svg`](extended_hamming_block_packer.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_block_packer.symbol.drawio`](extended_hamming_block_packer.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_block_packer.md`](extended_hamming_block_packer.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                       | Path                                                     | Comment |
| ------------------------------------------------------------ | -------------------------------------------------------- | ------- |
| [`hamming_block_packer`](../hamming/hamming_block_packer.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                                  | Path                                                              | Comment                                    |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------ |
| [`extended_hamming_block_unpacker`](extended_hamming_block_unpacker.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Inverse operation for block decomposition. |
| [`extended_hamming_encoder`](extended_hamming_encoder.md)               | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block packer for complete encoding.   |
| [`extended_hamming_checker`](extended_hamming_checker.md)               | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block packer for error checking.      |
| [`extended_hamming_corrector`](extended_hamming_corrector.md)           | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Uses block packer for error correction.    |
