# Static Priority Stream Arbiter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Static Priority Stream Arbiter                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![static_priority_stream_arbiter](static_priority_stream_arbiter.symbol.svg)

Arbitrates between `NUMBER_STREAMS` valid-ready upstream streams and forwards the payload of the highest-priority valid channel to a single valid-ready downstream channel. The arbiter is not fair and a higher-indexed channel can be starved indefinitely if a lower-indexed channel is persistently valid. All outputs reflect the current inputs with no registered state, making the handshake propagate in a single cycle.

## Parameters

| Name             | Type    | Allowed Values | Default | Description                                            |
| ---------------- | ------- | -------------- | ------- | ------------------------------------------------------ |
| `PAYLOAD_WIDTH`  | integer | `>0`           | `8`     | Bit width of the payload data on each channel.         |
| `NUMBER_STREAMS` | integer | `>0`           | `4`     | Number of upstream channels competing for the arbiter. |

## Ports

| Name                 | Direction | Width                          | Clock        | Reset | Reset value | Description                                                                                                                   |
| -------------------- | --------- | ------------------------------ | ------------ | ----- | ----------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `upstream_valids`    | input     | `NUMBER_STREAMS`               | asynchronous |       |             | Valid signals from each upstream channel.<br/>• `1`: data is valid.<br/>• `0`: idle.                                          |
| `upstream_readys`    | output    | `NUMBER_STREAMS`               | asynchronous |       |             | Ready signals to each upstream channel.<br/>• `1`: channel is being granted.<br/>• `0`: not selected or downstream not ready. |
| `upstream_payloads`  | input     | `NUMBER_STREAMS×PAYLOAD_WIDTH` | asynchronous |       |             | Payload data from each upstream stream.                                                                                       |
| `downstream_valid`   | output    | 1                              | asynchronous |       |             | Valid signal to the downstream channel.                                                                                       |
| `downstream_ready`   | input     | 1                              | asynchronous |       |             | Ready signal from the downstream channel.                                                                                     |
| `downstream_payload` | output    | `PAYLOAD_WIDTH`                | asynchronous |       |             | Payload of the granted upstream stream.                                                                                       |

## Operation

The `static_priority_arbiter` receives the `upstream_valids` as requests and produces a one-hot `upstream_grant` that selects the lowest-indexed valid channel. The `downstream_valid` is the OR of all `upstream_valids`. The `upstream_readys` are gated by `downstream_ready`: when the downstream is ready, the grant vector is forwarded as the ready signals; otherwise all readys are deasserted. The `array_select` (configured in one-hot mode) uses the grant vector to select which `upstream_payloads` value drives `downstream_payload`.

Because the logic is entirely combinational, the handshake propagates in a single cycle: as soon as an upstream valid and the downstream ready are both asserted, the selected payload appears on `downstream_payload` and the corresponding `upstream_ready` is asserted.

## Paths

| From                | To                   | Type          | Comment                                                               |
| ------------------- | -------------------- | ------------- | --------------------------------------------------------------------- |
| `upstream_valids`   | `downstream_valid`   | combinational | Through OR reduction.                                                 |
| `upstream_valids`   | `upstream_readys`    | combinational | Through static priority arbiter and AND gate with `downstream_ready`. |
| `upstream_valids`   | `downstream_payload` | combinational | Through static priority arbiter and array select.                     |
| `upstream_payloads` | `downstream_payload` | combinational | Through array select, gated by the grant vector.                      |
| `downstream_ready`  | `upstream_readys`    | combinational | Direct AND gate with the grant vector.                                |

## Complexity

| Delay               | Gates                               |
| ------------------- | ----------------------------------- |
| `O(NUMBER_STREAMS)` | `O(NUMBER_STREAMS × PAYLOAD_WIDTH)` |

The critical path goes through the static priority arbiter (first-one detection) and the one-hot array select (AND-OR reduction chain). The default `"fast"` variant of the arbiter reduces the arbiter delay to `O(log₂ NUMBER_STREAMS)`, but the one-hot array select maintains a linear `O(NUMBER_STREAMS)` delay due to its serial OR chain.

## Verification

The static priority stream arbiter is verified using a SystemVerilog testbench that checks the arbiter's behaviour against a reference model using random stimulus.

The following table lists the checks performed by the testbench.

