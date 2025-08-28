# Registered Vector Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Registered Vector Synchronizer                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![registered_vector_synchronizer](registered_vector_synchronizer.symbol.svg)

Registers a multi-bit vector signal `data_in` in its source `source_clock` clock domain and then resynchronizes it to the destination `destination_clock` domain using a chain of flip-flops. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The synchronized data must be synchronous to its clock and remain stable for at least one cycle of the destination `clock` to be correctly captured.

This module synchronizes inidivually each bit of the vector, ensuring proper clock domain crossing for multi-bit data. However, it doesn't guarantee that the synchonized data resolves its metastability at the same time, and that a simultaneous update of the input data results in an update of the output data in the same synchronization clock cycle. Therefore, this module may be used for synchronizing vector of unrelated bits, for encoding where only one bit flips between two clock cycles of the synchronization clock (Grey encoding), or when the logic around it takes into accound the impredictable delay of the individual bit updates.

The added source clock domain register (presynchronization stage) is useful to ensure stable glitch-free input to the synchronizer stages. This prevents combinational logic glitches in the source domain from affecting the clock domain crossing reliability. This variant is recommended when there might be combinational logic between the signal source and the synchronizer.

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                     |
| -------- | ------- | -------------- | ------- | ----------------------------------------------- |
| `WIDTH`  | integer | `≥1`           | `8`     | Width of the data vector to be synchronized.    |
| `STAGES` | integer | `≥1`           | `2`     | Number of flip-flop stages in the synchronizer. |

## Ports

| Name                 | Direction | Width   | Clock               | Reset                | Reset value | Description                                               |
| -------------------- | --------- | ------- | ------------------- | -------------------- | ----------- | --------------------------------------------------------- |
| `source_clock`       | input     | 1       | self                |                      |             | Source clock domain for the input signal.                 |
| `source_resetn`      | input     | 1       | `source_clock`      | self                 | active-low  | Asynchronous active-low reset for the source domain.      |
| `destination_clock`  | input     | 1       | self                |                      |             | Destination clock domain for the synchronized signal.     |
| `destination_resetn` | input     | 1       | `destination_clock` | self                 | active-low  | Asynchronous active-low reset for the destination domain. |
| `data_in`            | input     | `WIDTH` | `source_clock`      |                      |             | Input data vector from the source clock domain.           |
| `data_out`           | output    | `WIDTH` | `destination_clock` | `destination_resetn` | `0`         | Synchronized output data vector to `destination_clock`.   |

## Operation

The `registered_vector_synchronizer` module consists of a presynchronization flip-flop stage for each bit in the source clock domain followed by an instance of a `vector_synchronizer` in the destination clock domain. The presynchronization stage captures `data_in` on the rising edge of `source_clock`, providing a stable glitch-free vector signal for the subsequent synchronization stages.

This presynchronized vector then passes through the vector synchronizer, which consists of `WIDTH` instances of the basic `synchronizer` module, each handling one bit of the vector. Each bit is independently synchronized through `STAGES` D-type flip-flops in the destination clock domain.

On each rising edge of `destination_clock`, the presynchronized vector is captured by the first flip-flop in each synchronization chain (called the capture stage). Subsequent flip-flops (called synchronization stages) capture the output of the preceding flip-flop in the chain. The `data_out` signal is the output of the last flip-flop in each chain.

## Paths

| From      | To         | Type       | Comment                                                                                                     |
| --------- | ---------- | ---------- | ----------------------------------------------------------------------------------------------------------- |
| `data_in` | `data_out` | sequential | Each bit first passes through the presynchronization stage, then through `STAGES` flip-flops independently. |

The latency from `data_in` to `data_out` is one clock cycle of the `source_clock` domain plus `STAGES` clock cycles of the `destination_clock` domain, however it is not guaranteed that all bits are synchronized with the same latency.

## Complexity

| Delay       | Gates             |
| ----------- | ----------------- |
| `O(STAGES)` | `O(WIDTH×STAGES)` |

## Verification

The registered vector synchronizer is verified using a SystemVerilog testbench with a single check sequence.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                              |
| ------ | ----------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Random test | Changes the `data_in` randomly and checks that it propagates with the expected delay and without glitch. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `STAGES` |           |
| ------- | -------- | --------- |
| 8       | 2        | (default) |

## Constraints

The constraints file `registered_vector_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::registered_vector_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set registered_vector_synchronizer_path "path/to/registered_vector_synchronizer"

::omnicores::buildingblocks::timing::registered_vector_synchronizer::apply_constraints_to_instance $registered_vector_synchronizer_path
```

The procedure applies a false-path from the output of the presynchronization flops to the input of the capture flops and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `registered_vector_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::registered_vector_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "registered_vector_synchronizer" "::omnicores::buildingblocks::timing::registered_vector_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                                             | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`registered_vector_synchronizer.v`](registered_vector_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`registered_vector_synchronizer.testbench.sv`](registered_vector_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`registered_vector_synchronizer.testbench.gtkw`](registered_vector_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`registered_vector_synchronizer.symbol.sss`](registered_vector_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`registered_vector_synchronizer.symbol.svg`](registered_vector_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`registered_vector_synchronizer.symbol.drawio`](registered_vector_synchronizer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`registered_vector_synchronizer.md`](registered_vector_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                                                 | Path                                                          | Description                           |
| ---------------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------- |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/vector_synchronizer` | Multi-bit synchronizer module.        |
| [`synchronizer`](../synchronizer/synchronizer.md)                      | `omnicores-buildingblocks/sources/timing/synchronizer`        | Basic single-bit synchronizer module. |

## Related modules

| Module                                                                                         | Path                                                                  | Comment                                                                      |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                              | `omnicores-buildingblocks/sources/timing/synchronizer`                | Basic single-bit synchronizer.                                               |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                               | `omnicores-buildingblocks/sources/timing/fast_synchronizer`           | A slightly faster synchronizer.                                              |
| [`registered_synchronizer`](../registered_synchronizer/registered_synchronizer.md)             | `omnicores-buildingblocks/sources/timing/registered_synchronizer`     | Single-bit synchronizer with source domain registration to prevent glitches. |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                         | `omnicores-buildingblocks/sources/timing/vector_synchronizer`         | Multi-bit synchronizer without source domain registration.                   |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                            | `omnicores-buildingblocks/sources/timing/reset_synchronizer`          | Synchronizer specifically for reset signals.                                 |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md) | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer` | Synchronizer for pulses using a feedback mechanism.                          |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)       | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`   | Synchronizer for pulses using a toggle mechanism.                            |
