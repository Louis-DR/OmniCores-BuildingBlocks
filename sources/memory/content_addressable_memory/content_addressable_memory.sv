// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║ Project:     OmniCores-BuildingBlocks                                     ║
// ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
// ║ Website:     louis-dr.github.io                                           ║
// ║ License:     MIT License                                                  ║
// ║ File:        content_addressable_memory.sv                                ║
// ╟───────────────────────────────────────────────────────────────────────────╢
// ║ Description: Associative memory that is addresses by a tag instead of an  ║
// ║              address. Also called a CAM.                                  ║
// ║                                                                           ║
// ║              When the memory is not full, the write interface allows data ║
// ║              to be stored alongside a tag. The tag is provided by the     ║
// ║              system around the CAM.                                       ║
// ║                                                                           ║
// ║              The memory is then addressed by the tags. When a tag is      ║
// ║              provided on the read interface, it is searched for and it    ║
// ║              can result in a hit or a miss. In case of a hit, the corres- ║
// ║              ponding data is returned.                                    ║
// ║                                                                           ║
// ║              The delete interface also takes in a tag and searches for it ║
// ║              but invalidates the corresponding entry to free the slot.    ║
// ║                                                                           ║
// ║              All operations take one cycle. For the read, the data is     ║
// ║              available one cycle after the tag is provided.               ║
// ║                                                                           ║
// ║              Reading and eviction cannot occur in the same cycle. The     ║
// ║              eviction takes precedence over the read. The read data is    ║
// ║              only valid when the hit is notified (which it is not if an   ║
// ║              eviction is also requested).                                 ║
// ║                                                                           ║
// ╚═══════════════════════════════════════════════════════════════════════════╝



module content_addressable_memory #(
  parameter TAG_WIDTH   = 8,
  parameter DATA_WIDTH  = 8,
  parameter DEPTH       = 16
) (
  input                   clock,
  input                   resetn,
  output                  full,
  output                  empty,
  // Write interface
  input                   write_enable,
  input   [TAG_WIDTH-1:0] write_tag,
  input  [DATA_WIDTH-1:0] write_data,
  // Read interface
  input                   read_enable,
  input   [TAG_WIDTH-1:0] read_tag,
  output [DATA_WIDTH-1:0] read_data,
  output                  read_hit,
  // Evict interface
  input                   delete_enable,
  input   [TAG_WIDTH-1:0] delete_tag
);

parameter INDEX_WIDTH = $clog2(DEPTH);

// Tag directory
logic                   directory_allocate_enable;
logic   [TAG_WIDTH-1:0] directory_allocate_tag;
logic [INDEX_WIDTH-1:0] directory_allocate_index;
logic   [TAG_WIDTH-1:0] directory_search_tag;
logic [INDEX_WIDTH-1:0] directory_search_index;
logic                   directory_search_hit;
logic                   directory_evict_enable;
logic [INDEX_WIDTH-1:0] directory_evict_index;
tag_directory #(
  .WIDTH ( TAG_WIDTH ),
  .DEPTH ( DEPTH     )
) tag_directory (
  .clock           ( clock                     ),
  .resetn          ( resetn                    ),
  .full            ( full                      ),
  .empty           ( empty                     ),
  .allocate_enable ( directory_allocate_enable ),
  .allocate_tag    ( directory_allocate_tag    ),
  .allocate_index  ( directory_allocate_index  ),
  .search_tag      ( directory_search_tag      ),
  .search_index    ( directory_search_index    ),
  .search_hit      ( directory_search_hit      ),
  .evict_enable    ( directory_evict_enable    ),
  .evict_index     ( directory_evict_index     )
);

// Data memory
logic                     ram_write_enable;
logic [ADDRESS_WIDTH-1:0] ram_write_address;
logic    [DATA_WIDTH-1:0] ram_write_data;
logic                     ram_read_enable;
logic [ADDRESS_WIDTH-1:0] ram_read_address;
logic    [DATA_WIDTH-1:0] ram_read_data;
simple_dual_port_ram #(
  .WIDTH ( DATA_WIDTH ),
  .DEPTH ( DEPTH      )
) simple_dual_port_ram (
  .clock         ( clock             ),
  .write_enable  ( ram_write_enable  ),
  .write_address ( ram_write_address ),
  .write_data    ( ram_write_data    ),
  .read_enable   ( ram_read_enable   ),
  .read_address  ( ram_read_address  ),
  .read_data     ( ram_read_data     )
);

// Write logic
assign directory_allocate_enable = write_enable;
assign directory_allocate_tag    = write_tag;
assign ram_write_enable          = write_enable;
assign ram_write_address         = directory_allocate_index;
assign ram_write_data            = write_data;

// Search arbitration
assign directory_search_tag = delete_enable ? delete_tag : read_tag;

// Read logic
assign ram_read_enable  = read_enable & ~delete_enable & directory_search_hit;
assign ram_read_address = directory_search_index;
assign read_data        = ram_read_data;
assign read_hit         = ram_read_enable;

// Assign
assign directory_evict_enable = delete_enable & directory_search_hit;
assign directory_evict_index  = directory_search_index;

endmodule