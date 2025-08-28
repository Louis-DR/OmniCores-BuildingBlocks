# Hamming Encoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Encoder                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_encoder](hamming_encoder.symbol.svg)

Computes Hamming error correction codes for input data, enabling single-bit error detection and correction. Hamming encoding is an advanced error control technique that uses strategically positioned parity bits to create self-correcting codes. This encoder supports variable data widths with automatically calculated optimal parity bit counts for maximum efficiency.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                  |
| ------------ | ------- | -------------- | ------- | ---------------------------- |
| `DATA_WIDTH` | integer | `≥1`           | `4`     | Bit width of the input data. |

## Ports

| Name    | Direction | Width                     | Clock | Reset | Reset value | Description                           |
| ------- | --------- | ------------------------- | ----- | ----- | ----------- | ------------------------------------- |
| `data`  | input     | `DATA_WIDTH`              |       |       |             | Input data to be Hamming encoded.     |
| `code`  | output    | `PARITY_WIDTH`            |       |       |             | Computed Hamming parity bits.         |
| `block` | output    | `DATA_WIDTH+PARITY_WIDTH` |       |       |             | Complete Hamming block (code + data). |

## Operation

The Hamming encoder computes parity bits using systematic Hamming code generation where parity bits are positioned at powers of 2 (positions 1, 2, 4, 8, etc.) within the encoded block. Each parity bit covers specific data bit positions according to the binary representation pattern, ensuring that any single-bit error produces a unique syndrome that directly identifies the error location.

The encoder generates both individual parity codes for separate transmission or storage, and complete Hamming blocks that interleave parity and data bits according to the standard Hamming code structure. The number of parity bits is automatically calculated based on data width to provide optimal protection with minimal overhead.

## Paths

| From   | To      | Type          | Comment                           |
| ------ | ------- | ------------- | --------------------------------- |
| `data` | `code`  | combinatorial | Through parity generation logic.  |
| `data` | `block` | combinatorial | Through block packer integration. |

## Complexity

| Delay                | Gates                             | Comment                                      |
| -------------------- | --------------------------------- | -------------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH × log₂ DATA_WIDTH)` | XOR tree depth proportional to parity width. |

The Hamming encoding requires XOR trees for each parity bit with complexity logarithmic in data width, making it efficient for moderate to large data paths while providing strong error correction capabilities.

## Verification

The Hamming encoder is verified using a comprehensive SystemVerilog testbench that validates both the parity generation correctness and integration with the complete Hamming family of modules. The testbench instantiates and verifies all Hamming modules.

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
| Design            | [`hamming_encoder.sv`](hamming_encoder.sv)                       | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                   | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)               | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_encoder.symbol.sss`](hamming_encoder.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_encoder.symbol.svg`](hamming_encoder.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`hamming_encoder.symbol.drawio`](hamming_encoder.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`hamming_encoder.md`](hamming_encoder.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                            | Path                                                     | Comment |
| ------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`hamming_block_packer`](hamming_block_packer.md) | `omnicores-buildingblocks/sources/error_control/hamming` |         |

## Related modules

| Module                                                  | Path                                                     | Comment                                   |
| ------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------- |
| [`hamming_checker`](hamming_checker.md)                 | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming checker for data and code inputs. |
| [`hamming_corrector`](hamming_corrector.md)             | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming corrector with error correction.  |
| [`hamming_block_checker`](hamming_block_checker.md)     | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming checker for complete blocks.      |
| [`hamming_block_corrector`](hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Hamming corrector for complete blocks.    |
| [`hamming_block_packer`](hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/hamming` | Utility for block formatting.             |
| [`hamming_block_unpacker`](hamming_block_unpacker.md)   | `omnicores-buildingblocks/sources/error_control/hamming` | Utility for block parsing.                |
