# Toggle Flip-Flop with Reset

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Toggle Flip-Flop with Reset                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![toggle_flip_flop_with_reset](toggle_flip_flop_with_reset.symbol.svg)

The toggle flip-flop with asynchronous reset is a sequential logic element that inverts its output `state` on each rising `clock` edge when the `toggle` input is asserted. It maintains its current state when `toggle` is deasserted. This implementation includes an active-low asynchronous reset functionality, allowing the flip-flop to be reset to a configurable value independent of the clock signal.

## Parameters

| Name          | Type    | Default | Description                                                |
| ------------- | ------- | ------- | ---------------------------------------------------------- |
| `RESET_VALUE` | integer | 0       | Value to which the state is reset when resetn is asserted. |

## Ports

| Name     | Direction | Width | Clock        | Reset    | Reset value   | Description                    |
| -------- | --------- | ----- | ------------ | -------- | ------------- | ------------------------------ |
| `clock`  | input     | 1     | self         |          |               | Clock signal.                  |
| `resetn` | input     | 1     | asynchronous | self     | `0`           | Active-low asynchronous reset. |
| `toggle` | input     | 1     | `clock`      |          |               | Toggle the state.              |
| `state`  | output    | 1     | `clock`      | `resetn` | `RESET_VALUE` | State of the flip-flop.        |

## Operation

The toggle flip-flop operates by sampling the `toggle` input on each rising edge of the `clock`. When `toggle` is high, the state output is inverted. When `toggle` is low, the state remains unchanged. The asynchronous reset takes priority over all other inputs and immediately sets the state to `RESET_VALUE` when `resetn` is asserted low.

| `resetn` | `clock` | `toggle` | next `state`  |
| -------- | ------- | -------- | ------------- |
| `0`      | `x`     | `x`      | `RESET_VALUE` |
| `1`      | idle    | `x`      | `state`       |
| `1`      | falling | `x`      | `state`       |
| `1`      | rising  | `0`      | `state`       |
| `1`      | rising  | `1`      | `~state`      |

## Paths

| From     | To      | Type         | Comment |
| -------- | ------- | ------------ | ------- |
| `resetn` | `state` | asynchronous |         |
| `toggle` | `state` | sequential   |         |

## Verification

The toggle flip-flop with asynchronous reset module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                          |
| ------ | --------------- | -------------------------------------------------------------------- |
| 1      | Random stimulus | Stimulate the `toggle` input over many cycles and check the `state`. |

The following table lists the parameter values verified by the testbench.

| `RESET_VALUE` |           |
| ------------- | --------- |
| 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

If the technology node provides a dedicated toggle flip-flop cell with asynchronous reset, this module should be replaced with it.

## Deliverables

| Type              | File                                                                                       | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`toggle_flip_flop_with_reset.v`](toggle_flip_flop_with_reset.v)                           | Verilog design.                                     |
| Testbench         | [`toggle_flip_flop_with_reset.testbench.sv`](toggle_flip_flop_with_reset.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`toggle_flip_flop_with_reset.testbench.gtkw`](toggle_flip_flop_with_reset.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`toggle_flip_flop_with_reset.symbol.sss`](toggle_flip_flop_with_reset.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`toggle_flip_flop_with_reset.symbol.svg`](toggle_flip_flop_with_reset.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`toggle_flip_flop_with_reset.md`](toggle_flip_flop_with_reset.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                                                  | Path                                                                        | Comment                                        |
| ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------- |
| [`toggle_flip_flop`](../toggle_flip_flop/toggle_flip_flop.md)                                           | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop`               | Variant of the toggle flip-flop without reset. |
| [`set_reset_flip_flop_with_reset`](../set_reset_flip_flop_with_reset/set_reset_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop_with_reset` | Set-reset flip-flop with asynchronous reset.   |
| [`jk_flip_flop_with_reset`](../jk_flip_flop_with_reset/jk_flip_flop_with_reset.md)                      | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop_with_reset`        | JK flip-flop with asynchronous reset.          |
