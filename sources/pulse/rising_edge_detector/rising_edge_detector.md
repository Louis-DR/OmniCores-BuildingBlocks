# Rising Edge Detector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Rising Edge Detector                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![rising_edge_detector](rising_edge_detector.symbol.svg)

Synchronous edge detector that generates a single-cycle pulse exclusively on the rising edges of an input signal. It provides reliable rising edge detection with one clock cycle latency, making it suitable for event detection and synchronization applications.

![rising_edge_detector](rising_edge_detector.wavedrom.svg)

## Parameters

This module has no parameters.

## Ports

| Name          | Direction | Width | Clock        | Reset    | Reset value | Description                                                                               |
| ------------- | --------- | ----- | ------------ | -------- | ----------- | ----------------------------------------------------------------------------------------- |
| `clock`       | input     | 1     | self         |          |             | Clock signal.                                                                             |
| `resetn`      | input     | 1     | asynchronous | self     | active-low  | Asynchronous active-low reset.                                                            |
| `signal`      | input     | 1     | `clock`      |          |             | Input signal to detect rising edges on.                                                   |
| `rising_edge` | output    | 1     | `clock`      | `resetn` | `0`         | Rising edge detection output.<br/>• `0`: no rising edge.<br/>• `1`: rising edge detected. |

## Operation

The rising edge detector operates by maintaining a registered copy of the input signal from the previous clock cycle. On each rising edge of the clock, the current input signal is compared with the previous value using AND logic with inverted previous signal. When the current signal is high and the previous signal was low, indicating a rising edge, a single-cycle pulse is generated on the `rising_edge` output.

The module has a one clock cycle latency between the input signal transition and the output pulse generation. This latency is inherent to the synchronous operation and ensures reliable edge detection synchronized to the clock domain.

During reset, the internal previous signal register is cleared to 0, ensuring a known initial state. If the input signal is high when coming out of reset, this will be detected as a rising edge on the first active clock cycle.

## Paths

| From     | To            | Type          | Comment                   |
| -------- | ------------- | ------------- | ------------------------- |
| `signal` | `rising_edge` | sequential    | Through delay register.   |
| `signal` | `rising_edge` | combinational | Through comparison logic. |

## Complexity

| Delay  | Gates  | Comment                                        |
| ------ | ------ | ---------------------------------------------- |
| `O(1)` | `O(1)` | Single AND gate and one flip-flop for storage. |

The critical timing path consists of the AND gate delay, making this a very fast operation. The module requires minimal hardware resources: one flip-flop for the signal delay and one AND gate for rising edge detection.

## Verification

The rising edge detector is verified using a SystemVerilog testbench with five check sequences that validate the rising edge detection functionality under various conditions.

The following table lists the checks performed by the testbench.

| Number | Check                        | Description                                                                           |
| ------ | ---------------------------- | ------------------------------------------------------------------------------------- |
| 1      | Reset state                  | Verifies the state after reset.                                                       |
| 2      | Rising edge detection        | Tests that a rising edge generates a single-cycle pulse.                              |
| 3      | No detection on falling edge | Tests that a falling edge does not generate any pulse.                                |
| 4      | Consecutive rising edges     | Verifies proper operation with alternating signal transitions.                        |
| 5      | Random stimulus              | Performs random signal changes and verifies edge detection against expected behavior. |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type                | File                                                                         | Description                                         |
| ------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`rising_edge_detector.v`](rising_edge_detector.v)                           | Verilog design.                                     |
| Testbench           | [`rising_edge_detector.testbench.sv`](rising_edge_detector.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script     | [`rising_edge_detector.testbench.gtkw`](rising_edge_detector.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor   | [`rising_edge_detector.symbol.sss`](rising_edge_detector.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`rising_edge_detector.symbol.svg`](rising_edge_detector.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape        | [`rising_edge_detector.symbol.drawio`](rising_edge_detector.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Waveform descriptor | [`rising_edge_detector.wavedrom.json`](rising_edge_detector.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`rising_edge_detector.wavedrom.svg`](rising_edge_detector.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`rising_edge_detector.md`](rising_edge_detector.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                       | Path                                                           | Comment                                                          |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------- | ---------------------------------------------------------------- |
| [`edge_detector`](../edge_detector/edge_detector.md)                         | `omnicores-buildingblocks/sources/pulse/edge_detector`         | Edge detector for both rising and falling edges.                 |
| [`falling_edge_detector`](../falling_edge_detector/falling_edge_detector.md) | `omnicores-buildingblocks/sources/pulse/falling_edge_detector` | Edge detector variant for falling edges only.                    |
| [`multi_edge_detector`](../multi_edge_detector/multi_edge_detector.md)       | `omnicores-buildingblocks/sources/pulse/multi_edge_detector`   | Edge detector with separate output for rising and falling edges. |
