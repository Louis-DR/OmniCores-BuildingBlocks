# Array Select

|         |                                                                                  |
| ------- | -------------------------------------------------------------------------------- |
| Module  | Array Select                                                                     |
| Project | [OmniCores-BuildingBlocks](https://github.com/Louis-DR/OmniCores-BuildingBlocks) |
| Author  | Louis Duret-Robert - [louisduret@gmail.com](mailto:louisduret@gmail.com)         |
| Website | [louis-dr.github.io](https://louis-dr.github.io)                                 |
| License | MIT License - [mit-license.org](https://mit-license.org)                         |

## Overview

![array_select](array_select.symbol.svg)

Selects one element from an array of equally-sized elements, acting as an array-indexed multiplexer. The selection input can use either a binary-coded index or a one-hot encoded signal, configured through the `SELECT_ONEHOT` parameter.

The binary select mode (`SELECT_ONEHOT=0`) uses standard array indexing and synthesizes to a compact multiplexer tree with `O(log2(ARRAY_SIZE))` propagation delay. The one-hot mode (`SELECT_ONEHOT=1`) uses an AND-OR reduction tree, which is more suitable when the select signal is already available in one-hot form (e.g., from a priority decoder or a one-hot state machine), avoiding the need for a decoder.

## Parameters

| Name            | Type    | Allowed Values | Default                                          | Description                                                             |
| --------------- | ------- | -------------- | ------------------------------------------------ | ----------------------------------------------------------------------- |
| `ELEMENT_WIDTH` | integer | `>0`           | `8`                                              | Bit width of each element in the array.                                 |
| `ARRAY_SIZE`    | integer | `>0`           | `4`                                              | Number of elements in the array.                                        |
| `SELECT_ONEHOT` | integer | `0` or `1`     | `0`                                              | When set, the select input is one-hot encoded rather than binary-coded. |
| `SELECT_WIDTH`  | integer | derived        | `SELECT_ONEHOT ? ARRAY_SIZE : clog2(ARRAY_SIZE)` | Bit width of the select input, computed from the other parameters.      |

## Ports

| Name      | Direction | Width                      | Clock | Reset | Reset value | Description                                                        |
| --------- | --------- | -------------------------- | ----- | ----- | ----------- | ------------------------------------------------------------------ |
| `array`   | input     | `ARRAY_SIZE×ELEMENT_WIDTH` |       |       |             | Input array of `ARRAY_SIZE` elements of `ELEMENT_WIDTH` bits each. |
| `select`  | input     | `SELECT_WIDTH`             |       |       |             | Element selection signal, either binary or one-hot encoded.        |
| `element` | output    | `ELEMENT_WIDTH`            |       |       |             | Selected array element.                                            |

## Operation

The module uses a generate block to select between two implementations based on `SELECT_ONEHOT`.

When `SELECT_ONEHOT=0`, the selection is a direct indexed access which infers a multiplexer tree that selects one of `ARRAY_SIZE` input elements using the binary-encoded `select`. The entire path is purely combinational.

When `SELECT_ONEHOT=1`, an AND-OR reduction tree is used instead. A running `and_or_tree` wire holds the accumulated result. For each bit of the one-hot `select`, the corresponding array element is AND-gated with that select bit (driving zero when the bit is unasserted), and the result is ORed into the running chain. The final element of the chain drives `element`. This avoids the need for a decoder when the select is already one-hot. When the `select` signal is zero, the output is all zero as well. When the `select` signal is not one-hot and multiple bits are set, the output is the OR of the corresponding inputs.

## Paths

| From     | To        | Type          | Comment                                  |
| -------- | --------- | ------------- | ---------------------------------------- |
| `array`  | `element` | combinational | Through multiplexer or AND-OR reduction. |
| `select` | `element` | combinational | Through multiplexer or AND-OR reduction. |

## Complexity

| Mode           | Delay                 | Gates                           |
| -------------- | --------------------- | ------------------------------- |
| Binary select  | `O(log2(ARRAY_SIZE))` | `O(ARRAY_SIZE × ELEMENT_WIDTH)` |
| One-hot select | `O(ARRAY_SIZE)`       | `O(ARRAY_SIZE × ELEMENT_WIDTH)` |

The binary select mode uses a multiplexer tree with logarithmic delay. The one-hot select mode uses a linear AND-OR reduction chain, resulting in delay proportional to the array size but avoiding the need for a separate binary-to-one-hot decoder.

## Verification

The array select module is verified using a SystemVerilog testbench that instantiates the module.

The following table lists the checks performed by the testbench.

| Number | Check           | Description                                                                                        |
| ------ | --------------- | -------------------------------------------------------------------------------------------------- |
| 1      | Random stimulus | Random array contents and select values, verifies `element` output matches expected array element. |

The following table lists the parameter values verified by the testbench.

| `ELEMENT_WIDTH` | `ARRAY_SIZE` | `SELECT_ONEHOT` |           |
| --------------- | ------------ | --------------- | --------- |
| 8               | 4            | 0               | (default) |

## Constraints

There are no specific synthesis or implementation constraints for this block.

## Deliverables

| Type                | File                                                                 | Description                                         |
| ------------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| Design              | [`array_select.v`](array_select.v)                                   | Verilog design.                                     |
| Testbench           | [`array_select.testbench.sv`](array_select.testbench.sv)             | SystemVerilog verification testbench.               |
| Waveform script     | [`array_select.testbench.gtkw`](array_select.testbench.gtkw)         | Script to load the waveforms in GTKWave.            |
| Design filelist     | [`array_select.design.filelist`](array_select.design.filelist)       | Filelist for synthesis and implementation.          |
| Design include list | [`array_select.design.inclist`](array_select.design.inclist)         | Include paths for the design.                       |
| Testbench filelist  | [`array_select.testbench.filelist`](array_select.testbench.filelist) | Filelist for simulation.                            |
| Testbench include   | [`array_select.testbench.inclist`](array_select.testbench.inclist)   | Include paths for the testbench.                    |
| Symbol descriptor   | [`array_select.symbol.sss`](array_select.symbol.sss)                 | Symbol descriptor for SiliconSuite-SymbolGenerator. |
| Symbol image        | [`array_select.symbol.svg`](array_select.symbol.svg)                 | Generated vector image of the symbol.               |
| Symbol shape        | [`array_select.symbol.drawio`](array_select.symbol.drawio)           | Generated DrawIO shape of the symbol.               |
| Makefile            | [`Makefile`](Makefile)                                               | Build configuration.                                |
| Datasheet           | [`array_select.md`](array_select.md)                                 | Markdown documentation datasheet.                   |

## Dependencies

| Module     | Path                                               | Comment                                                |
| ---------- | -------------------------------------------------- | ------------------------------------------------------ |
| `clog2.vh` | `omnicores-buildingblocks/sources/common/clog2.vh` | Used to compute `SELECT_WIDTH` when `SELECT_ONEHOT=0`. |

## Related modules

There are currently no related modules
