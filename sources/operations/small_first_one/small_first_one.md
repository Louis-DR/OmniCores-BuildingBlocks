# Small First One

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Small First One                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![small_first_one](small_first_one.symbol.svg)

Determines the position of the first '1' (least significant bit set) in an input vector `data`. This implementation uses a ripple-chain structure, resulting in a small area footprint but a propagation delay that scales linearly with the input width. A faster variant, `fast_first_one`, is available.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                   |
| ------- | ------- | -------------- | ------- | ----------------------------- |
| `WIDTH` | integer | `>0`           | `8`     | Bit width of the data vector. |

## Ports

| Name        | Direction | Width   | Clock        | Reset | Reset value | Description                                                            |
| ----------- | --------- | ------- | ------------ | ----- | ----------- | ---------------------------------------------------------------------- |
| `data`      | input     | `WIDTH` | asynchronous |       |             | Input data vector.                                                     |
| `first_one` | output    | `WIDTH` | asynchronous |       |             | Output vector with a single '1' indicating the first set bit position. |

## Operation

The module uses a chain of logic from least to most significant bits of the `first_one` output vector such that each bit is set if and only if the corresponding bit of the input `data` vector is set, and none of the previous ones are set.

## Paths

| From   | To          | Type          | Comment |
| ------ | ----------- | ------------- | ------- |
| `data` | `first_one` | combinational |         |

## Complexity

| Delay      | Gates           | Comment                 |
| ---------- | --------------- | ----------------------- |
| `O(WIDTH)` | `O(log₂ WIDTH)` | Ripple-chain structure. |

## Verification

The first-one module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check      | Description                                                                                                          |
| ------ | ---------- | -------------------------------------------------------------------------------------------------------------------- |
| 1      | Exhaustive | For `WIDTH=8`, iterates through all 256 possible input `data` values and verifies the `first_one` output is correct. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                               | Description                                         |
| ----------------- | ------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`small_first_one.v`](small_first_one.v)                           | Verilog design.                                     |
| Testbench         | [`small_first_one.testbench.sv`](small_first_one.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`small_first_one.testbench.gtkw`](small_first_one.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`small_first_one.symbol.sss`](small_first_one.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`small_first_one.symbol.svg`](small_first_one.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`small_first_one.md`](small_first_one.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                  | Path                                                         | Comment                                               |
| ------------------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------- |
| [`first_one`](../first_one/first_one.md)                | `omnicores-buildingblocks/sources/operations/first_one`      | Wrapper module for the variants.                      |
| [`fast_first_one`](../fast_first_one/fast_first_one.md) | `omnicores-buildingblocks/sources/operations/fast_first_one` | Faster but bigger variant using prefix-network logic. |
| [`count_ones`](../count_ones/count_ones.md)             | `omnicores-buildingblocks/sources/operations/count_ones`     | Counts the total number of set bits in a vector.      |
