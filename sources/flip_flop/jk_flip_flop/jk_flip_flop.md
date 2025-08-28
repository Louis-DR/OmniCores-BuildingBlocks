# JK Flip-Flop

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | JK Flip-Flop                                                                     |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![jk_flip_flop](jk_flip_flop.symbol.svg)

The JK flip-flop is a sequential logic element that combines the functionality of set-reset and toggle operations. When only one of them is asserted, `j` and `k` act like `set` and `reset`. When both `j` and `k` are asserted, the state toggles. This implementation has no asynchronous reset functionality, making it suitable for applications where the initial state is not critical.

## Parameters

This module has no parameters.

## Ports

| Name    | Direction | Width | Clock   | Reset | Reset value | Description                |
| ------- | --------- | ----- | ------- | ----- | ----------- | -------------------------- |
| `clock` | input     | 1     | self    |       |             | Clock signal.              |
| `j`     | input     | 1     | `clock` |       |             | J input (set or toggle).   |
| `k`     | input     | 1     | `clock` |       |             | K input (reset or toggle). |
| `state` | output    | 1     | `clock` |       |             | State of the flip-flop.    |

## Operation

The JK flip-flop operates by sampling the `j` and `k` inputs on each rising edge of the `clock`. When only `j` is high, the state is set to 1. When only `k` is high, the state is reset to 0. When both `j` and `k` are high, the state toggles. When neither input is asserted, the state remains unchanged. Since there is no asynchronous reset signal, the flip-flop will power up to a random state in hardware. In simulation, the `state` is initialized to `0` to avoid propagating `x` in the rest of the design.

| `clock` | `j` | `k` | next `state` |
| ------- | --- | --- | ------------ |
| idle    | `x` | `x` | `state`      |
| falling | `x` | `x` | `state`      |
| rising  | `0` | `0` | `state`      |
| rising  | `1` | `0` | `1`          |
| rising  | `0` | `1` | `0`          |
| rising  | `1` | `1` | `~state`     |

## Paths

| From | To      | Type       | Comment |
| ---- | ------- | ---------- | ------- |
| `j`  | `state` | sequential |         |
| `k`  | `state` | sequential |         |

## Verification

The JK flip-flop module is verified using a SystemVerilog testbench with multiple checks.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                          |
| ------ | --------------- | -------------------------------------------------------------------- |
| 1      | Random stimulus | Stimulate the `toggle` input over many cycles and check the `state`. |

## Constraints

The JK flip-flop module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                              |
| ------ | --------------- | ------------------------------------------------------------------------ |
| 1      | Random stimulus | Stimulate the `j` and `k` inputs over many cycles and check the `state`. |

## Deliverables

| Type              | File                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`jk_flip_flop.v`](jk_flip_flop.v)                           | Verilog design.                                     |
| Testbench         | [`jk_flip_flop.testbench.sv`](jk_flip_flop.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`jk_flip_flop.testbench.gtkw`](jk_flip_flop.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`jk_flip_flop.symbol.sss`](jk_flip_flop.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`jk_flip_flop.symbol.svg`](jk_flip_flop.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`jk_flip_flop.symbol.drawio`](jk_flip_flop.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`jk_flip_flop.md`](jk_flip_flop.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                             | Path                                                                 | Comment                                 |
| ---------------------------------------------------------------------------------- | -------------------------------------------------------------------- | --------------------------------------- |
| [`jk_flip_flop_with_reset`](../jk_flip_flop_with_reset/jk_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop_with_reset` | Variant of the JK flip-flop with reset. |
| [`set_reset_flip_flop`](../set_reset_flip_flop/set_reset_flip_flop.md)             | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop`     | Set-reset flip-flop.                    |
| [`toggle_flip_flop`](../toggle_flip_flop/toggle_flip_flop.md)                      | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop`        | Toggle flip-flop.                       |
