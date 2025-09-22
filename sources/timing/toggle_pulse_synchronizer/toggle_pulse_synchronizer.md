# Toggle Pulse Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Toggle Pulse Synchronizer                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![toggle_pulse_synchronizer](toggle_pulse_synchronizer.symbol.svg)

Resynchronizes a single-cycle pulse signal `pulse_in` from the source `source_clock` clock domain to the destination `destination_clock` domain using a toggle flip-flop mechanism. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The input pulse must be exactly one clock cycle wide and must be synchronous to the source clock.

Input pulses should be spaced sufficiently to allow the synchronization to complete and prevent overlapping of pulse events. The minimum spacing depends on the number of synchronization stages and the relative clock frequencies. This pulse resynchronizer requires less time between input pulses compared to the `feedback_pulse_synchronizer` variant, but doesn't provide a feedback to indicate when it is ready to accept a new pulse.

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

## Operation

The `toggle_pulse_synchronizer` module consists of three main components: a toggle flip-flop in the source domain, a standard synchronizer chain, and an edge detector in the destination domain. When `pulse_in` is asserted for one cycle, the toggle flip-flop changes state, creating a level transition. This state is then synchronized to the destination clock domain through `STAGES` D-type flip-flops.

In the destination domain, an edge detector monitors the synchronized state and generates a single-cycle pulse `pulse_out` whenever a state transition is detected (either rising or falling edge). This ensures that each input pulse generates exactly one output pulse, regardless of the relative timing of the source and destination clocks.

The toggle mechanism is essential because it converts the timing-critical pulse into a level that can be safely synchronized. The edge detector then reconstructs the pulse in the destination domain, maintaining the pulse semantics while crossing clock domains safely.

## Paths

| From       | To          | Type       | Comment                                                                        |
| ---------- | ----------- | ---------- | ------------------------------------------------------------------------------ |
| `pulse_in` | `pulse_out` | sequential | The pulse triggers a state change that propagates through `STAGES` flip-flops. |

The latency from `pulse_in` to `pulse_out` is `STAGES + 1` clock cycles of the `destination_clock` domain.

## Complexity

| Delay       | Gates       |
| ----------- | ----------- |
| `O(STAGES)` | `O(STAGES)` |

## Verification

The toggle pulse synchronizer is verified using a SystemVerilog testbench with multiple check sequences for different clock domain scenarios.

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

The constraints file `toggle_pulse_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set toggle_pulse_synchronizer_path "path/to/toggle_pulse_synchronizer"

::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance $toggle_pulse_synchronizer_path
```

The procedure applies a false-path to the input of the capture flop and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `toggle_pulse_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "toggle_pulse_synchronizer" "::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`toggle_pulse_synchronizer.v`](toggle_pulse_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`toggle_pulse_synchronizer.testbench.sv`](toggle_pulse_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`toggle_pulse_synchronizer.testbench.gtkw`](toggle_pulse_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Constraint script | [`toggle_pulse_synchronizer.sdc`](toggle_pulse_synchronizer.sdc)                       | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor | [`toggle_pulse_synchronizer.symbol.sss`](toggle_pulse_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`toggle_pulse_synchronizer.symbol.svg`](toggle_pulse_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`toggle_pulse_synchronizer.symbol.drawio`](toggle_pulse_synchronizer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`toggle_pulse_synchronizer.md`](toggle_pulse_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                                                                                      | Path                                                                     | Description                            |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | -------------------------------------- |
| [`toggle_flip_flop_with_reset`](../../flip_flop/toggle_flip_flop_with_reset/toggle_flip_flop_with_reset.md) | `omnicores-buildingblocks/sources/flip_flop/toggle_flip_flop_with_reset` | Toggle flip-flop for state conversion. |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                           | `omnicores-buildingblocks/sources/timing/synchronizer`                   | Basic single-bit synchronizer module.  |
| [`edge_detector`](../../pulse/edge_detector/edge_detector.md)                                               | `omnicores-buildingblocks/sources/pulse/edge_detector`                   | Edge detector for pulse regeneration.  |

## Related modules

| Module                                                                                                     | Path                                                                      | Comment                                                                      |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                          | `omnicores-buildingblocks/sources/timing/synchronizer`                    | Basic single-bit synchronizer.                                               |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                                           | `omnicores-buildingblocks/sources/timing/fast_synchronizer`               | A slightly faster synchronizer.                                              |
| [`registered_synchronizer`](../registered_synchronizer/registered_synchronizer.md)                         | `omnicores-buildingblocks/sources/timing/registered_synchronizer`         | Single-bit synchronizer with source domain registration to prevent glitches. |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                                     | `omnicores-buildingblocks/sources/timing/vector_synchronizer`             | Multi-bit synchronizer without source domain registration.                   |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md)    | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer`  | Multi-bit synchronizer with source domain registration.                      |
| [`gray_vector_synchronizer`](../gray_vector_synchronizer/gray_vector_synchronizer.md)                      | `omnicores-buildingblocks/sources/timing/gray_vector_synchronizer`        | Vector synchronizer using Gray encoding for incremental counters.            |
| [`closed_loop_vector_synchronizer`](../closed_loop_vector_synchronizer/closed_loop_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/closed_loop_vector_synchronizer` | Vector synchronizer with feedback for guaranteed atomic updates.             |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                                        | `omnicores-buildingblocks/sources/timing/reset_synchronizer`              | Synchronizer specifically for reset signals.                                 |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md)             | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer`     | Synchronizer for pulses using a feedback mechanism.                          |

