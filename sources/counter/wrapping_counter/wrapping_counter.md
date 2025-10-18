# Wrapping Counter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Wrapping Counter                                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![wrapping_counter](wrapping_counter.symbol.svg)

Synchronous bidirectional counter that increments and decrements within a configurable range with wrapping behavior. The counter provides overflow and underflow wrapping, allowing it to cycle continuously through its range, making it ideal for applications requiring circular counting such as ring buffer indexing, state machine counters, or modular arithmetic operations.

The counter supports both power-of-2 and non-power-of-2 ranges with optimized implementations for each case. Trying to increment and decrement within the same cycle is ignored and the count doesn't change.

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

The wrapping counter maintains a count value within the range `[0, RANGE-1]`. On each rising edge of the clock, the counter responds to the increment and decrement control signals.

For **decrement operation**, when `decrement` is asserted and the counter is not at its minimum value (`0`), the counter decreases by 1. If the counter is at the minimum value, asserting `decrement` causes the counter to wrap around to the maximum value (`RANGE-1`).

For **increment operation**, when `increment` is asserted and the counter is not at its maximum value (`RANGE-1`), the counter increases by 1. If the counter is at the maximum value, asserting `increment` causes the counter to wrap around to the minimum value (`0`).

The counter exhibits **wrapping behavior** at both boundaries, providing overflow wrapping when incrementing at maximum value and underflow wrapping when decrementing at minimum value. This makes it suitable for applications requiring circular or modular counting behavior. If both `increment` and `decrement` are asserted simultaneously, the counter value is not changed.

The implementation is optimized for different range types. For power-of-2 ranges, the wrapping behavior is automatic due to the natural overflow of binary arithmetic. For non-power-of-2 ranges, explicit boundary detection and wrapping logic is implemented to ensure correct modular behavior.

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

The module requires `log₂(RANGE)` flip-flops for the counter register, plus combinational logic for boundary detection (in non-power-of-2 cases) and increment/decrement operations. For power-of-2 ranges, the implementation is more efficient as it leverages natural binary overflow behavior. The critical path includes the counter comparison logic (for non-power-of-2 ranges) and the increment/decrement arithmetic.

## Verification

The wrapping counter is verified using a SystemVerilog testbench with eight check sequences that validate the counter operations, boundary conditions, and wrapping behavior.

The following table lists the checks performed by the testbench.

| Number | Check                      | Description                                                                                               |
| ------ | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| 1      | Reset value                | Verifies that the counter initializes to the specified `RESET_VALUE` after reset.                         |
| 2      | Increment without wrapping | Tests incrementing from minimum towards maximum value without reaching the boundary.                      |
| 3      | Increment with wrapping    | Tests increment wrapping behavior from maximum value back to minimum value.                               |
| 4      | Decrement with wrapping    | Tests decrement wrapping behavior from minimum value back to maximum value.                               |
| 5      | Decrement without wrapping | Tests decrementing from maximum towards minimum value without reaching the boundary.                      |
| 6      | Full cycle increment       | Tests a complete increment cycle through all values and verifies return to starting point.                |
| 7      | Full cycle decrement       | Tests a complete decrement cycle through all values and verifies return to starting point.                |
| 8      | Random                     | Performs random increment and decrement operations and verifies counter behavior against expected values. |

The following table lists the parameter values verified by the testbench.

| `RANGE` | `RESET_VALUE` |           |
| ------- | ------------- | --------- |
| 4       | 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                 | Description                                         |
| ----------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`wrapping_counter.v`](wrapping_counter.v)                           | Verilog design.                                     |
| Testbench         | [`wrapping_counter.testbench.sv`](wrapping_counter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`wrapping_counter.testbench.gtkw`](wrapping_counter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`wrapping_counter.symbol.sss`](wrapping_counter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`wrapping_counter.symbol.svg`](wrapping_counter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`wrapping_counter.symbol.drawio`](wrapping_counter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`wrapping_counter.md`](wrapping_counter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module     | Path                                      | Comment                                         |
| ---------- | ----------------------------------------- | ----------------------------------------------- |
| `clog2.vh` | `omnicores-buildingblocks/sources/common` | Macro for calculating log₂ of parameter values. |

## Related modules

| Module                                                                                                        | Path                                                                        | Comment                                                 |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`wrapping_increment_counter`](../wrapping_increment_counter/wrapping_increment_counter.md)                   | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter`       | Increment-only variant with wrapping behavior.          |
| [`wrapping_decrement_counter`](../wrapping_decrement_counter/wrapping_decrement_counter.md)                   | `omnicores-buildingblocks/sources/counter/wrapping_decrement_counter`       | Decrement-only variant with wrapping behavior.          |
| [`saturating_counter`](../saturating_counter/saturating_counter.md)                                           | `omnicores-buildingblocks/sources/counter/saturating_counter`               | Counter variant with saturating behavior.               |
| [`hysteresis_saturating_counter`](../hysteresis_saturating_counter/hysteresis_saturating_counter.md)          | `omnicores-buildingblocks/sources/counter/hysteresis_saturating_counter`    | Saturating counter variant with hysteresis behavior.    |
| [`probabilistic_saturating_counter`](../probabilistic_saturating_counter/probabilistic_saturating_counter.md) | `omnicores-buildingblocks/sources/counter/probabilistic_saturating_counter` | Saturating counter variant with probabilistic behavior. |
