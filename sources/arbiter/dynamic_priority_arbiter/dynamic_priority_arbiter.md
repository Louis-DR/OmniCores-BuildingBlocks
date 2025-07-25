# Dynamic Priority Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Dynamic Priority Arbiter                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![dynamic_priority_arbiter](dynamic_priority_arbiter.symbol.svg)

Arbiters between different request channels based on externally supplied priority values. The grant is given to the requesting channel with the highest priority value. If multiple requesting channels share the highest priority value, the fallback arbiter is used. It can be configured to a static priority arbiter, or a round-robin arbiter.

## Parameters

| Name               | Type    | Allowed Values                       | Default                 | Description                                              |
| ------------------ | ------- | ------------------------------------ | ----------------------- | -------------------------------------------------------- |
| `SIZE`             | integer | `>1`                                 | `4`                     | Number of channels.                                      |
| `PRIORITY_WIDTH`   | integer | `>0`                                 | `log₂(SIZE)=2`          | Bit width of the priority value for each channel.        |
| `PRIORITIES_WIDTH` | integer | `>1`                                 | `PRIORITY_WIDTH×SIZE=8` | Bit width of the combined priority array.                |
| `FALLBACK_ARBITER` | string  | `"static_priority"`, `"round_robin"` | `"static_priority"`     | Fallback arbiter for multiple highest priority requests. |
| `FALLBACK_VARIANT` | string  | `"fast"`, `"balanced"`, `"small"`    | `"fast"`                | Variant for the fallback arbiter.                        |

## Ports

| Name         | Direction | Width                   | Clock        | Reset    | Reset value | Description                                                                                                                                   |
| ------------ | --------- | ----------------------- | ------------ | -------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `clock`      | input     | 1                       | self         |          |             | Clock signal.                                                                                                                                 |
| `resetn`     | input     | 1                       | asynchronous | self     | `0`         | Asynchronous reset signal. Resets the priority pointer.                                                                                       |
| `requests`   | input     | `SIZE`                  | `clock`      |          |             | Request channels.<br/>`1`: requesting a grant.<br/>`0`: idle.                                                                                 |
| `priorities` | input     | `SIZE × PRIORITY_WIDTH` | `clock`      |          |             | Priority values for each channel.<br/>Packed array: `{priority[N-1], ..., priority[1], priority[0]}`.<br/>Higher value means higher priority. |
| `grant`      | output    | `SIZE`                  | `clock`      | `resetn` |             | Channel receiving the grant. One-hot encoding.<br/>`1`: grant given.<br/>`0`: no grant.                                                       |

## Operation

The arbiter first unpacks the priority array and classifies the requests per priority class, then it finds the highest priority class with an active request and filters corresponding requests, and finally it feeds those requests to the fallback arbiter to get the correct grant.

## Paths

| From         | To      | Type          | Comment |
| ------------ | ------- | ------------- | ------- |
| `requests`   | `grant` | combinational |         |
| `priorities` | `grant` | combinational |         |

## Complexity

| `FALLBACK_ARBITER`  | `FALLBACK_VARIANT` | Delay | Gates | Comment |
| ------------------- | ------------------ | ----- | ----- | ------- |
| `"static_priority"` | `"fast"` (default) |       |       |         |
| `"static_priority"` | `"small"`          |       |       |         |
| `"round_robin"`     | `"fast"`           |       |       |         |
| `"round_robin"`     | `"balanced"`       |       |       |         |
| `"round_robin"`     | `"small"`          |       |       |         |

Note that the default fallback arbiter variant (`FALLBACK_VARIANT`) is `"fast"` because it is the default fallback arbiter is the static priority arbiter (`FALLBACK_ARBITER="static_priority"`). If the round-robin arbiter fallback variant is selected instead (`FALLBACK_ARBITER="round_robin"`), the `"balanced"` variant is preferable.

## Verification

The arbiter is verified using a SystemVerilog testbench with concurrent assertions and three check sequences. It uses a helper function to calculate the mask of active highest priority requests.

The following table lists the checks performed by the testbench.

| Number | Check                 | Description                                                                                                                    |
| ------ | --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 1      | Single request active | Activate each request one at a time and check that it is granted over all prority configurations.                              |
| 2      | All requests active   | Activate all requests and check over all prority configurations that the grant is within the highest priority active requests. |
| 3      | Random stimulus       | Random value of the request and priorities buses and check that the grant is within the highest priority active requests.      |

