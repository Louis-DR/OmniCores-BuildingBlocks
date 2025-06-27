`ifndef __OMNICORES_CONSTANTS__
`define __OMNICORES_CONSTANTS__

// Signed 8-bit limits
localparam byte              BYTE_MIN              = 8'sh80;                 // -128
localparam byte              BYTE_MAX              = 8'sh7F;                 //  127

// Unsigned 8-bit limits
localparam byte unsigned     BYTE_UNSIGNED_MIN     = 8'h00;                  // 0
localparam byte unsigned     BYTE_UNSIGNED_MAX     = 8'hFF;                  // 255

// Signed 16-bit limits
localparam shortint          SHORTINT_MIN          = 16'sh8000;              // -32,768
localparam shortint          SHORTINT_MAX          = 16'sh7FFF;              //  32,767

// Unsigned 16-bit limits
localparam shortint unsigned SHORTINT_UNSIGNED_MIN = 16'h0000;               // 0
localparam shortint unsigned SHORTINT_UNSIGNED_MAX = 16'hFFFF;               // 65,535

// Signed 32-bit limits
localparam int               INT_MIN               = 32'sh80000000;          // -2,147,483,648
localparam int               INT_MAX               = 32'sh7FFFFFFF;          //  2,147,483,647

// Unsigned 32-bit limits
localparam int unsigned      INT_UNSIGNED_MIN      = 32'h00000000;           // 0
localparam int unsigned      INT_UNSIGNED_MAX      = 32'hFFFFFFFF;           // 4,294,967,295

// Signed 64-bit limits
localparam longint           LONGINT_MIN           = 64'sh8000000000000000;  // -9,223,372,036,854,775,808
localparam longint           LONGINT_MAX           = 64'sh7FFFFFFFFFFFFFFF;  //  9,223,372,036,854,775,807

// Unsigned 64-bit limits
localparam longint unsigned  LONGINT_UNSIGNED_MIN  = 64'h0000000000000000;   // 0
localparam longint unsigned  LONGINT_UNSIGNED_MAX  = 64'hFFFFFFFFFFFFFFFF;   // 18,446,744,073,709,551,615

`endif