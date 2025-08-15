# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ Project:     OmniCores-BuildingBlocks                                     ║
# ║ Author:      Louis Duret-Robert - louisduret@gmail.com                    ║
# ║ Website:     louis-dr.github.io                                           ║
# ║ License:     MIT License                                                  ║
# ║ File:        clock_divider.sdc                                            ║
# ╟───────────────────────────────────────────────────────────────────────────╢
# ║ Description: SDC constraints for the clock divider module.                ║
# ║                                                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝



# Source common helper functions
source [file join [file dirname [info script]] "../../common/common.sdc"]



namespace eval ::omnicores::buildingblocks::timing::clock_divider {

  # Apply timing constraints to a specific instance of the clock divider module
  proc apply_constraints_to_instance { instance_path {division_factor ""} } {
    # Use common helper functions
    namespace import ::omnicores::common::get_registers
    namespace import ::omnicores::common::get_at_index
    namespace import ::omnicores::common::get_width
    namespace import ::omnicores::parameters::get_parameter

    # Check if the instance exists
    if { [get_cells -quiet $instance_path] eq "" } {
      puts "Warning: Instance '$instance_path' not found. Skipping constraints."
      return
    }

    # Get the instance name
    set instance_name [file tail $instance_path]

    # Get the division factor (use manual value if provided, otherwise read from parameter)
    if { $division_factor eq "" } {
      set division_factor [get_parameter $instance_path "DIVISION"]

      # Safety check: handle empty parameter value
      if { $division_factor eq "" } {
        puts "Warning: Could not read DIVISION parameter for instance '$instance_path'. Skipping constraints."
        return
      }
    }

    # Safety check: ensure division factor is valid (>= 1)
    if { ![string is integer $division_factor] || $division_factor < 1 } {
      puts "Warning: Invalid division factor '$division_factor' for instance '$instance_path'. Skipping constraints."
      return
    }

    # Get the output clock pin
    set clock_out_pin [get_pins -quiet "${instance_path}/clock_out"]

    if { $clock_out_pin eq "" } {
      puts "Warning: Output pin '${instance_path}/clock_out' not found for instance '$instance_path'. Skipping constraints."
      return
    }

    # Get the input clock pin
    set clock_in_pin [get_pins -quiet "${instance_path}/clock_in"]

    if { $clock_in_pin eq "" } {
      puts "Warning: Input clock pin '${instance_path}/clock_in' not found for instance '$instance_path'. Skipping constraints."
      return
    }

    set generated_clocks_on_output [list]

    # Process clocks from clock_in_pin
    if { $clock_in_pin ne "" } {
      set clocks_on_input [get_clocks -quiet -of_objects $clock_in_pin]
      if { [llength $clocks_on_input] == 0 } {
        puts "Warning: No clocks found on '$clock_in_pin' for instance '$instance_path'. Skipping constraints."
        return
      } else {
        foreach clock_on_input $clocks_on_input {
          # Sanitize clock_on_input for use in a generated clock name if necessary
          set generated_clock_name "${clock_on_input}_through_${instance_name}_input"

          if { [llength [get_clocks -quiet $generated_clock_name]] == 0 } {
            puts "Info: Creating generated clock '$generated_clock_name' on '$clock_out_pin' of clock '$clock_on_input' through '$clock_in_pin'."

            # For odd division factors, use -edges to handle asymmetric duty cycle
            if { $division_factor > 1 && $division_factor % 2 == 1 } {
              # The high pulse is one cycle longer than the low pulse
              set falling_edge [expr ($division_factor + 1) / 2]
              set next_rising_edge $division_factor
              set edge_list [list 0 $falling_edge $next_rising_edge]
              create_generated_clock -name $generated_clock_name \
                                     -source $clock_in_pin \
                                     -master_clock $clock_on_input \
                                     -edges $edge_list -add $clock_out_pin
            } else {
              # For even division factors or division factor of 1, use -divide_by (50% duty cycle)
              create_generated_clock -name $generated_clock_name \
                                     -source $clock_in_pin \
                                     -master_clock $clock_on_input \
                                     -divide_by $division_factor -add $clock_out_pin
            }

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

  }

}
