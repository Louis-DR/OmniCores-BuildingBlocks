# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        asynchronous_advanced_fifo_controller.sdc                    ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the asynchronous advanced FIFO           ║
# ║              controller module.                                           ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../../common/common.sdc"]
# Source the vector synchronizer constraints
source [file join [file dirname [info script]] "../../../timing/vector_synchronizer/vector_synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::asynchronous_advanced_fifo_controller {

  # Apply timing constraints to a specific instance of the asynchronous advanced FIFO controller module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Get the instance name
    set instance_name [file tail $instance_path]

    # Call the vector synchronizer constraints procedure on both pointer synchronizers
    puts "Info: Applying vector synchronizer constraints to 'read_pointer_gray_sync' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance "${instance_path}/read_pointer_gray_sync"

    puts "Info: Applying vector synchronizer constraints to 'write_pointer_gray_sync' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::vector_synchronizer::apply_constraints_to_instance "${instance_path}/write_pointer_gray_sync"
  }

}
