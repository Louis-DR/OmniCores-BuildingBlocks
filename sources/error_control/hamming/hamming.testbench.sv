// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming.testbench.sv                                         ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Testbench for the Hamming error control modules.             ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "hamming.svh"



module hamming__testbench ();

// Device parameters
localparam DATA_WIDTH   = 8;
localparam PARITY_WIDTH = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH);
localparam BLOCK_WIDTH  = DATA_WIDTH + PARITY_WIDTH;

// Test parameters
localparam DATA_WIDTH_POW2         = 2**DATA_WIDTH;
localparam FULL_CHECK_MAX_DURATION = 512;  // Exhaustive up to 2^9
localparam RANDOM_CHECK_DURATION   = 1024;

// Device ports
logic   [DATA_WIDTH-1:0] encoder_data;
logic [PARITY_WIDTH-1:0] encoder_code;
logic  [BLOCK_WIDTH-1:0] encoder_block;

logic   [DATA_WIDTH-1:0] packer_data;
logic [PARITY_WIDTH-1:0] packer_code;
logic  [BLOCK_WIDTH-1:0] packer_block;

logic  [BLOCK_WIDTH-1:0] unpacker_block;
logic   [DATA_WIDTH-1:0] unpacker_data;
logic [PARITY_WIDTH-1:0] unpacker_code;

logic   [DATA_WIDTH-1:0] checker_data;
logic [PARITY_WIDTH-1:0] checker_code;
logic                    checker_error;

logic   [DATA_WIDTH-1:0] corrector_data;
logic [PARITY_WIDTH-1:0] corrector_code;
logic                    corrector_error;
logic   [DATA_WIDTH-1:0] corrector_corrected_data;

logic  [BLOCK_WIDTH-1:0] block_checker_block;
logic                    block_checker_error;

logic  [BLOCK_WIDTH-1:0] block_corrector_block;
logic                    block_corrector_error;
logic  [BLOCK_WIDTH-1:0] block_corrector_corrected_block;

// Test signals
logic   [DATA_WIDTH-1:0] test_data;
logic [PARITY_WIDTH-1:0] expected_code;
logic  [BLOCK_WIDTH-1:0] expected_block;
logic  [BLOCK_WIDTH-1:0] poisoned_block;
logic   [DATA_WIDTH-1:0] poisoned_data;
logic [PARITY_WIDTH-1:0] poisoned_code;

// Test variables
integer error_position;

// Devices under test
hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_encoder_dut (
  .data  ( encoder_data  ),
  .code  ( encoder_code  ),
  .block ( encoder_block )
);

hamming_block_packer #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_block_packer_dut (
  .data  ( packer_data  ),
  .code  ( packer_code  ),
  .block ( packer_block )
);

hamming_block_unpacker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) hamming_block_unpacker_dut (
  .block ( unpacker_block ),
  .data  ( unpacker_data  ),
  .code  ( unpacker_code  )
);

hamming_checker #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_checker_dut (
  .data  ( checker_data  ),
  .code  ( checker_code  ),
  .error ( checker_error )
);

hamming_block_checker #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) hamming_block_checker_dut (
  .block ( block_checker_block ),
  .error ( block_checker_error )
);

hamming_corrector #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_corrector_dut (
  .data           ( corrector_data           ),
  .code           ( corrector_code           ),
  .error          ( corrector_error          ),
  .corrected_data ( corrector_corrected_data )
);

hamming_block_corrector #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) hamming_block_corrector_dut (
  .block           ( block_corrector_block           ),
  .error           ( block_corrector_error           ),
  .corrected_block ( block_corrector_corrected_block )
);

// Reference function for the Hamming(7,4) encoding
function logic [2:0] hamming_7_4(input logic [3:0] data);
  return {data[3] ^ data[2] ^ data[1],
          data[3] ^ data[2] ^ data[0],
          data[3] ^ data[1] ^ data[0]};
endfunction

// Reference function for the Hamming(15,11) encoding
function logic [3:0] hamming_15_11(input logic [10:0] data);
  return {data[10] ^ data[9] ^ data[8] ^ data[7] ^ data[6] ^ data[5] ^ data[4],
          data[10] ^ data[9] ^ data[8] ^ data[7] ^ data[3] ^ data[2] ^ data[1],
          data[10] ^ data[9] ^ data[6] ^ data[5] ^ data[3] ^ data[2] ^ data[0],
          data[10] ^ data[8] ^ data[6] ^ data[4] ^ data[3] ^ data[1] ^ data[0]};
endfunction

