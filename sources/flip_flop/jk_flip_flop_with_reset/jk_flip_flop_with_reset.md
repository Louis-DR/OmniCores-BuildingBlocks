# JK Flip-Flop with Reset

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | JK Flip-Flop with Reset                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![jk_flip_flop_with_reset](jk_flip_flop_with_reset.symbol.svg)

The JK flip-flop with asynchronous reset is a sequential logic element that combines the functionality of set-reset and toggle operations. When `j` is high and `k` is low, the state is set to 1. When `j` is low and `k` is high, the state is reset to 0. When both `j` and `k` are high, the state toggles. This implementation includes an active-low asynchronous reset functionality, allowing the flip-flop to be reset to a configurable value independent of the clock signal.

## Parameters

| Name          | Type    | Default | Description                                                |
| ------------- | ------- | ------- | ---------------------------------------------------------- |
| `RESET_VALUE` | integer | 0       | Value to which the state is reset when resetn is asserted. |

## Ports

| Name     | Direction | Width | Clock        | Reset    | Reset value   | Description                    |
| -------- | --------- | ----- | ------------ | -------- | ------------- | ------------------------------ |
| `clock`  | input     | 1     | self         |          |               | Clock signal.                  |
| `resetn` | input     | 1     | asynchronous | self     | `0`           | Active-low asynchronous reset. |
| `j`      | input     | 1     | `clock`      | `resetn` |               | J input (set or toggle).       |
| `k`      | input     | 1     | `clock`      | `resetn` |               | K input (reset or toggle).     |
| `state`  | output    | 1     | `clock`      | `resetn` | `RESET_VALUE` | State of the flip-flop.        |

## Operation

The JK flip-flop operates by sampling the `j` and `k` inputs on each rising edge of the `clock`. When only `j` is high, the state is set to 1. When only `k` is high, the state is reset to 0. When both `j` and `k` are high, the state toggles. When neither input is asserted, the state remains unchanged. The asynchronous reset takes priority over all other inputs and immediately sets the state to `RESET_VALUE` when `resetn` is asserted low.

| `resetn` | `clock` | `j` | `k` | next `state`  |
| -------- | ------- | --- | --- | ------------- |
| `0`      | `x`     | `x` | `x` | `RESET_VALUE` |
| `1`      | idle    | `x` | `x` | `state`       |
| `1`      | falling | `x` | `x` | `state`       |
| `1`      | rising  | `0` | `0` | `state`       |
| `1`      | rising  | `1` | `0` | `1`           |
| `1`      | rising  | `0` | `1` | `0`           |
| `1`      | rising  | `1` | `1` | `~state`      |

## Paths

| From | To      | Type       | Comment |
| ---- | ------- | ---------- | ------- |
| `j`  | `state` | sequential |         |
| `k`  | `state` | sequential |         |

## Verification

The JK flip-flop with asynchronous reset module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                              |
| ------ | --------------- | ------------------------------------------------------------------------ |
| 1      | Random stimulus | Stimulate the `j` and `k` inputs over many cycles and check the `state`. |

The following table lists the parameter values verified by the testbench.

| `RESET_VALUE` |           |
| ------------- | --------- |
| 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

If the technology node provides a dedicated JK flip-flop cell with asynchronous reset, this module should be replaced with it.

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`jk_flip_flop_with_reset.v`](jk_flip_flop_with_reset.v)                           | Verilog design.                                     |
| Testbench         | [`jk_flip_flop_with_reset.testbench.sv`](jk_flip_flop_with_reset.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`jk_flip_flop_with_reset.testbench.gtkw`](jk_flip_flop_with_reset.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`jk_flip_flop_with_reset.symbol.sss`](jk_flip_flop_with_reset.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`jk_flip_flop_with_reset.symbol.svg`](jk_flip_flop_with_reset.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`jk_flip_flop_with_reset.symbol.drawio`](jk_flip_flop_with_reset.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`jk_flip_flop_with_reset.md`](jk_flip_flop_with_reset.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                                                  | Path                                                                        | Comment                                    |
| ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------ |
| [`jk_flip_flop`](../jk_flip_flop/jk_flip_flop.md)                                                       | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop`                   | Variant of the JK flip-flop without reset. |
| [`toggle_flip_flop_with_reset`](../toggle_flip_flop_with_reset/toggle_flip_flop_with_reset.md)          | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop_with_reset`    | Toggle flip-flop with reset.               |
| [`set_reset_flip_flop_with_reset`](../set_reset_flip_flop_with_reset/set_reset_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop_with_reset` | Set-reset flip-flop with reset.            |
