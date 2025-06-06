# Static Priority Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Static Priority Arbiter                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![static_priority_arbiter](static_priority_arbiter.symbol.svg)

Arbiters between different request channels. The grant is given to the first ready request channel. It is not fair.

## Parameters

| Name      | Type    | Allowed Values      | Default  | Description             |
| --------- | ------- | ------------------- | -------- | ----------------------- |
| `SIZE`    | integer | `>1`                | `4`      | Number of channels.     |
| `VARIANT` | string  | `"fast"`, `"small"` | `"fast"` | Implementation variant. |

## Ports

| Name       | Direction | Width  | Clock        | Reset | Reset value | Description                                                                             |
| ---------- | --------- | ------ | ------------ | ----- | ----------- | --------------------------------------------------------------------------------------- |
| `requests` | input     | `SIZE` | asynchronous |       |             | Request channels.<br/>`1`: requesting a grant.<br/>`0`: idle.                           |
| `grant`    | output    | `SIZE` | `clock`      |       |             | Channel receiving the grant. One-hot encoding.<br/>`1`: grant given.<br/>`0`: no grant. |

## Operation

The arbiter gives the grant to the first ready request channel by detecting the first high bit in the `requests` vector.

## Paths

| From       | To      | Type          | Comment |
| ---------- | ------- | ------------- | ------- |
| `requests` | `grant` | combinational |         |

## Complexity

| `VARIANT`          | Delay          | Gates          | Comment                    |
| ------------------ | -------------- | -------------- | -------------------------- |
| `"fast"` (default) | `O(log₂ SIZE)` | `O(SIZE)`      | Uses prefix-network logic. |
| `"small"`          | `O(SIZE)`      | `O(log₂ SIZE)` | Uses ripple-chain logic.   |

## Verification

The arbiter is verified exhaustively for the default parameter values by iterating over all the request combinations and checking the grant.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                 |
| ------ | --------------- | --------------------------------------------------------------------------- |
| 1      | Exhaustive test | Check that the grant is correct for all combinations of the request vector. |

The following table lists the parameter values verified by the testbench.

| `SIZE` |           |
| ------ | --------- |
| 4      | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`static_priority_arbiter.v`](static_priority_arbiter.v)                           | Verilog design.                                     |
| Testbench         | [`static_priority_arbiter.testbench.sv`](static_priority_arbiter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`static_priority_arbiter.testbench.gtkw`](static_priority_arbiter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`static_priority_arbiter.symbol.sss`](static_priority_arbiter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`static_priority_arbiter.symbol.svg`](static_priority_arbiter.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`static_priority_arbiter.md`](static_priority_arbiter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                   | Path                                                          | Comment                         |
| ------------------------------------------------------------------------ | ------------------------------------------------------------- | ------------------------------- |
| [`first_one`](../../operations/first_one/first_one.md)                   | `omnicores-buildingblocks/sources/operations/first_one`       |                                 |
| [`fast_first_one`](../../operations/fast_first_one/fast_first_one.md)    | `omnicores-buildingblocks/sources/operations/fast_first_one`  | For the default `fast` variant. |
| [`small_first_one`](../../operations/small_first_one/small_first_one.md) | `omnicores-buildingblocks/sources/operations/small_first_one` | For the `small` variant.        |
| [`shift_left`](../../operations/shift_left/shift_left.md)                | `omnicores-buildingblocks/sources/operations/shift_left`      | For the default `fast` variant. |

## Related modules

| Module                                                                                                     | Path                                                                       | Comment                                    |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------ |
| [`timeout_static_priority_arbiter`](../timeout_static_priority_arbiter/timeout_static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/timeout_static_priority_arbiter` | Also unfair but avoiding starvation.       |
| [`round_robin_arbiter`](../round_robin_arbiter/round_robin_arbiter.md)                                     | `omnicores-buildingblocks/sources/arbiter/round_robin_arbiter`             | Fair arbiter.                              |
| [`dynamic_priority_arbiter`](../dynamic_priority_arbiter/dynamic_priority_arbiter.md)                      | `omnicores-buildingblocks/sources/arbiter/dynamic_priority_arbiter`        | Arbiter with per-channel dynamic priority. |
