# Hamming Block Checker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Block Checker                                                            |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_block_checker](hamming_block_checker.symbol.svg)

Validates the integrity of complete Hamming-encoded blocks containing interleaved data and parity bits. This checker extracts data and parity components from the input block and computes the error syndrome to detect single-bit errors. It is designed for systems where Hamming-protected data is transmitted or stored as complete unified blocks.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                      |
| ------------- | ------- | -------------- | ------- | -------------------------------- |
| `BLOCK_WIDTH` | integer | `≥3`           | `7`     | Bit width of the complete block. |

## Ports

| Name    | Direction | Width         | Clock | Reset | Reset value | Description                           |
| ------- | --------- | ------------- | ----- | ----- | ----------- | ------------------------------------- |
| `block` | input     | `BLOCK_WIDTH` |       |       |             | Complete Hamming block to be checked. |
| `error` | output    | 1             |       |       |             | Error detection flag.                 |

## Operation

The Hamming block checker separates the input block into data and parity components using the block unpacker, then reconstructs the expected Hamming code using the encoder and compares it with the received parity bits. The module computes the syndrome by XORing received and expected codes, detecting errors when the syndrome is non-zero.

The module provides a unified interface for error detection in systems where Hamming-protected data is transmitted or stored as complete blocks. This approach simplifies system design by eliminating the need to handle data and parity codes separately during error checking operations.

## Paths

| From    | To      | Type          | Comment                                              |
| ------- | ------- | ------------- | ---------------------------------------------------- |
| `block` | `error` | combinatorial | Through unpacker, encoder, and syndrome computation. |

## Complexity

| Delay                 | Gates                               | Comment                                  |
| --------------------- | ----------------------------------- | ---------------------------------------- |
| `O(log₂ BLOCK_WIDTH)` | `O(BLOCK_WIDTH × log₂ BLOCK_WIDTH)` | Single level syndrome computation logic. |

The checker utilizes block unpacking, Hamming encoding, and syndrome computation that operates efficiently for single-level delay suitable for high-performance error detection applications.

## Verification

The Hamming block checker is verified using a comprehensive SystemVerilog testbench that validates error detection with both correct and corrupted Hamming blocks. The testbench instantiates and verifies all Hamming modules.

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

| Type              | File                                                                         | Description                                         |
| ----------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`hamming_block_checker.sv`](hamming_block_checker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                               | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)                           | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_block_checker.symbol.sss`](hamming_block_checker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_block_checker.symbol.svg`](hamming_block_checker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`hamming_block_checker.symbol.drawio`](hamming_block_checker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`hamming_block_checker.md`](hamming_block_checker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                | Path                                                     | Comment |
| ----------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_unpacker`](hamming_block_unpacker.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`hamming_encoder`](hamming_encoder.md)               | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                  | Path                                                     | Comment                                   |
| ------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------- |
| [`hamming_encoder`](hamming_encoder.md)                 | `omnicores-buildingblocks/sources/error_control/hamming` | Internal dependency for code generation.  |
| [`hamming_checker`](hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/hamming` | Variant for separate data and code.       |
| [`hamming_block_corrector`](hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Variant with error correction capability. |
