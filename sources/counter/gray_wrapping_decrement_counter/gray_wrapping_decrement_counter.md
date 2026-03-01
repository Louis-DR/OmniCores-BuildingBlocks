# Gray Wrapping Decrement Counter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Gray Wrapping Decrement Counter                                                  |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![gray_wrapping_decrement_counter](gray_wrapping_decrement_counter.symbol.svg)

Synchronous decrement-only counter that counts down within a configurable range with wrapping behavior, providing its output in both binary and Gray code. The counter provides underflow wrapping, allowing it to cycle continuously through its range when decrementing, making it ideal for applications requiring reverse circular counting across asynchronous clock domains (using the Gray-coded output), such as asynchronous FIFO read pointers or countdown timing logic.

The counter supports both power-of-2 and non-power-of-2 ranges (even ranges restricted for Gray code continuity) with optimized implementations for each case. The counter only decrements when the decrement signal is asserted.

## Parameters

| Name          | Type    | Allowed Values | Default | Description                                                                       |
| ------------- | ------- | -------------- | ------- | --------------------------------------------------------------------------------- |
| `RANGE`       | integer | `≥2`, even     | `4`     | Counter range. Counter counts from `0` to `RANGE-1`. Must be even for Gray code.  |
| `RESET_VALUE` | integer | `0 to RANGE-1` | `0`     | Initial counter value after reset. Must be within the valid range `[0, RANGE-1]`. |

## Ports

| Name           | Direction | Width         | Clock        | Reset    | Reset value         | Description                                                              |
| -------------- | --------- | ------------- | ------------ | -------- | ------------------- | ------------------------------------------------------------------------ |
| `clock`        | input     | 1             | self         |          |                     | Clock signal.                                                            |
| `resetn`       | input     | 1             | asynchronous | self     | active-low          | Asynchronous active-low reset.                                           |
| `decrement`    | input     | 1             | `clock`      |          |                     | Decrement control signal.<br/>• `0`: idle.<br/>• `1`: decrement counter. |
| `count_gray`   | output    | `log₂(RANGE)` | `clock`      | `resetn` | `gray(RESET_VALUE)` | Current counter value in Gray code.                                      |
| `count_binary` | output    | `log₂(RANGE)` | `clock`      | `resetn` | `RESET_VALUE`       | Current counter value in standard binary.                                |

## Operation

The gray wrapping decrement counter maintains a count value within the range `[0, RANGE-1]`. On each rising edge of the clock, the counter responds to the decrement control signal.

For **decrement operation**, when `decrement` is asserted and the counter is not at its minimum value (`0`), the counter decreases by 1. If the counter is at the minimum value, asserting `decrement` causes the counter to wrap around to the maximum value (`RANGE-1`).

The counter exhibits **wrapping behavior** at the lower boundary, providing underflow wrapping when decrementing at minimum value. This makes it suitable for applications requiring reverse circular counting behavior. When `decrement` is not asserted, the counter value remains unchanged.

The outputs are provided simultaneously in both standard binary (`count_binary`) and Gray code (`count_gray`). The Gray-coded output guarantees that only one bit changes its state between any two successive counter values, including during the wrap-around from minimum to maximum, ensuring glitch-free sampling across asynchronous clock boundaries. This restriction is why the `RANGE` parameter must be an even number.

The implementation is optimized for different range types. For power-of-2 ranges, the wrapping behavior is automatic due to the natural underflow of binary arithmetic. For non-power-of-2 even ranges, explicit boundary detection and wrapping logic is implemented to ensure correct modular behavior.

The counter is reset to `RESET_VALUE` (and its Gray code equivalent) when `resetn` is asserted (active-low). The reset operation is asynchronous and takes precedence over all other operations.

## Paths

| From        | To             | Type       | Comment                                                  |
| ----------- | -------------- | ---------- | -------------------------------------------------------- |
| `decrement` | `count_binary` | sequential | Decrement control path through internal binary register. |
| `decrement` | `count_gray`   | sequential | Decrement control path through internal Gray register.   |

