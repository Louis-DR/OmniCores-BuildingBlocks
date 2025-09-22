# Binary-Coded Decimal to Binary Decoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Binary-Coded Decimal to Binary Decoder                                           |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![bcd_to_binary](bcd_to_binary.symbol.svg)

Converts Binary-Coded Decimal (BCD) values back to standard binary representation. This decoder performs the inverse operation of the binary-to-BCD encoder, recovering the original binary value from its BCD representation using the reverse double-dabble algorithm.

## Parameters

| Name           | Type    | Allowed Values | Default                          | Description                            |
| -------------- | ------- | -------------- | -------------------------------- | -------------------------------------- |
| `WIDTH_BCD`    | integer | `≥4`           | `8`                              | Bit width of the BCD input vector.     |
| `WIDTH_BINARY` | integer | `≥1`           | `BCD_TO_BINARY_WIDTH(WIDTH_BCD)` | Bit width of the binary output vector. |

## Ports

| Name     | Direction | Width          | Clock | Reset | Reset value | Description              |
| -------- | --------- | -------------- | ----- | ----- | ----------- | ------------------------ |
| `bcd`    | input     | `WIDTH_BCD`    |       |       |             | BCD input to be decoded. |
| `binary` | output    | `WIDTH_BINARY` |       |       |             | Binary output.           |

## Operation

The BCD-to-binary conversion uses the reverse double-dabble algorithm, which performs the inverse operations of the double-dabble encoder. The algorithm iteratively shifts the BCD input right while adjusting BCD digits to reconstruct the original binary value. The algorithm performs the following steps for each bit of the binary output:

1. **Shift right**: Shift the entire scratch register (BCD + binary) right by 1 bit
2. **Check BCD digits**: For each 4-bit BCD digit, if the value is ≥ 8, subtract 3 from it
3. **Repeat**: Continue for all bits of the binary output

## Paths

| From  | To       | Type          | Comment                                                |
| ----- | -------- | ------------- | ------------------------------------------------------ |
| `bcd` | `binary` | combinational | Reverse double-dabble algorithm with iterative shifts. |

## Complexity

| Delay             | Gates                         | Comment                                                 |
| ----------------- | ----------------------------- | ------------------------------------------------------- |
| `O(WIDTH_BINARY)` | `O(WIDTH_BINARY × WIDTH_BCD)` | Iterative algorithm requires WIDTH_BINARY shift stages. |

The conversion requires WIDTH_BINARY stages of shifting and conditional subtraction logic, resulting in a delay proportional to the binary output width. Each stage processes all BCD digits in parallel.

## Verification

The BCD-to-binary decoder is verified using a comprehensive SystemVerilog testbench that validates both the conversion correctness and the fundamental properties of BCD decoding. The testbench instantiates and verifies both the `binary_to_bcd` and `bcd_to_binary` modules.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                                     |
| ------ | --------------- | ----------------------------------------------------------------------------------------------- |
| 1a     | Exhaustive test | If `WIDTH_BINARY` ≤ 10, checks the BCD decoding and its properties for all binary input values. |
| 1b     | Random test     | If `WIDTH_BINARY` > 10, checks the BCD decoding and its properties for random values.           |

The following table lists the parameter values verified by the testbench.

| `WIDTH_BINARY` |           |
| -------------- | --------- |
| 8              | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                         | Description                                         |
| ----------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`bcd_to_binary.v`](bcd_to_binary.v)                         | Verilog design.                                     |
| Testbench         | [`bcd.testbench.sv`](bcd.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`bcd.testbench.gtkw`](bcd.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`bcd_to_binary.symbol.sss`](bcd_to_binary.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`bcd_to_binary.symbol.svg`](bcd_to_binary.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`bcd_to_binary.symbol.drawio`](bcd_to_binary.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`bcd_to_binary.md`](bcd_to_binary.md)                       | Markdown documentation datasheet.                   |

## Dependencies

| Module                                                       | Path                                                      | Comment                       |
| ------------------------------------------------------------ | --------------------------------------------------------- | ----------------------------- |
| [`shift_right`](../../operations/shift_right/shift_right.md) | `omnicores-buildingblocks/sources/operations/shift_right` | Static right shift operation. |

## Related modules

| Module                                              | Path                                               | Comment                    |
| --------------------------------------------------- | -------------------------------------------------- | -------------------------- |
| [`binary_to_bcd`](binary_to_bcd.md)                 | `omnicores-buildingblocks/sources/encoding/bcd`    | Binary to BCD encoder.     |
| [`onehot_to_binary`](../onehot/onehot_to_binary.md) | `omnicores-buildingblocks/sources/encoding/onehot` | One-hot to binary decoder. |
| [`gray_to_binary`](../gray/gray_to_binary.md)       | `omnicores-buildingblocks/sources/encoding/gray`   | Gray to binary decoder.    |

## References

- [Wikipedia, “Double dabble”.](https://en.wikipedia.org/wiki/Double_dabble)
