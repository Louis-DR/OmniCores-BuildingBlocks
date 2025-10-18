# Saturating Counter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Saturating Counter                                                               |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![saturating_counter](saturating_counter.symbol.svg)

Synchronous counter that increments and decrements within a configurable range with saturation behavior. The counter prevents overflow and underflow by saturating at the minimum and maximum values instead of wrapping around, making it ideal for applications requiring bounded counting such as credit counters, buffer level indicators, branch prediction systems, or state machines with limited ranges.

The counter supports non-power-of-two range. Trying to increment and decrement within the same cycle is ignored and the count doesn't change.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                                                                       |
| ------------- | ------- | -------------- | ------- | --------------------------------------------------------------------------------- |
| `RANGE`       | integer | `≥2`           | `4`     | Counter range. Counter counts from `0` to `RANGE-1`.                              |
| `RESET_VALUE` | integer | `0 to RANGE-1` | `0`     | Initial counter value after reset. Must be within the valid range `[0, RANGE-1]`. |

## Ports

| Name        | Direction | Width         | Clock        | Reset    | Reset value   | Description                                                              |
| ----------- | --------- | ------------- | ------------ | -------- | ------------- | ------------------------------------------------------------------------ |
| `clock`     | input     | 1             | self         |          |               | Clock signal.                                                            |
| `resetn`    | input     | 1             | asynchronous | self     | active-low    | Asynchronous active-low reset.                                           |
| `decrement` | input     | 1             | `clock`      |          |               | Decrement control signal.<br/>• `0`: idle.<br/>• `1`: decrement counter. |
| `increment` | input     | 1             | `clock`      |          |               | Increment control signal.<br/>• `0`: idle.<br/>• `1`: increment counter. |
| `count`     | output    | `log₂(RANGE)` | `clock`      | `resetn` | `RESET_VALUE` | Current counter value.                                                   |

## Operation

The saturating counter maintains a count value within the range `[0, RANGE-1]`. On each rising edge of the clock, the counter responds to the increment and decrement control signals.

For **decrement operation**, when `decrement` is asserted and the counter is not at its minimum value (`0`), the counter decreases by 1. If the counter is already at the minimum value, asserting `decrement` has no effect, and the counter remains saturated at its lower boundary.

For **increment operation**, when `increment` is asserted and the counter is not at its maximum value (`RANGE-1`), the counter increases by 1. If the counter is already at the maximum value, asserting `increment` has no effect, and the counter remains saturated at its upper boundary.

The counter exhibits **saturation behavior** at both boundaries, preventing overflow when incrementing at maximum value or underflow when decrementing at minimum value. This makes it suitable for applications where maintaining bounded values is critical. If both `increment` and `decrement` are asserted simultaneously, the counter value is not changed.

The counter is reset to `RESET_VALUE` when `resetn` is asserted (active-low). The reset operation is asynchronous and takes precedence over all other operations.

## Paths

| From        | To      | Type       | Comment                                                   |
| ----------- | ------- | ---------- | --------------------------------------------------------- |
| `decrement` | `count` | sequential | Decrement control path through internal counter register. |
| `increment` | `count` | sequential | Increment control path through internal counter register. |

## Complexity

| Delay                | Gates           | Comment |
| -------------------- | --------------- | ------- |
| `O(log₂ log₂ RANGE)` | `O(log₂ RANGE)` |         |

The module requires `log₂(RANGE)` flip-flops for the counter register, plus small combinational logic for boundary detection and increment/decrement operations. The critical path includes the counter comparison logic and the increment/decrement arithmetic.

## Verification

The saturating counter is verified using a SystemVerilog testbench with four check sequences that validate the counter operations and boundary conditions.

The following table lists the checks performed by the testbench.

| Number | Check       | Description                                                                                               |
| ------ | ----------- | --------------------------------------------------------------------------------------------------------- |
| 1      | Reset value | Verifies that the counter initializes to the specified `RESET_VALUE` after reset.                         |
| 2      | Increment   | Tests incrementing from minimum to maximum value and verifies saturation at the upper boundary.           |
| 3      | Decrement   | Tests decrementing from maximum to minimum value and verifies saturation at the lower boundary.           |
| 4      | Random      | Performs random increment and decrement operations and verifies counter behavior against expected values. |

The following table lists the parameter values verified by the testbench.

| `RANGE` | `RESET_VALUE` |           |
| ------- | ------------- | --------- |
| 4       | 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                     | Description                                         |
| ----------------- | ------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`saturating_counter.v`](saturating_counter.v)                           | Verilog design.                                     |
| Testbench         | [`saturating_counter.testbench.sv`](saturating_counter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`saturating_counter.testbench.gtkw`](saturating_counter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`saturating_counter.symbol.sss`](saturating_counter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`saturating_counter.symbol.svg`](saturating_counter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`saturating_counter.symbol.drawio`](saturating_counter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`saturating_counter.md`](saturating_counter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module     | Path                                      | Comment                                         |
| ---------- | ----------------------------------------- | ----------------------------------------------- |
| `clog2.vh` | `omnicores-buildingblocks/sources/common` | Macro for calculating log₂ of parameter values. |

## Related modules

| Module                                                                                                        | Path                                                                        | Comment                                                 |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`hysteresis_saturating_counter`](../hysteresis_saturating_counter/hysteresis_saturating_counter.md)          | `omnicores-buildingblocks/sources/counter/hysteresis_saturating_counter`    | Saturating counter variant with hysteresis behavior.    |
| [`probabilistic_saturating_counter`](../probabilistic_saturating_counter/probabilistic_saturating_counter.md) | `omnicores-buildingblocks/sources/counter/probabilistic_saturating_counter` | Saturating counter variant with probabilistic behavior. |
| [`wrapping_counter`](../wrapping_counter/wrapping_counter.md)                                                 | `omnicores-buildingblocks/sources/counter/wrapping_counter`                 | Counter variant with wrapping behavior.                 |
