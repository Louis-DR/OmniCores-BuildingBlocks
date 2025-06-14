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
localparam DATA_WIDTH   = 4;
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
logic   [DATA_WIDTH-1:0] block_corrector_corrected_data;

logic   [DATA_WIDTH-1:0] packager_data;
logic [PARITY_WIDTH-1:0] packager_code;
logic  [BLOCK_WIDTH-1:0] packager_block;

logic  [BLOCK_WIDTH-1:0] extractor_block;
logic   [DATA_WIDTH-1:0] extractor_data;
logic [PARITY_WIDTH-1:0] extractor_code;

// Test signals
logic [PARITY_WIDTH-1:0] expected_code;
logic  [BLOCK_WIDTH-1:0] expected_block;
logic   [DATA_WIDTH-1:0] test_data;
logic [PARITY_WIDTH-1:0] test_code;
logic  [BLOCK_WIDTH-1:0] test_block;

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

hamming_block_packager #(
  .DATA_WIDTH ( DATA_WIDTH )
) hamming_block_packager_dut (
  .data  ( packager_data  ),
  .code  ( packager_code  ),
  .block ( packager_block )
);

hamming_block_extractor #(
  .BLOCK_WIDTH ( BLOCK_WIDTH )
) hamming_block_extractor_dut (
  .block ( extractor_block ),
  .data  ( extractor_data  ),
  .code  ( extractor_code  )
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
  .block          ( block_corrector_block          ),
  .error          ( block_corrector_error          ),
  .corrected_data ( block_corrector_corrected_data )
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

// Reference function for calculating expected Hamming code
function logic [PARITY_WIDTH-1:0] calculate_expected_code(input logic [DATA_WIDTH-1:0] data);
  case (PARITY_WIDTH)
    3: calculate_expected_code = hamming_7_4(data);
    4: calculate_expected_code = hamming_15_11(data);
    5: calculate_expected_code = hamming_31_26(data);
    6: calculate_expected_code = hamming_63_57(data);
    7: calculate_expected_code = hamming_127_120(data);
    8: calculate_expected_code = hamming_255_247(data);
    default: begin
      $fatal(1, "[%0tns] Unsupported parity width '%0d' for reference function.", $time, PARITY_WIDTH);
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
  return expected_block;
endfunction

// Task to introduce single bit error in block
task introduce_single_bit_error(input integer error_position, input logic [BLOCK_WIDTH-1:0] original_block, output logic [BLOCK_WIDTH-1:0] corrupted_block);
  corrupted_block = original_block ^ (1 << error_position);
endtask

// Main test block
initial begin
  // Log waves
  $dumpfile("hamming.testbench.vcd");
  $dumpvars(0, hamming__testbench);

  // Initialization
  encoder_data          = 0;
  checker_data          = 0;
  checker_code          = 0;
  corrector_data        = 0;
  corrector_code        = 0;
  block_checker_block   = 0;
  block_corrector_block = 0;
  packager_data         = 0;
  packager_code         = 0;
  extractor_block       = 0;

  // Small delay after initialization
  #1;

  // Determine if we do exhaustive or random testing
  if (DATA_WIDTH_POW2 <= FULL_CHECK_MAX_DURATION) begin
    $display("Using exhaustive testing (2^%0d = %0d configurations)", DATA_WIDTH, DATA_WIDTH_POW2);

    // Check 1: Complete error-free path testing
    $display("CHECK 1: Complete error-free path testing (all modules with correct data).");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      // Encode the data
      encoder_data = data_configuration;

      // Calculate expected Hamming code and block
      expected_code  = calculate_expected_code(encoder_data);
      expected_block = hamming_block_pack(encoder_data, expected_code);

      // Wait for combinatorial logic propagation
      #1;

      // Test encoder outputs
      assert (encoder_code === expected_code)
        else $error("[%0tns] Incorrect encoder code for data %b. Expected %b, got %b.",
                    $time, data_configuration, expected_code, encoder_code);
      assert (encoder_block === expected_block)
        else $error("[%0tns] Incorrect encoder block for data %b. Expected %b, got %b.",
                    $time, data_configuration, expected_block, encoder_block);

      // Test packager with same data and code
      packager_data = encoder_data;
      packager_code = encoder_code;
      #1;

      assert (packager_block === encoder_block)
        else $error("[%0tns] Packager block mismatch for data %b. Expected %b, got %b.",
                    $time, data_configuration, encoder_block, packager_block);

      // Test extractor with encoder block
      extractor_block = encoder_block;
      #1;

      assert (extractor_data === encoder_data)
        else $error("[%0tns] Extractor data mismatch for block %b. Expected %b, got %b.",
                    $time, encoder_block, encoder_data, extractor_data);
      assert (extractor_code === encoder_code)
        else $error("[%0tns] Extractor code mismatch for block %b. Expected %b, got %b.",
                    $time, encoder_block, encoder_code, extractor_code);

      // Test pack-unpack roundtrip consistency
      packager_data = encoder_data;
      packager_code = encoder_code;
      #1;
      extractor_block = packager_block;
      #1;

      assert (extractor_data === encoder_data)
        else $error("[%0tns] Pack-unpack roundtrip data mismatch for data %b. Expected %b, got %b.",
                    $time, data_configuration, encoder_data, extractor_data);
      assert (extractor_code === encoder_code)
        else $error("[%0tns] Pack-unpack roundtrip code mismatch for data %b. Expected %b, got %b.",
                    $time, data_configuration, encoder_code, extractor_code);

      // Test all modules with correct data/code/block
      checker_data          = encoder_data;
      checker_code          = encoder_code;
      corrector_data        = encoder_data;
      corrector_code        = encoder_code;
      block_checker_block   = encoder_block;
      block_corrector_block = encoder_block;
      #1;

      // All modules should report no errors with correct data
      assert (checker_error === 1'b0)
        else $error("[%0tns] False error detected in checker for correct data %b.",
                    $time, data_configuration);
      assert (corrector_error === 1'b0)
        else $error("[%0tns] False error detected in corrector for correct data %b.",
                    $time, data_configuration);
      assert (block_checker_error === 1'b0)
        else $error("[%0tns] False error detected in block checker for correct data %b.",
                    $time, data_configuration);
      assert (block_corrector_error === 1'b0)
        else $error("[%0tns] False error detected in block corrector for correct data %b.",
                    $time, data_configuration);

      // Corrected data should match original
      assert (corrector_corrected_data === encoder_data)
        else $error("[%0tns] Incorrect corrected data. Expected %b, got %b.",
                    $time, encoder_data, corrector_corrected_data);
      assert (block_corrector_corrected_data === encoder_data)
        else $error("[%0tns] Incorrect block corrected data. Expected %b, got %b.",
                    $time, encoder_data, block_corrector_corrected_data);

      // Small delay before next configuration
      #1;
    end

    // Check 2: Complete error injection testing
    $display("CHECK 2: Complete error injection testing (all modules with corrupted data).");
    for (integer data_configuration = 0; data_configuration < DATA_WIDTH_POW2; data_configuration++) begin
      // Encode the original data
      encoder_data = data_configuration;
      #1;

      // Introduce single bit errors in each position of the block
      for (error_position = 0; error_position < BLOCK_WIDTH; error_position++) begin
        // Create corrupted block with single bit error
        introduce_single_bit_error(error_position, encoder_block, test_block);

        // Test with block checker - should detect error
        block_checker_block = test_block;
        #1;

        assert (block_checker_error === 1'b1)
          else $error("[%0tns] Failed to detect single bit error at position %0d for data %b.",
                      $time, error_position, data_configuration);

        // Test with block corrector - should detect and correct error
        block_corrector_block = test_block;
        #1;

        assert (block_corrector_error === 1'b1)
          else $error("[%0tns] Block corrector failed to detect single bit error at position %0d for data %b.",
                      $time, error_position, data_configuration);
        assert (block_corrector_corrected_data === encoder_data)
          else $error("[%0tns] Block corrector failed to correct single bit error at position %0d for data %b. Expected %b, got %b.",
                      $time, error_position, data_configuration, encoder_data, block_corrector_corrected_data);

        // Extract corrupted data and code from corrupted block using DUT extractor
        extractor_block = test_block;
        #1;

        // Test with normal checker - should detect error
        checker_data = extractor_data;
        checker_code = extractor_code;
        #1;

        assert (checker_error === 1'b1)
          else $error("[%0tns] Normal checker failed to detect single bit error at position %0d for data %b.",
                      $time, error_position, data_configuration);

        // Test with normal corrector - should detect and correct error
        corrector_data = extractor_data;
        corrector_code = extractor_code;
        #1;

        assert (corrector_error === 1'b1)
          else $error("[%0tns] Normal corrector failed to detect single bit error at position %0d for data %b.",
                      $time, error_position, data_configuration);
        assert (corrector_corrected_data === encoder_data)
          else $error("[%0tns] Normal corrector failed to correct single bit error at position %0d for data %b. Expected %b, got %b.",
                      $time, error_position, data_configuration, encoder_data, corrector_corrected_data);

        // Small delay before next error position
        #1;
      end

      // Small delay before next data configuration
      #1;
    end

  end else begin
    // Random testing for larger data widths
    $display("Using random testing (%0d iterations)", RANDOM_CHECK_DURATION);

    // Check 1: Random error-free path testing
    $display("CHECK 1: Random error-free path testing (all modules with correct data).");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION; random_iteration++) begin
      // Generate random data
      encoder_data = $urandom_range(0, DATA_WIDTH_POW2-1);

      // Calculate expected Hamming code and block
      expected_code  = calculate_expected_code(encoder_data);
      expected_block = hamming_block_pack(encoder_data, expected_code);

      // Wait for combinatorial logic propagation
      #1;

      // Test encoder outputs
      assert (encoder_code === expected_code)
        else $error("[%0tns] Incorrect encoder code for data %b. Expected %b, got %b.",
                    $time, encoder_data, expected_code, encoder_code);
      assert (encoder_block === expected_block)
        else $error("[%0tns] Incorrect encoder block for data %b. Expected %b, got %b.",
                    $time, encoder_data, expected_block, encoder_block);

      // Test packager with same data and code
      packager_data = encoder_data;
      packager_code = encoder_code;
      #1;

      assert (packager_block === encoder_block)
        else $error("[%0tns] Random packager block mismatch for data %b. Expected %b, got %b.",
                    $time, encoder_data, encoder_block, packager_block);

      // Test extractor with encoder block
      extractor_block = encoder_block;
      #1;

      assert (extractor_data === encoder_data)
        else $error("[%0tns] Random extractor data mismatch for block %b. Expected %b, got %b.",
                    $time, encoder_block, encoder_data, extractor_data);
      assert (extractor_code === encoder_code)
        else $error("[%0tns] Random extractor code mismatch for block %b. Expected %b, got %b.",
                    $time, encoder_block, encoder_code, extractor_code);

      // Test pack-unpack roundtrip consistency
      packager_data = encoder_data;
      packager_code = encoder_code;
      #1;
      extractor_block = packager_block;
      #1;

      assert (extractor_data === encoder_data)
        else $error("[%0tns] Random pack-unpack roundtrip data mismatch for data %b. Expected %b, got %b.",
                    $time, encoder_data, encoder_data, extractor_data);
      assert (extractor_code === encoder_code)
        else $error("[%0tns] Random pack-unpack roundtrip code mismatch for data %b. Expected %b, got %b.",
                    $time, encoder_data, encoder_code, extractor_code);

      // Test all modules with correct data
      checker_data          = encoder_data;
      checker_code          = encoder_code;
      corrector_data        = encoder_data;
      corrector_code        = encoder_code;
      block_checker_block   = encoder_block;
      block_corrector_block = encoder_block;
      #1;

      // All should report no errors
      assert (checker_error === 1'b0)
        else $error("[%0tns] False error in checker for correct data %b.", $time, encoder_data);
      assert (corrector_error === 1'b0)
        else $error("[%0tns] False error in corrector for correct data %b.", $time, encoder_data);
      assert (block_checker_error === 1'b0)
        else $error("[%0tns] False error in block checker for correct data %b.", $time, encoder_data);
      assert (block_corrector_error === 1'b0)
        else $error("[%0tns] False error in block corrector for correct data %b.", $time, encoder_data);

      // Corrected data should match original
      assert (corrector_corrected_data === encoder_data)
        else $error("[%0tns] Incorrect corrected data %b, expected %b.", $time, corrector_corrected_data, encoder_data);
      assert (block_corrector_corrected_data === encoder_data)
        else $error("[%0tns] Incorrect block corrected data %b, expected %b.", $time, block_corrector_corrected_data, encoder_data);

      // Small delay before next iteration
      #1;
    end

    // Check 2: Random error injection testing
    $display("CHECK 2: Random error injection testing (all modules with corrupted data).");
    for (integer random_iteration = 0; random_iteration < RANDOM_CHECK_DURATION/4; random_iteration++) begin
      // Generate and encode random data
      encoder_data = $urandom_range(0, DATA_WIDTH_POW2-1);
      #1;

      // Randomly select error position
      error_position = $urandom_range(0, BLOCK_WIDTH-1);

      // Create corrupted block
      introduce_single_bit_error(error_position, encoder_block, test_block);

      // Test error detection and correction with block modules
      block_checker_block   = test_block;
      block_corrector_block = test_block;
      #1;

      // Should detect error
      assert (block_checker_error === 1'b1)
        else $error("[%0tns] Failed to detect random single bit error at position %0d for data %b.",
                    $time, error_position, encoder_data);
      assert (block_corrector_error === 1'b1)
        else $error("[%0tns] Block corrector failed to detect random single bit error at position %0d for data %b.",
                    $time, error_position, encoder_data);

      // Should correct error
      assert (block_corrector_corrected_data === encoder_data)
        else $error("[%0tns] Block corrector failed to correct random single bit error at position %0d for data %b. Expected %b, got %b.",
                    $time, error_position, encoder_data, encoder_data, block_corrector_corrected_data);

      // Extract corrupted data and code from corrupted block using DUT extractor
      extractor_block = test_block;
      #1;

      // Test with normal checker - should detect error
      checker_data = extractor_data;
      checker_code = extractor_code;
      #1;

      assert (checker_error === 1'b1)
        else $error("[%0tns] Normal checker failed to detect random single bit error at position %0d for data %b.",
                    $time, error_position, encoder_data);

      // Test with normal corrector - should detect and correct error
      corrector_data = extractor_data;
      corrector_code = extractor_code;
      #1;

      assert (corrector_error === 1'b1)
        else $error("[%0tns] Normal corrector failed to detect random single bit error at position %0d for data %b.",
                    $time, error_position, encoder_data);
      assert (corrector_corrected_data === encoder_data)
        else $error("[%0tns] Normal corrector failed to correct random single bit error at position %0d for data %b. Expected %b, got %b.",
                    $time, error_position, encoder_data, encoder_data, corrector_corrected_data);

      // Small delay before next iteration
      #1;
    end
  end

  // End of test
  $display("All Hamming tests completed successfully!");
  $finish;
end

endmodule