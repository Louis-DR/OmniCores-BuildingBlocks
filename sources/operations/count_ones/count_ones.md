# Count Ones

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Count Ones                                                                       |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![count_ones](count_ones.symbol.svg)

Counts the number of high bits (ones) in an input data vector (also known as the population count). It is widely used in digital systems for bit manipulation, error detection, Hamming weight calculations, and various algorithms requiring bit density analysis.

## Parameters

| Name          | Type    | Allowed Values | Default               | Description                           |
| ------------- | ------- | -------------- | --------------------- | ------------------------------------- |
| `DATA_WIDTH`  | integer | `≥1`           | `8`                   | Bit width of the input data vector.   |
| `COUNT_WIDTH` | integer | `≥1`           | `CLOG2(DATA_WIDTH+1)` | Bit width of the output count vector. |

## Ports

| Name    | Direction | Width         | Clock        | Reset | Reset value | Description                                |
| ------- | --------- | ------------- | ------------ | ----- | ----------- | ------------------------------------------ |
| `data`  | input     | `DATA_WIDTH`  | asynchronous |       |             | Input data vector for which to count ones. |
| `count` | output    | `COUNT_WIDTH` | asynchronous |       |             | Number of ones in the input data vector.   |

## Operation

The count ones operation examines each bit of the input data vector and accumulates the total number of bits that are set to '1'. The operation is implemented using a function that iterates through all bit positions and increments a counter for each high bit encountered.

For an input data vector of width N, the output count can range from 0 (all bits are zero) to N (all bits are one). The `COUNT_WIDTH` parameter is automatically calculated as `CLOG2(DATA_WIDTH+1)` to ensure sufficient bits to represent all possible count values.

## Paths

| From   | To      | Type          | Comment                                                |
| ------ | ------- | ------------- | ------------------------------------------------------ |
| `data` | `count` | combinational | Direct combinational logic for bit counting operation. |

## Complexity

| Delay                | Gates           | Comment                                                   |
| -------------------- | --------------- | --------------------------------------------------------- |
| `O(log₂ DATA_WIDTH)` | `O(DATA_WIDTH)` | Adder tree structure for efficient parallel bit counting. |

The implementation uses a function-based approach which synthesizers typically optimize into an efficient adder tree structure. The delay is logarithmic in the data width due to the tree-like accumulation of partial sums, while the gate count is linear in the input width.

## Verification

The count ones module is verified using a comprehensive SystemVerilog testbench that validates the counting correctness across various input patterns and bit configurations.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                                    |
| ------ | --------------- | ---------------------------------------------------------------------------------------------- |
| 1a     | Exhaustive test | If `DATA_WIDTH` ≤ 10, checks the count operation for all possible input values.                |
| 1b     | Directed test   | If `DATA_WIDTH` > 10, checks specific patterns: all zeros, all ones, walking patterns, shifts. |
| 2b     | Random test     | If `DATA_WIDTH` > 10, checks the count operation for random input values.                      |

The directed patterns include:
- **All zeros**: Verifies count = 0
- **All ones**: Verifies count = DATA_WIDTH
- **Walking ones**: Single bit walking through all positions
- **Walking zeros**: Single zero bit walking through all-ones pattern
- **Shifting ones**: Progressive patterns like 0001, 0011, 0111, 1111
- **Shifting zeros**: Progressive patterns like 1110, 1100, 1000, 0000

The following table lists the parameter values verified by the testbench.

| `DATA_WIDTH` |           |
| ------------ | --------- |
| 8            | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                     | Description                                         |
| ----------------- | -------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`count_ones.v`](count_ones.v)                           | Verilog design.                                     |
| Testbench         | [`count_ones.testbench.sv`](count_ones.testbench.sv)     | SystemVerilog verification testbench.               |
| Waveform script   | [`count_ones.testbench.gtkw`](count_ones.testbench.gtkw) | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`count_ones.symbol.sss`](count_ones.symbol.sss)         | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`count_ones.symbol.svg`](count_ones.symbol.svg)         | Generated vector image of the symbol.               |
| Symbol shape      | [`count_ones.symbol.drawio`](count_ones.symbol.drawio)   | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`count_ones.md`](count_ones.md)                         | Markdown documentation datasheet.                   |

## Dependencies

| Module                           | Path                                      | Comment                                      |
| -------------------------------- | ----------------------------------------- | -------------------------------------------- |
| [`clog2`](../../common/clog2.vh) | `omnicores-buildingblocks/sources/common` | Ceiling log2 function for width calculation. |

## Related modules

| Module                                   | Path                                                    | Comment                         |
| ---------------------------------------- | ------------------------------------------------------- | ------------------------------- |
| [`first_one`](../first_one/first_one.md) | `omnicores-buildingblocks/sources/operations/first_one` | Find position of first set bit. |