The following table lists the parameter values verified by the testbench.

| `SIZE` |           |
| ------ | --------- |
| 4      | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                                 | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`dynamic_priority_arbiter.v`](dynamic_priority_arbiter.v)                           | Verilog design.                                     |
| Testbench         | [`dynamic_priority_arbiter.testbench.sv`](dynamic_priority_arbiter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`dynamic_priority_arbiter.testbench.gtkw`](dynamic_priority_arbiter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`dynamic_priority_arbiter.symbol.sss`](dynamic_priority_arbiter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`dynamic_priority_arbiter.symbol.svg`](dynamic_priority_arbiter.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`dynamic_priority_arbiter.md`](dynamic_priority_arbiter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                                                               | Path                                                                     | Comment                                                           |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)                   | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`       |                                                                   |
| [`round_robing_arbiter`](../round_robing_arbiter/round_robing_arbiter.md)                            | `omnicores-buildingblocks/sources/arbiter/round_robing_arbiter`          | For the `round_robin` fallback arbiter.                           |
| [`small_round_robing_arbiter`](../small_round_robing_arbiter/small_round_robing_arbiter.md)          | `omnicores-buildingblocks/sources/arbiter/small_round_robing_arbiter`    | For the `small` variant of the `round_robin` fallback arbiter.    |
| [`balanced_round_robing_arbiter`](../balanced_round_robing_arbiter/balanced_round_robing_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/balanced_round_robing_arbiter` | For the `balanced` variant of the `round_robin` fallback arbiter. |
| [`fast_round_robing_arbiter`](../fast_round_robing_arbiter/fast_round_robing_arbiter.md)             | `omnicores-buildingblocks/sources/arbiter/fast_round_robing_arbiter`     | For the `fast` variant of the `round_robin` fallback arbiter.     |
| [`first_one`](../../operations/first_one/first_one.md)                                               | `omnicores-buildingblocks/sources/operations/first_one`                  |                                                                   |
| [`small_first_one`](../../operations/small_first_one/small_first_one.md)                             | `omnicores-buildingblocks/sources/operations/small_first_one`            | For the `small` variant.                                          |
| [`fast_first_one`](../../operations/fast_first_one/fast_first_one.md)                                | `omnicores-buildingblocks/sources/operations/fast_first_one`             | For the `fast` variant.                                           |
| `barrel_rotator_left`                                                                                | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`        | For the `small` variant of the `round_robin` fallback arbiter.    |
| `barrel_rotator_right`                                                                               | `omnicores-buildingblocks/sources/operations/barrel_rotator_right`       | For the `small` variant of the `round_robin` fallback arbiter.    |
| [`shift_left`](../../operations/shift_left/shift_left.md)                                            | `omnicores-buildingblocks/sources/operations/shift_left`                 | For the `fast` and default `balanced` variants.                   |
| [`rotate_left`](../../operations/rotate_left/rotate_left.md)                                         | `omnicores-buildingblocks/sources/operations/rotate_left`                | For the `fast` variant of the `round_robin` fallback arbiter.     |
| [`rotate_right`](../../operations/rotate_right/rotate_right.md)                                      | `omnicores-buildingblocks/sources/operations/rotate_right`               | For the `fast` variant of the `round_robin` fallback arbiter.     |
| `wrapping_increment_counter`                                                                         | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter`    | For the `round_robin` fallback arbiter.                           |
| `binary_to_onehot`                                                                                   | `omnicores-buildingblocks/sources/encoding/onehot/binary_to_onehot`      |                                                                   |

## Related modules

| Module                                                                                                     | Path                                                                       | Comment                                     |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------- |
| [`static_priority_arbiter`](../static_priority_arbiter/static_priority_arbiter.md)                         | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter`         | Arbiter with static priority order.         |
| [`timeout_static_priority_arbiter`](../timeout_static_priority_arbiter/timeout_static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/timeout_static_priority_arbiter` | Simpler and unfair but avoiding starvation. |
| [`round_robin_arbiter`](../round_robin_arbiter/round_robin_arbiter.md)                                     | `omnicores-buildingblocks/sources/arbiter/round_robin_arbiter`             | Fair arbiter.                               |
