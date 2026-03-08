# Fibonacci LFSR

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Fibonacci LFSR                                                                   |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![fibonacci_lfsr](fibonacci_lfsr.symbol.svg)

Fibonacci linear feedback shift register (LFSR) generating a pseudo-random maximal-length sequence of `2^WIDTH - 1` unique states before repeating, visiting every non-zero value exactly once before repeating. This is commonly used for pseudo-random events, built-in-self-test (BIST), noise generation, scrambling, and more.

The `SEED` parameter is one by default but can be changed to any non-zero value to start at a different state of the sequence. The `TAPS` parameter describes the position of the taps of the LFSR and is automatically selected from a look-up table to produce a maximal-length sequence.

## Parameters

| Name    | Type    | Allowed Values | Default                          | Description                                             |
| ------- | ------- | -------------- | -------------------------------- | ------------------------------------------------------- |
| `WIDTH` | integer | `≥2`           | `8`                              | Width of the LFSR shift register in bits.               |
| `SEED`  | integer | `≠0`           | `1`                              | Initial value of the LFSR loaded on reset.              |
| `TAPS`  | integer | non-zero       | `GET_FIBONACCI_LFSR_TAPS(WIDTH)` | Tap polynomial mask. Each set bit enables an XOR input. |

The default `TAPS` value is provided by the `GET_FIBONACCI_LFSR_TAPS` macro defined in the `fibonacci_lfsr.vh` header, which contains a look-up table of pre-computed maximal-length tap values for widths from 2 to 786 bits, plus 1024, 2048, and 4096 bits.

## Ports

| Name     | Direction | Width   | Clock   | Reset    | Reset value | Description                                   |
| -------- | --------- | ------- | ------- | -------- | ----------- | --------------------------------------------- |
| `clock`  | input     | 1       | self    |          |             | Clock signal.                                 |
| `resetn` | input     | 1       | `clock` | self     | active-low  | Asynchronous active-low reset.                |
| `enable` | input     | 1       | `clock` |          |             | Enable signal. The LFSR shifts when asserted. |
| `value`  | output    | `WIDTH` | `clock` | `resetn` | `SEED`      | Current LFSR state output.                    |

## Operation

On each rising edge of `clock` when `enable` is asserted, the LFSR advances to the next state using the Fibonacci configuration. The feedback bit is computed as the reduction XOR of the bitwise AND of `value` and `TAPS`, i.e. the XOR of all bit positions where the corresponding tap is set. The register then shifts right by one position and the feedback bit is inserted at the MSB.

When `resetn` is de-asserted (low), the LFSR is asynchronously reset to `SEED`. The LFSR must not be seeded with all zeros, as zero is an absorbing state with no feedback, and the sequence will remain stuck at zero.

With default taps for a given `WIDTH`, the LFSR cycles through all `2^WIDTH - 1` non-zero states before returning to `SEED`, forming a maximal-length pseudo-random binary sequence (PRBS).

The Fibonacci form differs from the Galois form in that a single XOR tree computes the feedback externally before insertion at the MSB. Because all maximal-length tap configurations in the look-up table use at most 4 taps, the feedback XOR tree has constant depth regardless of `WIDTH`.

## Paths

| From     | To      | Type       | Comment                                                       |
| -------- | ------- | ---------- | ------------------------------------------------------------- |
| `enable` | `value` | sequential | The LFSR advances one state per enabled clock cycle.          |
| `value`  | `value` | sequential | The next state depends on the current state and the tap mask. |

## Complexity

| Delay  | Gates      |
| ------ | ---------- |
| `O(1)` | `O(WIDTH)` |

The combinational feedback path is a small XOR tree over the tapped bits. Because all maximal-length tap configurations in the look-up table use at most 4 taps, the tree depth is constant and independent of `WIDTH`.

## Verification

The Fibonacci LFSR is verified using a SystemVerilog testbench with three check sequences.

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

| Type              | File                                                             | Description                                         |
| ----------------- | ---------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`fibonacci_lfsr.v`](fibonacci_lfsr.v)                           | Verilog design file.                                |
| Header            | [`fibonacci_lfsr.vh`](fibonacci_lfsr.vh)                         | Verilog header file with tap lookup table macro.    |
| Testbench         | [`fibonacci_lfsr.testbench.sv`](fibonacci_lfsr.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`fibonacci_lfsr.testbench.gtkw`](fibonacci_lfsr.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`fibonacci_lfsr.symbol.sss`](fibonacci_lfsr.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`fibonacci_lfsr.symbol.svg`](fibonacci_lfsr.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`fibonacci_lfsr.symbol.drawio`](fibonacci_lfsr.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`fibonacci_lfsr.md`](fibonacci_lfsr.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                         | Path                                                          | Comment                                                                        |
| ---------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [`galois_lfsr`](../galois_lfsr/galois_lfsr.md) | `omnicores-buildingblocks/sources/shift_register/galois_lfsr` | Galois (internal XOR) LFSR variant with shallower combinational feedback path. |
