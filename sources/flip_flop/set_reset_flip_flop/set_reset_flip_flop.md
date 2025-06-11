# Set-Reset Flip-Flop

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Set-Reset Flip-Flop                                                              |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![set_reset_flip_flop](set_reset_flip_flop.symbol.svg)

The set-reset flip-flop is a sequential logic element that can be set to high or reset to low using dedicated control inputs. When both `set` and `reset` are asserted simultaneously, set takes priority. This implementation has no asynchronous reset functionality, making it suitable for applications where the initial state is not critical.

## Parameters

This module has no parameters.

## Ports

| Name    | Direction | Width | Clock   | Reset | Reset value | Description             |
| ------- | --------- | ----- | ------- | ----- | ----------- | ----------------------- |
| `clock` | input     | 1     | self    |       |             | Clock signal.           |
| `set`   | input     | 1     | `clock` |       |             | Set the state to high.  |
| `reset` | input     | 1     | `clock` |       |             | Reset the state to low. |
| `state` | output    | 1     | `clock` |       |             | State of the flip-flop. |

## Operation

The set-reset flip-flop operates by sampling the `set` and `reset` inputs on each rising edge of the `clock`. When `set` is high, the state is set to 1. When `reset` is high, the state is reset to 0. Reset has priority over set when both are asserted. When neither input is asserted, the state remains unchanged. Since there is no asynchronous reset signal, the flip-flop will power up to a random state in hardware. In simulation, the `state` is initialized to `0` to avoid propagating `x` in the rest of the design.

| `clock` | `set` | `reset` | next `state` |
| ------- | ----- | ------- | ------------ |
| idle    | `x`   | `x`     | `state`      |
| falling | `x`   | `x`     | `state`      |
| rising  | `0`   | `0`     | `state`      |
| rising  | `1`   | `0`     | `1`          |
| rising  | `0`   | `1`     | `0`          |
| rising  | `1`   | `1`     | `0`          |

## Paths

| From    | To      | Type       | Comment |
| ------- | ------- | ---------- | ------- |
| `set`   | `state` | sequential |         |
| `reset` | `state` | sequential |         |

## Verification

The set-reset flip-flop module is verified using a SystemVerilog testbench with a single check.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                    |
| ------ | --------------- | ------------------------------------------------------------------------------ |
| 1      | Random stimulus | Stimulate the `set` and `reset` inputs over many cycles and check the `state`. |

## Constraints

There are no specific synthesis or implementation constraints for this block.

If the technology node provides a dedicated set-reset flip-flop cell, this module should be replaced with it.

## Deliverables

| Type              | File                                                                       | Description                                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`set_reset_flip_flop.v`](set_reset_flip_flop.v)                           | Verilog design.                                     |
| Testbench         | [`set_reset_flip_flop.testbench.sv`](set_reset_flip_flop.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`set_reset_flip_flop.testbench.gtkw`](set_reset_flip_flop.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`set_reset_flip_flop.symbol.sss`](set_reset_flip_flop.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`set_reset_flip_flop.symbol.svg`](set_reset_flip_flop.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`set_reset_flip_flop.md`](set_reset_flip_flop.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                                                                                         | Path                                                                                     | Comment                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [`set_reset_flip_flop_with_asynchronous_reset`](../set_reset_flip_flop_with_asynchronous_reset/set_reset_flip_flop_with_asynchronous_reset.md) | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop_with_asynchronous_reset` | Variant of the set-reset flip-flop with asynchronous reset. |
| [`toggle_flip_flop`](../toggle_flip_flop/toggle_flip_flop.md)                                                                                  | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop`                            | Toggle flip-flop.                                           |
| [`jk_flip_flop`](../jk_flip_flop/jk_flip_flop.md)                                                                                              | `omnicores-buildingblocks/sources/flip_flop/jk_flip_flop`                                | JK flip-flop.                                               |