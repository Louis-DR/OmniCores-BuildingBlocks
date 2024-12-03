// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        hamming_encoder_tb_sub.sv                                    ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Sub-level testbench for the Hamming encoder.                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



`timescale 1ns/1ns
`include "hamming.svh"



module hamming_encoder_tb_sub #(
  parameter DATA_WIDTH = 4
) (
  input  logic start,
  output logic finished
);

// Test parameters
localparam DATA_WIDTH_POW2   = 2**DATA_WIDTH;
localparam PARITY_WIDTH      = `GET_HAMMING_PARITY_WIDTH(DATA_WIDTH);
localparam PADDED_DATA_WIDTH = `GET_HAMMING_DATA_WIDTH(PARITY_WIDTH);
localparam BLOCK_WIDTH       = DATA_WIDTH+PARITY_WIDTH;

// Check parameters
localparam integer FULL_CHECK_MAX_DURATION = 2**11;
localparam integer RANDOM_CHECK_DURATION   = 1024;

// Device ports
logic   [DATA_WIDTH-1:0] data;
logic [PARITY_WIDTH-1:0] code;
logic  [BLOCK_WIDTH-1:0] block;

// Device under test
hamming_encoder #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_encoder_dut (
  .data  ( data  ),
  .code  ( code  ),
  .block ( block )
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

// Checker task for the code
task automatic check_code();
  logic [PARITY_WIDTH-1:0] expected_code = hamming_7_4(data);
  case (PARITY_WIDTH)
    3: expected_code = hamming_7_4(data);
    4: expected_code = hamming_15_11(data);
    5: expected_code = hamming_31_26(data);
    6: expected_code = hamming_63_57(data);
    7: expected_code = hamming_127_120(data);
    default: $fatal(1, "[%0tns] Invalid parity width '%0d'.", $time, PARITY_WIDTH);
  endcase
  if (code !== expected_code) begin
    $error("[%0tns] Incorrect code for data '%b' : expected '%b' but got '%b'.", $time, data, expected_code, code);
  end
endtask

// Reference function for Hamming block packing
function logic [BLOCK_WIDTH-1:0] hamming_block(input logic [DATA_WIDTH-1:0] data, input logic [PARITY_WIDTH-1:0] code);
  logic [BLOCK_WIDTH-1:0] expected_block;
  expected_block[      0] = code[      0];
  expected_block[      1] = code[      1];
  expected_block[      2] = data[      0];
  if (PARITY_WIDTH < 3) return expected_block;
  expected_block[      3] = code[      2];
  expected_block[    6:4] = data[    3:1];
  if (PARITY_WIDTH < 4) return expected_block;
  expected_block[      7] = code[      3];
  expected_block[   14:8] = data[   10:4];
  if (PARITY_WIDTH < 5) return expected_block;
  expected_block[     15] = code[      4];
  expected_block[  30:16] = data[  25:11];
  if (PARITY_WIDTH < 6) return expected_block;
  expected_block[     31] = code[      5];
  expected_block[  62:32] = data[  56:26];
  if (PARITY_WIDTH < 7) return expected_block;
  expected_block[     63] = code[      6];
  expected_block[ 126:64] = data[ 119:57];
  if (PARITY_WIDTH < 8) return expected_block;
  expected_block[    127] = code[      7];
  expected_block[254:128] = data[246:120];
  return expected_block;
endfunction

// Checker task for the block
task automatic check_block();
  logic [BLOCK_WIDTH-1:0] expected_block = hamming_block(data, code);
  if (block !== expected_block) begin
    $error("[%0tns] Incorrect block packing : expected '%b' but got '%b'.", $time, expected_block, block);
  end
endtask

// Main block
initial begin
  // Wait start of sub testbench
  finished = 0;
  #(1); while (!start) #(1);
  $display("TEST DATA_WIDTH=%0d", DATA_WIDTH);

  // Initialization
  data = 0;

  // If the data width is small enough, verify all values
  if (DATA_WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin
    // Check : full coverage
    $display("CHECK : Full coverage.");
    for (integer data_index=0 ; data_index<DATA_WIDTH_POW2 ; data_index++) begin
      data = data_index;
      #(1);
      check_code();
      check_block();
      #(1);
    end
  end
  // Else only perform a random check
  else begin
    // Check : random stimulus
    $display("CHECK : Random stimulus.");
    for (integer random_iteration=0 ; random_iteration<RANDOM_CHECK_DURATION ; random_iteration++) begin
      // std:randomize() isn't supported by every simulator
      // This alternative only works up to 128 bits
      data = {$urandom(), $urandom(), $urandom(), $urandom()};
      #(1);
      check_code();
      check_block();
      #(1);
    end
  end

  // Finish sub testbench
  finished = 1;
end

endmodule
