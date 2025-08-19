# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        wide_clock_multiplexer.sdc                                   ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the wide clock multiplexer module.       ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../common/common.sdc"]
# Source the synchronizer constraints
source [file join [file dirname [info script]] "../../timing/synchronizer/synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::wide_clock_multiplexer {

  # Apply timing constraints to a specific instance of the clock multiplexer module
  proc apply_constraints_to_instance { instance_path } {
    # Use common helper functions
    namespace import ::omnicores::common::get_width

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Get the instance name
    set instance_name [file tail $instance_path]

    # Get the output clock pin
    set clock_out_pin [get_pins -quiet "${instance_path}/clock_out"]

    if { $clock_out_pin eq "" } {
      puts "Warning: Output pin '${instance_path}/clock_out' not found for clock multiplexer instance '$instance_path'. Skipping generated clock creation."
      return
    }

    # Determine the number of input clocks
    set clocks_pin_pattern [get_pins -quiet "${instance_path}/clocks"]
    set num_clocks [get_width $clocks_pin_pattern]

    # Check if the number of clocks is valid
    if { $num_clocks == 0 } {
      puts "Warning: Could not determine the number of input clocks for clock multiplexer instance '$instance_path' (clocks pin pattern '$clocks_pin_pattern' not found or is 0-width). Skipping constraints."
      return
    }
    if { $num_clocks < 2 } {
      puts "Warning: Clock multiplexer instance '$instance_path' has only $num_clocks clock(s). This is unusual for a clock multiplexer. Skipping constraints."
      return
    }

    puts "Info: Detected $num_clocks input clocks for clock multiplexer instance '$instance_path'."

    set generated_clocks_on_output [list]

    # Process clocks from each input clock pin
    for { set clock_index 0 } { $clock_index < $num_clocks } { incr clock_index } {
      set clock_pin [get_pins -quiet "${instance_path}/clocks\[${clock_index}\]"]

      if { $clock_pin eq "" } {
        puts "Warning: Input clock pin '${instance_path}/clocks\[${clock_index}\]' not found. Cannot create generated clocks from this source."
        continue
      }

      set clocks_on_pin [get_clocks -quiet -of_objects $clock_pin]
      if { [llength $clocks_on_pin] == 0 } {
        puts "Warning: No clocks found on '$clock_pin' for instance '$instance_path'. Skipping generated clock creation from this pin."
        continue
      }

      foreach clock_on_pin $clocks_on_pin {
        # Sanitize clock_on_pin for use in a generated clock name if necessary
        set generated_clock_name "${clock_on_pin}_through_${instance_name}_input_${clock_index}"

        if { [llength [get_clocks -quiet $generated_clock_name]] == 0 } {
          puts "Info: Creating generated clock '$generated_clock_name' on '$clock_out_pin' of clock '$clock_on_pin' through '$clock_pin'."
          create_generated_clock -name $generated_clock_name \
                                 -source $clock_pin \
                                 -master_clock $clock_on_pin \
                                 -divide_by 1 -add $clock_out_pin
          lappend generated_clocks_on_output $generated_clock_name
        } else {
          puts "Info: Generated clock '$generated_clock_name' already exists. Skipping creation."
          if { [lsearch -exact $generated_clocks_on_output $generated_clock_name] == -1 } {
            lappend generated_clocks_on_output $generated_clock_name
          }
        }
      }
    }

    # Create logically exclusive clock groups of all generated clocks on the output
    if { [llength $generated_clocks_on_output] > 1 } {
      puts "Info: Setting logically exclusive group for clocks on output of instance '$instance_path'."
      set_clock_groups -logically_exclusive -group $generated_clocks_on_output
    } elseif { [llength $generated_clocks_on_output] == 1 } {
      puts "Info: Only one generated clock '[lindex $generated_clocks_on_output 0]' on output of instance '$instance_path'. No clock group needed."
    } else {
      puts "Warning: No generated clocks defined for instance '$instance_path'. Cannot set clock group."
    }

    # Call the synchronizer constraints procedure on all synchronizers
    for { set clock_index 0 } { $clock_index < $num_clocks } { incr clock_index } {
      set synchronizer_instance_name "gen_clocks\[${clock_index}\].clock_enable_synchronizer"
      puts "Info: Applying synchronizer constraints to '$synchronizer_instance_name' in instance '$instance_path'."
      ::omnicores::buildingblocks::timing::synchronizer::apply_constraints_to_instance "${instance_path}/${synchronizer_instance_name}"
    }
  }

}
