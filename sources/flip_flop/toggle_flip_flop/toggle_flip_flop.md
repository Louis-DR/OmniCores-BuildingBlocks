# Toggle Flip-Flop

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Toggle Flip-Flop                                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![toggle_flip_flop](toggle_flip_flop.symbol.svg)

The toggle flip-flop is a sequential logic element that inverts its output `stage` on each rising `clock` edge when the `toggle` input is asserted. It maintains its current state when `toggle` is deasserted. This implementation has no reset functionality, making it suitable for applications where the initial state is not critical.

## Parameters

This module has no parameters.

## Ports

| Name     | Direction | Width | Clock   | Reset | Reset value | Description             |
| -------- | --------- | ----- | ------- | ----- | ----------- | ----------------------- |
| `clock`  | input     | 1     | self    |       |             | Clock signal.           |
| `toggle` | input     | 1     | `clock` |       |             | Toggle the state.       |
| `state`  | output    | 1     | `clock` |       |             | State of the flip-flop. |

## Operation

The toggle flip-flop operates by sampling the `toggle` input on each rising edge of the `clock`. When `toggle` is high, the state output is inverted. When `toggle` is low, the state remains unchanged. Since there is no reset signal, the flip-flop will power up to a random state in hardware. In simulation, the `state` is initialized to `0` to avoid propagating `x` in the rest of the design.

| `clock` | `toggle` | next `state` |
| ------- | -------- | ------------ |
| idle    | `x`      | `state`      |
| falling | `x`      | `state`      |
| rising  | `0`      | `state`      |
| rising  | `1`      | `~state`     |

## Paths

| From     | To      | Type       | Comment |
| -------- | ------- | ---------- | ------- |
| `toggle` | `state` | sequential |         |

## Verification

The toggle flip-flop module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                          |
| ------ | --------------- | -------------------------------------------------------------------- |
| 1      | Random stimulus | Stimulate the `toggle` input over many cycles and check the `state`. |

## Constraints

There are no specific synthesis or implementation constraints for this block.

If the technology node provides a dedicated toggle flip-flop cell, this module should be replaced with it.

## Deliverables

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`toggle_flip_flop.v`](toggle_flip_flop.v)                           | Verilog design.                                     |
| Testbench         | [`toggle_flip_flop.testbench.sv`](toggle_flip_flop.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`toggle_flip_flop.testbench.gtkw`](toggle_flip_flop.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`toggle_flip_flop.symbol.sss`](toggle_flip_flop.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`toggle_flip_flop.symbol.svg`](toggle_flip_flop.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`toggle_flip_flop.md`](toggle_flip_flop.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                                         | Path                                                                     | Comment                                     |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------- |
| [`toggle_flip_flop_with_reset`](../toggle_flip_flop_with_reset/toggle_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop_with_reset` | Variant of the toggle flip-flop with reset. |
| [`set_reset_flip_flop`](../set_reset_flip_flop/set_reset_flip_flop.md)                         | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop`         | Set-reset flip-flop.                        |
| [`jk_flip_flop`](../jk_flip_flop/jk_flip_flop.md)                                              | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop`                | JK flip-flop.                               |
