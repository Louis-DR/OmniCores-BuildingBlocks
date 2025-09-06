# Feedback Pulse Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Feedback Pulse Synchronizer                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![feedback_pulse_synchronizer](feedback_pulse_synchronizer.symbol.svg)

Resynchronizes a single-cycle pulse signal `pulse_in` from the source `source_clock` clock domain to the destination `destination_clock` domain using a feedback mechanism to provide busy indication. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The input pulse must be exactly one clock cycle wide and must be synchronous to the source clock.

When a pulse is being resynchronized, the device is busy and no other input pulse can be received. The `busy` output signal can be used by upstream logic to prevent new pulses when the synchronizer is not ready. This pulse resynchronizer requires more time between input pulses compared to the `toggle_pulse_synchronizer` variant because it needs to resynchronize the feedback, but does provide the feedback to indicate when it is ready to receive a new pulse.

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                     |
| -------- | ------- | -------------- | ------- | ----------------------------------------------- |
| `STAGES` | integer | `≥1`           | `2`     | Number of flip-flop stages in the synchronizer. |

## Ports

| Name                 | Direction | Width | Clock               | Reset                | Reset value | Description                                               |
| -------------------- | --------- | ----- | ------------------- | -------------------- | ----------- | --------------------------------------------------------- |
| `source_clock`       | input     | 1     | self                |                      |             | Source clock domain for the input signal.                 |
| `source_resetn`      | input     | 1     | `source_clock`      | self                 | active-low  | Asynchronous active-low reset for the source domain.      |
| `destination_clock`  | input     | 1     | self                |                      |             | Destination clock domain for the synchronized signal.     |
| `destination_resetn` | input     | 1     | `destination_clock` | self                 | active-low  | Asynchronous active-low reset for the destination domain. |
| `pulse_in`           | input     | 1     | `source_clock`      |                      |             | Input pulse signal from the source clock domain.          |
| `pulse_out`          | output    | 1     | `destination_clock` | `destination_resetn` | `0`         | Synchronized output pulse signal to `destination_clock`.  |
| `busy`               | output    | 1     | `source_clock`      | `source_resetn`      | `0`         | Busy signal indicating synchronization in progress.       |

## Operation

The `feedback_pulse_synchronizer` module consists of four main components: a set-reset flip-flop in the source domain, a forward synchronizer chain, a rising edge detector in the destination domain, and a feedback synchronizer. When `pulse_in` is asserted for one cycle, the set-reset flip-flop is set, creating a stable level that represents the pending pulse.

This state is synchronized to the destination clock domain through `STAGES` D-type flip-flops. In the destination domain, a rising edge detector monitors the synchronized state and generates a single-cycle pulse `pulse_out` when the state transitions from low to high. Simultaneously, the synchronized state is fed back through another synchronizer to the source domain.

When the feedback reaches the source domain, it resets the set-reset flip-flop, clearing the pending state. The `busy` signal is derived from the logical OR of the source state and the feedback signal, ensuring it remains active during the entire synchronization process. This guarantees that no new pulses can be accepted until the current synchronization is completely finished.

## Paths

| From       | To          | Type       | Comment                                                                                          |
| ---------- | ----------- | ---------- | ------------------------------------------------------------------------------------------------ |
| `pulse_in` | `pulse_out` | sequential | The pulse sets a state that propagates through `STAGES` flip-flops to generate the output pulse. |
| `pulse_in` | `busy`      | sequential | The pulse immediately sets the busy signal which remains active until feedback is received.      |

The latency from `pulse_in` to `pulse_out` is `STAGES + 1` clock cycles of the `destination_clock` domain. The busy signal duration is approximately `2×STAGES + 2` clock cycles.

## Complexity

| Delay       | Gates         |
| ----------- | ------------- |
| `O(STAGES)` | `O(2×STAGES)` |

## Verification

The feedback pulse synchronizer is verified using a SystemVerilog testbench with multiple check sequences for different clock domain scenarios.

The following table lists the checks performed by the testbench.

