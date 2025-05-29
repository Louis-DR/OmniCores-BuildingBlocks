# Fast First One

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Fast First One                                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![fast_first_one](fast_first_one.symbol.svg)

Determines the position of the first '1' (least significant bit set) in an input vector `data`. This implementation uses a prefix-network structure, resulting in a fast propagation delay but a large area footprint that scales linearly with the input width. A smaller variant, `small_first_one`, is available.

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

The module build a prefix-network structure of OR gates to generate a vector `prefix_or_stages` in which each bit is the result of the ORing of the bits from the input `data` vector from the LSB to its position (`prefix_or_vector[i] = data[i] | ... | data[0]`). Then, the first one is located by ANDing the input `data` this the complement of this `prefix_or_vector`.

## Paths

| From   | To          | Type          | Comment |
| ------ | ----------- | ------------- | ------- |
| `data` | `first_one` | combinational |         |

## Complexity

| Delay           | Gates      | Comment                   |
| --------------- | ---------- | ------------------------- |
| `O(log₂ WIDTH)` | `O(WIDTH)` | Prefix-network structure. |

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

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`fast_first_one.v`](fast_first_one.v)                           | Verilog design.                                     |
| Testbench         | [`fast_first_one.testbench.sv`](fast_first_one.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`fast_first_one.testbench.gtkw`](fast_first_one.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`fast_first_one.symbol.sss`](fast_first_one.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`fast_first_one.symbol.svg`](fast_first_one.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`fast_first_one.md`](fast_first_one.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                    | Path                                                     | Comment |
| --------------------------------------------------------- | -------------------------------------------------------- | ------- |
| [`shift_left`](../../operations/shift_left/shift_left.md) | `omnicores-buildingblocks/sources/operations/shift_left` |         |

## Related modules

| Module                                                     | Path                                                          | Comment                                              |
| ---------------------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| [`first_one`](../first_one/first_one.md)                   | `omnicores-buildingblocks/sources/operations/first_one`       | Wrapper module for the variants.                     |
| [`small_first_one`](../small_first_one/small_first_one.md) | `omnicores-buildingblocks/sources/operations/small_first_one` | Smaller but slower variant using ripple-chain logic. |
| [`count_ones`](../count_ones/count_ones.md)                | `omnicores-buildingblocks/sources/operations/count_ones`      | Counts the total number of set bits in a vector.     |