## Complexity

| Delay                | Gates           | Comment |
| -------------------- | --------------- | ------- |
| `O(log₂ log₂ RANGE)` | `O(log₂ RANGE)` |         |

The module requires `2 * log₂(RANGE)` flip-flops for the counter registers (one for binary, one for Gray code), plus combinational logic for boundary detection (in non-power-of-2 cases), decrement operations, and Gray encoding. For power-of-2 ranges, the binary implementation is more efficient as it leverages natural binary underflow behavior. The critical path includes the counter comparison logic (for non-power-of-2 ranges), the decrement arithmetic, and the Gray encoder.

## Verification

The gray wrapping decrement counter is verified using a SystemVerilog testbench with five check sequences that validate the counter operations, boundary conditions, wrapping behavior, and Gray code validity.

The following table lists the checks performed by the testbench.

| Number | Check                      | Description                                                                                                   |
| ------ | -------------------------- | ------------------------------------------------------------------------------------------------------------- |
| 1      | Reset value                | Verifies that the counter initializes to the specified `RESET_VALUE` and its Gray equivalent after reset.     |
| 2      | Decrement without wrapping | Tests decrementing from maximum towards minimum value without reaching the boundary, verifying 1-bit changes. |
| 3      | Decrement with wrapping    | Tests decrement wrapping behavior from minimum value back to maximum value, verifying 1-bit changes.          |
| 4      | Full cycle decrement       | Tests a complete decrement cycle through all values and verifies return to starting point and 1-bit changes.  |
| 5      | Random                     | Performs random decrement operations and verifies counter behavior and Gray coding against expected values.   |

The following table lists the parameter values verified by the testbench.

| `RANGE` | `RESET_VALUE` |           |
| ------- | ------------- | --------- |
| 4       | 0             | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                                               | Description                                         |
| ----------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`gray_wrapping_decrement_counter.v`](gray_wrapping_decrement_counter.v)                           | Verilog design.                                     |
| Testbench         | [`gray_wrapping_decrement_counter.testbench.sv`](gray_wrapping_decrement_counter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`gray_wrapping_decrement_counter.testbench.gtkw`](gray_wrapping_decrement_counter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`gray_wrapping_decrement_counter.symbol.sss`](gray_wrapping_decrement_counter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`gray_wrapping_decrement_counter.symbol.svg`](gray_wrapping_decrement_counter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`gray_wrapping_decrement_counter.symbol.drawio`](gray_wrapping_decrement_counter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`gray_wrapping_decrement_counter.md`](gray_wrapping_decrement_counter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module           | Path                                             | Comment                                         |
| ---------------- | ------------------------------------------------ | ----------------------------------------------- |
| `clog2.vh`       | `omnicores-buildingblocks/sources/common`        | Macro for calculating log₂ of parameter values. |
| `is_pow2.vh`     | `omnicores-buildingblocks/sources/common`        | Macro for checking if a value is a power of 2.  |
| `binary_to_gray` | `omnicores-buildingblocks/sources/encoding/gray` | Binary to Gray encoder module.                  |

## Related modules

| Module                                                                                                     | Path                                                                       | Comment                                                   |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | --------------------------------------------------------- |
| [`gray_wrapping_counter`](../gray_wrapping_counter/gray_wrapping_counter.md)                               | `omnicores-buildingblocks/sources/counter/gray_wrapping_counter`           | Gray-coded bidirectional variant with wrapping behavior.  |
| [`gray_wrapping_increment_counter`](../gray_wrapping_increment_counter/gray_wrapping_increment_counter.md) | `omnicores-buildingblocks/sources/counter/gray_wrapping_increment_counter` | Gray-coded increment-only variant with wrapping behavior. |
| [`wrapping_decrement_counter`](../wrapping_decrement_counter/wrapping_decrement_counter.md)                | `omnicores-buildingblocks/sources/counter/wrapping_decrement_counter`      | Standard binary decrement counter without Gray code.      |
