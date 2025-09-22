# Hamming Checker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Checker                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_checker](hamming_checker.symbol.svg)

Detects single-bit errors in received data using associated Hamming parity codes. This checker validates data integrity by reconstructing the expected Hamming code and comparing it with the received parity bits to detect transmission or storage errors. The module is designed for systems where data and Hamming codes are transmitted or stored separately.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                  |
| ------------ | ------- | -------------- | ------- | ---------------------------- |
| `DATA_WIDTH` | integer | `≥1`           | `4`     | Bit width of the input data. |

## Ports

| Name    | Direction | Width          | Clock | Reset | Reset value | Description                   |
| ------- | --------- | -------------- | ----- | ----- | ----------- | ----------------------------- |
| `data`  | input     | `DATA_WIDTH`   |       |       |             | Received data to be checked.  |
| `code`  | input     | `PARITY_WIDTH` |       |       |             | Received Hamming parity code. |
| `error` | output    | 1              |       |       |             | Error detection flag.         |

## Operation

The Hamming checker validates data integrity by reconstructing the complete Hamming block from the received data and code components, then delegates error detection to the Hamming block checker module. The checker forms the block by interleaving data and parity bits according to the standard Hamming code structure and computes the syndrome to detect errors.

When the computed syndrome is zero, no error is detected (error = 0). If the syndrome is non-zero, a single-bit error is detected and flagged (error = 1). This approach provides reliable error detection for systems that handle data and Hamming codes separately during transmission or storage.

## Paths

| From   | To      | Type          | Comment                                 |
| ------ | ------- | ------------- | --------------------------------------- |
| `data` | `error` | combinational | Through internal Hamming block checker. |
| `code` | `error` | combinational | Through internal Hamming block checker. |

## Complexity

| Delay                | Gates                             | Comment                                   |
| -------------------- | --------------------------------- | ----------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | Single level logic through block checker. |

The checker utilizes the Hamming block checker internally, inheriting its efficient syndrome computation logic for fast error detection suitable for high-speed applications.

## Verification

The Hamming checker is verified using a comprehensive SystemVerilog testbench that validates error detection capabilities with both correct and incorrect Hamming code combinations. The testbench instantiates and verifies all Hamming modules.

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

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`hamming_checker.sv`](hamming_checker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_checker.symbol.sss`](hamming_checker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_checker.symbol.svg`](hamming_checker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`hamming_checker.symbol.drawio`](hamming_checker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`hamming_checker.md`](hamming_checker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                              | Path                                                     | Comment |
| --------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_packer`](hamming_block_packer.md)   | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`hamming_block_checker`](hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                              | Path                                                     | Comment                                   |
| --------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------- |
| [`hamming_encoder`](hamming_encoder.md)             | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming encoder for generating codes.     |
| [`hamming_corrector`](hamming_corrector.md)         | `omnicores-buildingblocks/sources/error_control/hamming` | Variant with error correction capability. |
| [`hamming_block_checker`](hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Variant for combined data and code.       |
