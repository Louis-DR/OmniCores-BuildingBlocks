# Advanced Wrapping Counter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Advanced Wrapping Counter                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![advanced_wrapping_counter](advanced_wrapping_counter.symbol.svg)

Synchronous bidirectional counter that increments and decrements within a configurable range with wrapping behavior. This advanced variant adds a load interface, optional lap bit, minimum/maximum flags, and single-cycle overflow/underflow pulses. It is suitable for circular counting (e.g., buffer indexing, modular arithmetic) and pointer-style use-cases when the lap bit is enabled.

The counter supports both power-of-2 and non-power-of-2 ranges with optimized implementations. Trying to increment and decrement within the same cycle is ignored and the count does not change.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                                                                                   |
| ------------- | ------- | -------------- | ------- | --------------------------------------------------------------------------------------------- |
| `RANGE`       | integer | `≥2`           | `4`     | Counter range. Counter counts from `0` to `RANGE-1`.                                          |
| `RESET_VALUE` | integer | `0 to RANGE-1` | `0`     | Initial counter value after reset. Must be within the valid range `[0, RANGE-1]`.             |
| `LAP_BIT`     | integer | `0 or 1`       | `0`     | When `1`, extends the counter with an MSB lap bit that toggles on wrap (useful for pointers). |

## Ports

| Name          | Direction | Width                 | Clock        | Reset    | Reset value   | Description                                                                    |
| ------------- | --------- | --------------------- | ------------ | -------- | ------------- | ------------------------------------------------------------------------------ |
| `clock`       | input     | 1                     | self         |          |               | Clock signal.                                                                  |
| `resetn`      | input     | 1                     | asynchronous | self     | active-low    | Asynchronous active-low reset.                                                 |
| `load_enable` | input     | 1                     | `clock`      |          |               | Synchronous load enable. When `1`, loads `load_count` on the next rising edge. |
| `load_count`  | input     | `log₂(RANGE)+LAP_BIT` | `clock`      |          |               | Value to load into the counter (includes lap bit on MSB when `LAP_BIT=1`).     |
| `decrement`   | input     | 1                     | `clock`      |          |               | Decrement control signal.                                                      |
| `increment`   | input     | 1                     | `clock`      |          |               | Increment control signal.                                                      |
| `count`       | output    | `log₂(RANGE)+LAP_BIT` | `clock`      | `resetn` | `RESET_VALUE` | Current counter value (includes lap bit on MSB when `LAP_BIT=1`).              |
| `minimum`     | output    | 1                     | `clock`      |          |               | High when the index is at `0`.                                                 |
| `maximum`     | output    | 1                     | `clock`      |          |               | High when the index is at `RANGE-1`.                                           |
| `underflow`   | output    | 1 (pulse)             | `clock`      |          |               | One-cycle pulse when decrementing at minimum wraps to maximum.                 |
| `overflow`    | output    | 1 (pulse)             | `clock`      |          |               | One-cycle pulse when incrementing at maximum wraps to minimum.                 |

## Operation

The wrapping counter maintains a count value within the range `[0, RANGE-1]` (plus an optional lap bit). On each rising edge of the clock, the counter responds to `increment`, `decrement`, and `load_enable`.

For **decrement operation**, when `decrement` is asserted and the counter is not at its minimum value (`0`), the counter decreases by 1. If the counter is at the minimum value, asserting `decrement` causes the counter to wrap around to the maximum value (`RANGE-1`) and asserts `underflow` for one cycle.

For **increment operation**, when `increment` is asserted and the counter is not at its maximum value (`RANGE-1`), the counter increases by 1. If the counter is at the maximum value, asserting `increment` causes the counter to wrap around to the minimum value (`0`) and asserts `overflow` for one cycle.

The counter exhibits **wrapping behavior** at both boundaries, with pulse signaling. If both `increment` and `decrement` are asserted simultaneously, the counter value is not changed. When `load_enable=1`, the counter synchronously loads `load_count` and pulses remain low.

The implementation is optimized for different range types. For power-of-2 ranges, wrapping (and lap-bit toggling when enabled) is automatic due to binary overflow. For non-power-of-2 ranges, explicit boundary detection and wrapping is implemented; when `LAP_BIT=1`, the lap bit toggles only on wrap events.

The counter is reset to `RESET_VALUE` when `resetn` is asserted (active-low). The reset operation is asynchronous and takes precedence over all other operations.

## Paths

