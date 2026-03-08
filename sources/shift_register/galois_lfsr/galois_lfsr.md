# Galois LFSR

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Galois LFSR                                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![galois_lfsr](galois_lfsr.symbol.svg)

Galois linear feedback shift register (LFSR) generating a pseudo-random maximal-length sequence of `2^WIDTH - 1` unique states before repeating, visiting every non-zero value exactly once before repeating. This is commonly used for pseudo-random events, built-in-self-test (BIST), noise generation, scrambling, and more.

The `SEED` parameter is one by default but can be changed to any non-zero value to start at a different state of the sequence. The `TAPS` parameter describes the position of the taps of the LFSR and is automatically selected from a look-up table to produce a maximal-length sequence.

## Parameters

| Name    | Type    | Allowed Values | Default                       | Description                                           |
| ------- | ------- | -------------- | ----------------------------- | ----------------------------------------------------- |
| `WIDTH` | integer | `≥2`           | `8`                           | Width of the LFSR shift register in bits.             |
| `SEED`  | integer | `≠0`           | `1`                           | Initial value of the LFSR loaded on reset.            |
| `TAPS`  | integer | non-zero       | `GET_GALOIS_LFSR_TAPS(WIDTH)` | Tap polynomial mask. Each set bit enables an XOR tap. |

The default `TAPS` value is provided by the `GET_GALOIS_LFSR_TAPS` macro defined in the `galois_lfsr.vh` header, which contains a look-up table of pre-computed maximal-length tap values for widths from 2 to 786 bits, plus 1024, 2048, and 4096 bits.

## Ports

| Name     | Direction | Width   | Clock   | Reset    | Reset value | Description                                   |
| -------- | --------- | ------- | ------- | -------- | ----------- | --------------------------------------------- |
| `clock`  | input     | 1       | self    |          |             | Clock signal.                                 |
| `resetn` | input     | 1       | `clock` | self     | active-low  | Asynchronous active-low reset.                |
| `enable` | input     | 1       | `clock` |          |             | Enable signal. The LFSR shifts when asserted. |
| `value`  | output    | `WIDTH` | `clock` | `resetn` | `SEED`      | Current LFSR state output.                    |

## Operation

On each rising edge of `clock` when `enable` is asserted, the LFSR advances to the next state using the Galois configuration. The feedback bit is taken from the LSB of `value`. Each internal bit position is either shifted directly from the predecessor (if the corresponding tap is not set) or XOR'd with the feedback (if the tap is set), and the MSB is filled with the feedback bit. This is equivalent to multiplying the LFSR state polynomial by `x` modulo the characteristic polynomial.

When `resetn` is de-asserted (low), the LFSR is asynchronously reset to `SEED`. The LFSR must not be seeded with all zeros, as zero is an absorbing state with no feedback, and the sequence will remain stuck at zero.

With default taps for a given `WIDTH`, the LFSR cycles through all `2^WIDTH - 1` non-zero states before returning to `SEED`, forming a maximal-length pseudo-random binary sequence (PRBS).

The Galois form differs from the Fibonacci form in that the XOR operations are distributed across internal stages rather than computed externally, resulting in a shorter critical path at the cost of differing output sequences for equivalent tap polynomials.

## Paths

| From     | To      | Type       | Comment                                                       |
| -------- | ------- | ---------- | ------------------------------------------------------------- |
| `enable` | `value` | sequential | The LFSR advances one state per enabled clock cycle.          |
| `value`  | `value` | sequential | The next state depends on the current state and the tap mask. |

## Complexity

| Delay  | Gates      |
| ------ | ---------- |
| `O(1)` | `O(WIDTH)` |

The combinational path per stage consists of a single XOR gate, giving a shallow critical path regardless of `WIDTH`.

## Verification

The Galois LFSR is verified using a SystemVerilog testbench with three check sequences.

The following table lists the checks performed by the testbench.

| Number | Check                   | Description                                                                                                         |
| ------ | ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 1      | Reset value             | Checks that `value` equals `SEED` immediately after reset is de-asserted.                                           |
| 2      | Disabled state          | Checks that `value` does not change when `enable` is de-asserted.                                                   |
| 3      | Maximal length sequence | Enables the LFSR and counts states until the seed is revisited, verifying the sequence length equals `2^WIDTH - 1`. |

The following table lists the parameter values verified by the testbench.

| `WIDTH`     | `SEED`      |
| ----------- | ----------- |
| 8 (default) | 1 (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                       | Description                                         |
| ----------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`galois_lfsr.v`](galois_lfsr.v)                           | Verilog design file.                                |
| Header            | [`galois_lfsr.vh`](galois_lfsr.vh)                         | Verilog header file with tap lookup table macro.    |
| Testbench         | [`galois_lfsr.testbench.sv`](galois_lfsr.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`galois_lfsr.testbench.gtkw`](galois_lfsr.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`galois_lfsr.symbol.sss`](galois_lfsr.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`galois_lfsr.symbol.svg`](galois_lfsr.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`galois_lfsr.symbol.drawio`](galois_lfsr.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`galois_lfsr.md`](galois_lfsr.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                  | Path                                                             | Comment                                                                        |
| ------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [`fibonacci_lfsr`](../fibonacci_lfsr/fibonacci_lfsr.md) | `omnicores-buildingblocks/sources/shift_register/fibonacci_lfsr` | Fibonacci (external XOR) LFSR variant with equivalent maximal-length sequence. |
