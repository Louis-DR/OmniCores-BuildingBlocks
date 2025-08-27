# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        reset_synchronizer.sdc                                       ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the reset synchronizer module.           ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../common/common.sdc"]



namespace eval ::omnicores::buildingblocks::timing::reset_synchronizer {

  # Apply timing constraints to a specific instance of the reset synchronizer module
  proc apply_constraints_to_instance { instance_path } {
    # Use common helper functions
    namespace import ::omnicores::common::get_registers
    namespace import ::omnicores::common::get_at_index
    namespace import ::omnicores::common::get_width

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Determine the number of stages by finding the width of the 'stages' register
    set stages_reg_pattern [get_registers "${instance_path}/stages"]
    set stages             [get_width $stages_reg_pattern]

    # Check if the number of stages is valid
    if { $stages == 0 } {
      puts "Warning: Could not determine the number of stages for synchronizer instance '$instance_path' (stages register pattern '$stages_reg_pattern' not found or is 0-width). Skipping constraints."
      return
    }
    if { $stages < 2 } {
      puts "Warning: Synchronizer instance '$instance_path' has only $stages stage(s). This is unusual for a synchronizer. Skipping constraints."
      return
    }

    # Set a false path to the input of the first synchronizer flip-flop
    set capture_flop_pattern [get_at_index $stages_reg_pattern 0]
    set capture_flop_pin     [get_pins -quiet ${capture_flop_pattern}/D]
    if { $capture_flop_pin ne "" } {
      puts "Info: Setting false path to '${capture_flop_pattern}/D'."
      set_false_path -to $capture_flop_pin
    } else {
      puts "Warning: Could not find pin pattern '${capture_flop_pattern}/D' for synchronizer instance '$instance_path'."
    }

    # Set a false path to the reset of all synchronizer flip-flops
    for { set stage_index 0 } { $stage_index < $stages } { incr stage_index } {
      set stage_reg_pattern [get_at_index $stages_reg_pattern $stage_index]
      set stage_clear_pin   [get_pins -quiet ${stage_reg_pattern}/R]
      if { $stage_clear_pin ne "" } {
        puts "Info: Setting false path to '${stage_reg_pattern}/R'."
        set_false_path -to $stage_clear_pin
      } else {
        puts "Warning: Could not find stage pin pattern '${stage_reg_pattern}/Q' for synchronizer instance '$instance_path'."
      }
    }

    # Set a max delay of 0 between consecutive synchronization stages to force them as close as possible
    for { set stage_index 0 } { $stage_index < $stages - 1 } { incr stage_index } {
      set source_reg_pattern      [get_at_index $stages_reg_pattern $stage_index]
      set destination_reg_pattern [get_at_index $stages_reg_pattern [expr {$stage_index + 1}]]

      set source_pin      [get_pins -quiet ${source_reg_pattern}/Q]
      set destination_pin [get_pins -quiet ${destination_reg_pattern}/D]

      if { $source_pin ne "" && $destination_pin ne "" } {
        # Use get_pin_info for better reporting if available
        puts "Info: Setting max delay 0 from '${source_reg_pattern}/Q' to '${destination_reg_pattern}/D'."
        set_max_delay 0 -from $source_pin -to $destination_pin
      } else {
        if { $source_pin eq "" } {
          puts "Warning: Could not find source pin pattern '${source_reg_pattern}/Q' for synchronizer instance '$instance_path'."
        }
        if { $destination_pin eq "" } {
          puts "Warning: Could not find destination pin pattern '${destination_reg_pattern}/D' for synchronizer instance '$instance_path'."
        }
      }
    }
  }

}
