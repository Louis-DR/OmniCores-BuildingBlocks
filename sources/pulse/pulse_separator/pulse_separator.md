# Pulse Separator

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Pulse Separator                                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![pulse_separator](pulse_separator.symbol.svg)

Pulse separator that converts multi-cycle input pulses into a series of single-cycle output pulses. For instance, a four-cycle long input pulse results in four successive one-cycle output pulses. It uses an internal counter to track how many pulses to generate and provides a busy signal for backpressure when the counter saturates. The module can only generate pulses at half the clock frequency due to its alternating output pattern.

![pulse_separator](pulse_separator.wavedrom.svg)

## Parameters

| Name                  | Type    | Allowed Values | Default | Description                                  |
| --------------------- | ------- | -------------- | ------- | -------------------------------------------- |
| `PULSE_COUNTER_WIDTH` | integer | `≥1`           | `3`     | Width of the internal pulse counter in bits. |

## Ports

| Name        | Direction | Width | Clock        | Reset    | Reset value | Description                                    |
| ----------- | --------- | ----- | ------------ | -------- | ----------- | ---------------------------------------------- |
| `clock`     | input     | 1     | self         |          |             | Clock signal.                                  |
| `resetn`    | input     | 1     | asynchronous | self     | active-low  | Asynchronous active-low reset.                 |
| `pulse_in`  | input     | 1     | `clock`      |          |             | Input pulse signal to be separated.            |
| `pulse_out` | output    | 1     | `clock`      | `resetn` | `0`         | Separated single-cycle pulse output.           |
| `busy`      | output    | 1     | `clock`      | `resetn` | `0`         | Backpressure signal when counter is saturated. |

## Operation

The pulse separator operates using an internal counter that tracks the number of pending output pulses to generate. When an input pulse is detected, the counter is incremented. The output alternates between active and inactive on each clock cycle when the counter is non-zero, generating single-cycle pulses. The counter decrements each time an output pulse is generated.

When an input pulse arrives while the counter is already counting, the counter increments further, queuing additional output pulses. If the counter reaches its maximum value (saturation), the busy signal is asserted to indicate backpressure, signaling that no more input pulses can be accepted until some output pulses are generated.

## Paths

| From       | To          | Type       | Comment                |
| ---------- | ----------- | ---------- | ---------------------- |
| `pulse_in` | `pulse_out` | sequential | Through counter logic. |
| `pulse_in` | `busy`      | sequential | Through counter logic. |

## Complexity

| Delay                         | Gates                    | Comment                                                      |
| ----------------------------- | ------------------------ | ------------------------------------------------------------ |
| `O(log₂ PULSE_COUNTER_WIDTH)` | `O(PULSE_COUNTER_WIDTH)` | Counter register, increment/decrement logic, and comparison. |

The critical timing path consists of the counter arithmetic and comparison logic. The module requires `PULSE_COUNTER_WIDTH` flip-flops for the counter register plus associated increment/decrement logic and saturation detection.

## Verification

The pulse separator is verified using a SystemVerilog testbench with five check sequences that validate the pulse separation functionality under various conditions.

The following table lists the checks performed by the testbench.

| Number | Check                        | Description                                                                         |
| ------ | ---------------------------- | ----------------------------------------------------------------------------------- |
| 1      | Single one-cycle pulse       | Tests that a single-cycle input pulse generates a single-cycle output pulse.        |
| 2      | Single multi-cycle pulse     | Tests that a multi-cycle input pulse generates multiple single-cycle output pulses. |
| 3      | Multiple single-cycle pulses | Tests multiple short input pulses and verifies proper pulse separation behavior.    |
| 4      | Saturating pulse             | Tests counter saturation behavior and busy signal generation.                       |
| 5      | Random stimulus              | Performs random input pulse generation with backpressure handling.                  |

The following table lists the parameter values verified by the testbench.

| `PULSE_COUNTER_WIDTH` |           |
| --------------------- | --------- |
| 3                     | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type                | File                                                               | Description                                         |
| ------------------- | ------------------------------------------------------------------ | --------------------------------------------------- |
| Design              | [`pulse_separator.v`](pulse_separator.v)                           | Verilog design.                                     |
| Testbench           | [`pulse_separator.testbench.sv`](pulse_separator.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script     | [`pulse_separator.testbench.gtkw`](pulse_separator.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor   | [`pulse_separator.symbol.sss`](pulse_separator.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`pulse_separator.symbol.svg`](pulse_separator.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape        | [`pulse_separator.symbol.drawio`](pulse_separator.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Waveform descriptor | [`pulse_separator.wavedrom.json`](pulse_separator.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`pulse_separator.wavedrom.svg`](pulse_separator.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`pulse_separator.md`](pulse_separator.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                                         | Path                                                                 | Comment                                                          |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [`fast_pulse_separator`](../fast_pulse_separator/fast_pulse_separator.md)                      | `omnicores-buildingblocks/sources/pulse/fast_pulse_separator`        | Faster variant of the pulse separator.                           |
| [`pulse_extender`](../pulse_extender/pulse_extender.md)                                        | `omnicores-buildingblocks/sources/pulse/pulse_extender`              | Extends pulse duration to a configurable number of clock cycles. |
| [`edge_detector`](../edge_detector/edge_detector.md)                                           | `omnicores-buildingblocks/sources/pulse/edge_detector`               | Edge detector for both rising and falling edges combined.        |
| [`toggle_pulse_synchronizer`](../toggle_pulse_synchronizer/toggle_pulse_synchronizer.md)       | `omnicores-buildingblocks/sources/pulse/toggle_pulse_synchronizer`   | Synchronizes pulses across clock domains using toggle flip-flop. |
| [`feedback_pulse_synchronizer`](../feedback_pulse_synchronizer/feedback_pulse_synchronizer.md) | `omnicores-buildingblocks/sources/pulse/feedback_pulse_synchronizer` | Synchronizes pulses across clock domains using feedback.         |