// Reference function for the Hamming(31,26) encoding
function logic [4:0] hamming_31_26(input logic [25:0] data);
  return {data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[21] ^ data[20] ^ data[19] ^ data[18] ^ data[17] ^ data[16] ^ data[15] ^ data[14] ^ data[13] ^ data[12] ^ data[11],
          data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[21] ^ data[20] ^ data[19] ^ data[18] ^ data[10] ^ data[ 9] ^ data[ 8] ^ data[ 7] ^ data[ 6] ^ data[ 5] ^ data[ 4],
          data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[17] ^ data[16] ^ data[15] ^ data[14] ^ data[10] ^ data[ 9] ^ data[ 8] ^ data[ 7] ^ data[ 3] ^ data[ 2] ^ data[ 1],
          data[25] ^ data[24] ^ data[21] ^ data[20] ^ data[17] ^ data[16] ^ data[13] ^ data[12] ^ data[10] ^ data[ 9] ^ data[ 6] ^ data[ 5] ^ data[ 3] ^ data[ 2] ^ data[ 0],
          data[25] ^ data[23] ^ data[21] ^ data[19] ^ data[17] ^ data[15] ^ data[13] ^ data[11] ^ data[10] ^ data[ 8] ^ data[ 6] ^ data[ 4] ^ data[ 3] ^ data[ 1] ^ data[ 0]};
endfunction

// Reference function for the Hamming(63,57) encoding
function logic [5:0] hamming_63_57(input logic [56:0] data);
  return {data[56] ^ data[55] ^ data[54] ^ data[53] ^ data[52] ^ data[51] ^ data[50] ^ data[49] ^ data[48] ^ data[47] ^ data[46] ^ data[45] ^ data[44] ^ data[43] ^ data[42] ^ data[41] ^ data[40] ^ data[39] ^ data[38] ^ data[37] ^ data[36] ^ data[35] ^ data[34] ^ data[33] ^ data[32] ^ data[31] ^ data[30] ^ data[29] ^ data[28] ^ data[27] ^ data[26],
          data[56] ^ data[55] ^ data[54] ^ data[53] ^ data[52] ^ data[51] ^ data[50] ^ data[49] ^ data[48] ^ data[47] ^ data[46] ^ data[45] ^ data[44] ^ data[43] ^ data[42] ^ data[41] ^ data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[21] ^ data[20] ^ data[19] ^ data[18] ^ data[17] ^ data[16] ^ data[15] ^ data[14] ^ data[13] ^ data[12] ^ data[11],
          data[56] ^ data[55] ^ data[54] ^ data[53] ^ data[52] ^ data[51] ^ data[50] ^ data[49] ^ data[40] ^ data[39] ^ data[38] ^ data[37] ^ data[36] ^ data[35] ^ data[34] ^ data[33] ^ data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[21] ^ data[20] ^ data[19] ^ data[18] ^ data[10] ^ data[ 9] ^ data[ 8] ^ data[ 7] ^ data[ 6] ^ data[ 5] ^ data[ 4],
          data[56] ^ data[55] ^ data[54] ^ data[53] ^ data[48] ^ data[47] ^ data[46] ^ data[45] ^ data[40] ^ data[39] ^ data[38] ^ data[37] ^ data[32] ^ data[31] ^ data[30] ^ data[29] ^ data[25] ^ data[24] ^ data[23] ^ data[22] ^ data[17] ^ data[16] ^ data[15] ^ data[14] ^ data[10] ^ data[ 9] ^ data[ 8] ^ data[ 7] ^ data[ 3] ^ data[ 2] ^ data[ 1],
          data[56] ^ data[55] ^ data[52] ^ data[51] ^ data[48] ^ data[47] ^ data[44] ^ data[43] ^ data[40] ^ data[39] ^ data[36] ^ data[35] ^ data[32] ^ data[31] ^ data[28] ^ data[27] ^ data[25] ^ data[24] ^ data[21] ^ data[20] ^ data[17] ^ data[16] ^ data[13] ^ data[12] ^ data[10] ^ data[ 9] ^ data[ 6] ^ data[ 5] ^ data[ 3] ^ data[ 2] ^ data[ 0],
          data[56] ^ data[54] ^ data[52] ^ data[50] ^ data[48] ^ data[46] ^ data[44] ^ data[42] ^ data[40] ^ data[38] ^ data[36] ^ data[34] ^ data[32] ^ data[30] ^ data[28] ^ data[26] ^ data[25] ^ data[23] ^ data[21] ^ data[19] ^ data[17] ^ data[15] ^ data[13] ^ data[11] ^ data[10] ^ data[ 8] ^ data[ 6] ^ data[ 4] ^ data[ 3] ^ data[ 1] ^ data[ 0]};
endfunction

