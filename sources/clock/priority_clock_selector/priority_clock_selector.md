# Priority Clock Selector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Priority Clock Selector                                                          |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![priority_clock_selector](priority_clock_selector.symbol.svg)

Automatic clock selector between a priority clock and a fallback clock. When the priority clock is running, it is selected, else it is the fallback clock.

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                              |
| -------- | ------- | -------------- | ------- | -------------------------------------------------------- |
| `STAGES` | integer | `≥1`           | `2`     | Number of synchronization stages for the internal logic. |

## Ports

| Name             | Direction | Width | Clock        | Reset    | Reset value | Description                           |
| ---------------- | --------- | ----- | ------------ | -------- | ----------- | ------------------------------------- |
| `priority_clock` | input     | 1     | self         |          |             | Input priority clock signal.          |
| `fallback_clock` | input     | 1     | self         |          |             | Input fallback clock signal.          |
| `resetn`         | input     | 1     | asynchronous | self     | `0`         | Asynchronous active-low reset signal. |
| `clock_out`      | output    | 1     | derived      | `resetn` | `0`         | Divided clock output signal.          |

## Operation

The selector is made of a running clock detector and a multiplexor.

The detector uses a synchronizer clocked by the fallback clock and reset by the falling edges of the priority clock. Its input is tied high. Therefore, when the priority clock is running, the synchronizer is constantly reset and its output stays low ; and when the priority clock is not running but the fallback clock is, then the output becomes high in a few cycles. The output of the synchronizer is the `priority_clock_not_running` signal.

This signal is then used as the select signal of a `nonstop_clock_multiplexer` such that when the priority clock is running, it is selected, and when it is not, the fallback clock is selected. The non-stop variant of the clock multiplexer is critical to ensure that the transition can occur.

## Paths

| From             | To          | Type       | Comment |
| ---------------- | ----------- | ---------- | ------- |
| `priority_clock` | `clock_out` | sequential |         |
| `fallback_clock` | `clock_out` | sequential |         |

## Verification

The priority clock selector is verified using a SystemVerilog testbench with eight check sequences, and a passive check for glitches. It uses a helper macro to measure the frequency of the output clock.

The following table lists the checks performed by the testbench.

| Number | Check               | Description                               |
| ------ | ------------------- | ----------------------------------------- |
| 1      | No clock running    | Start with no clock running.              |
| 2      | Fallback clock only | Start the fallback clock only.            |
| 3      | Both clocks running | Start the priority clock as well.         |
| 4      | Priority clock only | Stop the fallback clock only.             |
| 5      | No clock running    | Stop both clocks again.                   |
| 6      | Priority clock only | Start the priority clock first this time. |
| 7      | Both clocks running | Start the fallback clock.                 |
| 8      | Fallback clock only | Stop the priority clock first this time.  |

The following table lists the parameter values verified by the testbench.

| `STAGES` |           |
| -------- | --------- |
| 2        | (default) |

## Constraints

A `generated_clock` should be created on the output pin of the `clock_divided` flip-flop of the clock divider. For even division factors, `-divide_by` can be used since the duty cycle is 50%. For odd divisions factors, `-edges` must be used instead, with the high pulses being one more input clock cycle than the low pulses.

```tcl
# For an even division factor, the -divide_by argument can be used as the duty cycles is 50%
create_generated_clock -name  -source [get_pins priority_clock_selector/clock_in] -divide_by 2 [get_pins priority_clock_selector/priority_clock_selector_reg/Q]

# For an odd division factor, the -edges argument should be used instead
create_generated_clock -name  -source [get_pins priority_clock_selector/clock_in] -edges {0 4 6} [get_pins priority_clock_selector/priority_clock_selector_reg/Q]
```

## Deliverables

| Type              | File                                                                               | Description                                         |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`priority_clock_selector.v`](priority_clock_selector.v)                           | Verilog design.                                     |
| Testbench         | [`priority_clock_selector.testbench.sv`](priority_clock_selector.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`priority_clock_selector.testbench.gtkw`](priority_clock_selector.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`priority_clock_selector.symbol.sss`](priority_clock_selector.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`priority_clock_selector.symbol.svg`](priority_clock_selector.symbol.svg)         | Generated vector image of the symbol.               |
| Datasheet         | [`priority_clock_selector.md`](priority_clock_selector.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                      | Path                                                               | Comment                                  |
| --------------------------- | ------------------------------------------------------------------ | ---------------------------------------- |
| `nonstop_clock_multiplexer` | `omnicores-buildingblocks/sources/clock/nonstop_clock_multiplexer` | Core clock multiplexer.                  |
| `fast_clock_multiplexer`    | `omnicores-buildingblocks/sources/clock/fast_clock_multiplexer`    | Dependency of the clock multiplexer.     |
| `synchronizer`              | `omnicores-buildingblocks/sources/timing/synchronizer`             | Used for disable signal synchronization. |
| `fast_synchronizer`         | `omnicores-buildingblocks/sources/timing/fast_synchronizer`        | Used for enable signal synchronization.  |

## Related modules

| Module                                                                                   | Path                                                               | Comment                                                   |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------- |
| [`switchover_clock_selector`](../switchover_clock_selector/switchover_clock_selector.md) | `omnicores-buildingblocks/sources/clock/switchover_clock_selector` | Selector that switches to a second clock onces it starts. |
| [`clock_gater`](../clock_gater/clock_gater.md)                                           | `omnicores-buildingblocks/sources/clock/clock_gater`               | Clock gater behavioral model.                             |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md)                         | `omnicores-buildingblocks/sources/clock/clock_multiplexer`         | Multiplexer to select between clocks.                     |
| [`fast_clock_multiplexer`](../fast_clock_multiplexer/fast_clock_multiplexer.md)          | `omnicores-buildingblocks/sources/clock/fast_clock_multiplexer`    | Faster clock multiplexer.                                 |
| [`nonstop_clock_multiplexer`](../nonstop_clock_multiplexer/nonstop_clock_multiplexer.md) | `omnicores-buildingblocks/sources/clock/nonstop_clock_multiplexer` | Clock multiplexer working when one clock is not running.  |
