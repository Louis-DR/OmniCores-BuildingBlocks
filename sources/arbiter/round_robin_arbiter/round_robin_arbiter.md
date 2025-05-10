# Round-Robin Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Round-Robin Arbiter                                                              |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![round_robin_arbiter](round_robin_arbiter.svg)

Arbiters between different request channels using a round-robin scheme. The grant priority rotates among the requesting channels at each cycle, ensuring fairness. This is the wrapper between the different variants of the round-robin arbiter.

## Parameters

| Name              | Type    | Allowed Values     | Default  | Description                                         |
| ----------------- | ------- | ------------------ | -------- | --------------------------------------------------- |
| `SIZE`            | integer | `>1`               | `4`      | Number of channels.                                 |
| `ROTATE_ON_GRANT` | integer | `0`,`1`            | `0`      | `0`: rotate every cycles.<br/>`1`: rotate on grant. |
| `VARIANT`         | string  | `"small"`,`"fast"` | `"fast"` | Implementation variant.                             |

## Ports

| Name       | Direction | Width  | Clock        | Reset    | Reset value | Description                                                                             |
| ---------- | --------- | ------ | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------- |
| `clock`    | input     | 1      | self         |          |             | Clock signal.                                                                           |
| `resetn`   | input     | 1      | asynchronous | self     | `0`         | Asynchronous reset signal. Resets the priority pointer.                                 |
| `requests` | input     | `SIZE` | `clock`      |          |             | Request channels.<br/>`1`: requesting a grant.<br/>`0`: idle.                           |
| `grant`    | output    | `SIZE` | `clock`      | `resetn` |             | Channel receiving the grant. One-hot encoding.<br/>`1`: grant given.<br/>`0`: no grant. |

## Operation

The internal pointer `rotating_pointer` is incremented at each cycle and wraps around. If the parameter `ROTATE_ON_GRANT` is set to `1`, the pointer is incremented only when a grant is given.

The `requests` vector is rotated by the `rotating_pointer`, then passed to a `static_priority_arbiter`, and the `grant` vector is rotated back the other direction.

This variant of the arbiter uses a single `static_priority_arbiter` and two barrel rotators, making it small at the cost of a deeper slower logic path. It also uses the `"small"` variant of the `static_priority_arbiter`.

## Paths

| From       | To      | Type          | Comment |
| ---------- | ------- | ------------- | ------- |
| `requests` | `grant` | combinational |         |

## Complexity

| Variant            | Delay          | Gates               | Comment |
| ------------------ | -------------- | ------------------- | ------- |
| `"fast"` (default) | `O(log₂ SIZE)` | `O(SIZE²)`          |         |
| `"small"`          | `O(SIZE)`      | `O(SIZE log₂ SIZE)` |         |

## Verification

The arbiter is verified using a SystemVerilog testbench with concurrent assertions and three check sequences.

The following table lists the checks performed by the testbench.

| Number | Check                        | Description                                                                             |
| ------ | ---------------------------- | --------------------------------------------------------------------------------------- |
| 1      | Single request active        | Activate each request one at a time and check that it is granted over multiple cycles.  |
| 2      | All requests active          | Activate all requests and check that after a few cycles they have all been granted.     |
| 3      | Random stimulus and fairness | Random value of the request vector and check that the arbiter is fair between channels. |

The following table lists the parameter values verified by the testbench.

| `SIZE` |           |
| ------ | --------- |
| 4      | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`round_robin_arbiter.v`](round_robin_arbiter.v)             | Verilog design.                                     |
| Testbench         | [`round_robin_arbiter_tb.sv`](round_robin_arbiter_tb.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`round_robin_arbiter_tb.gtkw`](round_robin_arbiter_tb.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`round_robin_arbiter.sss`](round_robin_arbiter.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`round_robin_arbiter.svg`](round_robin_arbiter.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`round_robin_arbiter.md`](round_robin_arbiter.md)           | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                                      | Path                                                                  | Comment                         |
| ------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------- |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)          | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`    |                                 |
| [`small_round_robing_arbiter`](../small_round_robing_arbiter/small_round_robing_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/small_round_robing_arbiter` | For the `small` variant.        |
| [`fast_round_robing_arbiter`](../fast_round_robing_arbiter/fast_round_robing_arbiter.md)    | `omnicores-buildingblocks/sources/arbiter/fast_round_robing_arbiter`  | For the default `fast` variant. |
| `first_one`                                                                                 | `omnicores-buildingblocks/sources/operations/first_one`               |                                 |
| `small_first_one`                                                                           | `omnicores-buildingblocks/sources/operations/small_first_one`         | For the `small` variant.        |
| `fast_first_one`                                                                            | `omnicores-buildingblocks/sources/operations/fast_first_one`          | For the default `fast` variant. |
| `barrel_rotator_left`                                                                       | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`     | For the `small` variant.        |
| `barrel_rotator_right`                                                                      | `omnicores-buildingblocks/sources/operations/barrel_rotator_right`    | For the `small` variant.        |
| `rotate_left`                                                                               | `omnicores-buildingblocks/sources/operations/rotate_left`             | For the default `fast` variant. |
| `rotate_right`                                                                              | `omnicores-buildingblocks/sources/operations/rotate_right`            | For the default `fast` variant. |
| `wrapping_increment_counter`                                                                | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter` |                                 |

## Related modules

| Module                                                                                      | Path                                                                  | Comment                                             |
| ------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------- |
| [`small_round_robing_arbiter`](../small_round_robing_arbiter/small_round_robing_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/small_round_robing_arbiter` | Small but slow variant of the round-robing arbiter. |
| [`fast_round_robing_arbiter`](../fast_round_robing_arbiter/fast_round_robing_arbiter.md)    | `omnicores-buildingblocks/sources/arbiter/fast_round_robing_arbiter`  | Fast but big variant of the round-robing arbiter.   |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)          | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`    | Simpler but unfair arbiter.                         |
| [`dynamic_priority_arbiter`](../dynamic_priority_arbiter/dynamic_priority_arbiter.md)       | `omnicores-buildingblocks/sources/arbiter/dynamic_priority_arbiter`   | Arbiter with per-channel dynamic priority.          |
