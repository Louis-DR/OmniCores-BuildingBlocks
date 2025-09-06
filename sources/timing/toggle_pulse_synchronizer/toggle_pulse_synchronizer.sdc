# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        toggle_pulse_synchronizer.sdc                                ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the toggle pulse synchronizer module.    ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the synchronizer constraints
source [file join [file dirname [info script]] "../../timing/synchronizer/synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::toggle_pulse_synchronizer {

  # Apply timing constraints to a specific instance of the toggle pulse synchronizer module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Call the synchronizer constraints procedure
    puts "Info: Applying synchronizer constraints to 'state_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/state_synchronizer"

  }

}
