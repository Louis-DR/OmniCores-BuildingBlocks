# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        nonstop_clock_multiplexer.sdc                                ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the non-stop clock multiplexer module.   ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source the synchronizers constraints
source [file join [file dirname [info script]] "../fast_clock_multiplexer/fast_clock_multiplexer.sdc"]
source [file join [file dirname [info script]] "../../timing/synchronizer/synchronizer.sdc"]
source [file join [file dirname [info script]] "../../timing/fast_synchronizer/fast_synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::nonstop_clock_multiplexer {

  # Apply timing constraints to a specific instance of the non-stop clock multiplexer module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Call the fast clock multiplexer constraints procedure on the core multiplexer
    puts "Info: Applying fast clock multiplexer constraints to 'core_clock_multiplexer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::fast_clock_multiplexer::apply_constraints_to_instance "${instance_path}/core_clock_multiplexer"

    # Call the synchronizer constraints procedure on the disable synchronizers
    puts "Info: Applying synchronizer constraints to 'disable_clock_0_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/disable_clock_0_synchronizer"

    puts "Info: Applying synchronizer constraints to 'disable_clock_1_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/disable_clock_1_synchronizer"
  }

}
