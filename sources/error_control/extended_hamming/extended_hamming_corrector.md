# Extended Hamming Corrector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Corrector                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Corrector corrects single-bit errors and detects double-bit errors in data with Extended Hamming codes. It provides SECDED (Single Error Correction, Double Error Detection) capability by analyzing received data and parity codes to perform error correction when possible and error detection for uncorrectable cases. The corrector internally uses Extended Hamming block packing, correction, and unpacking logic to process data. It outputs corrected data, error position information, and error status flags, enabling robust error recovery in communication and storage systems.

## Parameters

| Name         | Type    | Default | Range          | Description                      |
| ------------ | ------- | ------- | -------------- | -------------------------------- |
| `DATA_WIDTH` | integer | `4`     | `1` to `65519` | Width of the input data in bits. |

## Ports

| Name                       | Direction | Width               | Clock | Reset | Reset value | Description                             |
| -------------------------- | --------- | ------------------- | ----- | ----- | ----------- | --------------------------------------- |
| `data`                     | input     | `DATA_WIDTH`        |       |       |             | Received data to be checked.            |
| `code`                     | input     | `PARITY_WIDTH`      |       |       |             | Received Extended Hamming parity codes. |
| `corrected_data`           | output    | `DATA_WIDTH`        |       |       |             | Error-corrected output data.            |
| `corrected_error_position` | output    | `log₂(BLOCK_WIDTH)` |       |       |             | Position of corrected error.            |
| `correctable_error`        | output    | 1                   |       |       |             | Single-bit error detection flag.        |
| `uncorrectable_error`      | output    | 1                   |       |       |             | Double-bit error detection flag.        |

## Operation

The Extended Hamming Corrector operates by first padding the input data to match the message length corresponding to the number of parity bits, then using an internal Extended Hamming block packer to construct the complete block. The packed block is processed by an Extended Hamming block corrector that performs syndrome computation, error position identification, and block correction. The corrected block is then unpacked to extract the corrected data. Single-bit errors are corrected automatically with position information provided, while double-bit errors are detected but not corrected. The module provides comprehensive error status information enabling appropriate error handling strategies.

## Paths

| From   | To                         | Type          | Comment                                            |
| ------ | -------------------------- | ------------- | -------------------------------------------------- |
| `data` | `corrected_data`           | combinatorial | Through internal Extended Hamming block corrector. |
| `code` | `corrected_data`           | combinatorial | Through internal Extended Hamming block corrector. |
| `data` | `corrected_error_position` | combinatorial | Through internal Extended Hamming block corrector. |
| `code` | `corrected_error_position` | combinatorial | Through internal Extended Hamming block corrector. |
| `data` | `correctable_error`        | combinatorial | Through internal Extended Hamming block corrector. |
| `code` | `correctable_error`        | combinatorial | Through internal Extended Hamming block corrector. |
| `data` | `uncorrectable_error`      | combinatorial | Through internal Extended Hamming block corrector. |
| `code` | `uncorrectable_error`      | combinatorial | Through internal Extended Hamming block corrector. |

## Complexity

| Delay                | Gates                             | Comment                                     |
| -------------------- | --------------------------------- | ------------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | Single level logic through block corrector. |

The corrector utilizes the Extended Hamming block corrector internally, inheriting its efficient syndrome computation and error correction logic for fast error recovery suitable for high-speed applications.

## Verification

The verification approach tests the Extended Hamming corrector across all modules in the Extended Hamming error control suite. The testbench validates error correction accuracy, proper handling of correctable and uncorrectable errors, and integration with other Extended Hamming modules.

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

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`extended_hamming_corrector.sv`](extended_hamming_corrector.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_corrector.symbol.sss`](extended_hamming_corrector.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_corrector.symbol.svg`](extended_hamming_corrector.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_corrector.symbol.drawio`](extended_hamming_corrector.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_corrector.md`](extended_hamming_corrector.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                    | Path                                                              | Comment |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | ------- |
| [`extended_hamming_block_packer`](extended_hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/extended_hamming` |         |
| [`extended_hamming_block_corrector`](extended_hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` |         |
| [`extended_hamming_block_unpacker`](extended_hamming_block_unpacker.md)   | `omnicores-buildingblocks/sources/error_control/extended_hamming` |         |

## Related modules

| Module                                                                    | Path                                                              | Comment                                        |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------- |
| [`extended_hamming_encoder`](extended_hamming_encoder.md)                 | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Extended Hamming encoder for generating codes. |
| [`extended_hamming_checker`](extended_hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant with error detection only.             |
| [`extended_hamming_block_corrector`](extended_hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant for combined data and code.            |