| Number | Check               | Description                                                                          |
| ------ | ------------------- | ------------------------------------------------------------------------------------ |
| 1      | Same frequency test | Verifies pulse propagation between clock domains of the same frequency.              |
| 2      | Fast to slow test   | Verifies pulse propagation from a faster source clock to a slower destination clock. |
| 3      | Slow to fast test   | Verifies pulse propagation from a slower source clock to a faster destination clock. |

The following table lists the parameter values verified by the testbench.

| `STAGES` |           |
| -------- | --------- |
| 1        |           |
| 2        | (default) |
| 3        |           |
| 4        |           |
| 5        |           |

## Constraints

The constraints file `feedback_pulse_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::feedback_pulse_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set feedback_pulse_synchronizer_path "path/to/feedback_pulse_synchronizer"

::omnicores::buildingblocks::timing::feedback_pulse_synchronizer::apply_constraints_to_instance $feedback_pulse_synchronizer_path
```

The procedure applies a false-path to the input of the capture flops for both forward and feedback synchronizers and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider these timing paths as they are clock-domain-crossings. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `feedback_pulse_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::feedback_pulse_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "feedback_pulse_synchronizer" "::omnicores::buildingblocks::timing::feedback_pulse_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                                       | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`feedback_pulse_synchronizer.v`](feedback_pulse_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`feedback_pulse_synchronizer.testbench.sv`](feedback_pulse_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`feedback_pulse_synchronizer.testbench.gtkw`](feedback_pulse_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Constraint script | [`feedback_pulse_synchronizer.sdc`](feedback_pulse_synchronizer.sdc)                       | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor | [`feedback_pulse_synchronizer.symbol.sss`](feedback_pulse_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`feedback_pulse_synchronizer.symbol.svg`](feedback_pulse_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`feedback_pulse_synchronizer.symbol.drawio`](feedback_pulse_synchronizer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`feedback_pulse_synchronizer.md`](feedback_pulse_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                                                                                               | Path                                                                        | Description                                  |
| -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | -------------------------------------------- |
| [`set_reset_flip_flop_with_reset`](../../flip_flop/set_reset_flip_flop_with_reset/set_reset_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/set_reset_flip_flop_with_reset` | Set-reset flip-flop for pulse latching.      |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                                    | `omnicores-buildingblocks/sources/timing/synchronizer`                      | Basic single-bit synchronizer module.        |
| [`rising_edge_detector`](../../pulse/rising_edge_detector/rising_edge_detector.md)                                   | `omnicores-buildingblocks/sources/pulse/rising_edge_detector`               | Rising edge detector for pulse regeneration. |

## Related modules

| Module                                                                                                     | Path                                                                      | Comment                                                                      |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                          | `omnicores-buildingblocks/sources/timing/synchronizer`                    | Basic single-bit synchronizer.                                               |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                                           | `omnicores-buildingblocks/sources/timing/fast_synchronizer`               | A slightly faster synchronizer.                                              |
| [`registered_synchronizer`](../registered_synchronizer/registered_synchronizer.md)                         | `omnicores-buildingblocks/sources/timing/registered_synchronizer`         | Single-bit synchronizer with source domain registration to prevent glitches. |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                                     | `omnicores-buildingblocks/sources/timing/vector_synchronizer`             | Multi-bit synchronizer without source domain registration.                   |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md)    | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer`  | Multi-bit synchronizer with source domain registration.                      |
| [`grey_vector_synchronizer`](../grey_vector_synchronizer/grey_vector_synchronizer.md)                      | `omnicores-buildingblocks/sources/timing/grey_vector_synchronizer`        | Vector synchronizer using Grey encoding for incremental counters.            |
| [`closed_loop_vector_synchronizer`](../closed_loop_vector_synchronizer/closed_loop_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/closed_loop_vector_synchronizer` | Vector synchronizer with feedback for guaranteed atomic updates.             |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                                        | `omnicores-buildingblocks/sources/timing/reset_synchronizer`              | Synchronizer specifically for reset signals.                                 |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)                   | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`       | Synchronizer for pulses using a toggle mechanism.                            |