| Number | Check                          | Description                                                                                               |
| ------ | ------------------------------ | --------------------------------------------------------------------------------------------------------- |
| 1a     | downstream_valid assertion     | When any upstream channel is valid, `downstream_valid` must be asserted.                                  |
| 1b     | downstream_valid deassertion   | When no upstream channel is valid, `downstream_valid` must be deasserted.                                 |
| 1c     | upstream_readys gating         | When `downstream_ready` is low, all `upstream_readys` must be deasserted.                                 |
| 1d     | upstream_readys one-hot        | At most one `upstream_ready` can be asserted at any time.                                                 |
| 1e     | upstream_readys validity       | Only valid upstream channels can have their ready asserted.                                               |
| 1f     | upstream_readys correctness    | `upstream_readys` must match the expected pattern (lowest-indexed valid stream when downstream is ready). |
| 1g     | downstream_payload correctness | `downstream_payload` must match the payload of the highest-priority valid upstream stream.                |

The following table lists the parameter values verified by the testbench.

| `PAYLOAD_WIDTH` | `NUMBER_STREAMS` |           |
| --------------- | ---------------- | --------- |
| 8               | 4                | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type                | File                                                                                                     | Description                                         |
| ------------------- | -------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`static_priority_stream_arbiter.v`](static_priority_stream_arbiter.v)                                   | Verilog design.                                     |
| Testbench           | [`static_priority_stream_arbiter.testbench.sv`](static_priority_stream_arbiter.testbench.sv)             | SystemVerilog verification testbench.               |
| Waveform script     | [`static_priority_stream_arbiter.testbench.gtkw`](static_priority_stream_arbiter.testbench.gtkw)         | Script to load the waveforms in GTKWave.            |
| Design filelist     | [`static_priority_stream_arbiter.design.filelist`](static_priority_stream_arbiter.design.filelist)       | Filelist for synthesis and implementation.          |
| Design include list | [`static_priority_stream_arbiter.design.inclist`](static_priority_stream_arbiter.design.inclist)         | Include paths for the design.                       |
| Testbench filelist  | [`static_priority_stream_arbiter.testbench.filelist`](static_priority_stream_arbiter.testbench.filelist) | Filelist for simulation.                            |
| Testbench include   | [`static_priority_stream_arbiter.testbench.inclist`](static_priority_stream_arbiter.testbench.inclist)   | Include paths for the testbench.                    |
| Symbol descriptor   | [`static_priority_stream_arbiter.symbol.sss`](static_priority_stream_arbiter.symbol.sss)                 | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`static_priority_stream_arbiter.symbol.svg`](static_priority_stream_arbiter.symbol.svg)                 | Generated vector image of the symbol.               |
| Symbol shape        | [`static_priority_stream_arbiter.symbol.drawio`](static_priority_stream_arbiter.symbol.drawio)           | Generated DrawIO shape of the symbol.               |
| Makefile            | [`Makefile`](Makefile)                                                                                   | Build configuration.                                |
| Datasheet           | [`static_priority_stream_arbiter.md`](static_priority_stream_arbiter.md)                                 | Markdown documentation datasheet.                   |

## Dependencies

| Module                    | Path                                                               | Comment                                                   |
| ------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------- |
| `static_priority_arbiter` | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter` | Provides the fixed-priority grant vector.                 |
| `first_one`               | `omnicores-buildingblocks/sources/operations/first_one`            | Used by the static priority arbiter.                      |
| `fast_first_one`          | `omnicores-buildingblocks/sources/operations/fast_first_one`       | Default variant for the arbiter.                          |
| `small_first_one`         | `omnicores-buildingblocks/sources/operations/small_first_one`      | Area-optimized variant for the arbiter.                   |
| `shift_left`              | `omnicores-buildingblocks/sources/operations/shift_left`           | Used by the `fast_first_one` variant.                     |
| `array_select`            | `omnicores-buildingblocks/sources/array/array_select`              | Selects the payload of the granted stream (one-hot mode). |
| `clog2.vh`                | `omnicores-buildingblocks/sources/common/clog2.vh`                 | Used by `array_select` for width computation.             |

## Related modules

| Module                                                                                        | Path                                                               | Comment                                                      |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------ |
| [`static_priority_arbiter`](../../arbiter/static_priority_arbiter/static_priority_arbiter.md) | `omnicores-buildingblocks/sources/arbiter/static_priority_arbiter` | The arbiter core used internally.                            |
| [`stream_dispatcher`](../stream_dispatcher/stream_dispatcher.md)                              | `omnicores-buildingblocks/sources/stream/stream_dispatcher`        | Inverse operation: routes one stream to one of many outputs. |
| [`array_select`](../../array/array_select/array_select.md)                                    | `omnicores-buildingblocks/sources/array/array_select`              | Selects the granted payload from the array.                  |
