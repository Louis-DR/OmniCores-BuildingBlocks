# Gray to Binary Decoder

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Gray to Binary Decoder                                                           |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![gray_to_binary](gray_to_binary.symbol.svg)

Converts Gray code (reflected binary code) back to standard binary representation. This decoder performs the inverse operation of the binary-to-gray encoder, recovering the original binary value from its Gray code representation.

## Parameters

| Name    | Type    | Allowed Values | Default | Description                           |
| ------- | ------- | -------------- | ------- | ------------------------------------- |
| `WIDTH` | integer | `≥1`           | `8`     | Bit width of the gray/binary vectors. |

## Ports

| Name     | Direction | Width   | Clock | Reset | Reset value | Description                    |
| -------- | --------- | ------- | ----- | ----- | ----------- | ------------------------------ |
| `gray`   | input     | `WIDTH` |       |       |             | Gray code input to be decoded. |
| `binary` | output    | `WIDTH` |       |       |             | Binary output.                 |

## Operation

The gray-to-binary conversion uses an iterative algorithm where each binary bit is computed based on the Gray code input and previously computed binary bits. The most significant bit (MSB) of the binary output equals the MSB of the Gray code input. For all other positions `i` (from MSB-1 down to LSB), the binary bit is computed as `binary[i] = binary[i+1] ^ gray[i]`.

This sequential dependency from MSB to LSB means the conversion requires multiple logic levels but ensures perfect reconstruction of the original binary value.

## Paths

| From   | To       | Type          | Comment                                                     |
| ------ | -------- | ------------- | ----------------------------------------------------------- |
| `gray` | `binary` | combinational | Multi-level XOR chain from MSB to LSB for conversion logic. |

## Complexity

| Delay      | Gates      | Comment                                                |
| ---------- | ---------- | ------------------------------------------------------ |
| `O(WIDTH)` | `O(WIDTH)` | Chain of XOR gates creates WIDTH-dependent delay path. |

The conversion requires `WIDTH-1` XOR gates arranged in a dependency chain, resulting in a delay proportional to the bit width. For wide data paths, this may require pipeline consideration in high-frequency designs.

## Verification

The gray-to-binary decoder is verified using a comprehensive SystemVerilog testbench that validates both the conversion correctness and the fundamental properties of Gray code decoding. The testbench instanciates and verifies both the `binary_to_gray` and `gray_to_binary` modules.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                            |
| ------ | --------------- | -------------------------------------------------------------------------------------- |
| 1a     | Exhaustive test | If `WIDTH` ≤ 10, checks the Gray code and its properties for all binary input values . |
| 1b     | Random test     | If `WIDTH` > 10, checks the Gray code and its properties for random sequences.         |

The following table lists the parameter values verified by the testbench.

| `WIDTH` |           |
| ------- | --------- |
| 8       | (default) |

## Constraints

There are no synthesis and implementation constraints for this block.

## Deliverables

| Type              | File                                                           | Description                                         |
| ----------------- | -------------------------------------------------------------- | --------------------------------------------------- |
| Design            | [`gray_to_binary.v`](gray_to_binary.v)                         | Verilog design.                                     |
| Testbench         | [`gray.testbench.sv`](gray.testbench.sv)                       | SystemVerilog verification shared testbench.        |
| Waveform script   | [`gray.testbench.gtkw`](gray.testbench.gtkw)                   | Script to load the waveforms in GTKWave.            |
| Symbol descriptor | [`gray_to_binary.symbol.sss`](gray_to_binary.symbol.sss)       | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image      | [`gray_to_binary.symbol.svg`](gray_to_binary.symbol.svg)       | Generated vector image of the symbol.               |
| Symbol shape      | [`gray_to_binary.symbol.drawio`](gray_to_binary.symbol.drawio) | Generated DrawIO shape of the symbol.               |
| Datasheet         | [`gray_to_binary.md`](gray_to_binary.md)                       | Markdown documentation datasheet.                   |

## Dependencies

This module has no external module dependencies.

## Related modules

| Module                                              | Path                                               | Comment                    |
| --------------------------------------------------- | -------------------------------------------------- | -------------------------- |
| [`binary_to_gray`](binary_to_gray.md)               | `omnicores-buildingblocks/sources/encoding/gray`   | Binary to Gray encoder.    |
| [`onehot_to_binary`](../onehot/onehot_to_binary.md) | `omnicores-buildingblocks/sources/encoding/onehot` | One-hot to binary decoder. |
| [`bcd_to_binary`](bcd_to_binary.md)                 | `omnicores-buildingblocks/sources/encoding/bcd`    | BCD to binary decoder.     |
