# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        vector_synchronizer.sdc                                      ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the vector synchronizer module.          ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the synchronizer constraints
source [file join [file dirname [info script]] "../../timing/synchronizer/synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::vector_synchronizer {

  # Apply timing constraints to a specific instance of the vector synchronizer module
  proc apply_constraints_to_instance { instance_path } {
    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Determine the width of the data by
    set depth 8

    # Check if the number of stages is valid
    if { $depth == 0 } {
      puts "Warning: Could not determine the width of the data for vector synchronizer instance '$instance_path'. Skipping constraints."
      return
    }

    # Call the synchronizer constraints procedure for each bit
    for { set depth_index 0 } { $depth_index < $depth - 1 } { incr depth_index } {
      puts "Info: Applying synchronizer constraints to 'synchronizer[$depth_index]' in instance '$instance_path'."
      ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/synchronizer_${depth_index}_"
    }
  }

}
