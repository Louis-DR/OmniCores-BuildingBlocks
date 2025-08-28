# Extended Hamming Block Checker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Block Checker                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Block Checker detects correctable single-bit errors and uncorrectable double-bit errors in complete Extended Hamming blocks. It provides SECDED (Single Error Correction, Double Error Detection) capability by analyzing complete encoded blocks to determine error status. The checker separates the extra parity bit from the standard Hamming block, validates both components independently, and categorizes errors based on their patterns. Single-bit errors are identified as correctable when the extra parity indicates an error, while double-bit errors are detected as uncorrectable when the Hamming syndrome indicates errors but the extra parity is correct.

## Parameters

| Name          | Type    | Default | Range          | Description                          |
| ------------- | ------- | ------- | -------------- | ------------------------------------ |
| `BLOCK_WIDTH` | integer | `8`     | `4` to `65536` | Width of the complete block in bits. |

## Ports

| Name                  | Direction | Width         | Clock | Reset | Reset value | Description                                    |
| --------------------- | --------- | ------------- | ----- | ----- | ----------- | ---------------------------------------------- |
| `block`               | input     | `BLOCK_WIDTH` |       |       |             | Complete Extended Hamming block to be checked. |
| `correctable_error`   | output    | 1             |       |       |             | Single-bit error detection flag.               |
| `uncorrectable_error` | output    | 1             |       |       |             | Double-bit error detection flag.               |

## Operation

The Extended Hamming Block Checker operates by first separating the extra parity bit (LSB) from the standard Hamming block (remaining bits). It calculates the expected extra parity using a parity encoder over the Hamming block and compares it with the received extra parity. Simultaneously, it validates the Hamming block using an internal Hamming block checker. Error categorization follows Extended Hamming logic: correctable errors occur when the extra parity is incorrect (indicating a single-bit error), while uncorrectable errors occur when the Hamming syndrome indicates errors but the extra parity is correct (indicating a double-bit error pattern).

## Paths

| From    | To                    | Type          | Comment                                                |
| ------- | --------------------- | ------------- | ------------------------------------------------------ |
| `block` | `correctable_error`   | combinatorial | Through extra parity validation and syndrome analysis. |
| `block` | `uncorrectable_error` | combinatorial | Through extra parity validation and syndrome analysis. |

## Complexity

| Delay                 | Gates                               | Comment                                  |
| --------------------- | ----------------------------------- | ---------------------------------------- |
| `O(log₂ BLOCK_WIDTH)` | `O(BLOCK_WIDTH × log₂ BLOCK_WIDTH)` | Single level syndrome computation logic. |

The checker utilizes block separation, parity computation, and syndrome analysis that operates efficiently for single-level delay suitable for high-performance error detection applications.

## Verification

The verification approach tests the Extended Hamming block checker across all modules in the Extended Hamming error control suite. The testbench validates error detection correctness, proper categorization of correctable and uncorrectable errors, and integration with other Extended Hamming modules.

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

| Type              | File                                                                                           | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`extended_hamming_block_checker.sv`](extended_hamming_block_checker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                               | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)                           | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_block_checker.symbol.sss`](extended_hamming_block_checker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_block_checker.symbol.svg`](extended_hamming_block_checker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_block_checker.symbol.drawio`](extended_hamming_block_checker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_block_checker.md`](extended_hamming_block_checker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                         | Path                                                     | Comment |
| -------------------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_checker`](../hamming/hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`parity_encoder`](../parity/parity_encoder.md)                | `omnicores-buildingblocks/sources/error_control/parity`  |         |

## Related modules

| Module                                                                    | Path                                                              | Comment                                              |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------- |
| [`extended_hamming_checker`](extended_hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant for separate data and code.                  |
| [`extended_hamming_block_corrector`](extended_hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant with error correction capability.            |
| [`hamming_block_checker`](../hamming/hamming_block_checker.md)            | `omnicores-buildingblocks/sources/error_control/hamming`          | Internal dependency for standard Hamming validation. |
