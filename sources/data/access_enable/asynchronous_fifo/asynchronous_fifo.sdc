# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        asynchronous_fifo.sdc                                        ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the asynchronous FIFO module.            ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../../common/common.sdc"]
# Source the asynchronous FIFO controller constraints
source [file join [file dirname [info script]] "../../controllers/asynchronous_fifo/asynchronous_fifo_controller.sdc"]



namespace eval ::omnicores::buildingblocks::timing::asynchronous_fifo {

  # Apply timing constraints to a specific instance of the asynchronous FIFO module
  proc apply_constraints_to_instance { instance_path } {

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Get the instance name
    set instance_name [file tail $instance_path]

    # Call the asynchronous FIFO controller constraints procedure on the controller instance
    puts "Info: Applying asynchronous FIFO controller constraints to 'controller' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::asynchronous_fifo_controller::apply_constraints_to_instance "${instance_path}/controller"
  }

}
