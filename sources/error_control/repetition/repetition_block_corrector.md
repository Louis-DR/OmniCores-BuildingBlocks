# Repetition Block Corrector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Repetition Block Corrector                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![repetition_block_corrector](repetition_block_corrector.symbol.svg)

Detects and corrects errors in complete repetition-encoded blocks using majority voting among all repetitions. This corrector extracts individual repetitions from the input block and applies majority voting to recover the correct data value for each bit position. It is designed for systems where repetition-protected data is transmitted or stored as unified blocks and automatic error correction is required.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                    |
| ------------ | ------- | -------------- | ------- | ------------------------------ |
| `DATA_WIDTH` | integer | `≥1`           | `8`     | Bit width of the data portion. |
| `REPETITION` | integer | `≥2`           | `3`     | Number of data repetitions.    |

## Ports

| Name             | Direction | Width                   | Clock | Reset | Reset value | Description                                |
| ---------------- | --------- | ----------------------- | ----- | ----- | ----------- | ------------------------------------------ |
| `block`          | input     | `REPETITION×DATA_WIDTH` |       |       |             | Complete repetition block to be corrected. |
| `error`          | output    | 1                       |       |       |             | Error detection flag.                      |
| `corrected_data` | output    | `DATA_WIDTH`            |       |       |             | Error-corrected output data.               |

## Operation

The repetition block corrector separates the input block into individual repetitions and performs majority voting for each bit position across all copies. The module groups corresponding bits from each repetition together and counts the number of 1s and 0s to determine the majority value. Any disagreement among repetitions indicates an error condition, while the majority value is selected as the corrected output.

The module provides a unified interface for both error detection and correction in systems where repetition-protected data is transmitted or stored as complete blocks. This approach simplifies system design by eliminating the need to handle data and repetition codes separately during error correction operations.

## Paths

| From    | To               | Type          | Comment                                         |
| ------- | ---------------- | ------------- | ----------------------------------------------- |
| `block` | `error`          | combinatorial | Through bit grouping and comparison logic.      |
| `block` | `corrected_data` | combinatorial | Through bit grouping and majority voting logic. |

## Complexity

| Delay  | Gates                      | Comment                                            |
| ------ | -------------------------- | -------------------------------------------------- |
| `O(1)` | `O(REPETITION×DATA_WIDTH)` | Single level comparison and majority voting logic. |

The corrector utilizes bit grouping, comparison, and majority voting logic that operates in parallel across all bit positions, resulting in efficient single-level delay suitable for high-performance error correction applications.

## Verification

The repetition block corrector is verified using a comprehensive SystemVerilog testbench that validates both error detection and correction with various error patterns. The testbench instanciates and verifies all repetition modules.

The following table lists the checks performed by the testbench.

| Number | Check                               | Description                                                      |
| ------ | ----------------------------------- | ---------------------------------------------------------------- |
| 1      | Encoder exhaustive test             | Tests repetition generation for all possible input data values.  |
| 2      | Checker with correct repetition     | Verifies no false errors with matching data and repetitions.     |
| 3      | Checker with incorrect repetition   | Confirms error detection with mismatched data and repetitions.   |
| 4      | Block checker with correct blocks   | Verifies no false errors with valid repetition blocks.           |
| 5      | Block checker with incorrect blocks | Confirms error detection with corrupted repetition blocks.       |
| 6      | Complete encode-decode cycle        | Verifies end-to-end encoding and checking without errors.        |
| 7      | Single bit error detection          | Confirms single-bit errors are detectable in encoded blocks.     |
| 8      | Corrector with correct data         | Validates proper operation with uncorrupted repetition data.     |
| 9      | Corrector with single bit errors    | Tests error correction capabilities with single-bit corruptions. |
| 10     | Double bit error detection          | Verifies detection of uncorrectable double-bit errors.           |

The following table lists the parameter values verified by the testbench.

| `DATA_WIDTH` | `REPETITION` |           |
| ------------ | ------------ | --------- |
| 8            | 3            | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`repetition_block_corrector.v`](repetition_block_corrector.v)                         | Verilog design.                                     |
| Testbench         | [`repetition.testbench.sv`](repetition.testbench.sv)                                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`repetition.testbench.gtkw`](repetition.testbench.gtkw)                               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`repetition_block_corrector.symbol.sss`](repetition_block_corrector.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`repetition_block_corrector.symbol.svg`](repetition_block_corrector.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`repetition_block_corrector.symbol.drawio`](repetition_block_corrector.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`repetition_block_corrector.md`](repetition_block_corrector.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                    | Path                                                        | Comment                                        |
| --------------------------------------------------------- | ----------------------------------------------------------- | ---------------------------------------------- |
| [`repetition_encoder`](repetition_encoder.md)             | `omnicores-buildingblocks/sources/error_control/repetition` | Internal dependency for repetition generation. |
| [`repetition_corrector`](repetition_corrector.md)         | `omnicores-buildingblocks/sources/error_control/repetition` | Variant for separate data and code.            |
| [`repetition_block_checker`](repetition_block_checker.md) | `omnicores-buildingblocks/sources/error_control/repetition` | Variant with error detection only.             |