# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        closed_loop_vector_synchronizer.sdc                          ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the closed-loop vector synchronizer      ║
# ║              module.                                                      ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the toggle pulse synchronizer constraints
source [file join [file dirname [info script]] "../../timing/toggle_pulse_synchronizer/toggle_pulse_synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::closed_loop_vector_synchronizer {

  # Apply timing constraints to a specific instance of the closed-loop vector synchronizer module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Call the toggle pulse synchronizer constraints procedure
    puts "Info: Applying toggle pulse synchronizer constraints to 'update_pulse_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance "${instance_path}/update_pulse_synchronizer"
    puts "Info: Applying toggle pulse synchronizer constraints to 'feedback_pulse_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::toggle_pulse_synchronizer::apply_constraints_to_instance "${instance_path}/feedback_pulse_synchronizer"

  }

}
