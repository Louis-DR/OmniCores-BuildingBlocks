# Switchover Clock Selector

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Switchover Clock Selector                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![switchover_clock_selector](switchover_clock_selector.symbol.svg)

Clock switchover mechanism that starts on the first clock, then switches to the second clock once it is running.

## Parameters

| Name     | Type    | Allowed Values | Default | Description                                              |
| -------- | ------- | -------------- | ------- | -------------------------------------------------------- |
| `STAGES` | integer | `≥1`           | `2`     | Number of synchronization stages for the internal logic. |

## Ports

| Name           | Direction | Width | Clock        | Reset    | Reset value | Description                           |
| -------------- | --------- | ----- | ------------ | -------- | ----------- | ------------------------------------- |
| `first_clock`  | input     | 1     | self         |          |             | Input first clock signal.             |
| `second_clock` | input     | 1     | self         |          |             | Input second clock signal.            |
| `resetn`       | input     | 1     | asynchronous | self     | `0`         | Asynchronous active-low reset signal. |
| `clock_out`    | output    | 1     | derived      | `resetn` | `0`         | Output clock signal.                  |

## Operation

The switchover mechanism starts with the first clock active. When the second clock starts running, the module detects this and switches to the second clock, disabling the first clock to prevent glitches.

## Paths

| From           | To          | Type       | Comment |
| -------------- | ----------- | ---------- | ------- |
| `first_clock`  | `clock_out` | sequential |         |
| `second_clock` | `clock_out` | sequential |         |

## Verification

The switchover clock selector is verified using a SystemVerilog testbench with four check sequences, and a passive check for glitches. It uses a helper macro to measure the frequency of the output clock.

The following table lists the checks performed by the testbench.

| Number | Check               | Description                        |
| ------ | ------------------- | ---------------------------------- |
| 1      | No clock running    | Start with no clock running.       |
| 2      | Start first clock   | Start the first clock only.        |
| 3      | Start second clock  | Start the second clock as well.    |
| 4      | Stop first clock    | Stop the first clock only.         |

The following table lists the parameter values verified by the testbench.

| `STAGES` |           |
| -------- | --------- |
| 2        | (default) |

## Deliverables

| Type              | File                                                                                                   | Description                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`switchover_clock_selector.v`](switchover_clock_selector.v)                                           | Verilog design.                                     |
| Testbench         | [`switchover_clock_selector.testbench.sv`](switchover_clock_selector.testbench.sv)                     | SystemVerilog verification testbench.               |
| Waveform script   | [`switchover_clock_selector.testbench.gtkw`](switchover_clock_selector.testbench.gtkw)                 | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`switchover_clock_selector.symbol.sss`](switchover_clock_selector.symbol.sss)                         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`switchover_clock_selector.symbol.svg`](switchover_clock_selector.symbol.svg)                         | Generated vector image of the symbol.               |
| Datasheet         | [`switchover_clock_selector.md`](switchover_clock_selector.md)                                         | Markdown documentation datasheet.                   |

## Dependencies

| Module         | Path                                                    | Comment                                  |
| -------------- | ------------------------------------------------------- | ---------------------------------------- |
| `synchronizer` | `omnicores-buildingblocks/sources/timing/synchronizer` | Used for enable signal synchronization. |

## Related modules

| Module                                                                                   | Path                                                               | Comment                                                  |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------------- |
| [`clock_gater`](../clock_gater/clock_gater.md)                                           | `omnicores-buildingblocks/sources/clock/clock_gater`               | Clock gater behavioral model.                            |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md)                         | `omnicores-buildingblocks/sources/clock/clock_multiplexer`         | Multiplexer to select between clocks.                    |
| [`priority_clock_selector`](../priority_clock_selector/priority_clock_selector.md)       | `omnicores-buildingblocks/sources/clock/priority_clock_selector`   | Priority-based clock selector.                           |