| From          | To                   | Type          | Comment                                                    |
| ------------- | -------------------- | ------------- | ---------------------------------------------------------- |
| `decrement`   | `count`              | sequential    | Decrement control path through internal counter register.  |
| `increment`   | `count`              | sequential    | Increment control path through internal counter register.  |
| `load_enable` | `count`              | sequential    | Synchronous load.                                          |
| `load_count`  | `count`              | sequential    | Synchronous load.                                          |
| `decrement`   | `minimum`, `maximum` | combinational | Minimum flag computed from index value.                    |
| `increment`   | `minimum`, `maximum` | combinational | Minimum flag computed from index value.                    |
| `decrement`   | `underflow`          | sequential    | Pulse asserted for one cycle when decrementing at minimum. |
| `increment`   | `overflow`           | sequential    | Pulse asserted for one cycle when incrementing at maximum. |

## Complexity

| Delay                | Gates           | Comment                                                              |
| -------------------- | --------------- | -------------------------------------------------------------------- |
| `O(log₂ log₂ RANGE)` | `O(log₂ RANGE)` | Includes compare logic for non-power-of-2 and optional lap handling. |

The module requires `log₂(RANGE)` flip-flops for the counter register, plus combinational logic for boundary detection (in non-power-of-2 cases) and increment/decrement operations. For power-of-2 ranges, the implementation is more efficient as it leverages natural binary overflow behavior. The critical path includes the counter comparison logic (for non-power-of-2 ranges) and the increment/decrement arithmetic.

## Verification

The advanced wrapping counter is verified using a SystemVerilog testbench with nine check sequences that validate operations, flags, pulses, and load behavior.

The following table lists the checks performed by the testbench.

| Number | Check                      | Description                                                                                 |
| ------ | -------------------------- | ------------------------------------------------------------------------------------------- |
| 1      | Reset value                | Verifies reset value, flags low/high as appropriate, and no pulses.                         |
| 2      | Increment without wrapping | Steps up without crossing maximum; ensures no pulses.                                       |
| 3      | Increment with wrapping    | Increments at maximum; verifies wrap to minimum, overflow pulse, and flag transitions.      |
| 4      | Decrement with wrapping    | Decrements at minimum; verifies wrap to maximum, underflow pulse, and flag transitions.     |
| 5      | Decrement without wrapping | Steps down without crossing minimum; ensures no pulses.                                     |
| 6      | Full cycle increment       | Completes one full cycle, verifying pulses only at boundaries and correct final value.      |
| 7      | Full cycle decrement       | Completes one full cycle down, verifying pulses only at boundaries and correct final value. |
| 8      | Random                     | Random inc/dec; verifies pulses against previous value and flags/values each step.          |
| 9      | Load behavior              | Loads a value synchronously; verifies no pulses on load and correct flags afterward.        |

The following table lists the parameter values verified by the testbench.

| `RANGE` | `RESET_VALUE` | `LAP_BIT` |
| ------- | ------------- | --------- |
| 4       | 0             | 0         |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                   | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`advanced_wrapping_counter.v`](advanced_wrapping_counter.v)                           | Verilog design.                                     |
| Testbench         | [`advanced_wrapping_counter.testbench.sv`](advanced_wrapping_counter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`advanced_wrapping_counter.testbench.gtkw`](advanced_wrapping_counter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`advanced_wrapping_counter.symbol.sss`](advanced_wrapping_counter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`advanced_wrapping_counter.symbol.svg`](advanced_wrapping_counter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`advanced_wrapping_counter.symbol.drawio`](advanced_wrapping_counter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`advanced_wrapping_counter.md`](advanced_wrapping_counter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module       | Path                                      | Comment                                         |
| ------------ | ----------------------------------------- | ----------------------------------------------- |
| `clog2.vh`   | `omnicores-buildingblocks/sources/common` | Macro for calculating log₂ of parameter values. |
| `is_pow2.vh` | `omnicores-buildingblocks/sources/common` | Macro to detect power-of-2 ranges.              |

## Related modules

| Module                                                                                                        | Path                                                                        | Comment                                                 |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------- |
| [`wrapping_increment_counter`](../wrapping_increment_counter/wrapping_increment_counter.md)                   | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter`       | Increment-only variant with wrapping behavior.          |
| [`wrapping_decrement_counter`](../wrapping_decrement_counter/wrapping_decrement_counter.md)                   | `omnicores-buildingblocks/sources/counter/wrapping_decrement_counter`       | Decrement-only variant with wrapping behavior.          |
| [`saturating_counter`](../saturating_counter/saturating_counter.md)                                           | `omnicores-buildingblocks/sources/counter/saturating_counter`               | Counter variant with saturating behavior.               |
| [`hysteresis_saturating_counter`](../hysteresis_saturating_counter/hysteresis_saturating_counter.md)          | `omnicores-buildingblocks/sources/counter/hysteresis_saturating_counter`    | Saturating counter variant with hysteresis behavior.    |
| [`probabilistic_saturating_counter`](../probabilistic_saturating_counter/probabilistic_saturating_counter.md) | `omnicores-buildingblocks/sources/counter/probabilistic_saturating_counter` | Saturating counter variant with probabilistic behavior. |
