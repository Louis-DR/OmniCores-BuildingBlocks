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

}