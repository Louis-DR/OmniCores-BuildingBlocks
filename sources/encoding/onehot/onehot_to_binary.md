# One-Hot to Binary Decoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | One-Hot to Binary Decoder                                                        |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![onehot_to_binary](onehot_to_binary.symbol.svg)

Converts one-hot encoded values back to standard binary representation. This decoder performs the inverse operation of the binary-to-one-hot encoder, recovering the original binary value from its one-hot representation by identifying the position of the single set bit.

## Parameters

| Name           | Type    | Allowed Values | Default               | Description                            |
| -------------- | ------- | -------------- | --------------------- | -------------------------------------- |
| `WIDTH_ONEHOT` | integer | `≥2`           | `8`                   | Bit width of the one-hot input vector. |
| `WIDTH_BINARY` | integer | `≥1`           | `clog2(WIDTH_ONEHOT)` | Bit width of the binary output vector. |

## Ports

| Name     | Direction | Width          | Clock | Reset | Reset value | Description                  |
| -------- | --------- | -------------- | ----- | ----- | ----------- | ---------------------------- |
| `onehot` | input     | `WIDTH_ONEHOT` |       |       |             | One-hot input to be decoded. |
| `binary` | output    | `WIDTH_BINARY` |       |       |             | Binary output.               |

## Operation

The one-hot-to-binary conversion uses a priority encoder algorithm that searches through the one-hot input to find the position of the set bit. The conversion is implemented using a function that iterates through all bit positions and returns the index of the bit that is set to 1.

This implementation assumes that exactly one bit is set in the one-hot input. If multiple bits are set, the decoder will return the index of the highest-numbered set bit. If no bits are set, the output will be 0.

## Paths

| From     | To       | Type          | Comment                                                 |
| -------- | -------- | ------------- | ------------------------------------------------------- |
| `onehot` | `binary` | combinatorial | Priority encoder logic to find the position of set bit. |

## Complexity

| Delay             | Gates             | Comment                                                      |
| ----------------- | ----------------- | ------------------------------------------------------------ |
| `O(WIDTH_ONEHOT)` | `O(WIDTH_ONEHOT)` | Priority encoder requires logic proportional to input width. |

The conversion requires priority encoder logic that examines all input bits, resulting in a delay and gate count proportional to the one-hot input width. For wide inputs, this may require careful consideration in high-frequency designs.

## Verification

The one-hot-to-binary decoder is verified using a comprehensive SystemVerilog testbench that validates both the conversion correctness and the fundamental properties of one-hot decoding. The testbench instanciates and verifies both the `binary_to_onehot` and `onehot_to_binary` modules.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                                         |
| ------ | --------------- | --------------------------------------------------------------------------------------------------- |
| 1a     | Exhaustive test | If `WIDTH_BINARY` ≤ 10, checks the one-hot encoding and its properties for all binary input values. |
| 1b     | Random test     | If `WIDTH_BINARY` > 10, checks the one-hot encoding and its properties for random sequences.        |

The following table lists the parameter values verified by the testbench.

| `WIDTH_BINARY` |           |
| -------------- | --------- |
| 8              | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                               | Description                                         |
| ----------------- | ------------------------------------------------------------------ | --------------------------------------------------- |
| Design            | [`onehot_to_binary.v`](onehot_to_binary.v)                         | Verilog design.                                     |
| Testbench         | [`onehot.testbench.sv`](onehot.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`onehot.testbench.gtkw`](onehot.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`onehot_to_binary.symbol.sss`](onehot_to_binary.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`onehot_to_binary.symbol.svg`](onehot_to_binary.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`onehot_to_binary.symbol.drawio`](onehot_to_binary.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`onehot_to_binary.md`](onehot_to_binary.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                        | Path                                               | Comment                    |
| --------------------------------------------- | -------------------------------------------------- | -------------------------- |
| [`binary_to_onehot`](binary_to_onehot.md)     | `omnicores-buildingblocks/sources/encoding/onehot` | Binary to one-hot encoder. |
| [`grey_to_binary`](../grey/grey_to_binary.md) | `omnicores-buildingblocks/sources/encoding/grey`   | Grey to binary decoder.    |
| [`bcd_to_binary`](bcd_to_binary.md)           | `omnicores-buildingblocks/sources/encoding/bcd`    | BCD to binary decoder.     |
