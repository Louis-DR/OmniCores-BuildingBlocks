# Extended Hamming Encoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Encoder                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Encoder computes Extended Hamming codes for error control with SECDED (Single Error Correction, Double Error Detection) capability. It generates systematic Extended Hamming codes by combining standard Hamming codes with an additional overall parity bit. The encoder places parity bits at power-of-2 positions (1, 2, 4, 8, ...) with an extra parity bit at position 0, enabling correction of single-bit errors and detection of double-bit errors. The module provides both separate parity codes and complete encoded blocks for flexible integration in error control systems.

## Parameters

| Name         | Type    | Default | Range          | Description                      |
| ------------ | ------- | ------- | -------------- | -------------------------------- |
| `DATA_WIDTH` | integer | `4`     | `1` to `65519` | Width of the input data in bits. |

## Ports

| Name    | Direction | Width                     | Clock | Reset | Reset value | Description                                    |
| ------- | --------- | ------------------------- | ----- | ----- | ----------- | ---------------------------------------------- |
| `data`  | input     | `DATA_WIDTH`              |       |       |             | Input data to be Extended Hamming encoded.     |
| `code`  | output    | `PARITY_WIDTH`            |       |       |             | Computed Extended Hamming parity bits.         |
| `block` | output    | `DATA_WIDTH+PARITY_WIDTH` |       |       |             | Complete Extended Hamming block (code + data). |

## Operation

The Extended Hamming Encoder operates by first generating standard Hamming codes using an internal Hamming encoder, then computing an additional overall parity bit using a parity encoder. The extra parity bit is calculated over the entire standard Hamming block and placed at position 0 in the Extended Hamming code. This configuration enables SECDED capability where single-bit errors can be corrected and double-bit errors can be detected. The encoder outputs both the complete parity code (including the extra bit) and the full encoded block with data and parity bits properly positioned according to Extended Hamming code structure.

## Paths

| From   | To      | Type          | Comment                                     |
| ------ | ------- | ------------- | ------------------------------------------- |
| `data` | `code`  | combinatorial | Through Hamming encoder and parity encoder. |
| `data` | `block` | combinatorial | Through Hamming encoder and block packer.   |

## Complexity

| Delay                | Gates                             | Comment                                      |
| -------------------- | --------------------------------- | -------------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | XOR tree depth proportional to parity width. |

The Extended Hamming encoding requires XOR trees for each parity bit plus an additional XOR tree for the extra parity bit, with complexity logarithmic in data width, making it efficient for moderate to large data paths while providing enhanced error correction capabilities.

## Verification

The verification approach tests the Extended Hamming encoder across all modules in the Extended Hamming error control suite. The testbench validates encoding correctness, parity generation, and block formation under various conditions including error-free scenarios and error injection testing.

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

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`extended_hamming_encoder.sv`](extended_hamming_encoder.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_encoder.symbol.sss`](extended_hamming_encoder.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_encoder.symbol.svg`](extended_hamming_encoder.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_encoder.symbol.drawio`](extended_hamming_encoder.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_encoder.md`](extended_hamming_encoder.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                       | Path                                                     | Comment |
| ------------------------------------------------------------ | -------------------------------------------------------- | ------- |
| [`hamming_encoder`](../hamming/hamming_encoder.md)           | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`parity_encoder`](../parity/parity_encoder.md)              | `omnicores-buildingblocks/sources/error_control/parity`  |         |
| [`hamming_block_packer`](../hamming/hamming_block_packer.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                                    | Path                                                              | Comment                                            |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | -------------------------------------------------- |
| [`extended_hamming_checker`](extended_hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming checker for data and code inputs. |
| [`extended_hamming_corrector`](extended_hamming_corrector.md)             | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming corrector with error correction.  |
| [`extended_hamming_block_checker`](extended_hamming_block_checker.md)     | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming checker for complete blocks.      |
| [`extended_hamming_block_corrector`](extended_hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming corrector for complete blocks.    |
| [`extended_hamming_block_packer`](extended_hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Utility for block formatting.                      |
| [`extended_hamming_block_unpacker`](extended_hamming_block_unpacker.md)   | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Utility for block parsing.                         |
