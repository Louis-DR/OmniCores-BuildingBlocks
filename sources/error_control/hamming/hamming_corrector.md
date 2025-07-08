# Hamming Corrector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Corrector                                                                |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_corrector](hamming_corrector.symbol.svg)

Detects and corrects single-bit errors in received data using Hamming syndrome analysis. This corrector can recover from single-bit errors by computing the error syndrome and directly identifying the error position for correction. The module is designed for systems where data and Hamming codes are transmitted or stored separately and automatic error correction is required.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                  |
| ------------ | ------- | -------------- | ------- | ---------------------------- |
| `DATA_WIDTH` | integer | `≥1`           | `4`     | Bit width of the input data. |

## Ports

| Name                       | Direction | Width               | Clock | Reset | Reset value | Description                    |
| -------------------------- | --------- | ------------------- | ----- | ----- | ----------- | ------------------------------ |
| `data`                     | input     | `DATA_WIDTH`        |       |       |             | Received data to be checked.   |
| `code`                     | input     | `PARITY_WIDTH`      |       |       |             | Received Hamming parity codes. |
| `error`                    | output    | 1                   |       |       |             | Error detection flag.          |
| `corrected_data`           | output    | `DATA_WIDTH`        |       |       |             | Error-corrected output data.   |
| `corrected_error_position` | output    | `log₂(BLOCK_WIDTH)` |       |       |             | Position of corrected error.   |

## Operation

The Hamming corrector validates and corrects data integrity by reconstructing the complete Hamming block from the received data and code components, then delegates both error detection and correction to the Hamming block corrector module. The corrector uses syndrome analysis to determine both the presence and exact location of single-bit errors.

The syndrome directly encodes the error position in the Hamming block, allowing immediate error correction by flipping the identified bit. When no error is present (syndrome = 0), the original data is output unchanged. When an error is detected, the corrected data and error position are provided for system analysis.

## Paths

| From   | To                         | Type          | Comment                                   |
| ------ | -------------------------- | ------------- | ----------------------------------------- |
| `data` | `error`                    | combinatorial | Through internal Hamming block corrector. |
| `code` | `error`                    | combinatorial | Through internal Hamming block corrector. |
| `data` | `corrected_data`           | combinatorial | Through internal Hamming block corrector. |
| `code` | `corrected_data`           | combinatorial | Through internal Hamming block corrector. |
| `data` | `corrected_error_position` | combinatorial | Through internal Hamming block corrector. |
| `code` | `corrected_error_position` | combinatorial | Through internal Hamming block corrector. |

## Complexity

| Delay                | Gates                             | Comment                                     |
| -------------------- | --------------------------------- | ------------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | Single level logic through block corrector. |

The corrector utilizes the Hamming block corrector internally, inheriting its efficient syndrome computation and error correction logic for fast error recovery suitable for high-speed applications.

## Verification

The Hamming corrector is verified using a comprehensive SystemVerilog testbench that validates both error detection and correction capabilities with various error patterns. The testbench instantiates and verifies all Hamming modules.

The following table lists the checks performed by the testbench.

| Number | Check                                 | Description                                                            |
| ------ | ------------------------------------- | ---------------------------------------------------------------------- |
| 1a     | Exhaustive test without error         | Tests all modules for all data values if `DATA_WIDTH` ≤ 9.             |
| 1b     | Random test without error             | Tests all modules for random data values if `DATA_WIDTH` > 9.          |
| 2a     | Exhaustive test with single-bit error | Tests error correction for all error positions if `DATA_WIDTH` ≤ 9.    |
| 2b     | Random test with single-bit error     | Tests error correction for random error positions if `DATA_WIDTH` > 9. |

The following table lists the parameter values verified by the testbench.

| `DATA_WIDTH` |           |
| ------------ | --------- |
| 4            | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                           | Description                                         |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`hamming_corrector.sv`](hamming_corrector.sv)                 | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                 | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)             | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_corrector.symbol.sss`](hamming_corrector.symbol.sss) | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_corrector.symbol.svg`](hamming_corrector.symbol.svg) | Generated vector image of the symbol.               |
| Datasheet         | [`hamming_corrector.md`](hamming_corrector.md)                 | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                  | Path                                                     | Comment |
| ------------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_packer`](hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`hamming_block_corrector`](hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`hamming_block_unpacker`](hamming_block_unpacker.md)   | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                  | Path                                                     | Comment                               |
| ------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------- |
| [`hamming_encoder`](hamming_encoder.md)                 | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming encoder for generating codes. |
| [`hamming_checker`](hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/hamming` | Variant with error detection only.    |
| [`hamming_block_corrector`](hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Variant for combined data and code.   |
