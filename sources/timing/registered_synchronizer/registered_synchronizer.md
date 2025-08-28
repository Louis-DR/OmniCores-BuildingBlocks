# Registered Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Registered Synchronizer                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![registered_synchronizer](registered_synchronizer.symbol.svg)

Registers a single-bit signal `data_in` in its source `source_clock` clock domain and then resynchronizes it to the destination `destination_clock` domain using a chain of flip-flops. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The synchronized signal must be synchronous to its clock and remain stable for at least one cycle of the destination `clock` to be correctly captured.

The added source clock domain register (presynchronization stage) is useful to ensure stable glitch-free input to the synchronizer stages. This prevents combinational logic glitches in the source domain from affecting the clock domain crossing reliability. This variant is recommended when there might be combinational logic between the signal source and the synchronizer.

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
| `data_in`            | input     | 1     | `source_clock`      |                      |             | Input data signal from the source clock domain.           |
| `data_out`           | output    | 1     | `destination_clock` | `destination_resetn` | `0`         | Synchronized output data signal to `destination_clock`.   |

## Operation

The `registered_synchronizer` module consists of a presynchronization flip-flop in the source clock domain followed by a chain of `STAGES` D-type flip-flops in the destination clock domain. The presynchronization stage captures `data_in` on the rising edge of `source_clock`, providing a stable glitch-free signal for the subsequent synchronization stages. This presynchronized signal then passes through the standard synchronizer chain clocked by `destination_clock`.

On each rising edge of `destination_clock`, the presynchronized signal is captured by the first flip-flop in the synchronization chain (called the capture stage). Subsequent flip-flops (called synchronization stages) capture the output of the preceding flip-flop in the chain. The `data_out` signal is the output of the last flip-flop in the synchronization chain.

## Paths

| From      | To         | Type       | Comment                                                                                         |
| --------- | ---------- | ---------- | ----------------------------------------------------------------------------------------------- |
| `data_in` | `data_out` | sequential | The signal first passes through the presynchronization stage, then through `STAGES` flip-flops. |

The latency from `data_in` to `data_out` is 1 clock cycle of the `source_clock` domain plus `STAGES` clock cycles of the `destination_clock` domain.

## Complexity

| Delay       | Gates       |
| ----------- | ----------- |
| `O(STAGES)` | `O(STAGES)` |

## Verification

The registered synchronizer is verified using a SystemVerilog testbench with a single check sequence.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                              |
| ------ | ----------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Random test | Toggles the `data_in` randomly and checks that it propagates with the expected delay and without glitch. |

The following table lists the parameter values verified by the testbench.

| `STAGES`    |
| ----------- |
| 2 (default) |

## Constraints

The constraints file `registered_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::registered_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set registered_synchronizer_path "path/to/registered_synchronizer"

::omnicores::buildingblocks::timing::registered_synchronizer::apply_constraints_to_instance $registered_synchronizer_path
```

The procedure applies a false-path from the output of the presynchronization flop to the input of the capture flop and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `registered_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::registered_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "registered_synchronizer" "::omnicores::buildingblocks::timing::registered_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`registered_synchronizer.v`](registered_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`registered_synchronizer.testbench.sv`](registered_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`registered_synchronizer.testbench.gtkw`](registered_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`registered_synchronizer.symbol.sss`](registered_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`registered_synchronizer.symbol.svg`](registered_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`registered_synchronizer.symbol.drawio`](registered_synchronizer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`registered_synchronizer.md`](registered_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                            | Path                                                   | Description                           |
| ------------------------------------------------- | ------------------------------------------------------ | ------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md) | `omnicores-buildingblocks/sources/timing/synchronizer` | Basic single-bit synchronizer module. |

## Related modules

| Module                                                                                                  | Path                                                                     | Comment                                                                  |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                       | `omnicores-buildingblocks/sources/timing/synchronizer`                   | Basic single-bit synchronizer without source domain registration.        |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                                        | `omnicores-buildingblocks/sources/timing/fast_synchronizer`              | A slightly faster synchronizer.                                          |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                                  | `omnicores-buildingblocks/sources/timing/vector_synchronizer`            | Synchronizer for multi-bit data vectors.                                 |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer` | Vector synchronizer with source domain registration to prevent glitches. |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                                     | `omnicores-buildingblocks/sources/timing/reset_synchronizer`             | Synchronizer specifically for reset signals.                             |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md)          | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer`    | Synchronizer for pulses using a feedback mechanism.                      |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)                | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`      | Synchronizer for pulses using a toggle mechanism.                        |
