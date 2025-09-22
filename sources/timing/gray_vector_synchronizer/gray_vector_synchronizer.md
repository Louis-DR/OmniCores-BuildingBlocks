# Gray Vector Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Gray Vector Synchronizer                                                         |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![gray_vector_synchronizer](gray_vector_synchronizer.symbol.svg)

Resynchronizes an incremental multi-bit vector signal `data_in` from its source `source_clock` clock domain to the destination `destination_clock` domain using Gray encoding, a presynchronization stage, and a chain of flip-flops. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The synchronized data must be synchronous to its clock and remain stable for at least one cycle of the destination `clock` to be correctly captured.

This variant of the registered vector synchronizer is specifically designed for synchronizing binary vectors that change incrementally (by +1 or -1) between clock cycles. The Gray encoding ensures that only one bit changes between consecutive values, making it safe for clock domain crossing without the risk of multiple bits resolving metastability at different times. This is particularly useful for counters, pointers, and other incrementally changing values.

The added source clock domain register (presynchronization stage) is useful to ensure stable glitch-free input to the synchronizer stages. This prevents combinational logic glitches in the source domain from affecting the clock domain crossing reliability.

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

The `gray_vector_synchronizer` module consists of three stages: binary-to-Gray encoding, registered vector synchronization, and Gray-to-binary decoding. First, the input binary vector `data_in` is converted to Gray code using a `binary_to_gray` encoder. This Gray-coded vector is then passed through a `registered_vector_synchronizer` which registers it in the source domain and synchronizes it to the destination domain through `STAGES` flip-flops. Finally, the synchronized Gray-coded vector is converted back to binary using a `gray_to_binary` decoder.

The Gray encoding is crucial because it ensures that when the input data changes by ±1, only one bit of the Gray-coded representation changes. This eliminates the possibility of spurious intermediate values that could occur if multiple bits of a binary counter were to resolve metastability at different times during clock domain crossing.

## Paths

| From      | To         | Type       | Comment                                                                                                                              |
| --------- | ---------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `data_in` | `data_out` | sequential | The signal passes through binary-to-Gray encoding, presynchronization stage, then `STAGES` flip-flops, then Gray-to-binary decoding. |

The latency from `data_in` to `data_out` is one clock cycle of the `source_clock` domain plus `STAGES` clock cycles of the `destination_clock` domain.

## Complexity

| Delay       | Gates             |
| ----------- | ----------------- |
| `O(STAGES)` | `O(WIDTH×STAGES)` |

## Verification

The gray vector synchronizer is verified using a SystemVerilog testbench with a single check sequence.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                              |
| ------ | ----------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Random test | Changes the `data_in` randomly and checks that it propagates with the expected delay and without glitch. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `STAGES` |           |
| ------- | -------- | --------- |
| 8       | 2        | (default) |

## Constraints

The constraints file `gray_vector_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::gray_vector_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set gray_vector_synchronizer_path "path/to/gray_vector_synchronizer"

::omnicores::buildingblocks::timing::gray_vector_synchronizer::apply_constraints_to_instance $gray_vector_synchronizer_path
```

The procedure applies a false-path from the output of the presynchronization flops to the input of the capture flops and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `gray_vector_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::gray_vector_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "gray_vector_synchronizer" "::omnicores::buildingblocks::timing::gray_vector_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                                 | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`gray_vector_synchronizer.v`](gray_vector_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`gray_vector_synchronizer.testbench.sv`](gray_vector_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`gray_vector_synchronizer.testbench.gtkw`](gray_vector_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Constraint script | [`gray_vector_synchronizer.sdc`](gray_vector_synchronizer.sdc)                       | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor | [`gray_vector_synchronizer.symbol.sss`](gray_vector_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`gray_vector_synchronizer.symbol.svg`](gray_vector_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`gray_vector_synchronizer.symbol.drawio`](gray_vector_synchronizer.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`gray_vector_synchronizer.md`](gray_vector_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                                                                                  | Path                                                                     | Description                                             |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------- |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer` | Multi-bit synchronizer with source domain registration. |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                                  | `omnicores-buildingblocks/sources/timing/vector_synchronizer`            | Multi-bit synchronizer module.                          |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                       | `omnicores-buildingblocks/sources/timing/synchronizer`                   | Basic single-bit synchronizer module.                   |
| [`binary_to_gray`](../../encoding/gray/binary_to_gray.md)                                               | `omnicores-buildingblocks/sources/encoding/gray`                         | Binary to Gray code encoder.                            |
| [`gray_to_binary`](../../encoding/gray/gray_to_binary.md)                                               | `omnicores-buildingblocks/sources/encoding/gray`                         | Gray code to binary decoder.                            |

## Related modules

| Module                                                                                                     | Path                                                                      | Comment                                                                      |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                          | `omnicores-buildingblocks/sources/timing/synchronizer`                    | Basic single-bit synchronizer.                                               |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                                           | `omnicores-buildingblocks/sources/timing/fast_synchronizer`               | A slightly faster synchronizer.                                              |
| [`registered_synchronizer`](../registered_synchronizer/registered_synchronizer.md)                         | `omnicores-buildingblocks/sources/timing/registered_synchronizer`         | Single-bit synchronizer with source domain registration to prevent glitches. |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                                     | `omnicores-buildingblocks/sources/timing/vector_synchronizer`             | Multi-bit synchronizer without source domain registration.                   |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md)    | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer`  | Multi-bit synchronizer with source domain registration.                      |
| [`closed_loop_vector_synchronizer`](../closed_loop_vector_synchronizer/closed_loop_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/closed_loop_vector_synchronizer` | Vector synchronizer with feedback for guaranteed atomic updates.             |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                                        | `omnicores-buildingblocks/sources/timing/reset_synchronizer`              | Synchronizer specifically for reset signals.                                 |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md)             | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer`     | Synchronizer for pulses using a feedback mechanism.                          |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)                   | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`       | Synchronizer for pulses using a toggle mechanism.                            |

