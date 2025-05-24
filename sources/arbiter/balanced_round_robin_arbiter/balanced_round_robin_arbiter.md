# Balanced Round-Robin Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Balanced Round-Robin Arbiter                                                     |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - https://mit-license.org/                                           |

## Overview

![balanced_round_robin_arbiter](balanced_round_robin_arbiter.svg)

Arbiters between different request channels using a round-robin scheme. The grant priority rotates among the requesting channels at each cycle, ensuring fairness. This is the balanced variant of the round-robing arbiter, between the fast and the small.

## Parameters

| Name              | Type    | Allowed Values | Default | Description                                         |
| ----------------- | ------- | -------------- | ------- | --------------------------------------------------- |
| `SIZE`            | integer | `>1`           | `4`     | Number of channels.                                 |
| `ROTATE_ON_GRANT` | integer | `0`,`1`        | `0`     | `0`: rotate every cycles.<br/>`1`: rotate on grant. |

## Ports

| Name       | Direction | Width  | Clock        | Reset    | Reset value | Description                                                                             |
| ---------- | --------- | ------ | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------- |
| `clock`    | input     | 1      | self         |          |             | Clock signal.                                                                           |
| `resetn`   | input     | 1      | asynchronous | self     | `0`         | Asynchronous reset signal. Resets the priority pointer.                                 |
| `requests` | input     | `SIZE` | `clock`      |          |             | Request channels.<br/>`1`: requesting a grant.<br/>`0`: idle.                           |
| `grant`    | output    | `SIZE` | `clock`      | `resetn` |             | Channel receiving the grant. One-hot encoding.<br/>`1`: grant given.<br/>`0`: no grant. |

## Operation

An internal mask separates the channels in two regions, high and low priority. The mask is updated at each cycle (or only when a grant is given if the parameter `ROTATE_ON_GRANT` is set to `1`). When updated, the mask is shifted to the left. When the mask is only a single one at the MSB, it wraps back to being all ones.

The `requests` vector is masked to get the high priority request. The low priority requests vector is just the `requests` vector. We don't need to mask off the high priority channels for the low priority `requests` vector. The grant for each region is calculated by a pair of static priority arbiters.

If a grant is given in the high priority region, then it is the final `grant`. Else, the `grant` is given to the low priority region (if any grant is given there as well).

This variant is a balanced option between the small and fast variants. It uses a pair of static priority arbiters compared to one per channel for the fast variant, and it doesn't require the pair of barrel rotators of the small variant (replaced by an AND and MUX stages).

## Paths

| From       | To      | Type          | Comment |
| ---------- | ------- | ------------- | ------- |
| `requests` | `grant` | combinational |         |

## Complexity

| Delay          | Gates     | Comment |
| -------------- | --------- | ------- |
| `O(log₂ SIZE)` | `O(SIZE)` |         |

Note that this variant uses the fast variant of the static priority arbiter.

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

| Type              | File                                                                           | Description                                         |
| ----------------- | ------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`balanced_round_robin_arbiter.v`](balanced_round_robin_arbiter.v)             | Verilog design.                                     |
| Testbench         | [`balanced_round_robin_arbiter_tb.sv`](balanced_round_robin_arbiter_tb.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`balanced_round_robin_arbiter_tb.gtkw`](balanced_round_robin_arbiter_tb.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`balanced_round_robin_arbiter.sss`](balanced_round_robin_arbiter.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`balanced_round_robin_arbiter.svg`](balanced_round_robin_arbiter.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`balanced_round_robin_arbiter.md`](balanced_round_robin_arbiter.md)           | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                             | Path                                                               | Comment |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------- |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter` |         |
| [`first_one`](../../operations/first_one/first_one.md)                             | `omnicores-buildingblocks/sources/operations/first_one`            |         |
| [`fast_first_one`](../../operations/fast_first_one/fast_first_one.md)              | `omnicores-buildingblocks/sources/operations/fast_first_one`       |         |
| [`shift_left`](../../operations/shift_left/shift_left.md)                          | `omnicores-buildingblocks/sources/operations/shift_left`           |         |

## Related modules

| Module                                                                                                     | Path                                                                       | Comment                                                 |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`round_robing_arbiter`](../round_robing_arbiter/round_robing_arbiter.md)                                  | `omnicores-buildingblocks/sources/arbiter/round_robing_arbiter`            | Variant wrapper of the round-robing arbiter.            |
| [`small_round_robing_arbiter`](../small_round_robing_arbiter/small_round_robing_arbiter.md)                | `omnicores-buildingblocks/sources/arbiter/small_round_robing_arbiter`      | Smaller but slower variant of the round-robing arbiter. |
| [`fast_round_robing_arbiter`](../fast_round_robing_arbiter/fast_round_robing_arbiter.md)                   | `omnicores-buildingblocks/sources/arbiter/fast_round_robing_arbiter`       | Faster but bigger variant of the round-robing arbiter.  |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)                         | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`         | Simpler but unfair arbiter.                             |
| [`timeout_static_priority_arbiter`](../timeout_static_priority_arbiter/timeout_static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/timeout_static_priority_arbiter` | Simpler and unfair but avoiding starvation.             |
| [`dynamic_priority_arbiter`](../dynamic_priority_arbiter/dynamic_priority_arbiter.md)                      | `omnicores-buildingblocks/sources/arbiter/dynamic_priority_arbiter`        | Arbiter with per-channel dynamic priority.              |

## References

- [Wikipedia, “Round-robin scheduling”.](https://en.wikipedia.org/wiki/Round-robin_scheduling)
- [M. Weber, “Arbiters: design ideas and coding styles”, SNUG Boston, 2001.](https://abdullahyildiz.github.io/files/Arbiters-Design_Ideas_and_Coding_Styles.pdf)
