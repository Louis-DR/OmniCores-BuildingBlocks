# Gray Wrapping Counter

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Gray Wrapping Counter                                                            |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![gray_wrapping_counter](gray_wrapping_counter.symbol.svg)

Synchronous bidirectional counter that increments and decrements within a configurable range with wrapping behavior. In addition to the binary count, it provides the corresponding Gray-coded output and supports a load interface that accepts either binary or Gray values based on a parameter. Minimum/maximum flags and single-cycle overflow/underflow pulses are provided. There is no lap bit.

The counter supports both power-of-2 and non-power-of-2 ranges. Note that the Gray count for zero when the range is not a power-of-two is not zero. This is especially important at reset if some other registers or synchronizers are reset to all zero.

Also note that the MSB of the Gray encoding is low for the first half of the range and high for the second, and sequence of the rest of the bits is symetrical after the half depth. This can be useful to use the MSB as a lap bit.

When both `increment` and `decrement` are asserted in the same cycle, the count does not change.

## Parameters

| Name          | Type    | Allowed Values   | Default | Description                                                              |
| ------------- | ------- | ---------------- | ------- | ------------------------------------------------------------------------ |
| `RANGE`       | integer | `≥2`             | `4`     | Counter range. Counter counts from `0` to `RANGE-1`.                     |
| `RESET_VALUE` | integer | `0` to `RANGE-1` | `0`     | Initial counter value after reset. Must be within `[0, RANGE-1]`.        |
| `LOAD_BINARY` | integer | `0` or `1`       | `0`     | Selects load encoding: `1` loads a binary value, `0` loads a Gray value. |

## Ports

| Name           | Direction | Width         | Clock        | Reset    | Reset value         | Description                                                          |
| -------------- | --------- | ------------- | ------------ | -------- | ------------------- | -------------------------------------------------------------------- |
| `clock`        | input     | 1             | self         |          |                     | Clock signal.                                                        |
| `resetn`       | input     | 1             | asynchronous | self     | active-low          | Asynchronous active-low reset.                                       |
| `load_enable`  | input     | 1             | `clock`      |          |                     | Synchronous load enable. Loads `load_count` on the next rising edge. |
| `load_count`   | input     | `log₂(RANGE)` | `clock`      |          |                     | Value to load (encoding set by `LOAD_BINARY`).                       |
| `decrement`    | input     | 1             | `clock`      |          |                     | Decrement control signal.                                            |
| `increment`    | input     | 1             | `clock`      |          |                     | Increment control signal.                                            |
| `count_binary` | output    | `log₂(RANGE)` | `clock`      | `resetn` | `RESET_VALUE`       | Current binary counter value.                                        |
| `count_gray`   | output    | `log₂(RANGE)` | `clock`      | `resetn` | `gray(RESET_VALUE)` | Gray-coded representation of the current count.                      |
| `minimum`      | output    | 1             | `clock`      |          |                     | High when the index is at `0`.                                       |
| `maximum`      | output    | 1             | `clock`      |          |                     | High when the index is at `RANGE-1`.                                 |
| `underflow`    | output    | 1 (pulse)     | `clock`      |          |                     | One-cycle pulse when decrementing at minimum wraps to maximum.       |
| `overflow`     | output    | 1 (pulse)     | `clock`      |          |                     | One-cycle pulse when incrementing at maximum wraps to minimum.       |

## Operation

The counter maintains a binary count within the range `[0, RANGE-1]` and derives a Gray-coded output each cycle.

- Decrement: If `decrement` is asserted and the counter is not at minimum, the binary count decreases by 1. At minimum, it wraps to `RANGE-1` and asserts `underflow` for one cycle.
- Increment: If `increment` is asserted and the counter is not at maximum, the binary count increases by 1. At maximum, it wraps to `0` and asserts `overflow` for one cycle.
- Simultaneous `increment` and `decrement` is ignored (no change).
- Load: When `load_enable=1`, the counter synchronously loads `load_count`. The encoding is selected by `LOAD_BINARY`: binary when `1`, Gray when `0`. Pulses remain low on load.

Power-of-2 ranges leverage natural wrapping in binary and a simple XOR network to form the Gray output. Non-power-of-2 ranges use explicit boundary handling for wrapping while preserving a consistent Gray mapping (offset-based for the encoder/decoder).

The counter is asynchronously reset to `RESET_VALUE` (binary). The corresponding Gray output at reset equals the Gray encoding of `RESET_VALUE` (for power-of-2 ranges, computed via a macro).

## Paths

| From          | To                           | Type          | Comment                                                    |
| ------------- | ---------------------------- | ------------- | ---------------------------------------------------------- |
| `decrement`   | `count_binary`, `count_gray` | sequential    | Decrement path through binary register and Gray encoder.   |
| `increment`   | `count_binary`, `count_gray` | sequential    | Increment path through binary register and Gray encoder.   |
| `load_enable` | `count_binary`, `count_gray` | sequential    | Synchronous load (encoding set by `LOAD_BINARY`).          |
| `load_count`  | `count_binary`, `count_gray` | sequential    | Synchronous load path.                                     |
| `decrement`   | `minimum`, `maximum`         | combinational | Flags computed from binary index value.                    |
| `increment`   | `minimum`, `maximum`         | combinational | Flags computed from binary index value.                    |
| `decrement`   | `underflow`                  | sequential    | Pulse asserted for one cycle when decrementing at minimum. |
| `increment`   | `overflow`                   | sequential    | Pulse asserted for one cycle when incrementing at maximum. |

