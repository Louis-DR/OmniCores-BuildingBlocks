# Binary to Binary-Coded Decimal Encoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Binary to Binary-Coded Decimal Encoder                                           |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![binary_to_bcd](binary_to_bcd.symbol.svg)

Converts binary numbers to Binary-Coded Decimal (BCD) representation where each decimal digit is encoded using 4 bits. BCD encoding is widely used in digital systems for decimal arithmetic, display drivers, and applications where decimal precision is critical such as financial calculations and measurement systems.

## Parameters

| Name           | Type    | Allowed Values | Default                                 | Description                           |
| -------------- | ------- | -------------- | --------------------------------------- | ------------------------------------- |
| `WIDTH_BINARY` | integer | `≥1`           | `8`                                     | Bit width of the binary input vector. |
| `WIDTH_BCD`    | integer | `≥4`           | `BINARY_TO_BCD_WIDTH(WIDTH_BINARY) * 4` | Bit width of the BCD output vector.   |

## Ports

| Name     | Direction | Width          | Clock | Reset | Reset value | Description                 |
| -------- | --------- | -------------- | ----- | ----- | ----------- | --------------------------- |
| `binary` | input     | `WIDTH_BINARY` |       |       |             | Binary input to be encoded. |
| `bcd`    | output    | `WIDTH_BCD`    |       |       |             | BCD encoded output.         |

## Operation

The binary-to-BCD conversion uses the double-dabble algorithm, which iteratively shifts the binary input left while adjusting BCD digits to maintain valid decimal representation. The algorithm performs the following steps for each bit of the binary input:

1. **Check BCD digits**: For each 4-bit BCD digit, if the value is ≥ 5, add 3 to it
2. **Shift left**: Shift the entire scratch register (BCD + binary) left by 1 bit
3. **Repeat**: Continue for all bits of the binary input

## Paths

| From     | To    | Type          | Comment                                        |
| -------- | ----- | ------------- | ---------------------------------------------- |
| `binary` | `bcd` | combinatorial | Double-dabble algorithm with iterative shifts. |

## Complexity

| Delay             | Gates                         | Comment                                                 |
| ----------------- | ----------------------------- | ------------------------------------------------------- |
| `O(WIDTH_BINARY)` | `O(WIDTH_BINARY * WIDTH_BCD)` | Iterative algorithm requires WIDTH_BINARY shift stages. |

The conversion requires WIDTH_BINARY stages of conditional addition and shifting logic, resulting in a delay proportional to the binary input width. Each stage processes all BCD digits in parallel.

## Verification

The binary-to-BCD encoder is verified using a comprehensive SystemVerilog testbench that validates both the conversion correctness and the fundamental BCD encoding properties. The testbench instantiates and verifies both the `binary_to_bcd` and `bcd_to_binary` modules.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                                     |
| ------ | --------------- | ----------------------------------------------------------------------------------------------- |
| 1a     | Exhaustive test | If `WIDTH_BINARY` ≤ 10, checks the BCD encoding and its properties for all binary input values. |
| 1b     | Random test     | If `WIDTH_BINARY` > 10, checks the BCD encoding and its properties for random values.           |

The following table lists the parameter values verified by the testbench.

| `WIDTH_BINARY` |           |
| -------------- | --------- |
| 8              | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`binary_to_bcd.v`](binary_to_bcd.v)                         | Verilog design.                                     |
| Testbench         | [`bcd.testbench.sv`](bcd.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`bcd.testbench.gtkw`](bcd.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`binary_to_bcd.symbol.sss`](binary_to_bcd.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`binary_to_bcd.symbol.svg`](binary_to_bcd.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`binary_to_bcd.symbol.drawio`](binary_to_bcd.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`binary_to_bcd.md`](binary_to_bcd.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                    | Path                                                     | Comment                      |
| --------------------------------------------------------- | -------------------------------------------------------- | ---------------------------- |
| [`shift_left`](../../operations/shift_left/shift_left.md) | `omnicores-buildingblocks/sources/operations/shift_left` | Static left shift operation. |

## Related modules

| Module                                              | Path                                               | Comment                    |
| --------------------------------------------------- | -------------------------------------------------- | -------------------------- |
| [`bcd_to_binary`](bcd_to_binary.md)                 | `omnicores-buildingblocks/sources/encoding/bcd`    | BCD to binary decoder.     |
| [`binary_to_onehot`](../onehot/binary_to_onehot.md) | `omnicores-buildingblocks/sources/encoding/onehot` | Binary to one-hot encoder. |
| [`binary_to_grey`](../grey/binary_to_grey.md)       | `omnicores-buildingblocks/sources/encoding/grey`   | Binary to Grey encoder.    |

## References

- [Wikipedia, “Double dabble”.](https://en.wikipedia.org/wiki/Double_dabble)
