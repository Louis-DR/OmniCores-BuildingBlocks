# Reset Synchronizer

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Reset Synchronizer                                                               |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![reset_synchronizer](reset_synchronizer.symbol.svg)

Resynchronizes the deassertion of an active-low reset signal `resetn_in` from an asynchronous or different clock domain to the destination `clock` domain using a chain of flip-flops. This helps prevent metastability issues when crossing clock domains. The number of flip-flop stages `STAGES` can be increased from the default two to three or more for even better MTBF. The synchronized signal must remain stable for at least one cycle of the destination `clock` to be correctly captured.

Compared to the standard `synchronizer`, this variant is adapted for active-low resets as only the deassertion (low-to-high transition) is resynchronized. The assertion (high-to-low transition) is asynchronous, thus allowing the reset to propagate even in the absence of a clock. When the destination clock starts running, the deassertion of the reset is propagated and the circuit can begin operation after as many cycles as `STAGES`, the number of synchronization stages.

To prevent glitches at the capture stage for the deassertion, there should be no combinational logic between the last flop in the source domain and the capture flop in the capture domain.

With the clock running before the deassertion :

![reset_synchronizer](reset_synchronizer_clockbefore.wavedrom.svg)

With the clock starting after the deassertion :

![reset_synchronizer](reset_synchronizer_clockafter.wavedrom.svg)

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                     |
| -------- | ------- | -------------- | ------- | ----------------------------------------------- |
| `STAGES` | integer | `≥1`           | `2`     | Number of flip-flop stages in the synchronizer. |

## Ports

| Name         | Direction | Width | Clock        | Reset       | Reset value | Description                                                    |
| ------------ | --------- | ----- | ------------ | ----------- | ----------- | -------------------------------------------------------------- |
| `clock`      | input     | 1     | self         |             |             | Destination clock domain for the synchronized signal.          |
| `resetn_in`  | input     | 1     | asynchronous | self        | active-low  | Asynchronous input active-low reset signal to be synchronized. |
| `resetn_out` | output    | 1     | `clock`      | `resetn_in` | `0`         | Synchronized output active-low reset signal to `clock`.        |

## Operation

The `reset_synchronizer` module consists of a chain of `STAGES` D-type flip-flops. The input `resetn_in` resets all the flops when low, which allows the reset to propagate asynchronously without the clock running. When the `clock` is running, on each rising edges, the deassertion of `resetn_in` is captured by the first flip-flop in the chain (called the capture stage). Subsequent flip-flops (called synchronization stages) capture the output of the preceding flip-flop in the chain, thus propagating the deassertion of the reset. The `resetn_out` signal is the output of the last flip-flop in the chain.

## Paths

| From        | To           | Type          | Comment                                                                               |
| ----------- | ------------ | ------------- | ------------------------------------------------------------------------------------- |
| `resetn_in` | `resetn_out` | combinational | The assertion (high-to-low) is asynchronous through the reset path of the flip-flops. |
| `resetn_in` | `resetn_out` | sequential    | The deassertion (low-to-high) propagates through `STAGES` flip-flops.                 |

The deassertion latency from `resetn_in` to `resetn_out` is `STAGES` clock cycles of the `clock` domain.

## Complexity

| Delay       | Gates       |
| ----------- | ----------- |
| `O(STAGES)` | `O(STAGES)` |

## Verification

The fast synchronizer is verified using a SystemVerilog testbench with a single check sequences.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                                |
| ------ | ----------- | ---------------------------------------------------------------------------------------------------------- |
| 1      | Random test | Toggles the `resetn_in` randomly and checks that it propagates with the expected delay and without glitch. |

The following table lists the parameter values verified by the testbench.

| `STAGES`    |
| ----------- |
| 2 (default) |

## Constraints

The constraints file `reset_synchronizer.sdc` contains the procedure `::omnicores::buildingblocks::timing::reset_synchronizer::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the synchronizer and applies constraints to it.

```tcl
set reset_synchronizer_path "path/to/reset_synchronizer"

::omnicores::buildingblocks::timing::reset_synchronizer::apply_constraints_to_instance $reset_synchronizer_path
```

The procedure applies a false-path to the input of the capture flop and a max-delay of 0 between the synchronization flops. The false-path tells the tool to not consider this timing path as this is clock-domain-crossing. The max-delay forces the tool to place the synchronization flops as close as possible to each other to minimize metastability. This max-delay of 0 will necessarily violate as it is impossible to meet, so the violation should be waived. Alternatively, the max-delay can be removed and replaced by special instructions for the place-ant-route tool.

To call the procedure automatically on all instances of the synchronizer, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `reset_synchronizer` and the constraints procedure `::omnicores::buildingblocks::timing::reset_synchronizer::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "reset_synchronizer" "::omnicores::buildingblocks::timing::reset_synchronizer::apply_constraints_to_instance"
```

## Deliverables

| Type                | File                                                                                           | Description                                         |
| ------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`reset_synchronizer.v`](reset_synchronizer.v)                                                 | Verilog design file.                                |
| Testbench           | [`reset_synchronizer.testbench.sv`](reset_synchronizer.testbench.sv)                           | SystemVerilog verification testbench.               |
| Waveform script     | [`reset_synchronizer.testbench.gtkw`](reset_synchronizer.testbench.gtkw)                       | Script to load the waveforms in GTKWave.            |
| Constraint script   | [`reset_synchronizer.sdc`](reset_synchronizer.sdc)                                             | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor   | [`reset_synchronizer.symbol.sss`](reset_synchronizer.symbol.sss)                               | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`reset_synchronizer.symbol.svg`](reset_synchronizer.symbol.svg)                               | Generated vector image of the symbol.               |
| Waveform descriptor | [`reset_synchronizer_clockbefore.wavedrom.json`](reset_synchronizer_clockbefore.wavedrom.json) | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`reset_synchronizer_clockbefore.wavedrom.svg`](reset_synchronizer_clockbefore.wavedrom.svg)   | Generated image of the waveform.                    |
| Waveform descriptor | [`reset_synchronizer_clockafter.wavedrom.json`](reset_synchronizer_clockafter.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`reset_synchronizer_clockafter.wavedrom.svg`](reset_synchronizer_clockafter.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`reset_synchronizer.md`](reset_synchronizer.md)                                               | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                                         | Path                                                                  | Comment                                             |
| ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------- |
| [`synchronizer`](../synchronizer/synchronizer.md)                                              | `omnicores-buildingblocks/sources/timing/synchronizer`                | Standard synchronizer for normal signals.           |
| [`vector_synchronizer`](../vector_synchronizer/vector_synchronizer.md)                         | `omnicores-buildingblocks/sources/timing/vector_synchronizer`         | Synchronizer for multi-bit data vectors.            |
| [`reset_synchronizer`](../reset_synchronizer/reset_synchronizer.md)                            | `omnicores-buildingblocks/sources/timing/reset_synchronizer`          | Synchronizer specifically for reset signals.        |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md) | `omnicores-buildingblocks/sources/timing/feedback_pulse_synchronizer` | Synchronizer for pulses using a feedback mechanism. |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)       | `omnicores-buildingblocks/sources/timing/toggle_pulse_synchronizer`   | Synchronizer for pulses using a toggle mechanism.   |
