# Rotate Left

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Rotate Left                                                                      |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![rotate_left](rotate_left.symbol.svg)

Rotates an input vector `data_in` to the left by a static number of bits specified by the `ROTATION` parameter. The bits shifted out from the most significant bit (MSB) are wrapped around to the least significant bit (LSB).

## Parameters

| Name       | Type    | Allowed Values | Default | Description                                                                                                                                                     |
| ---------- | ------- | -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WIDTH`    | integer | `>0`           | `8`     | Bit width of the data vector.                                                                                                                                   |
| `ROTATION` | integer | `≥0`           | `1`     | Number of bit positions to rotate to the left.<br/Rotation by zero doesn't reorder the data.<br/>Rotation by `WIDTH` or more is effectively `ROTATION % WIDTH`. |

## Ports

| Name       | Direction | Width   | Clock        | Reset | Reset value | Description                      |
| ---------- | --------- | ------- | ------------ | ----- | ----------- | -------------------------------- |
| `data_in`  | input     | `WIDTH` | asynchronous |       |             | Input data vector to be rotated. |
| `data_out` | output    | `WIDTH` | asynchronous |       |             | Left-rotated output data vector. |

## Operation

The module performs a left circular rotation of the `data_in` vector by `ROTATION` bit positions. This is implemented within a Verilog function by first creating a `2×WIDTH`-bit temporary vector, `data_extended`, by concatenating `data_in` with itself (`{data_in, data_in}`). The final `data_out` is then obtained by selecting `WIDTH` bits from `data_extended` starting at bit position `WIDTH - (ROTATION % WIDTH)`.

## Paths

| From      | To         | Type          | Comment                                                 |
| --------- | ---------- | ------------- | ------------------------------------------------------- |
| `data_in` | `data_out` | combinational | No logic, only reordering of the bits within the vector |

## Complexity

The operation is only a static reordering of the bits within the vector. Therefore, this module is zero-cost.

## Verification

The rotate left module is verified using a SystemVerilog testbench with three check sequences.

The following table lists the checks performed by the testbench.

| Number | Check        | Description                                                                                           |
| ------ | ------------ | ----------------------------------------------------------------------------------------------------- |
| 1      | Walking one  | With input all zero and a single one, iterate through all bit positions and verify correct output.   |
| 2      | Walking zero | With input all ones and a single zero, iterate through all bit positions and verify correct output.  |
| 3      | Random       | With random input data, verify correct outputs.                                                       |

The following table lists the parameter values verified by the testbench.

| `WIDTH` | `ROTATION` |           |
| ------- | ---------- | --------- |
| 8       | 1          | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                     | Description                                         |
| ----------------- | -------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`rotate_left.v`](rotate_left.v)                         | Verilog design file.                                |
| Testbench         | [`rotate_left.testbench.sv`](rotate_left.testbench.sv)   | SystemVerilog verification testbench.               |
| Waveform script   | [`rotate_left.testbench.gtkw`](rotate_left.testbench.gtkw) | Script to load waveforms in GTKWave.                |
| Symbol descriptor | [`rotate_left.symbol.sss`](rotate_left.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`rotate_left.symbol.svg`](rotate_left.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`rotate_left.symbol.drawio`](rotate_left.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`rotate_left.md`](rotate_left.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                                                    | Path                                                               | Comment                                    |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------ |
| [`barrel_rotator_left`](../barrel_rotator_left/barrel_rotator_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`  | Barrel rotator for dynamic left rotation.  |
| [`barrel_rotator_right`](../barrel_rotator_right/barrel_rotator_right.md) | `omnicores-buildingblocks/sources/operations/barrel_rotator_right` | Barrel rotator for dynamic right rotation. |
| [`rotate_right`](../rotate_right/rotate_right.md)                         | `omnicores-buildingblocks/sources/operations/rotate_right`         | Static right rotation with fixed amount.   |
| [`barrel_shifter_left`](../barrel_shifter_left/barrel_shifter_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_shifter_left`  | Barrel shifter for dynamic left shift.     |
| [`barrel_shifter_right`](../barrel_shifter_right/barrel_shifter_right.md) | `omnicores-buildingblocks/sources/operations/barrel_shifter_right` | Barrel shifter for dynamic right shift.    |


