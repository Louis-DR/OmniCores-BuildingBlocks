# First One

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | First One                                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![first_one](first_one.symbol.svg)

Determines the position of the first '1' (least significant bit set) in an input vector `data`. This is the wrapper between the different variants of the round-robin arbiter.

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

This module is a wrapper between the different implementation variants of the first-one opepartion. The details about the operation of each variant is available in their datasheets.

## Paths

| From   | To          | Type          | Comment |
| ------ | ----------- | ------------- | ------- |
| `data` | `first_one` | combinational |         |

## Complexity

| Variant            | Delay           | Gates           | Comment                   |
| ------------------ | --------------- | --------------- | ------------------------- |
| `"fast"` (default) | `O(log₂ WIDTH)` | `O(WIDTH)`      | Prefix-network structure. |
| `"small"`          | `O(WIDTH)`      | `O(log₂ WIDTH)` | Ripple-chain structure.   |

| Delay           | Gates      | Comment                   |
| --------------- | ---------- | ------------------------- |
| `O(log₂ WIDTH)` | `O(WIDTH)` | Prefix-network structure. |

## Verification

The first-one module is verified using a SystemVerilog testbench with a single check applied on two instances of the DUT, one for each variant.

The following table lists the checks performed by the testbench.

| Number | Check      | Description                                                                                                          |
| ------ | ---------- | -------------------------------------------------------------------------------------------------------------------- |
| 1      | Exhaustive | For `WIDTH=8`, iterates through all 256 possible input `data` values and verifies the `first_one` output is correct. |

The following table lists the parameter values verified by the testbench.

| `VARIANT` | `WIDTH` |           |
| --------- | ------- | --------- |
| `"fast"`  | 8       | (default) |
| `"small"` | 8       |           |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                   | Description                                         |
| ----------------- | ------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`first_one.v`](first_one.v)                           | Verilog design.                                     |
| Testbench         | [`first_one.testbench.sv`](first_one.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`first_one.testbench.gtkw`](first_one.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`first_one.symbol.sss`](first_one.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`first_one.symbol.svg`](first_one.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`first_one.symbol.drawio`](first_one.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`first_one.md`](first_one.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                   | Path                                                          | Comment                         |
| ------------------------------------------------------------------------ | ------------------------------------------------------------- | ------------------------------- |
| [`fast_first_one`](../../operations/fast_first_one/fast_first_one.md)    | `omnicores-buildingblocks/sources/operations/fast_first_one`  | For the default `fast` variant. |
| [`small_first_one`](../../operations/small_first_one/small_first_one.md) | `omnicores-buildingblocks/sources/operations/small_first_one` | For the `small` variant.        |
| [`shift_left`](../../operations/shift_left/shift_left.md)                | `omnicores-buildingblocks/sources/operations/shift_left`      | For the default `fast` variant. |

## Related modules

| Module                                                     | Path                                                          | Comment                                          |
| ---------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------ |
| [`small_first_one`](../small_first_one/small_first_one.md) | `omnicores-buildingblocks/sources/operations/small_first_one` | Small but slow variant using ripple-chain logic. |
| [`fast_first_one`](../fast_first_one/fast_first_one.md)    | `omnicores-buildingblocks/sources/operations/fast_first_one`  | Fast but big variant using prefix-network logic. |
| [`count_ones`](../count_ones/count_ones.md)                | `omnicores-buildingblocks/sources/operations/count_ones`      | Counts the total number of set bits in a vector. |
