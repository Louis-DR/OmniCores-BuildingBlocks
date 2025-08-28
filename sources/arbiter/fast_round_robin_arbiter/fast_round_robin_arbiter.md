# Fast Round-Robin Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Fast Round-Robin Arbiter                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![fast_round_robin_arbiter](fast_round_robin_arbiter.symbol.svg)

Arbiters between different request channels using a round-robin scheme. The grant priority rotates among the requesting channels at each cycle, ensuring fairness. This is the faster but bigger variant of the round-robing arbiter.

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

The internal pointer `rotating_pointer` is incremented at each cycle and wraps around. If the parameter `ROTATE_ON_GRANT` is set to `1`, the pointer is incremented only when a grant is given.

This variant uses one `static_priority_arbiter` for each request channel. Each `static_priority_arbiter` computes the priority with the `requests` vector rotated to a different value between 0 and `SIZE` and its `grant` vector is rotated back, then the expected `grant` vector is selected by a multiplexer using the `rotating_pointer`.

The faster operation of this variant is obtained by the parallel computation of the core arbitration, but at the cost of more logic. It also uses the `"fast"` variant of the `static_priority_arbiter`.

## Paths

| From       | To      | Type          | Comment |
| ---------- | ------- | ------------- | ------- |
| `requests` | `grant` | combinational |         |

## Complexity

| Delay          | Gates      | Comment |
| -------------- | ---------- | ------- |
| `O(log₂ SIZE)` | `O(SIZE²)` |         |

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

| Type              | File                                                                                 | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`fast_round_robin_arbiter.v`](fast_round_robin_arbiter.v)                           | Verilog design.                                     |
| Testbench         | [`fast_round_robin_arbiter.testbench.sv`](fast_round_robin_arbiter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`fast_round_robin_arbiter.testbench.gtkw`](fast_round_robin_arbiter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`fast_round_robin_arbiter.symbol.sss`](fast_round_robin_arbiter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`fast_round_robin_arbiter.symbol.svg`](fast_round_robin_arbiter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`fast_round_robin_arbiter.symbol.drawio`](fast_round_robin_arbiter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`fast_round_robin_arbiter.md`](fast_round_robin_arbiter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                             | Path                                                                  | Comment |
| ---------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------- |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`    |         |
| [`first_one`](../../operations/first_one/first_one.md)                             | `omnicores-buildingblocks/sources/operations/first_one`               |         |
| [`fast_first_one`](../../operations/fast_first_one/fast_first_one.md)              | `omnicores-buildingblocks/sources/operations/fast_first_one`          |         |
| [`shift_left`](../../operations/shift_left/shift_left.md)                          | `omnicores-buildingblocks/sources/operations/shift_left`              |         |
| [`rotate_left`](../../operations/rotate_left/rotate_left.md)                       | `omnicores-buildingblocks/sources/operations/rotate_left`             |         |
| [`rotate_right`](../../operations/rotate_right/rotate_right.md)                    | `omnicores-buildingblocks/sources/operations/rotate_right`            |         |
| `wrapping_increment_counter`                                                       | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter` |         |

## Related modules

| Module                                                                                                     | Path                                                                       | Comment                                                 |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`round_robing_arbiter`](../round_robing_arbiter/round_robing_arbiter.md)                                  | `omnicores-buildingblocks/sources/arbiter/round_robing_arbiter`            | Variant wrapper of the round-robing arbiter.            |
| [`small_round_robing_arbiter`](../small_round_robing_arbiter/small_round_robing_arbiter.md)                | `omnicores-buildingblocks/sources/arbiter/small_round_robing_arbiter`      | Smaller but slower variant of the round-robing arbiter. |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)                         | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`         | Simpler but unfair arbiter.                             |
| [`timeout_static_priority_arbiter`](../timeout_static_priority_arbiter/timeout_static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/timeout_static_priority_arbiter` | Simpler and unfair but avoiding starvation.             |
| [`dynamic_priority_arbiter`](../dynamic_priority_arbiter/dynamic_priority_arbiter.md)                      | `omnicores-buildingblocks/sources/arbiter/dynamic_priority_arbiter`        | Arbiter with per-channel dynamic priority.              |

## References

- [Wikipedia, “Round-robin scheduling”.](https://en.wikipedia.org/wiki/Round-robin_scheduling)
- [M. Weber, “Arbiters: design ideas and coding styles”, SNUG Boston, 2001.](https://abdullahyildiz.github.io/files/Arbiters-Design_Ideas_and_Coding_Styles.pdf)
