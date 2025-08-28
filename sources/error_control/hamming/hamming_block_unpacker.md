# Hamming Block Unpacker

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Block Unpacker                                                           |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_block_unpacker](hamming_block_unpacker.symbol.svg)

Extracts data and Hamming parity codes from properly formatted Hamming blocks with interleaved structure. This utility module separates parity bits located at power-of-2 positions (1, 2, 4, 8, etc.) from data bits in remaining positions according to the standard Hamming code format. It serves as a building block for other Hamming modules that require block decomposition.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                      |
| ------------- | ------- | -------------- | ------- | -------------------------------- |
| `BLOCK_WIDTH` | integer | `≥3`           | `7`     | Bit width of the complete block. |

## Ports

| Name    | Direction | Width          | Clock | Reset | Reset value | Description                     |
| ------- | --------- | -------------- | ----- | ----- | ----------- | ------------------------------- |
| `block` | input     | `BLOCK_WIDTH`  |       |       |             | Complete Hamming block input.   |
| `data`  | output    | `DATA_WIDTH`   |       |       |             | Extracted data bits.            |
| `code`  | output    | `PARITY_WIDTH` |       |       |             | Extracted Hamming parity codes. |

## Operation

The Hamming block unpacker extracts data and parity bits from the systematic Hamming code structure where parity bits are located at positions that are powers of 2 (1, 2, 4, 8, etc.) and data bits occupy the remaining positions. The module uses generate blocks to efficiently map block bits to their proper output positions.

The unpacker automatically handles different block widths by calculating the embedded data and parity sizes and extracting them correctly from the block structure. This ensures compatibility with standard Hamming code encoders and provides the foundation for error detection and correction analysis.

## Paths

| From    | To     | Type          | Comment                      |
| ------- | ------ | ------------- | ---------------------------- |
| `block` | `data` | combinatorial | Direct bit extraction logic. |
| `block` | `code` | combinatorial | Direct bit extraction logic. |

## Complexity

| Delay  | Gates  | Comment                                 |
| ------ | ------ | --------------------------------------- |
| `O(0)` | `O(0)` | Direct wiring and bit position routing. |

The block unpacker requires only combinatorial wiring to extract bits according to the Hamming code structure, resulting in zero delay and no logic gates.

## Verification

The Hamming block unpacker is verified using a comprehensive SystemVerilog testbench that validates correct bit extraction and integration with the complete Hamming family of modules. The testbench instantiates and verifies all Hamming modules.

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

| Type              | File                                                                           | Description                                         |
| ----------------- | ------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`hamming_block_unpacker.sv`](hamming_block_unpacker.sv)                       | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                                 | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)                             | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_block_unpacker.symbol.sss`](hamming_block_unpacker.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_block_unpacker.symbol.svg`](hamming_block_unpacker.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`hamming_block_unpacker.symbol.drawio`](hamming_block_unpacker.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`hamming_block_unpacker.md`](hamming_block_unpacker.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                  | Path                                                     | Comment                                   |
| ------------------------------------------------------- | -------------------------------------------------------- | ----------------------------------------- |
| [`hamming_block_packer`](hamming_block_packer.md)       | `omnicores-buildingblocks/sources/error_control/hamming` | Inverse operation for block formation.    |
| [`hamming_block_checker`](hamming_block_checker.md)     | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block unpacker for error checking.   |
| [`hamming_block_corrector`](hamming_block_corrector.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block unpacker for error correction. |
| [`hamming_corrector`](hamming_corrector.md)             | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block unpacker for data extraction.  |
