# Right Shift

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Right Shift                                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![shift_right](shift_right.symbol.svg)

Shifts an input vector `data_in` to the right by a static number of bits specified by the `SHIFT` parameter and pad the left side with the value `PAD_VALUE`.

## Parameters

| Name        | Type    | Allowed Values | Default | Description                                                                                                                                                               |
| ----------- | ------- | -------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WIDTH`     | integer | `>0`           | `8`     | Bit width of the data vector.                                                                                                                                             |
| `SHIFT`     | integer | `≥0`           | `1`     | Number of bit positions to rotate to the right.<br/Shifting by zero doesn't reorder the data.<br/>Shifting by `WIDTH` or more sets all bits of `data_out` to `PAD_VALUE`. |
| `PAD_VALUE` | bit     | `1'b0`, `1'b1` | `1'b0`  | Value by which to pad on the left side.                                                                                                                                   |

## Ports

| Name       | Direction | Width   | Clock        | Reset | Reset value | Description                       |
| ---------- | --------- | ------- | ------------ | ----- | ----------- | --------------------------------- |
| `data_in`  | input     | `WIDTH` | asynchronous |       |             | Input data vector to be shifted.  |
| `data_out` | output    | `WIDTH` | asynchronous |       |             | Right-shifted output data vector. |

## Operation

The module performs a right shift of the `data_in` vector by `SHIFT` bit positions. This is implemented within a Verilog function by first creating a `2×WIDTH`-bit temporary vector, `data_extended`, by concatenating `data_in` with the padding value. The final `data_out` is then obtained by selecting `WIDTH` bits from `data_extended`.

## Paths

| From      | To         | Type          | Comment                                                            |
| --------- | ---------- | ------------- | ------------------------------------------------------------------ |
| `data_in` | `data_out` | combinational | No logic, only reordering and replacing the bits within the vector |

## Complexity

The operation is only a static reordering and replacing of the bits within the vector. Therefore, this module is zero-cost.

## Verification

The shift right module is verified using a SystemVerilog testbench with three check sequences.

The following table lists the checks performed by the testbench.

| Number | Check        | Description                                                                                           |
| ------ | ------------ | ----------------------------------------------------------------------------------------------------- |
| 1      | Walking one  | With input all zero and a single one, iterate through all bit positions and verify correct output.   |
| 2      | Walking zero | With input all ones and a single zero, iterate through all bit positions and verify correct output.  |
| 3      | Random       | With random input data, verify correct outputs.                                                       |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `SHIFT` | `PAD_VALUE` |           |
| ------- | ------- | ----------- | --------- |
| 8       | 1       | 0           | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`shift_right.v`](shift_right.v)                             | Verilog design file.                                |
| Testbench         | [`shift_right.testbench.sv`](shift_right.testbench.sv)       | SystemVerilog verification testbench.               |
| Waveform script   | [`shift_right.testbench.gtkw`](shift_right.testbench.gtkw)   | Script to load waveforms in GTKWave.                |
| Symbol descriptor | [`shift_right.symbol.sss`](shift_right.symbol.sss)           | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`shift_right.symbol.svg`](shift_right.symbol.svg)           | Generated vector image of the symbol.               |
| Symbol shape      | [`shift_right.symbol.drawio`](shift_right.symbol.drawio)     | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`shift_right.md`](shift_right.md)                           | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                    | Path                                                               | Comment                                    |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------ |
| [`barrel_shifter_left`](../barrel_shifter_left/barrel_shifter_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_shifter_left`  | Barrel shifter for dynamic left shift.     |
| [`barrel_shifter_right`](../barrel_shifter_right/barrel_shifter_right.md) | `omnicores-buildingblocks/sources/operations/barrel_shifter_right` | Barrel shifter for dynamic right shift.    |
| [`shift_left`](../shift_left/shift_left.md)                               | `omnicores-buildingblocks/sources/operations/shift_left`           | Static left shift with fixed amount.       |
| [`barrel_rotator_left`](../barrel_rotator_left/barrel_rotator_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`  | Barrel rotator for dynamic left rotation.  |
| [`barrel_rotator_right`](../barrel_rotator_right/barrel_rotator_right.md) | `omnicores-buildingblocks/sources/operations/barrel_rotator_right` | Barrel rotator for dynamic right rotation. |


