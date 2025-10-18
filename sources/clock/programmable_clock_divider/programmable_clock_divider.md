# Programmable Clock Divider

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Programmable Clock Divider                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![programmable_clock_divider](programmable_clock_divider.symbol.svg)

Divides the frequency of the input clock `clock_in` by a programmable factor provided by the `division` input. The output clock `clock_out` is guaranteed to be glitch-free, even when the division factor is changed dynamically (but it must stay synchronous to the input clock). The module has two variants selected by the `POWER_OF_TWO` parameter: decimal division (division by `division + 1`) and power-of-two division (division by `2^division`). When `division = 0`, `clock_in` is directly passed through to `clock_out` via an internal glitchless clock multiplexer, this is the passthrough mode.

![programmable_clock_divider](programmable_clock_divider.wavedrom.svg)

## Parameters

| Name             | Type    | Allowed Values | Default | Description                                                                                                |
| ---------------- | ------- | -------------- | ------- | ---------------------------------------------------------------------------------------------------------- |
| `DIVISION_WIDTH` | integer | `>0`           | `4`     | Width of the `division` input port.                                                                        |
| `POWER_OF_TWO`   | integer | `0`, `1`       | `0`     | Selects the division mode.<br/>• `0`: division by `division + 1`.<br/>• `1`: for division by `2^division`. |

## Ports

| Name        | Direction | Width            | Clock        | Reset    | Reset value | Description                           |
| ----------- | --------- | ---------------- | ------------ | -------- | ----------- | ------------------------------------- |
| `clock_in`  | input     | 1                | self         |          |             | Input clock signal.                   |
| `resetn`    | input     | 1                | asynchronous | self     | active-low  | Asynchronous active-low reset signal. |
| `division`  | input     | `DIVISION_WIDTH` | `clock_in`   |          |             | Programmable division factor.         |
| `clock_out` | output    | 1                | derived      | `resetn` | `0`         | Divided clock output signal.          |

## Operation

The `division` factor is registered internally to ensure glitch-free operation. The new division factor from the input is sampled at the end of a full output clock cycle, allowing the division rate to be changed dynamically without corrupting the output clock. For `division = 0`, the module operates in passthrough mode, forwarding `clock_in` to `clock_out`.

The module's behavior is determined by the `POWER_OF_TWO` parameter:

In **fine decimal division mode** (`POWER_OF_TWO = 0`), the module divides the clock frequency by `division + 1`. For odd division factors, the high pulse of `clock_out` is one `clock_in` cycle longer than the low pulse. For even factors, the duty cycle is exactly 50%. This is implemented with a decrementing counter to time the duration of the high and low pulses of the output clock.

In **coarse power-of-two division mode** (`POWER_OF_TWO = 1`), the module divides the clock frequency by `2^division`. This allows for a very large division range. The output clock has a perfect 50% duty cycle. This is implemented using a decrementing counter that times a half-period of the output clock, toggling the output clock when it reaches zero. This mode requires a larger internal counter and more complex combinational logic (a barrel shifter) to calculate the reload value, but offers an exponential division range.

## Paths

| From       | To          | Type         | Comment                                                               |
| ---------- | ----------- | ------------ | --------------------------------------------------------------------- |
| `clock_in` | `clock_out` | pass-through | When `division_reg = 0`. Handled by the internal `clock_multiplexer`. |
| `clock_in` | `clock_out` | sequential   | When `division_reg > 0`. Output is registered.                        |

## Complexity

| `POWER_OF_TWO` | Delay                 | Gates                                  |
| -------------- | --------------------- | -------------------------------------- |
| `0`            | `O(DIVISION_WIDTH)`   | `O(DIVISION_WIDTH)`                    |
| `1`            | `O(2^DIVISION_WIDTH)` | `O(DIVISION_WIDTH * 2^DIVISION_WIDTH)` |

## Verification

The programmable clock divider is verified using a SystemVerilog testbench a single check sequence. It uses a helper macro to measure the frequency of the output clock.

The following table lists the checks performed by the testbench.

| Number | Check                    | Description                               |
| ------ | ------------------------ | ----------------------------------------- |
| 1      | Output divided frequency | Checks the frequency of the output clock. |

The following table lists the parameter values verified by the testbench.

| `POWER_OF_TWO` | `DIVISION_WIDTH` |           |
| -------------- | ---------------- | --------- |
| `0`            | `4`              | (default) |

## Constraints

The constraints file `programmable_clock_divider.sdc` contains the procedure `::omnicores::buildingblocks::timing::programmable_clock_divider::apply_constraints_to_instance`. It takes as parameter the hierarchical path to the instance of the clock divider, and as optional parameter the guaranteed minimum division factor.

