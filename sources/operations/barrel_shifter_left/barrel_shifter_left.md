# Barrel Shifter Left

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Barrel Shifter Left                                                              |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![barrel_shifter_left](barrel_shifter_left.symbol.svg)

Shifts an input vector `data_in` to the left by a dynamic number of bit positions specified by the `shift` input and pads the right side with the value `pad_value`.

The `shift` value should not exceed `DATA_WIDTH`, else the behavior is unspecified.

## Parameters

| Name          | Type    | Allowed Values               | Default            | Description                            |
| ------------- | ------- | ---------------------------- | ------------------ | -------------------------------------- |
| `DATA_WIDTH`  | integer | `>0`                         | `8`                | Bit width of the data vector.          |
| `SHIFT_WIDTH` | integer | `>0` and `≤log₂(DATA_WIDTH)` | `log₂(DATA_WIDTH)` | Bit width of the shift control signal. |

## Ports

| Name        | Direction | Width         | Clock        | Reset | Reset value | Description                              |
| ----------- | --------- | ------------- | ------------ | ----- | ----------- | ---------------------------------------- |
| `data_in`   | input     | `DATA_WIDTH`  | asynchronous |       |             | Input data vector to be shifted.         |
| `shift`     | input     | `SHIFT_WIDTH` | asynchronous |       |             | Number of positions to shift left.       |
| `pad_value` | input     | 1             | asynchronous |       |             | Value by which to pad on the right side. |
| `data_out`  | output    | `DATA_WIDTH`  | asynchronous |       |             | Left-shifted output data vector.         |

## Operation

The module performs a left shift of the `data_in` vector by `shift` bit positions. This is implemented by first creating a `2×DATA_WIDTH`-bit temporary vector, `data_in_extended`, by concatenating `data_in` with a vector of `DATA_WIDTH` bits all set to `pad_value`. The final `data_out` is then obtained by selecting `DATA_WIDTH` bits from `data_in_extended` starting at bit position `DATA_WIDTH - shift`.

## Paths

| From        | To         | Type          | Comment                                                            |
| ----------- | ---------- | ------------- | ------------------------------------------------------------------ |
| `data_in`   | `data_out` | combinational | No logic, only reordering and replacing the bits within the vector |
| `shift`     | `data_out` | combinational | Selects the shift amount                                           |
| `pad_value` | `data_out` | combinational | Determines the value of the padded bits                            |

## Complexity

The operation is only a dynamic reordering and replacing of the bits within the vector. Synthesis tools typically implement this using a barrel-shifter structure or a multiplexer network. The delay is logarithmic with respect to `DATA_WIDTH`.

| Delay           | Gates                   | Comment                       |
| --------------- | ----------------------- | ----------------------------- |
| `O(log₂ WIDTH)` | `O(WIDTH × log₂ WIDTH)` | Multiplexer network structure |

## Verification

The barrel shifter left module is verified using a SystemVerilog testbench with five check sequences.

The following table lists the checks performed by the testbench.

| Number | Check                            | Description                                                                                                           |
| ------ | -------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 1      | Walking one with pad value zero  | With input all zero and a single one and pad value zero, iterate through all shift values and verify correct output.  |
| 2      | Walking zero with pad value one  | With input all ones and a single zero and pad value one, iterate through all shift values and verify correct output.  |
| 3      | Walking one with pad value one   | With input all zero and a single one and pad value one, iterate through all shift values and verify correct output.   |
| 4      | Walking zero with pad value zero | With input all ones and a single zero and pad value zero, iterate through all shift values and verify correct output. |
| 5      | Random                           | With random input data, shift, and pad value, verify correct outputs.                                                 |

The following table lists the parameter values verified by the testbench.

| `DATA_WIDTH` | `SHIFT_WIDTH` |           |
| ------------ | ------------- | --------- |
| 8            | 3             | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                                       | Description                                         |
| ----------------- | -------------------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`barrel_shifter_left.v`](barrel_shifter_left.v)                           | Verilog design file.                                |
| Testbench         | [`barrel_shifter_left.testbench.sv`](barrel_shifter_left.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`barrel_shifter_left.testbench.gtkw`](barrel_shifter_left.testbench.gtkw) | Script to load waveforms in GTKWave.                |
| Symbol descriptor | [`barrel_shifter_left.symbol.sss`](barrel_shifter_left.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`barrel_shifter_left.symbol.svg`](barrel_shifter_left.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`barrel_shifter_left.symbol.drawio`](barrel_shifter_left.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`barrel_shifter_left.md`](barrel_shifter_left.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                              | Path                                      | Comment                            |
| ----------------------------------- | ----------------------------------------- | ---------------------------------- |
| [`clog2.vh`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | For computing `CLOG2(DATA_WIDTH)`. |

## Related modules

| Module                                                                    | Path                                                               | Comment                                    |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------ |
| [`barrel_shifter_right`](../barrel_shifter_right/barrel_shifter_right.md) | `omnicores-buildingblocks/sources/operations/barrel_shifter_right` | Barrel shifter for dynamic right shift.    |
| [`barrel_rotator_left`](../barrel_rotator_left/barrel_rotator_left.md)    | `omnicores-buildingblocks/sources/operations/barrel_rotator_left`  | Barrel rotator for dynamic left rotation.  |
| [`barrel_rotator_right`](../barrel_rotator_right/barrel_rotator_right.md) | `omnicores-buildingblocks/sources/operations/barrel_rotator_right` | Barrel rotator for dynamic right rotation. |
| [`shift_left`](../shift_left/shift_left.md)                               | `omnicores-buildingblocks/sources/operations/shift_left`           | Static left shift with fixed amount.       |



