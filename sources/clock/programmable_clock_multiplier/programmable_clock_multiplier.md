# Programmable Clock Multiplier

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Programmable Clock Multiplier                                                    |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![programmable_clock_multiplier](programmable_clock_multiplier.symbol.svg)

Multiplies the frequency of the input clock `clock_in` by a programmable `multiplication` factor plus one. The output clock `clock_out` runs `multiplication + 1` times faster than the input clock. If `multiplication` is 0, `clock_in` is directly passed through to `clock_out` without any logic. If `multiplication` is 1 or more, a behavioral process measures the input period and toggles `clock_out` at the right period. This module is not synthesizable and serves as a behavioral model of a PLL/DLL multiplier with a programmable ratio.

![programmable_clock_multiplier](programmable_clock_multiplier.wavedrom.svg)

## Parameters

| Name                   | Type | Allowed Values | Default | Description                                  |
| ---------------------- | ---- | -------------- | ------- | -------------------------------------------- |
| `MULTIPLICATION_WIDTH` | int  | `>=1`          | `4`     | Width of the `multiplication` input in bits. |

## Ports

| Name             | Direction | Width                  | Clock   | Reset | Reset value | Description                         |
| ---------------- | --------- | ---------------------- | ------- | ----- | ----------- | ----------------------------------- |
| `clock_in`       | input     | 1                      | self    |       |             | Input clock signal.                 |
| `multiplication` | input     | `MULTIPLICATION_WIDTH` | self    |       |             | Programmable multiplication factor. |
| `clock_out`      | output    | 1                      | derived |       |             | Multiplied clock output signal.     |

## Operation

If `multiplication == 0`, `clock_out` is directly assigned to `clock_in`. Else, the module measures the input period at runtime and generates `clock_out` by toggling every `clock_in_period / (2 × (multiplication + 1))`. Frequency changes follow updates of the `multiplication` input. This is a behavioral model intended for simulation (not synthesizable).

## Paths

| From       | To          | Type       | Comment                                                                        |
| ---------- | ----------- | ---------- | ------------------------------------------------------------------------------ |
| `clock_in` | `clock_out` | behavioral | If `multiplication > 0`. Generated with time-based delays (not synthesizable). |

## Complexity

This module is a behavioral model, so its complexity is irrelevant.

## Verification

The programmable clock multiplier is verified using a SystemVerilog testbench with a single DUT and two checks. It uses a helper macro to measure the frequency of the output clock.

The following table lists the checks performed by the testbench.

| Number | Check                                      | Description                                                                |
| ------ | ------------------------------------------ | -------------------------------------------------------------------------- |
| 1      | Output multiplied frequency across a range | Sweeps `multiplication` from a minimum to a maximum and checks frequency.  |
| 2      | Glitch-free output under random updates    | Randomly updates `multiplication` and checks output pulse width stability. |

## Constraints

There are no synthesis and implementation constraints for this block as it is a behavioral model.

## Deliverables

| Type                | File                                                                                           | Description                                         |
| ------------------- | ---------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`programmable_clock_multiplier.sv`](programmable_clock_multiplier.sv)                         | SystemVerilog design.                               |
| Testbench           | [`programmable_clock_multiplier.testbench.sv`](programmable_clock_multiplier.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script     | [`programmable_clock_multiplier.testbench.gtkw`](programmable_clock_multiplier.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor   | [`programmable_clock_multiplier.symbol.sss`](programmable_clock_multiplier.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`programmable_clock_multiplier.symbol.svg`](programmable_clock_multiplier.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape        | [`programmable_clock_multiplier.symbol.drawio`](programmable_clock_multiplier.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Waveform descriptor | [`programmable_clock_multiplier.wavedrom.json`](programmable_clock_multiplier.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`programmable_clock_multiplier.wavedrom.svg`](programmable_clock_multiplier.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`programmable_clock_multiplier.md`](programmable_clock_multiplier.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                                             | Path                                                             | Comment                               |
| ---------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------- |
| [`clock_gater`](../clock_gater/clock_gater.md)                                     | `omnicores-buildingblocks/sources/clock/clock_gater`             | Clock gater behavioral model.         |
| [`static_clock_multiplier`](../static_clock_multiplier/static_clock_multiplier.md) | `omnicores-buildingblocks/sources/clock/static_clock_multiplier` | Static clock multiplier.              |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md)                   | `omnicores-buildingblocks/sources/clock/clock_multiplexer`       | Multiplexer to select between clocks. |
