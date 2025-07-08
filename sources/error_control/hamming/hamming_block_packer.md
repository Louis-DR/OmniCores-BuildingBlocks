# Hamming Block Packer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Hamming Block Packer                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![hamming_block_packer](hamming_block_packer.symbol.svg)

Combines data and Hamming parity codes into properly formatted Hamming blocks with interleaved structure. This utility module positions parity bits at power-of-2 locations (1, 2, 4, 8, etc.) and arranges data bits in remaining positions according to the standard Hamming code format. It serves as a building block for other Hamming modules that require block formation.

## Parameters

| Name         | Type    | Allowed Values | Default | Description                  |
| ------------ | ------- | -------------- | ------- | ---------------------------- |
| `DATA_WIDTH` | integer | `≥1`           | `4`     | Bit width of the input data. |

## Ports

| Name    | Direction | Width                     | Clock | Reset | Reset value | Description                    |
| ------- | --------- | ------------------------- | ----- | ----- | ----------- | ------------------------------ |
| `data`  | input     | `DATA_WIDTH`              |       |       |             | Input data to be packed.       |
| `code`  | input     | `PARITY_WIDTH`            |       |       |             | Input Hamming parity codes.    |
| `block` | output    | `DATA_WIDTH+PARITY_WIDTH` |       |       |             | Complete Hamming block output. |

## Operation

The Hamming block packer arranges data and parity bits according to the systematic Hamming code structure where parity bits occupy positions that are powers of 2 (1, 2, 4, 8, etc.) and data bits fill the remaining positions. The module uses generate blocks to efficiently map input bits to their proper positions in the output block.

The packer automatically handles different data widths by calculating the required number of parity bits and positioning them correctly within the block structure. This ensures compatibility with standard Hamming code decoders and provides the foundation for error detection and correction operations.

## Paths

| From   | To      | Type          | Comment                       |
| ------ | ------- | ------------- | ----------------------------- |
| `data` | `block` | combinatorial | Direct bit positioning logic. |
| `code` | `block` | combinatorial | Direct bit positioning logic. |

## Complexity

| Delay  | Gates  | Comment                                 |
| ------ | ------ | --------------------------------------- |
| `O(0)` | `O(0)` | Direct wiring and bit position routing. |

The block packer requires only combinatorial wiring to position bits according to the Hamming code structure, resulting in zero delay and no logic gates.

## Verification

The Hamming block packer is verified using a comprehensive SystemVerilog testbench that validates correct bit positioning and integration with the complete Hamming family of modules. The testbench instantiates and verifies all Hamming modules.

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

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`hamming_block_packer.sv`](hamming_block_packer.sv)                 | SystemVerilog design.                               |
| Testbench         | [`hamming.testbench.sv`](hamming.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`hamming.testbench.gtkw`](hamming.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`hamming_block_packer.symbol.sss`](hamming_block_packer.symbol.sss) | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`hamming_block_packer.symbol.svg`](hamming_block_packer.symbol.svg) | Generated vector image of the symbol.               |
| Datasheet         | [`hamming_block_packer.md`](hamming_block_packer.md)                 | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                | Path                                                     | Comment                                    |
| ----------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------ |
| [`hamming_block_unpacker`](hamming_block_unpacker.md) | `omnicores-buildingblocks/sources/error_control/hamming` | Inverse operation for block decomposition. |
| [`hamming_encoder`](hamming_encoder.md)               | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block packer for complete encoding.   |
| [`hamming_checker`](hamming_checker.md)               | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block packer for error checking.      |
| [`hamming_corrector`](hamming_corrector.md)           | `omnicores-buildingblocks/sources/error_control/hamming` | Uses block packer for error correction.    |