// Reference function for the Hamming(127,120) encoding
function logic [6:0] hamming_127_120(input logic [119:0] data);
  return {data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 91] ^ data[ 90] ^ data[ 89] ^ data[ 88] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 75] ^ data[ 74] ^ data[ 73] ^ data[ 72] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 67] ^ data[ 66] ^ data[ 65] ^ data[ 64] ^ data[ 63] ^ data[ 62] ^ data[ 61] ^ data[ 60] ^ data[ 59] ^ data[ 58] ^ data[ 57],
          data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 91] ^ data[ 90] ^ data[ 89] ^ data[ 88] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 44] ^ data[ 43] ^ data[ 42] ^ data[ 41] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 36] ^ data[ 35] ^ data[ 34] ^ data[ 33] ^ data[ 32] ^ data[ 31] ^ data[ 30] ^ data[ 29] ^ data[ 28] ^ data[ 27] ^ data[ 26],
          data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 75] ^ data[ 74] ^ data[ 73] ^ data[ 72] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 44] ^ data[ 43] ^ data[ 42] ^ data[ 41] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 21] ^ data[ 20] ^ data[ 19] ^ data[ 18] ^ data[ 17] ^ data[ 16] ^ data[ 15] ^ data[ 14] ^ data[ 13] ^ data[ 12] ^ data[ 11],
          data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 67] ^ data[ 66] ^ data[ 65] ^ data[ 64] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 36] ^ data[ 35] ^ data[ 34] ^ data[ 33] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 21] ^ data[ 20] ^ data[ 19] ^ data[ 18] ^ data[ 10] ^ data[  9] ^ data[  8] ^ data[  7] ^ data[  6] ^ data[  5] ^ data[  4],
          data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 63] ^ data[ 62] ^ data[ 61] ^ data[ 60] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 32] ^ data[ 31] ^ data[ 30] ^ data[ 29] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 17] ^ data[ 16] ^ data[ 15] ^ data[ 14] ^ data[ 10] ^ data[  9] ^ data[  8] ^ data[  7] ^ data[  3] ^ data[  2] ^ data[  1],
          data[119] ^ data[118] ^ data[115] ^ data[114] ^ data[111] ^ data[110] ^ data[107] ^ data[106] ^ data[103] ^ data[102] ^ data[ 99] ^ data[ 98] ^ data[ 95] ^ data[ 94] ^ data[ 91] ^ data[ 90] ^ data[ 87] ^ data[ 86] ^ data[ 83] ^ data[ 82] ^ data[ 79] ^ data[ 78] ^ data[ 75] ^ data[ 74] ^ data[ 71] ^ data[ 70] ^ data[ 67] ^ data[ 66] ^ data[ 63] ^ data[ 62] ^ data[ 59] ^ data[ 58] ^ data[ 56] ^ data[ 55] ^ data[ 52] ^ data[ 51] ^ data[ 48] ^ data[ 47] ^ data[ 44] ^ data[ 43] ^ data[ 40] ^ data[ 39] ^ data[ 36] ^ data[ 35] ^ data[ 32] ^ data[ 31] ^ data[ 28] ^ data[ 27] ^ data[ 25] ^ data[ 24] ^ data[ 21] ^ data[ 20] ^ data[ 17] ^ data[ 16] ^ data[ 13] ^ data[ 12] ^ data[ 10] ^ data[  9] ^ data[  6] ^ data[  5] ^ data[  3] ^ data[  2] ^ data[  0],
          data[119] ^ data[117] ^ data[115] ^ data[113] ^ data[111] ^ data[109] ^ data[107] ^ data[105] ^ data[103] ^ data[101] ^ data[ 99] ^ data[ 97] ^ data[ 95] ^ data[ 93] ^ data[ 91] ^ data[ 89] ^ data[ 87] ^ data[ 85] ^ data[ 83] ^ data[ 81] ^ data[ 79] ^ data[ 77] ^ data[ 75] ^ data[ 73] ^ data[ 71] ^ data[ 69] ^ data[ 67] ^ data[ 65] ^ data[ 63] ^ data[ 61] ^ data[ 59] ^ data[ 57] ^ data[ 56] ^ data[ 54] ^ data[ 52] ^ data[ 50] ^ data[ 48] ^ data[ 46] ^ data[ 44] ^ data[ 42] ^ data[ 40] ^ data[ 38] ^ data[ 36] ^ data[ 34] ^ data[ 32] ^ data[ 30] ^ data[ 28] ^ data[ 26] ^ data[ 25] ^ data[ 23] ^ data[ 21] ^ data[ 19] ^ data[ 17] ^ data[ 15] ^ data[ 13] ^ data[ 11] ^ data[ 10] ^ data[  8] ^ data[  6] ^ data[  4] ^ data[  3] ^ data[  1] ^ data[  0]};
endfunction

