# Static Priority Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Static Priority Arbiter                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![static_priority_arbiter](static_priority_arbiter.svg)

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

| Number | Check           | Description                                                                 |
| ------ | --------------- | --------------------------------------------------------------------------- |
| 1      | Exhaustive test | Check that the grant is correct for all combinations of the request vector. |

The folowing table lists the parameter values verified by the testbench.

| `SIZE` |           |
| ------ | --------- |
| 4      | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`static_priority_arbiter.v`](static_priority_arbiter.v)             | Verilog design.                                     |
| Testbench         | [`static_priority_arbiter_tb.sv`](static_priority_arbiter_tb.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`static_priority_arbiter_tb.gtkw`](static_priority_arbiter_tb.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`static_priority_arbiter.sss`](static_priority_arbiter.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`static_priority_arbiter.svg`](static_priority_arbiter.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`static_priority_arbiter.md`](static_priority_arbiter.md)           | Markdown documentation datasheet.                   |

## Dependencies

| Module            | Path                                                    | Comment                         |
| ----------------- | ------------------------------------------------------- | ------------------------------- |
| `first_one`       | `omnicores-buildingblocks/sources/operations/first_one` |                                 |
| `fast_first_one`  | `omnicores-buildingblocks/sources/operations/first_one` | For the default `fast` variant. |
| `small_first_one` | `omnicores-buildingblocks/sources/operations/first_one` | For the `small` variant.        |

## Related modules

| Module                                                                                | Path                                                                | Comment                                    |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------ |
| [`round_robin_arbiter`](../round_robin_arbiter/round_robin_arbiter.md)                | `omnicores-buildingblocks/sources/arbiter/round_robin_arbiter`      | Fair arbiter.                              |
| [`dynamic_priority_arbiter`](../dynamic_priority_arbiter/dynamic_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/dynamic_priority_arbiter` | Arbiter with per-channel dynamic priority. |
