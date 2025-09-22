# Extended Hamming Block Corrector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Extended Hamming Block Corrector                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

The Extended Hamming Block Corrector corrects single-bit errors and detects double-bit errors in complete Extended Hamming blocks. It provides SECDED (Single Error Correction, Double Error Detection) capability by analyzing complete encoded blocks to perform error correction when possible and error detection for uncorrectable cases. The corrector separates the extra parity bit from the standard Hamming block, processes both components independently, and reconstructs the corrected block. Single-bit errors are corrected with precise position identification, while double-bit errors are detected but not corrected, enabling robust error recovery in communication and storage systems.

## Parameters

| Name          | Type    | Default | Range          | Description                          |
| ------------- | ------- | ------- | -------------- | ------------------------------------ |
| `BLOCK_WIDTH` | integer | `8`     | `4` to `65536` | Width of the complete block in bits. |

## Ports

| Name                       | Direction | Width               | Clock | Reset | Reset value | Description                                      |
| -------------------------- | --------- | ------------------- | ----- | ----- | ----------- | ------------------------------------------------ |
| `block`                    | input     | `BLOCK_WIDTH`       |       |       |             | Complete Extended Hamming block to be corrected. |
| `corrected_block`          | output    | `BLOCK_WIDTH`       |       |       |             | Error-corrected output block.                    |
| `corrected_error_position` | output    | `log₂(BLOCK_WIDTH)` |       |       |             | Position of corrected error in block.            |
| `correctable_error`        | output    | 1                   |       |       |             | Single-bit error detection flag.                 |
| `uncorrectable_error`      | output    | 1                   |       |       |             | Double-bit error detection flag.                 |

## Operation

The Extended Hamming Block Corrector operates by first separating the extra parity bit (LSB) from the standard Hamming block (remaining bits). It calculates the expected extra parity using a parity encoder and validates the Hamming block using an internal Hamming block corrector. Error correction follows Extended Hamming logic: correctable errors occur when the extra parity is incorrect, enabling single-bit error correction with position identification. Uncorrectable errors occur when the Hamming syndrome indicates errors but the extra parity is correct, indicating double-bit error patterns. The corrector reconstructs the complete block with appropriate error corrections applied and provides comprehensive error status information.

## Paths

| From    | To                         | Type          | Comment                                                 |
| ------- | -------------------------- | ------------- | ------------------------------------------------------- |
| `block` | `corrected_block`          | combinational | Through syndrome computation and error mask generation. |
| `block` | `corrected_error_position` | combinational | Through syndrome to position conversion.                |
| `block` | `correctable_error`        | combinational | Through extra parity validation and syndrome analysis.  |
| `block` | `uncorrectable_error`      | combinational | Through extra parity validation and syndrome analysis.  |

## Complexity

| Delay                 | Gates                               | Comment                                           |
| --------------------- | ----------------------------------- | ------------------------------------------------- |
| `O(log₂ BLOCK_WIDTH)` | `O(BLOCK_WIDTH × log₂ BLOCK_WIDTH)` | Single level syndrome computation and correction. |

The corrector utilizes syndrome computation, error mask generation, and block correction logic that operates efficiently for single-level delay suitable for high-performance error correction applications.

## Verification

The verification approach tests the Extended Hamming block corrector across all modules in the Extended Hamming error control suite. The testbench validates error correction accuracy, proper handling of correctable and uncorrectable errors, and integration with other Extended Hamming modules.

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

| Type              | File                                                                                               | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`extended_hamming_block_corrector.sv`](extended_hamming_block_corrector.sv)                       | SystemVerilog design.                               |
| Testbench         | [`extended_hamming.testbench.sv`](extended_hamming.testbench.sv)                                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`extended_hamming.testbench.gtkw`](extended_hamming.testbench.gtkw)                               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`extended_hamming_block_corrector.symbol.sss`](extended_hamming_block_corrector.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`extended_hamming_block_corrector.symbol.svg`](extended_hamming_block_corrector.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`extended_hamming_block_corrector.symbol.drawio`](extended_hamming_block_corrector.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`extended_hamming_block_corrector.md`](extended_hamming_block_corrector.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                             | Path                                                     | Comment |
| ------------------------------------------------------------------ | -------------------------------------------------------- | ------- |
| [`hamming_block_corrector`](../hamming/hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |
| [`parity_encoder`](../parity/parity_encoder.md)                    | `omnicores-buildingblocks/sources/error_control/parity`  |         |

## Related modules

| Module                                                                | Path                                                              | Comment                                              |
| --------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------- |
| [`extended_hamming_corrector`](extended_hamming_corrector.md)         | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant for separate data and code.                  |
| [`extended_hamming_block_checker`](extended_hamming_block_checker.md) | `omnicores-buildingblocks/sources/error_control/extended_hamming` | Variant with error detection only.                   |
| [`hamming_block_corrector`](../hamming/hamming_block_corrector.md)    | `omnicores-buildingblocks/sources/error_control/hamming`          | Internal dependency for standard Hamming correction. |
