# Barrel Rotator Right

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Barrel Rotator Right                                                             |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![barrel_rotator_right](barrel_rotator_right.symbol.svg)

Rotates an input vector `data_in` to the right by a dynamic number of bit positions specified by the `rotation` input. The bits shifted out from the least significant bit (LSB) are wrapped around to the most significant bit (MSB).

The `rotation` value should not exceed `DATA_WIDTH`, else the behavior is unspecified.

## Parameters

| Name             | Type    | Allowed Values               | Default            | Description                               |
| ---------------- | ------- | ---------------------------- | ------------------ | ----------------------------------------- |
| `DATA_WIDTH`     | integer | `>0`                         | `8`                | Bit width of the data vector.             |
| `ROTATION_WIDTH` | integer | `>0` and `≤log₂(DATA_WIDTH)` | `log₂(DATA_WIDTH)` | Bit width of the rotation control signal. |

## Ports

| Name       | Direction | Width            | Clock        | Reset | Reset value | Description                          |
| ---------- | --------- | ---------------- | ------------ | ----- | ----------- | ------------------------------------ |
| `data_in`  | input     | `DATA_WIDTH`     | asynchronous |       |             | Input data vector to be rotated.     |
| `rotation` | input     | `ROTATION_WIDTH` | asynchronous |       |             | Number of positions to rotate right. |
| `data_out` | output    | `DATA_WIDTH`     | asynchronous |       |             | Right-rotated output data vector.    |

## Operation

The module performs a right circular rotation of the `data_in` vector by `rotation` bit positions. This is implemented by first creating a `2×DATA_WIDTH`-bit temporary vector, `data_in_extended`, by concatenating `data_in` with itself (`{data_in, data_in}`). The final `data_out` is then obtained by selecting `DATA_WIDTH` bits from `data_in_extended` starting at bit position `rotation`.

## Paths

| From       | To         | Type          | Comment                                                 |
| ---------- | ---------- | ------------- | ------------------------------------------------------- |
| `data_in`  | `data_out` | combinational | No logic, only reordering of the bits within the vector |
| `rotation` | `data_out` | combinational | Selects the rotation amount                             |

## Complexity

The operation is only a dynamic reordering of the bits within the vector. Synthesis tools typically implement this using a barrel-shifter structure or a multiplexer network. The delay is logarithmic with respect to `DATA_WIDTH`.

| Delay           | Gates                   | Comment                       |
| --------------- | ----------------------- | ----------------------------- |
| `O(log₂ WIDTH)` | `O(WIDTH × log₂ WIDTH)` | Multiplexer network structure |

## Verification

The barrel rotator right module is verified using a SystemVerilog testbench with three check sequences.

The following table lists the checks performed by the testbench.

| Number | Check        | Description                                                                                           |
| ------ | ------------ | ----------------------------------------------------------------------------------------------------- |
| 1      | Walking one  | With input all zero and a single one, iterate through all rotation values and verify correct output.  |
| 2      | Walking zero | With input all ones and a single zero, iterate through all rotation values and verify correct output. |
| 3      | Random       | With random input data and rotation, verify correct outputs.                                          |

The following table lists the parameter values verified by the testbench.

| `DATA_WIDTH` | `ROTATION_WIDTH` |           |
| ------------ | ---------------- | --------- |
| 8            | 3                | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                         | Description                                         |
| ----------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`barrel_rotator_right.v`](barrel_rotator_right.v)                           | Verilog design file.                                |
| Testbench         | [`barrel_rotator_right.testbench.sv`](barrel_rotator_right.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`barrel_rotator_right.testbench.gtkw`](barrel_rotator_right.testbench.gtkw) | Script to load waveforms in GTKWave.                |
| Symbol descriptor | [`barrel_rotator_right.symbol.sss`](barrel_rotator_right.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`barrel_rotator_right.symbol.svg`](barrel_rotator_right.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`barrel_rotator_right.symbol.drawio`](barrel_rotator_right.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`barrel_rotator_right.md`](barrel_rotator_right.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                              | Path                                      | Comment                            |
| ----------------------------------- | ----------------------------------------- | ---------------------------------- |
| [`clog2.vh`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | For computing `CLOG2(DATA_WIDTH)`. |

## Related modules

| Module                                                                    | Path                                                               | Comment                                   |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------- |
| [`barrel_rotator_left`](../barrel_rotator_left/barrel_rotator_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`  | Barrel rotator for dynamic left rotation. |
| [`barrel_shifter_left`](../barrel_shifter_left/barrel_shifter_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_shifter_left`  | Barrel shifter for dynamic left shift.    |
| [`barrel_shifter_right`](../barrel_shifter_right/barrel_shifter_right.md) | `omnicores-buildingblocks/sources/operations/barrel_shifter_right` | Barrel shifter for dynamic right shift.   |
| [`rotate_right`](../rotate_right/rotate_right.md)                         | `omnicores-buildingblocks/sources/operations/rotate_right`         | Static right rotation with fixed amount.  |



