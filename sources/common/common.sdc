# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        common.sdc                                                   ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: Common helper procedures for SDC Tickle scripts.             ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



namespace eval ::omnicores::common {

  # Get the hierarchical path of an object
  proc get_path { object } {
    # Synopsys DesignCompiler, Synopsys ICCompiler2, Synopsys PrimeTime (default) :
    return [get_attribute $object full_name]
  }

  # Generates the register path based on a base path
  proc get_registers { patterns } {
    # Synopsys DesignCompiler, Synopsys ICCompiler2, Synopsys PrimeTime (default) :
    return "${patterns}_reg"
    # Xilinx Vivado? :
    # return "${patterns}_"
  }

  # Generates the indexed path on an element within a vector
  proc get_at_index { patterns index } {
    # Synopsys DesignCompiler (default) :
    return "${patterns}\[${index}\]"
    # Synopsys ICCompiler2, Synopsys PrimeTime, Xilinx Vivado? :
    # return "${patterns}_${index}_"
  }

  # Get all instances of a module
  proc get_instances { module_name } {
    return [get_cells -hierarchical -filter "ref_name == $module_name"]
  }

  # Determines the width of a vector register
  proc get_width { base_object_pattern } {
    # Use the get_at_index procedure to generate the indexed pattern
    namespace import ::omnicores::common::get_at_index

    # Safety limit for loop iterations
    set max_search_depth 1024

    # Iterate over the indexed pattern
    set width        0
    set search_index 0
    while { $search_index < $max_search_depth } {
      # Generate the indexed pattern
      set indexed_pattern [get_at_index $base_object_pattern $search_index]

      # Check if the indexed pattern is a valid cell
      if { [llength [get_cells -quiet $indexed_pattern]] > 0 } {
        incr width
        incr search_index
      } else {
        # No element found at the search_index, we reached the end of the register.
        break
      }
    }
    return $width
  }

}