## Complexity

| Delay                | Gates           | Comment                                                                                  |
| -------------------- | --------------- | ---------------------------------------------------------------------------------------- |
| `O(log₂ log₂ RANGE)` | `O(log₂ RANGE)` | Binary add/subtract plus compare (for non-2ⁿ) and a small XOR network for Gray encoding. |

The module uses `log₂(RANGE)` flip-flops for the binary counter and the same for the registered Gray output. The Gray encoder is an XOR network; for non-power-of-2 ranges, boundary compares add minimal overhead.

## Verification

The gray wrapping counter is verified using a SystemVerilog testbench with nine checks that validate operations, flags, pulses, load behavior, and Gray properties (single-bit difference and correct mapping).

| Number | Check                      | Description                                                                                   |
| ------ | -------------------------- | --------------------------------------------------------------------------------------------- |
| 1      | Reset value                | Verifies reset value, flags, no pulses, and Gray equals the encoding of the reset value.      |
| 2      | Increment without wrapping | Steps up without crossing maximum; ensures no pulses and correct Gray mapping.                |
| 3      | Increment with wrapping    | Increments at maximum; verifies wrap, overflow pulse, flags, and Gray mapping.                |
| 4      | Decrement with wrapping    | Decrements at minimum; verifies wrap, underflow pulse, flags, and Gray mapping.               |
| 5      | Decrement without wrapping | Steps down without crossing minimum; ensures no pulses and correct Gray mapping.              |
| 6      | Full cycle increment       | Completes one full cycle, checking pulses at boundaries and Gray single-bit transitions.      |
| 7      | Full cycle decrement       | Completes one full cycle down, checking pulses at boundaries and Gray single-bit transitions. |
| 8      | Random                     | Random inc/dec; checks pulses, flags/values, and Gray mapping each step.                      |
| 9      | Load behavior              | Loads a value; verifies no pulses on load, flags afterward, and Gray mapping.                 |

Parameter sweeps outside the testbench can set `LOAD_BINARY` to verify both binary-load and gray-load modes.

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type              | File                                                                           | Description                                         |
| ----------------- | ------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`gray_wrapping_counter.v`](gray_wrapping_counter.v)                           | Verilog design.                                     |
| Testbench         | [`gray_wrapping_counter.testbench.sv`](gray_wrapping_counter.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`gray_wrapping_counter.testbench.gtkw`](gray_wrapping_counter.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`gray_wrapping_counter.symbol.sss`](gray_wrapping_counter.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`gray_wrapping_counter.symbol.svg`](gray_wrapping_counter.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`gray_wrapping_counter.symbol.drawio`](gray_wrapping_counter.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`gray_wrapping_counter.md`](gray_wrapping_counter.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module / Header    | Path                                             | Comment                                         |
| ------------------ | ------------------------------------------------ | ----------------------------------------------- |
| `clog2.vh`         | `omnicores-buildingblocks/sources/common`        | Macro for calculating log₂ of parameter values. |
| `is_pow2.vh`       | `omnicores-buildingblocks/sources/common`        | Macro to detect power-of-2 ranges.              |
| `gray.vh`          | `omnicores-buildingblocks/sources/encoding/gray` | Macros for Gray/Binary conversion (power-of-2). |
| `binary_to_gray.v` | `omnicores-buildingblocks/sources/encoding/gray` | Encoder used for general ranges.                |
| `gray_to_binary.v` | `omnicores-buildingblocks/sources/encoding/gray` | Decoder used for gray-load mode.                |

## Related modules

| Module                                                                                                    | Path                                                                       | Comment                                      |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------- |
| [`wrapping_counter`](../wrapping_counter/wrapping_counter.md)                                             | `omnicores-buildingblocks/sources/counter/wrapping_counter`                | Binary wrapping counter (no Gray outputs).   |
| [`gray_wrapping_increment_counter`](../gray_wrapping_increment_counter/gray_wrapping_increment_counter.v) | `omnicores-buildingblocks/sources/counter/gray_wrapping_increment_counter` | Gray-coded increment-only counter.           |
| [`gray_wrapping_decrement_counter`](../gray_wrapping_decrement_counter/gray_wrapping_decrement_counter.v) | `omnicores-buildingblocks/sources/counter/gray_wrapping_decrement_counter` | Gray-coded decrement-only counter.           |
| [`wrapping_increment_counter`](../wrapping_increment_counter/wrapping_increment_counter.md)               | `omnicores-buildingblocks/sources/counter/wrapping_increment_counter`      | Increment-only binary counter with wrapping. |
| [`wrapping_decrement_counter`](../wrapping_decrement_counter/wrapping_decrement_counter.md)               | `omnicores-buildingblocks/sources/counter/wrapping_decrement_counter`      | Decrement-only binary counter with wrapping. |
