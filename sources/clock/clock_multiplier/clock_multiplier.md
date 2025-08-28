# Clock Multiplier

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Clock Multiplier                                                                 |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![clock_multiplier](clock_multiplier.symbol.svg)

Multiplies the frequency of the input clock `clock_in` by the `MULTIPLICATION` factor. The output clock `clock_out` runs `MULTIPLICATION` times faster than the input clock. If `MULTIPLICATION` is 1 or less, `clock_in` is directly passed through to `clock_out` without any logic. If `MULTIPLICATION` is 2 or more, a behavioral process measures the input period and toggles `clock_out` at the right period.

![clock_multiplier](clock_multiplier.wavedrom.svg)

## Parameters

| Name             | Type    | Allowed Values | Default | Description                                            |
| ---------------- | ------- | -------------- | ------- | ------------------------------------------------------ |
| `MULTIPLICATION` | integer | `>0`           | `2`     | Factor by which to multiply the input clock frequency. |

## Ports

| Name        | Direction | Width | Clock   | Reset | Reset value | Description                     |
| ----------- | --------- | ----- | ------- | ----- | ----------- | ------------------------------- |
| `clock_in`  | input     | 1     | self    |       |             | Input clock signal.             |
| `clock_out` | output    | 1     | derived |       |             | Multiplied clock output signal. |

## Operation

If `MULTIPLICATION < 2`, `clock_out` is directly assigned to `clock_in`. Else, the module measures the input period at runtime and generates `clock_out` by toggling every `clock_in_period / (2 × MULTIPLICATION)`. This is a behavioral model intended for simulation (not synthesizable) that emulates a PLL/DLL static frequency multiplier.

## Paths

| From       | To          | Type         | Comment                                                                         |
| ---------- | ----------- | ------------ | ------------------------------------------------------------------------------- |
| `clock_in` | `clock_out` | pass-through | If `MULTIPLICATION < 2`.                                                        |
| `clock_in` | `clock_out` | behavioral   | If `MULTIPLICATION >= 2`. Generated with time-based delays (not synthesizable). |

## Complexity

| `MULTIPLICATION` | Logic                             | Delay | Gates |
| ---------------- | --------------------------------- | ----- | ----- |
| `<2`             | None (pass-through)               | `0`   | `0`   |
| `≥2`             | Timer-based toggling (behavioral) | N/A   | `0`   |

## Verification

The clock multiplier is verified using a SystemVerilog testbench with multiple DUTs with different parameters, and a single common check sequence. It uses a helper macro to measure the frequency of the output clock.

The following table lists the checks performed by the testbench.

| Number | Check                       | Description                               |
| ------ | --------------------------- | ----------------------------------------- |
| 1      | Output multiplied frequency | Checks the frequency of the output clock. |

The following table lists the parameter values verified by the testbench.

| `MULTIPLICATION` |           |
| ---------------- | --------- |
| 1                |           |
| 2                | (default) |
| 3                |           |
| 4                |           |
| 5                |           |
| 6                |           |
| 7                |           |
| 8                |           |
| 9                |           |
| 10               |           |

## Constraints

There are no synthesis and implementation constraints for this block as it is a behavioral model.

## Deliverables

| Type                | File                                                                 | Description                                         |
| ------------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`clock_multiplier.sv`](clock_multiplier.sv)                         | SystemVerilog design.                               |
| Testbench           | [`clock_multiplier.testbench.sv`](clock_multiplier.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script     | [`clock_multiplier.testbench.gtkw`](clock_multiplier.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor   | [`clock_multiplier.symbol.sss`](clock_multiplier.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`clock_multiplier.symbol.svg`](clock_multiplier.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape        | [`clock_multiplier.symbol.drawio`](clock_multiplier.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Waveform descriptor | [`clock_multiplier.wavedrom.json`](clock_multiplier.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`clock_multiplier.wavedrom.svg`](clock_multiplier.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`clock_multiplier.md`](clock_multiplier.md)                         | Markdown documentation datasheet.                   |

## Dependencies

This module has no dependency.

## Related modules

| Module                                                           | Path                                                       | Comment                               |
| ---------------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------- |
| [`clock_gater`](../clock_gater/clock_gater.md)                   | `omnicores-buildingblocks/sources/clock/clock_gater`       | Clock gater behavioral model.         |
| [`clock_divider`](../clock_divider/clock_divider.md)             | `omnicores-buildingblocks/sources/clock/clock_divider`     | Static clock divider.                 |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md) | `omnicores-buildingblocks/sources/clock/clock_multiplexer` | Multiplexer to select between clocks. |
