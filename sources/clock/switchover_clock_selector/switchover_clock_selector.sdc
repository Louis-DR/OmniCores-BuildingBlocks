# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        switchover_clock_selector.sdc                                ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the switchover clock selector module.    ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the synchronizers constraints
source [file join [file dirname [info script]] "../../timing/synchronizer/synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::switchover_clock_selector {

  # Apply timing constraints to a specific instance of the switchover clock selector module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Call the synchronizer constraints procedure on the synchronizers
    puts "Info: Applying synchronizer constraints to 'disable_first_clock_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/disable_first_clock_synchronizer"

    puts "Info: Applying synchronizer constraints to 'enable_second_clock_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/enable_second_clock_synchronizer"
  }

}