```tcl
set programmable_clock_divider_path "path/to/programmable_clock_divider"
set minimum_division_factor 1

::omnicores::buildingblocks::timing::programmable_clock_divider::apply_constraints_to_instance $programmable_clock_divider_path $minimum_division_factor
```

The procedure fetches all the clocks defined on the input clock pin, and creates a generated clock on the output clock pin for each of them. Since the division factor is programmable, the generated clock are defined with a `divide_by` and the minimum division factor required. By default, this minimum is a division by 1 (`division = 0`), meaning that the clock is passed through at the same frequency. Another minimum division factor can be provided as an argument of the procedure.

The procedure also calls the contraints of the clock multiplexer for the instanced used for the pass-through mode.

To call the procedure automatically on all instances of the clock divider, use the common procedure `::omnicores::common::apply_constraints_to_all_module_instances` with the module name `programmable_clock_divider` and the constraints procedure `::omnicores::buildingblocks::timing::programmable_clock_divider::apply_constraints_to_instance`. It will search the design for all instances of the module and call the constraints procedure on each.

```tcl
::omnicores::common::apply_constraints_to_all_module_instances "programmable_clock_divider" "::omnicores::buildingblocks::timing::programmable_clock_divider::apply_constraints_to_instance"
```

**Important:** the constraints procedure should be called after all clocks on the input pin have been declared. If the input clocks are defined by other OmniCores procedures, they should be called in order of the clock tree. The procedure will print a warning if no clocks are defined on the input clock pin, but it cannot detect if other clocks are added after the procedure is called. This is especially important when applying the constraints automatically on all instances as the order cannot be controlled.

Special gates (AND, OR, NOT) made for clock paths can be used for better results if they are available in the technology node.

## Deliverables

| Type                | File                                                                                     | Description                                         |
| ------------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`programmable_clock_divider.v`](programmable_clock_divider.v)                           | Verilog design.                                     |
| Testbench           | [`programmable_clock_divider.testbench.sv`](programmable_clock_divider.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script     | [`programmable_clock_divider.testbench.gtkw`](programmable_clock_divider.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Constraint script   | [`programmable_clock_divider.sdc`](programmable_clock_divider.sdc)                       | Tickle SDC constraint script for synthesis.         |
| Symbol descriptor   | [`programmable_clock_divider.symbol.sss`](programmable_clock_divider.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`programmable_clock_divider.symbol.svg`](programmable_clock_divider.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape        | [`programmable_clock_divider.symbol.drawio`](programmable_clock_divider.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Waveform descriptor | [`programmable_clock_divider.wavedrom.json`](programmable_clock_divider.wavedrom.json)   | Waveform descriptor for Wavedrom.                   |
| Waveform image      | [`programmable_clock_divider.wavedrom.svg`](programmable_clock_divider.wavedrom.svg)     | Generated image of the waveform.                    |
| Datasheet           | [`programmable_clock_divider.md`](programmable_clock_divider.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                           | Path                                                       | Comment                                             |
| ---------------------------------------------------------------- | ---------------------------------------------------------- | --------------------------------------------------- |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md) | `omnicores-buildingblocks/sources/clock/clock_multiplexer` | Used for glitch-free switching to passthrough mode. |
| [`synchronizer`](../../timing/synchronizer/synchronizer.md)      | `omnicores-buildingblocks/sources/timing/synchronizer`     | Used in the clock multiplexer.                      |
| `clog2.vh`                                                       | `omnicores-buildingblocks/sources/common`                  | Common function include.                            |

## Related modules

| Module                                                                                               | Path                                                                   | Comment                                         |
| ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | ----------------------------------------------- |
| [`programmable_clock_multiplier`](../programmable_clock_multiplier/programmable_clock_multiplier.md) | `omnicores-buildingblocks/sources/clock/programmable_clock_multiplier` | Programmable clock multiplier behavioral model. |
| [`static_clock_divider`](../static_clock_divider/static_clock_divider.md)                            | `omnicores-buildingblocks/sources/clock/static_clock_divider`          | Statically configured version of this module.   |
| [`clock_gater`](../clock_gater/clock_gater.md)                                                       | `omnicores-buildingblocks/sources/clock/clock_gater`                   | Clock gater.                                    |
| [`clock_multiplexer`](../clock_multiplexer/clock_multiplexer.md)                                     | `omnicores-buildingblocks/sources/clock/clock_multiplexer`             | Multiplexer to select between clocks.           |