// Reference function for the Hamming(255,247) encoding
function logic [7:0] hamming_255_247(input logic [246:0] data);
  return {data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[242] ^ data[241] ^ data[240] ^ data[239] ^ data[238] ^ data[237] ^ data[236] ^ data[235] ^ data[234] ^ data[233] ^ data[232] ^ data[231] ^ data[230] ^ data[229] ^ data[228] ^ data[227] ^ data[226] ^ data[225] ^ data[224] ^ data[223] ^ data[222] ^ data[221] ^ data[220] ^ data[219] ^ data[218] ^ data[217] ^ data[216] ^ data[215] ^ data[214] ^ data[213] ^ data[212] ^ data[211] ^ data[210] ^ data[209] ^ data[208] ^ data[207] ^ data[206] ^ data[205] ^ data[204] ^ data[203] ^ data[202] ^ data[201] ^ data[200] ^ data[199] ^ data[198] ^ data[197] ^ data[196] ^ data[195] ^ data[194] ^ data[193] ^ data[192] ^ data[191] ^ data[190] ^ data[189] ^ data[188] ^ data[187] ^ data[186] ^ data[185] ^ data[184] ^ data[183] ^ data[182] ^ data[181] ^ data[180] ^ data[179] ^ data[178] ^ data[177] ^ data[176] ^ data[175] ^ data[174] ^ data[173] ^ data[172] ^ data[171] ^ data[170] ^ data[169] ^ data[168] ^ data[167] ^ data[166] ^ data[165] ^ data[164] ^ data[163] ^ data[162] ^ data[161] ^ data[160] ^ data[159] ^ data[158] ^ data[157] ^ data[156] ^ data[155] ^ data[154] ^ data[153] ^ data[152] ^ data[151] ^ data[150] ^ data[149] ^ data[148] ^ data[147] ^ data[146] ^ data[145] ^ data[144] ^ data[143] ^ data[142] ^ data[141] ^ data[140] ^ data[139] ^ data[138] ^ data[137] ^ data[136] ^ data[135] ^ data[134] ^ data[133] ^ data[132] ^ data[131] ^ data[130] ^ data[129] ^ data[128] ^ data[127] ^ data[126] ^ data[125] ^ data[124] ^ data[123] ^ data[122] ^ data[121] ^ data[120],
          data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[242] ^ data[241] ^ data[240] ^ data[239] ^ data[238] ^ data[237] ^ data[236] ^ data[235] ^ data[234] ^ data[233] ^ data[232] ^ data[231] ^ data[230] ^ data[229] ^ data[228] ^ data[227] ^ data[226] ^ data[225] ^ data[224] ^ data[223] ^ data[222] ^ data[221] ^ data[220] ^ data[219] ^ data[218] ^ data[217] ^ data[216] ^ data[215] ^ data[214] ^ data[213] ^ data[212] ^ data[211] ^ data[210] ^ data[209] ^ data[208] ^ data[207] ^ data[206] ^ data[205] ^ data[204] ^ data[203] ^ data[202] ^ data[201] ^ data[200] ^ data[199] ^ data[198] ^ data[197] ^ data[196] ^ data[195] ^ data[194] ^ data[193] ^ data[192] ^ data[191] ^ data[190] ^ data[189] ^ data[188] ^ data[187] ^ data[186] ^ data[185] ^ data[184] ^ data[183] ^ data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 91] ^ data[ 90] ^ data[ 89] ^ data[ 88] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 75] ^ data[ 74] ^ data[ 73] ^ data[ 72] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 67] ^ data[ 66] ^ data[ 65] ^ data[ 64] ^ data[ 63] ^ data[ 62] ^ data[ 61] ^ data[ 60] ^ data[ 59] ^ data[ 58] ^ data[ 57],
          data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[242] ^ data[241] ^ data[240] ^ data[239] ^ data[238] ^ data[237] ^ data[236] ^ data[235] ^ data[234] ^ data[233] ^ data[232] ^ data[231] ^ data[230] ^ data[229] ^ data[228] ^ data[227] ^ data[226] ^ data[225] ^ data[224] ^ data[223] ^ data[222] ^ data[221] ^ data[220] ^ data[219] ^ data[218] ^ data[217] ^ data[216] ^ data[215] ^ data[182] ^ data[181] ^ data[180] ^ data[179] ^ data[178] ^ data[177] ^ data[176] ^ data[175] ^ data[174] ^ data[173] ^ data[172] ^ data[171] ^ data[170] ^ data[169] ^ data[168] ^ data[167] ^ data[166] ^ data[165] ^ data[164] ^ data[163] ^ data[162] ^ data[161] ^ data[160] ^ data[159] ^ data[158] ^ data[157] ^ data[156] ^ data[155] ^ data[154] ^ data[153] ^ data[152] ^ data[151] ^ data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 91] ^ data[ 90] ^ data[ 89] ^ data[ 88] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 44] ^ data[ 43] ^ data[ 42] ^ data[ 41] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 36] ^ data[ 35] ^ data[ 34] ^ data[ 33] ^ data[ 32] ^ data[ 31] ^ data[ 30] ^ data[ 29] ^ data[ 28] ^ data[ 27] ^ data[ 26],
          data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[242] ^ data[241] ^ data[240] ^ data[239] ^ data[238] ^ data[237] ^ data[236] ^ data[235] ^ data[234] ^ data[233] ^ data[232] ^ data[231] ^ data[214] ^ data[213] ^ data[212] ^ data[211] ^ data[210] ^ data[209] ^ data[208] ^ data[207] ^ data[206] ^ data[205] ^ data[204] ^ data[203] ^ data[202] ^ data[201] ^ data[200] ^ data[199] ^ data[182] ^ data[181] ^ data[180] ^ data[179] ^ data[178] ^ data[177] ^ data[176] ^ data[175] ^ data[174] ^ data[173] ^ data[172] ^ data[171] ^ data[170] ^ data[169] ^ data[168] ^ data[167] ^ data[150] ^ data[149] ^ data[148] ^ data[147] ^ data[146] ^ data[145] ^ data[144] ^ data[143] ^ data[142] ^ data[141] ^ data[140] ^ data[139] ^ data[138] ^ data[137] ^ data[136] ^ data[135] ^ data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[107] ^ data[106] ^ data[105] ^ data[104] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 75] ^ data[ 74] ^ data[ 73] ^ data[ 72] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 44] ^ data[ 43] ^ data[ 42] ^ data[ 41] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 21] ^ data[ 20] ^ data[ 19] ^ data[ 18] ^ data[ 17] ^ data[ 16] ^ data[ 15] ^ data[ 14] ^ data[ 13] ^ data[ 12] ^ data[ 11],
          data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[242] ^ data[241] ^ data[240] ^ data[239] ^ data[230] ^ data[229] ^ data[228] ^ data[227] ^ data[226] ^ data[225] ^ data[224] ^ data[223] ^ data[214] ^ data[213] ^ data[212] ^ data[211] ^ data[210] ^ data[209] ^ data[208] ^ data[207] ^ data[198] ^ data[197] ^ data[196] ^ data[195] ^ data[194] ^ data[193] ^ data[192] ^ data[191] ^ data[182] ^ data[181] ^ data[180] ^ data[179] ^ data[178] ^ data[177] ^ data[176] ^ data[175] ^ data[166] ^ data[165] ^ data[164] ^ data[163] ^ data[162] ^ data[161] ^ data[160] ^ data[159] ^ data[150] ^ data[149] ^ data[148] ^ data[147] ^ data[146] ^ data[145] ^ data[144] ^ data[143] ^ data[134] ^ data[133] ^ data[132] ^ data[131] ^ data[130] ^ data[129] ^ data[128] ^ data[127] ^ data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[115] ^ data[114] ^ data[113] ^ data[112] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 99] ^ data[ 98] ^ data[ 97] ^ data[ 96] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 83] ^ data[ 82] ^ data[ 81] ^ data[ 80] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 67] ^ data[ 66] ^ data[ 65] ^ data[ 64] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 52] ^ data[ 51] ^ data[ 50] ^ data[ 49] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 36] ^ data[ 35] ^ data[ 34] ^ data[ 33] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 21] ^ data[ 20] ^ data[ 19] ^ data[ 18] ^ data[ 10] ^ data[  9] ^ data[  8] ^ data[  7] ^ data[  6] ^ data[  5] ^ data[  4],
          data[246] ^ data[245] ^ data[244] ^ data[243] ^ data[238] ^ data[237] ^ data[236] ^ data[235] ^ data[230] ^ data[229] ^ data[228] ^ data[227] ^ data[222] ^ data[221] ^ data[220] ^ data[219] ^ data[214] ^ data[213] ^ data[212] ^ data[211] ^ data[206] ^ data[205] ^ data[204] ^ data[203] ^ data[198] ^ data[197] ^ data[196] ^ data[195] ^ data[190] ^ data[189] ^ data[188] ^ data[187] ^ data[182] ^ data[181] ^ data[180] ^ data[179] ^ data[174] ^ data[173] ^ data[172] ^ data[171] ^ data[166] ^ data[165] ^ data[164] ^ data[163] ^ data[158] ^ data[157] ^ data[156] ^ data[155] ^ data[150] ^ data[149] ^ data[148] ^ data[147] ^ data[142] ^ data[141] ^ data[140] ^ data[139] ^ data[134] ^ data[133] ^ data[132] ^ data[131] ^ data[126] ^ data[125] ^ data[124] ^ data[123] ^ data[119] ^ data[118] ^ data[117] ^ data[116] ^ data[111] ^ data[110] ^ data[109] ^ data[108] ^ data[103] ^ data[102] ^ data[101] ^ data[100] ^ data[ 95] ^ data[ 94] ^ data[ 93] ^ data[ 92] ^ data[ 87] ^ data[ 86] ^ data[ 85] ^ data[ 84] ^ data[ 79] ^ data[ 78] ^ data[ 77] ^ data[ 76] ^ data[ 71] ^ data[ 70] ^ data[ 69] ^ data[ 68] ^ data[ 63] ^ data[ 62] ^ data[ 61] ^ data[ 60] ^ data[ 56] ^ data[ 55] ^ data[ 54] ^ data[ 53] ^ data[ 48] ^ data[ 47] ^ data[ 46] ^ data[ 45] ^ data[ 40] ^ data[ 39] ^ data[ 38] ^ data[ 37] ^ data[ 32] ^ data[ 31] ^ data[ 30] ^ data[ 29] ^ data[ 25] ^ data[ 24] ^ data[ 23] ^ data[ 22] ^ data[ 17] ^ data[ 16] ^ data[ 15] ^ data[ 14] ^ data[ 10] ^ data[  9] ^ data[  8] ^ data[  7] ^ data[  3] ^ data[  2] ^ data[  1],
          data[246] ^ data[245] ^ data[242] ^ data[241] ^ data[238] ^ data[237] ^ data[234] ^ data[233] ^ data[230] ^ data[229] ^ data[226] ^ data[225] ^ data[222] ^ data[221] ^ data[218] ^ data[217] ^ data[214] ^ data[213] ^ data[210] ^ data[209] ^ data[206] ^ data[205] ^ data[202] ^ data[201] ^ data[198] ^ data[197] ^ data[194] ^ data[193] ^ data[190] ^ data[189] ^ data[186] ^ data[185] ^ data[182] ^ data[181] ^ data[178] ^ data[177] ^ data[174] ^ data[173] ^ data[170] ^ data[169] ^ data[166] ^ data[165] ^ data[162] ^ data[161] ^ data[158] ^ data[157] ^ data[154] ^ data[153] ^ data[150] ^ data[149] ^ data[146] ^ data[145] ^ data[142] ^ data[141] ^ data[138] ^ data[137] ^ data[134] ^ data[133] ^ data[130] ^ data[129] ^ data[126] ^ data[125] ^ data[122] ^ data[121] ^ data[119] ^ data[118] ^ data[115] ^ data[114] ^ data[111] ^ data[110] ^ data[107] ^ data[106] ^ data[103] ^ data[102] ^ data[ 99] ^ data[ 98] ^ data[ 95] ^ data[ 94] ^ data[ 91] ^ data[ 90] ^ data[ 87] ^ data[ 86] ^ data[ 83] ^ data[ 82] ^ data[ 79] ^ data[ 78] ^ data[ 75] ^ data[ 74] ^ data[ 71] ^ data[ 70] ^ data[ 67] ^ data[ 66] ^ data[ 63] ^ data[ 62] ^ data[ 59] ^ data[ 58] ^ data[ 56] ^ data[ 55] ^ data[ 52] ^ data[ 51] ^ data[ 48] ^ data[ 47] ^ data[ 44] ^ data[ 43] ^ data[ 40] ^ data[ 39] ^ data[ 36] ^ data[ 35] ^ data[ 32] ^ data[ 31] ^ data[ 28] ^ data[ 27] ^ data[ 25] ^ data[ 24] ^ data[ 21] ^ data[ 20] ^ data[ 17] ^ data[ 16] ^ data[ 13] ^ data[ 12] ^ data[ 10] ^ data[  9] ^ data[  6] ^ data[  5] ^ data[  3] ^ data[  2] ^ data[  0],
          data[246] ^ data[244] ^ data[242] ^ data[240] ^ data[238] ^ data[236] ^ data[234] ^ data[232] ^ data[230] ^ data[228] ^ data[226] ^ data[224] ^ data[222] ^ data[220] ^ data[218] ^ data[216] ^ data[214] ^ data[212] ^ data[210] ^ data[208] ^ data[206] ^ data[204] ^ data[202] ^ data[200] ^ data[198] ^ data[196] ^ data[194] ^ data[192] ^ data[190] ^ data[188] ^ data[186] ^ data[184] ^ data[182] ^ data[180] ^ data[178] ^ data[176] ^ data[174] ^ data[172] ^ data[170] ^ data[168] ^ data[166] ^ data[164] ^ data[162] ^ data[160] ^ data[158] ^ data[156] ^ data[154] ^ data[152] ^ data[150] ^ data[148] ^ data[146] ^ data[144] ^ data[142] ^ data[140] ^ data[138] ^ data[136] ^ data[134] ^ data[132] ^ data[130] ^ data[128] ^ data[126] ^ data[124] ^ data[122] ^ data[120] ^ data[119] ^ data[117] ^ data[115] ^ data[113] ^ data[111] ^ data[109] ^ data[107] ^ data[105] ^ data[103] ^ data[101] ^ data[ 99] ^ data[ 97] ^ data[ 95] ^ data[ 93] ^ data[ 91] ^ data[ 89] ^ data[ 87] ^ data[ 85] ^ data[ 83] ^ data[ 81] ^ data[ 79] ^ data[ 77] ^ data[ 75] ^ data[ 73] ^ data[ 71] ^ data[ 69] ^ data[ 67] ^ data[ 65] ^ data[ 63] ^ data[ 61] ^ data[ 59] ^ data[ 57] ^ data[ 56] ^ data[ 54] ^ data[ 52] ^ data[ 50] ^ data[ 48] ^ data[ 46] ^ data[ 44] ^ data[ 42] ^ data[ 40] ^ data[ 38] ^ data[ 36] ^ data[ 34] ^ data[ 32] ^ data[ 30] ^ data[ 28] ^ data[ 26] ^ data[ 25] ^ data[ 23] ^ data[ 21] ^ data[ 19] ^ data[ 17] ^ data[ 15] ^ data[ 13] ^ data[ 11] ^ data[ 10] ^ data[  8] ^ data[  6] ^ data[  4] ^ data[  3] ^ data[  1] ^ data[  0]};
