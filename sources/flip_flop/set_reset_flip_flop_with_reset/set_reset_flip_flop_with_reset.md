# Set-Reset Flip-Flop with Reset

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Set-Reset Flip-Flop with Reset                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![set_reset_flip_flop_with_reset](set_reset_flip_flop_with_reset.symbol.svg)

The set-reset flip-flop with asynchronous reset is a sequential logic element that can be explicitly set to high or reset to low using dedicated control inputs. When both `set` and `reset` are asserted simultaneously, reset takes priority. This implementation includes an active-low asynchronous reset functionality, allowing the flip-flop to be reset to a configurable value independent of the clock signal.

## Parameters

| Name          | Type    | Default | Description                                                |
| ------------- | ------- | ------- | ---------------------------------------------------------- |
| `RESET_VALUE` | integer | 0       | Value to which the state is reset when resetn is asserted. |

## Ports

| Name     | Direction | Width | Clock        | Reset    | Reset value   | Description                    |
| -------- | --------- | ----- | ------------ | -------- | ------------- | ------------------------------ |
| `clock`  | input     | 1     | self         |          |               | Clock signal.                  |
| `resetn` | input     | 1     | asynchronous | self     | `0`           | Active-low asynchronous reset. |
| `set`    | input     | 1     | `clock`      | `resetn` |               | Set the state to high.         |
| `reset`  | input     | 1     | `clock`      | `resetn` |               | Reset the state to low.        |
| `state`  | output    | 1     | `clock`      | `resetn` | `RESET_VALUE` | State of the flip-flop.        |

## Operation

The set-reset flip-flop operates by sampling the `set` and `reset` inputs on each rising edge of the `clock`. When `set` is high, the state is set to 1. When `reset` is high, the state is reset to 0. Reset has priority over set when both are asserted. When neither input is asserted, the state remains unchanged. The asynchronous reset takes priority over all other inputs and immediately sets the state to `RESET_VALUE` when `resetn` is asserted low.

| `resetn` | `clock` | `set` | `reset` | next `state`  |
| -------- | ------- | ----- | ------- | ------------- |
| `0`      | `x`     | `x`   | `x`     | `RESET_VALUE` |
| `1`      | idle    | `x`   | `x`     | `state`       |
| `1`      | falling | `x`   | `x`     | `state`       |
| `1`      | rising  | `0`   | `0`     | `state`       |
| `1`      | rising  | `1`   | `0`     | `1`           |
| `1`      | rising  | `0`   | `1`     | `0`           |
| `1`      | rising  | `1`   | `1`     | `0`           |

## Paths

| From    | To      | Type       | Comment |
| ------- | ------- | ---------- | ------- |
| `set`   | `state` | sequential |         |
| `reset` | `state` | sequential |         |

## Verification

The set-reset flip-flop with asynchronous reset module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                    |
| ------ | --------------- | ------------------------------------------------------------------------------ |
| 1      | Random stimulus | Stimulate the `set` and `reset` inputs over many cycles and check the `state`. |

The following table lists the parameter values verified by the testbench.

| `RESET_VALUE` |           |
| ------------- | --------- |
| 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

If the technology node provides a dedicated set-reset flip-flop cell with asynchronous reset, this module should be replaced with it.

## Deliverables

| Type              | File                                                                                             | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`set_reset_flip_flop_with_reset.v`](set_reset_flip_flop_with_reset.v)                           | Verilog design.                                     |
| Testbench         | [`set_reset_flip_flop_with_reset.testbench.sv`](set_reset_flip_flop_with_reset.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`set_reset_flip_flop_with_reset.testbench.gtkw`](set_reset_flip_flop_with_reset.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`set_reset_flip_flop_with_reset.symbol.sss`](set_reset_flip_flop_with_reset.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`set_reset_flip_flop_with_reset.symbol.svg`](set_reset_flip_flop_with_reset.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`set_reset_flip_flop_with_reset.md`](set_reset_flip_flop_with_reset.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                                         | Path                                                                     | Comment                                           |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------- |
| [`set_reset_flip_flop`](../set_reset_flip_flop/set_reset_flip_flop.md)                         | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop`         | Variant of the set-reset flip-flop without reset. |
| [`toggle_flip_flop_with_reset`](../toggle_flip_flop_with_reset/toggle_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop_with_reset` | Toggle flip-flop with reset.                      |
| [`jk_flip_flop_with_reset`](../jk_flip_flop_with_reset/jk_flip_flop_with_reset.md)             | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop_with_reset`     | JK flip-flop with reset.                          |
```