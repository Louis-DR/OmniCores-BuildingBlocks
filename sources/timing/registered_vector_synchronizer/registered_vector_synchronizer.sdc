# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        registered_vector_synchronizer.sdc                           ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the registered vector synchronizer       ║
# ║              module.                                                      ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the vector synchronizer constraints
source [file join [file dirname [info script]] "../../timing/vector_synchronizer/vector_synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::registered_vector_synchronizer {

  # Apply timing constraints to a specific instance of the registered vector synchronizer module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Call the vector synchronizer constraints procedure
    puts "Info: Applying vector synchronizer constraints to 'vector_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance "${instance_path}/vector_synchronizer"

  }

}