endfunction

// Reference function for calculating Hamming code
function logic [PARITY_WIDTH-1:0] hamming_code(input logic [DATA_WIDTH-1:0] data);
  case (PARITY_WIDTH)
    3: hamming_code = hamming_7_4(data);
    4: hamming_code = hamming_15_11(data);
    5: hamming_code = hamming_31_26(data);
    6: hamming_code = hamming_63_57(data);
    7: hamming_code = hamming_127_120(data);
    8: hamming_code = hamming_255_247(data);
    default: begin
      $fatal(1, "[%0tns] Unsupported parity width '%0d' for reference Hamming code function.", $time, PARITY_WIDTH);
      return 0;
    end
  endcase
endfunction

// Reference function for Hamming block packing
function logic [BLOCK_WIDTH-1:0] hamming_block_pack(input logic [DATA_WIDTH-1:0] data, input logic [PARITY_WIDTH-1:0] code);
  logic [BLOCK_WIDTH-1:0] expected_block;
  expected_block[    0] = code[    0];
  expected_block[    1] = code[    1];
  expected_block[    2] = data[    0];
  if (PARITY_WIDTH < 3) return expected_block;
  expected_block[    3] = code[    2];
  expected_block[  6:4] = data[  3:1];
  if (PARITY_WIDTH < 4) return expected_block;
  expected_block[    7] = code[    3];
  expected_block[ 14:8] = data[ 10:4];
  if (PARITY_WIDTH < 5) return expected_block;
  expected_block[   15] = code[    4];
  expected_block[30:16] = data[25:11];
  if (PARITY_WIDTH < 6) return expected_block;
  expected_block[   31] = code[    5];
  expected_block[62:32] = data[56:26];
  if (PARITY_WIDTH < 7) return expected_block;
  expected_block[   63] = code[    6];
  expected_block[126:64] = data[119:57];
  if (PARITY_WIDTH < 8) return expected_block;
  return expected_block;
