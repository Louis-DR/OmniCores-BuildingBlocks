# Hamming Block Corrector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Block Corrector                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_block_corrector](hamming_block_corrector.symbol.svg)

Detects and corrects single-bit errors in complete Hamming-encoded blocks using syndrome analysis and direct error correction. This corrector extracts data and parity components from the input block, computes the error syndrome, and applies bit-level correction to recover the original data. It is designed for systems where Hamming-protected data is transmitted or stored as unified blocks and automatic error correction is required.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                      |
| ------------- | ------- | -------------- | ------- | -------------------------------- |
| `BLOCK_WIDTH` | integer | `≥3`           | `7`     | Bit width of the complete block. |

## Ports

| Name                       | Direction | Width               | Clock | Reset | Reset value | Description                             |
| -------------------------- | --------- | ------------------- | ----- | ----- | ----------- | --------------------------------------- |
| `block`                    | input     | `BLOCK_WIDTH`       |       |       |             | Complete Hamming block to be corrected. |
| `error`                    | output    | 1                   |       |       |             | Error detection flag.                   |
| `corrected_block`          | output    | `BLOCK_WIDTH`       |       |       |             | Error-corrected output block.           |
| `corrected_error_position` | output    | `log₂(BLOCK_WIDTH)` |       |       |             | Position of corrected error in block.   |

## Operation

The Hamming block corrector separates the input block into data and parity components, computes the error syndrome by comparing received and expected parity codes, and uses the syndrome value to directly identify and correct single-bit errors. The syndrome naturally encodes the error position in binary, enabling immediate error mask generation and correction.

The module provides a unified interface for both error detection and correction in systems where Hamming-protected data is transmitted or stored as complete blocks. This approach simplifies system design by eliminating the need to handle data and parity codes separately during error correction operations.

## Paths

| From    | To                         | Type          | Comment                                       |
| ------- | -------------------------- | ------------- | --------------------------------------------- |
| `block` | `error`                    | combinatorial | Through syndrome computation logic.           |
| `block` | `corrected_block`          | combinatorial | Through error mask generation and correction. |
| `block` | `corrected_error_position` | combinatorial | Through syndrome to position conversion.      |

## Complexity

| Delay                 | Gates                               | Comment                                           |
| --------------------- | ----------------------------------- | ------------------------------------------------- |
| `O(log₂ BLOCK_WIDTH)` | `O(BLOCK_WIDTH × log₂ BLOCK_WIDTH)` | Single level syndrome computation and correction. |

The corrector utilizes syndrome computation, error mask generation, and block correction logic that operates efficiently for single-level delay suitable for high-performance error correction applications.

## Verification

The Hamming block corrector is verified using a comprehensive SystemVerilog testbench that validates both error detection and correction with various error patterns. The testbench instantiates and verifies all Hamming modules.

The following table lists the checks performed by the testbench.

| Number | Check                                 | Description                                                            |
| ------ | ------------------------------------- | ---------------------------------------------------------------------- |
| 1a     | Exhaustive test without error         | Tests all modules for all data values if `DATA_WIDTH` ≤ 9.             |
| 1b     | Random test without error             | Tests all modules for random data values if `DATA_WIDTH` > 9.          |
| 2a     | Exhaustive test with single-bit error | Tests error correction for all error positions if `DATA_WIDTH` ≤ 9.    |
| 2b     | Random test with single-bit error     | Tests error correction for random error positions if `DATA_WIDTH` > 9. |

The following table lists the parameter values verified by the testbench.

| `BLOCK_WIDTH` |           |
| ------------- | --------- |
| 7             | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                       | Description                                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`hamming_block_corrector.sv`](hamming_block_corrector.sv)                 | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                             | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)                         | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_block_corrector.symbol.sss`](hamming_block_corrector.symbol.sss) | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_block_corrector.symbol.svg`](hamming_block_corrector.symbol.svg) | Generated vector image of the symbol.               |
| Datasheet         | [`hamming_block_corrector.md`](hamming_block_corrector.md)                 | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                | Path                                                     | Comment |
| ----------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_unpacker`](hamming_block_unpacker.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`hamming_encoder`](hamming_encoder.md)               | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                              | Path                                                     | Comment                                  |
| --------------------------------------------------- | -------------------------------------------------------- | ---------------------------------------- |
| [`hamming_encoder`](hamming_encoder.md)             | `omnicores-buildingblocks/sources/error_control/hamming` | Internal dependency for code generation. |
| [`hamming_corrector`](hamming_corrector.md)         | `omnicores-buildingblocks/sources/error_control/hamming` | Variant for separate data and code.      |
| [`hamming_block_checker`](hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Variant with error detection only.       |
