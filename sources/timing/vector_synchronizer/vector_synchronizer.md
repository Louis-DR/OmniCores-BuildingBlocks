# Vector Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Vector Synchronizer                                                              |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![vector_synchronizer](vector_synchronizer.symbol.svg)

Resynchronizes a multi-bit vector signal `data_in` from an asynchronous or different clock domain to the destination `clock` domain using a chain of flip-flops. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages can be increased from the default two to three or more for even better MTBF. The synchronized data must remain stable for at least one cycle of the destination `clock` to be correctly captured.

This module synchronizes inidivually each bit of the vector, ensuring proper clock domain crossing for multi-bit data. However, it doesn't guarantee that the synchonized data resolves its metastability at the same time, and that a simultaneous update of the input data results in an update of the output data in the same synchronization clock cycle. Therefore, this module may be used for synchronizing vector of unrelated bits, for encoding where only one bit flips between two clock cycles of the synchronization clock (Grey encoding), or when the logic around it takes into accound the impredictable delay of the individual bit updates.

To prevent glitches at the capture stage, there should be no combinational logic between the last stage of flops in the source domain and the capture stage in the capture domain. The variant `registered_vector_synchronizer` adds a built-in flop stage in the source domain to ensure this.

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                     |
| -------- | ------- | -------------- | ------- | ----------------------------------------------- |
| `WIDTH`  | integer | `≥1`           | `8`     | Width of the data vector to be synchronized.    |
| `STAGES` | integer | `≥1`           | `2`     | Number of flip-flop stages in the synchronizer. |

## Ports

| Name       | Direction | Width   | Clock        | Reset    | Reset value | Description                                           |
| ---------- | --------- | ------- | ------------ | -------- | ----------- | ----------------------------------------------------- |
| `clock`    | input     | 1       | self         |          |             | Destination clock domain for the synchronized signal. |
| `resetn`   | input     | 1       | `clock`      | self     | active-low  | Asynchronous active-low reset.                        |
| `data_in`  | input     | `WIDTH` | asynchronous |          |             | Asynchronous input data vector to be synchronized.    |
| `data_out` | output    | `WIDTH` | `clock`      | `resetn` | `0`         | Synchronized output data vector to `clock`.           |

## Operation

The `vector_synchronizer` module consists of `WIDTH` instances of the basic `synchronizer` module, each handling one bit of the vector. Each bit is independently synchronized through `STAGES` D-type flip-flops. On each rising edge of `clock`, the value of each bit in `data_in` is captured by the first flip-flop in the chain (called the capture stage). Subsequent flip-flops (called synchronization stages) capture the output of the preceding flip-flop in the chain. The `data_out` signal is the output of the last flip-flop in each chain.

## Paths

| From      | To         | Type       | Comment                                                        |
| --------- | ---------- | ---------- | -------------------------------------------------------------- |
| `data_in` | `data_out` | sequential | Each bit propagates through `STAGES` flip-flops independently. |

The latency from `data_in` to `data_out` is `STAGES` clock cycles of the `clock` domain, however it is not guaranteed that all bits are synchronized with the same latency.

## Complexity

| Delay       | Gates             |
| ----------- | ----------------- |
| `O(STAGES)` | `O(WIDTH×STAGES)` |

## Verification

The vector synchronizer is verified using a SystemVerilog testbench with a single check sequence.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                              |
| ------ | ----------- | -------------------------------------------------------------------------------------------------------- |
| 1      | Random test | Changes the `data_in` randomly and checks that it propagates with the expected delay and without glitch. |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `STAGES` |           |
| ------- | -------- | --------- |
| 8       | 2        | (default) |

## Constraints

The constraints file `vector_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set vector_synchronizer_path "path/to/vector_synchronizer"

::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance $vector_synchronizer_path
```

The procedure applies a false-path to the input of the capture flops and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `vector_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "vector_synchronizer" "::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type              | File                                                                       | Description                                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`vector_synchronizer.v`](vector_synchronizer.v)                           | Verilog design file.                                |
| Testbench         | [`vector_synchronizer.testbench.sv`](vector_synchronizer.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`vector_synchronizer.testbench.gtkw`](vector_synchronizer.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Constraint script | [`vector_synchronizer.sdc`](vector_synchronizer.sdc)                       | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor | [`vector_synchronizer.symbol.sss`](vector_synchronizer.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`vector_synchronizer.symbol.svg`](vector_synchronizer.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`vector_synchronizer.md`](vector_synchronizer.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module depends on the following external modules:

| Module                                            | Path                                                   | Description                           |
| ------------------------------------------------- | ------------------------------------------------------ | ------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md) | `omnicores-buildingblocks/sources/timing/synchronizer` | Basic single-bit synchronizer module. |

## Related modules

| Module                                                                                                  | Path                                                                     | Comment                                                                           |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                                       | `omnicores-buildingblocks/sources/timing/synchronizer`                   | Basic single-bit synchronizer.                                                    |
| [`fast_synchronizer`](../fast_synchronizer/fast_synchronizer.md)                                        | `omnicores-buildingblocks/sources/timing/fast_synchronizer`              | A slightly faster synchronizer.                                                   |
| [`registered_synchronizer`](../registered_synchronizer/registered_synchronizer.md)                      | `omnicores-buildingblocks/sources/timing/registered_synchronizer`        | Synchronizer variant with a final stage in the source domain to prevent glitches. |
| [`registered_vector_synchronizer`](../registered_vector_synchronizer/registered_vector_synchronizer.md) | `omnicores-buildingblocks/sources/timing/registered_vector_synchronizer` | Vector synchronizer with source domain registration to prevent glitches.          |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                                     | `omnicores-buildingblocks/sources/timing/reset_synchronizer`             | Synchronizer specifically for reset signals.                                      |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md)          | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer`    | Synchronizer for pulses using a feedback mechanism.                               |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)                | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`      | Synchronizer for pulses using a toggle mechanism.                                 |
