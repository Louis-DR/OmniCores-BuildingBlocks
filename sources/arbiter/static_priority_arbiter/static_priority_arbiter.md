# Static Priority Arbiter

|         |                                           |
| ------- | ----------------------------------------- |
| Module  | Static Priority Arbiter                   |
| File    | static_priority_arbiter.v                 |
| Project | OmniCores-BuildingBlocks                  |
| Author  | Louis Duret-Robert - louisduret@gmail.com |
| Website | louis-dr.github.io                        |
| License | MIT License - https://mit-license.org/    |

## Overview

![static_priority_arbiter](static_priority_arbiter.svg)

Arbiters between different request channels. The grant is given to the first ready request channel. It works by finding the first one in the request bus.

## Parameters

| Name      | Type    | Allowed Values      | Default  | Description             |
| --------- | ------- | ------------------- | -------- | ----------------------- |
| `SIZE`    | integer | >1                  | `4`      | Number of channels.     |
| `VARIANT` | string  | `"fast"`, `"small"` | `"fast"` | Implementation variant. |

## Ports

| Name       | Direction | Width  | Clock        | Reset | Reset value | Description                                                 |
| ---------- | --------- | ------ | ------------ | ----- | ----------- | ----------------------------------------------------------- |
| `requests` | input     | `SIZE` | asynchronous | none  | none        | Request channels. `1` for requesting a grant. `0` for idle. |
| `grant`    | output    | `SIZE` | asynchronous | none  | none        | Channel receiving the grant. One-hot encoding.              |

## Paths

| From       | To      | Type          | Comment |
| ---------- | ------- | ------------- | ------- |
| `requests` | `grant` | combinational |         |

## Variants

| Name             | Delay          | Gates          | Description                |
| ---------------- | -------------- | -------------- | -------------------------- |
| `fast` (default) | `O(log2 SIZE)` | `O(SIZE)`      | Uses prefix-network logic. |
| `small`          | `O(SIZE)`      | `O(log2 SIZE)` | Uses ripple-chain logic.   |

## Verification

The arbiter is verified exhaustively for the default parameter values by iterating over all the request combinations and checking the grant.

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                              | Description                                         |
| ----------------- | --------------------------------- | --------------------------------------------------- |
| Design            | `static_priority_arbiter.v`       | Verilog design.                                     |
| Testbench         | `static_priority_arbiter_tb.sv`   | SystemVerilog verification testbench.               |
| Waveform script   | `static_priority_arbiter_tb.gtkw` | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | `static_priority_arbiter.sss`     | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | `static_priority_arbiter.svg`     | Generated vector image of the symbol.               |
| Datasheet         | `static_priority_arbiter.md`      | Markdown documentation datasheet.                   |

## Dependencies

| Module            | Path                                                    | Comment                         |
| ----------------- | ------------------------------------------------------- | ------------------------------- |
| `first_one`       | `omnicores-buildingblocks/sources/operations/first_one` |                                 |
| `fast_first_one`  | `omnicores-buildingblocks/sources/operations/first_one` | For the default `fast` variant. |
| `small_first_one` | `omnicores-buildingblocks/sources/operations/first_one` | For the `small` variant.        |
