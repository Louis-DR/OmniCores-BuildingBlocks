# Extended Hamming Checker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Checker                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Checker detects correctable single-bit errors and uncorrectable double-bit errors in data with Extended Hamming codes. It provides SECDED (Single Error Correction, Double Error Detection) capability by analyzing received data and parity codes to determine error status. The checker internally uses Extended Hamming block packing and checking logic to validate data integrity. It categorizes errors into correctable (single-bit) and uncorrectable (double-bit) types, enabling appropriate error handling strategies in error control systems.

## Parameters

| Name         | Type    | Default | Range          | Description                      |
| ------------ | ------- | ------- | -------------- | -------------------------------- |
| `DATA_WIDTH` | integer | `4`     | `1` to `65519` | Width of the input data in bits. |

## Ports

| Name                  | Direction | Width          | Clock | Reset | Reset value | Description                            |
| --------------------- | --------- | -------------- | ----- | ----- | ----------- | -------------------------------------- |
| `data`                | input     | `DATA_WIDTH`   |       |       |             | Received data to be checked.           |
| `code`                | input     | `PARITY_WIDTH` |       |       |             | Received Extended Hamming parity code. |
| `correctable_error`   | output    | 1              |       |       |             | Single-bit error detection flag.       |
| `uncorrectable_error` | output    | 1              |       |       |             | Double-bit error detection flag.       |

## Operation

The Extended Hamming Checker operates by first padding the input data to match the message length corresponding to the number of parity bits, then using an internal Extended Hamming block packer to construct the complete block. The packed block is analyzed by an Extended Hamming block checker that computes syndrome information and extra parity validation. Single-bit errors are identified when the extra parity indicates an error, making them correctable. Double-bit errors are detected when the Hamming syndrome indicates errors but the extra parity is correct, making them uncorrectable. This dual-level error detection enables robust error handling in communication and storage systems.

## Paths

| From   | To                    | Type          | Comment                                          |
| ------ | --------------------- | ------------- | ------------------------------------------------ |
| `data` | `correctable_error`   | combinatorial | Through internal Extended Hamming block checker. |
| `code` | `correctable_error`   | combinatorial | Through internal Extended Hamming block checker. |
| `data` | `uncorrectable_error` | combinatorial | Through internal Extended Hamming block checker. |
| `code` | `uncorrectable_error` | combinatorial | Through internal Extended Hamming block checker. |

## Complexity

| Delay                | Gates                             | Comment                                   |
| -------------------- | --------------------------------- | ----------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | Single level logic through block checker. |

The checker utilizes the Extended Hamming block checker internally, inheriting its efficient syndrome computation and extra parity validation logic for fast error categorization suitable for high-speed applications.

## Verification

The verification approach tests the Extended Hamming checker across all modules in the Extended Hamming error control suite. The testbench validates error detection correctness, proper categorization of correctable and uncorrectable errors, and integration with other Extended Hamming modules.

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
| Design            | [`extended_hamming_checker.sv`](extended_hamming_checker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_checker.symbol.sss`](extended_hamming_checker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_checker.symbol.svg`](extended_hamming_checker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_checker.symbol.drawio`](extended_hamming_checker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_checker.md`](extended_hamming_checker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                | Path                                                              | Comment |
| --------------------------------------------------------------------- | ----------------------------------------------------------------- | ------- |
| [`extended_hamming_block_packer`](extended_hamming_block_packer.md)   | `omnicores-buildingblocks/sources/error_control/extended_hamming` |         |
| [`extended_hamming_block_checker`](extended_hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` |         |

## Related modules

| Module                                                                | Path                                                              | Comment                                        |
| --------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| [`extended_hamming_encoder`](extended_hamming_encoder.md)             | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming encoder for generating codes. |
| [`extended_hamming_corrector`](extended_hamming_corrector.md)         | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant with error correction capability.      |
| [`extended_hamming_block_checker`](extended_hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant for combined data and code.            |