endfunction

// Function to inject a single bit error in a block
function automatic logic [BLOCK_WIDTH-1:0] inject_single_bit_error(input integer error_position, input logic [BLOCK_WIDTH-1:0] original_block);
  logic [BLOCK_WIDTH-1:0] poisoned_block;
  poisoned_block = original_block ^ (1 << error_position);
  return poisoned_block;
endfunction

// Task to check the outputs of all modules for a given data without errors
task check_all_modules_no_error(input logic [DATA_WIDTH-1:0] test_data);

  // Calculate the expected Hamming code and block
  expected_code  = hamming_code(test_data);
  expected_block = hamming_block_pack(test_data, expected_code);

  // Check the encoder
  encoder_data = test_data;
  #1;
  assert (encoder_code === expected_code)
    else $error("[%0tns] Incorrect code from encoder for data '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, encoder_code);
  assert (encoder_block === expected_block)
    else $error("[%0tns] Incorrect block from encoder for data '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_block, encoder_block);

  // Check the packer
  packer_data = test_data;
  packer_code = expected_code;
  #1;
  assert (packer_block === expected_block)
    else $error("[%0tns] Incorrect block from packer for data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, expected_block, packer_block);

  // Check the unpacker
  unpacker_block = packer_block;
  #1;
  assert (unpacker_data === test_data)
    else $error("[%0tns] Incorrect data from unpacker for block '%b'. Expected '%b', got '%b'.",
                $time, packer_block, test_data, unpacker_data);
  assert (unpacker_code === expected_code)
    else $error("[%0tns] Incorrect code from unpacker for block '%b'. Expected '%b', got '%b'.",
                $time, packer_block, expected_code, unpacker_code);

  // Check the checker
  checker_data = test_data;
  checker_code = expected_code;
  #1;
  assert (checker_error === 1'b0)
    else $error("[%0tns] False error detected by checker for data '%b' and code '%b'.",
                $time, test_data, expected_code);

  // Check the corrector
  corrector_data = test_data;
  corrector_code = expected_code;
  #1;
  assert (corrector_error === 1'b0)
    else $error("[%0tns] False error detected by corrector for data '%b' and code '%b'.",
                $time, test_data, expected_code);
  assert (corrector_corrected_data === test_data)
    else $error("[%0tns] Incorrect corrected data by corrector for data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, test_data, expected_code, test_data, corrector_corrected_data);

  // Check the block checker
  block_checker_block = expected_block;
  #1;
  assert (block_checker_error === 1'b0)
    else $error("[%0tns] False error detected by block checker for block '%b'.",
                $time, expected_block);

  // Check the block corrector
  block_corrector_block = expected_block;
  #1;
  assert (block_corrector_error === 1'b0)
    else $error("[%0tns] False error detected by block corrector for block '%b'.",
                $time, expected_block);
  assert (block_corrector_corrected_block === expected_block)
    else $error("[%0tns] Incorrect corrected block by block corrector for block '%b'. Expected '%b', got '%b'.",
                $time, expected_block, expected_block, block_corrector_corrected_block);
endtask

// Task to check the outputs of the checker and corrector modules for a given data with a single bit error
task check_checker_and_corrector_single_bit_error(input logic [DATA_WIDTH-1:0] test_data, input integer error_position);

  // Calculate the expected Hamming code and block
  expected_code  = hamming_code(test_data);
  expected_block = hamming_block_pack(test_data, expected_code);

  // Poison block with single bit error
  poisoned_block = inject_single_bit_error(error_position, expected_block);

  // Use the unpacker to get the data and code from the poisoned block
  unpacker_block = poisoned_block;
  #1;
  poisoned_data = unpacker_data;
  poisoned_code = unpacker_code;

  // Check the checker
  checker_data = poisoned_data;
  checker_code = poisoned_code;
  #1;
  assert (checker_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by checker for data '%b' and code '%b'.",
                $time, poisoned_data, poisoned_code);

  // Check the corrector
  corrector_data = poisoned_data;
  corrector_code = poisoned_code;
  #1;
  assert (corrector_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by corrector for poisoned data '%b' and code '%b'.",
                $time, poisoned_data, poisoned_code);
  assert (corrector_corrected_data === test_data)
    else $error("[%0tns] Single-bit error not corrected by corrector for poisoned data '%b' and code '%b'. Expected '%b', got '%b'.",
                $time, poisoned_data, poisoned_code, test_data, corrector_corrected_data);

  // Check the block checker
  block_checker_block = poisoned_block;
  #1;
  assert (block_checker_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by block checker for poisoned block '%b'.",
                $time, poisoned_block);

  // Check the block corrector
  block_corrector_block = poisoned_block;
  #1;
  assert (block_corrector_error === 1'b1)
    else $error("[%0tns] Single-bit error not detected by block corrector for poisoned block '%b'.",
                $time, poisoned_block);
  assert (block_corrector_corrected_block === expected_block)
    else $error("[%0tns] Single-bit error not corrected by block corrector for poisoned block '%b'. Expected '%b', got '%b'.",
                $time, poisoned_block, expected_block, block_corrector_corrected_block);
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("hamming.testbench.vcd");
  $dumpvars(0, hamming__testbench);

  // Initialization
  encoder_data          = 0;
  packer_data           = 0;
  packer_code           = 0;
  unpacker_block        = 0;
  checker_data          = 0;
  checker_code          = 0;
  corrector_data        = 0;
  corrector_code        = 0;
  block_checker_block   = 0;
  block_corrector_block = 0;

  // Small delay after initialization
  #1;

  // If the data width is small, we perform exhaustive testing
  if (DATA_WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin

    // Check 1: Exhaustive test without error
    $display("CHECK 1: Exhaustive test without error.");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      test_data = data_configuration;
      check_all_modules_no_error(test_data);
    end

    // Check 2: Exhaustive test with single bit flip error
    $display("CHECK 2: Exhaustive test with single bit flip error.");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      test_data = data_configuration;
      for (integer error_position = 0; error_position < BLOCK_WIDTH; error_position++) begin
        check_checker_and_corrector_single_bit_error(test_data, error_position);
      end
    end

  end

  // If the data width is large, we perform random testing
  else begin

    // Check 1: Random test without error
    $display("CHECK 1: Random test without error.");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
      test_data = $urandom_range(0, DATA_WIDTH_POW2-1);
      check_all_modules_no_error(test_data);
    end

    // Check 2: Random test with single bit flip error
    $display("CHECK 2: Random test with single bit flip error.");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
      test_data = $urandom_range(0, DATA_WIDTH_POW2-1);
      error_position = $urandom_range(0, BLOCK_WIDTH-1);
      check_checker_and_corrector_single_bit_error(test_data, error_position);
    end

  end

  // End of test
  $finish;
end

endmodule