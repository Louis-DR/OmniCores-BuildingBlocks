# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        fast_clock_multiplexer.sdc                                   ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the fast clock multiplexer module.       ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../common/common.sdc"]
# Source the synchronizer constraints
source [file join [file dirname [info script]] "../../timing/fast_synchronizer/fast_synchronizer.sdc"]



namespace eval ::omnicores::buildingblocks::timing::fast_clock_multiplexer {

  # Apply timing constraints to a specific instance of the fast clock multiplexer module
  proc apply_constraints_to_instance { instance_path } {

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

    # Get the input clock pins
    set clock_0_pin [get_pins -quiet "${instance_path}/clock_0"]
    set clock_1_pin [get_pins -quiet "${instance_path}/clock_1"]

    if { $clock_0_pin eq "" } {
      puts "Warning: Input clock pin '${instance_path}/clock_0' not found. Cannot create generated clocks from this source."
    }
    if { $clock_1_pin eq "" } {
      puts "Warning: Input clock pin '${instance_path}/clock_1' not found. Cannot create generated clocks from this source."
    }

    set generated_clocks_on_output [list]

    # Process clocks from clock_0_pin
    if { $clock_0_pin ne "" } {
      set clocks_on_pin_0 [get_clocks -quiet -of_objects $clock_0_pin]
      if { [llength $clocks_on_pin_0] == 0 } {
        puts "Warning: No clocks found on '$clock_0_pin' for instance '$instance_path'. Skipping generated clock creation from this pin."
      } else {
        foreach clock_on_pin_0 $clocks_on_pin_0 {
          # Sanitize clock_on_pin_0 for use in a generated clock name if necessary
          set generated_clock_name "${clock_on_pin_0}_through_${instance_name}_input_0"

          if { [llength [get_clocks -quiet $generated_clock_name]] == 0 } {
            puts "Info: Creating generated clock '$generated_clock_name' on '$clock_out_pin' of clock '$clock_on_pin_0' through '$clock_0_pin'."
            create_generated_clock -name $generated_clock_name \
                                   -source $clock_0_pin \
                                   -master_clock $clock_on_pin_0 \
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
    }

    # Process clocks from clock_1_pin
    if { $clock_1_pin ne "" } {
      set clocks_on_pin_1 [get_clocks -quiet -of_objects $clock_1_pin]
      if { [llength $clocks_on_pin_1] == 0 } {
        puts "Warning: No clocks found on '$clock_1_pin' for instance '$instance_path'. Skipping generated clock creation from this pin."
      } else {
        foreach clock_on_pin_1 $clocks_on_pin_1 {
          set generated_clock_name "${clock_on_pin_1}_through_${instance_name}_input_1"

          if { [llength [get_clocks -quiet $generated_clock_name]] == 0 } {
            puts "Info: Creating generated clock '$generated_clock_name' on '$clock_out_pin' of clock '$clock_on_pin_1' through '$clock_1_pin'."
            create_generated_clock -name $generated_clock_name \
                                   -source $clock_1_pin \
                                   -master_clock $clock_on_pin_1 \
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

    # Call the fast synchronizer constraints procedure on both synchronizers
    puts "Info: Applying fast synchronizer constraints to 'enable_clock_0_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::fast_synchronizer::apply_constraints_to_instance "${instance_path}/enable_clock_0_synchronizer"

    puts "Info: Applying fast synchronizer constraints to 'enable_clock_1_synchronizer' in instance '$instance_path'."
    ::omnicores::buildingblocks::timing::fast_synchronizer::apply_constraints_to_instance "${instance_path}/enable_clock_1_synchronizer"
  }

}
