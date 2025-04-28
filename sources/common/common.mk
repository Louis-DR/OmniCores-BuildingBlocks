DESIGN_EXTENSION        ?= v
TESTBENCH_EXTENSION     ?= sv
RTL_SOURCES             ?= $(DESIGN_NAME).$(DESIGN_EXTENSION) $(DESIGN_NAME)_tb.$(TESTBENCH_EXTENSION)
RTL_SOURCES             := $(RTL_SOURCES) $(ADDITIONAL_RTL_SOURCES)
RTL_INCLUDES_ICARUS     := $(addprefix -I ,$(RTL_INCLUDES))
RTL_INCLUDES_MODELSIM   := $(addprefix +incdir+,$(RTL_INCLUDES))
WORK_LIBRARY            ?= $(DESIGN_NAME)_tb.lib
TOP_TESTBENCH           ?= $(DESIGN_NAME)_tb
OPTIMIZED_TOP           ?= $(TOP_TESTBENCH)_opt
VVP_FILE                ?= $(DESIGN_NAME)_tb.vvp
DESIGN_FILE             ?= $(DESIGN_NAME)_tb.design.bin
WLF_FILE                ?= $(DESIGN_NAME)_tb.wlf
QWAVE_FILE              ?= $(DESIGN_NAME)_tb.qwave.db
VCD_FILE                ?= $(DESIGN_NAME)_tb.vcd
LOG_FILE                ?= $(DESIGN_NAME)_tb.log
GTKW_FILE               ?= $(DESIGN_NAME)_tb.gtkw
COMPILE_FLAGS           ?=
COMPILE_FLAGS_ICARUS    ?=
COMPILE_FLAGS_ICARUS    += -g2012
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_BREAK_SUPPORT
COMPILE_FLAGS_MODELSIM  ?= +define+SIMUMLATOR_NO_BOOL_SUPPORT

compile_icarus:
	iverilog $(COMPILE_FLAGS_ICARUS) -o $(VVP_FILE) $(RTL_INCLUDES_ICARUS) $(RTL_SOURCES)

compile_modelsim:
	vlog -work $(WORK_LIBRARY) +acc $(COMPILE_FLAGS_MODELSIM) $(RTL_INCLUDES_MODELSIM) $(RTL_SOURCES)

compile: compile_icarus

optimize_icarus: compile_icarus

optimize_modelsim: compile_modelsim
	vopt -work $(WORK_LIBRARY) -designfile $(DESIGN_FILE) -o $(OPTIMIZED_TOP) $(TOP_TESTBENCH)

optimize: optimize_icarus

simulate_icarus: optimize_icarus
	vvp -l $(LOG_FILE) $(VVP_FILE)

simulate_modelsim: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -wlf $(WLF_FILE) -l $(LOG_FILE) -c -do "log -r * ; run -all" $(OPTIMIZED_TOP)

simulate_visualizer: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -l $(LOG_FILE) -qwavedb=+signal -qwavedb=+wavefile="$(QWAVE_FILE)" -c -do "run -all" $(OPTIMIZED_TOP)

simulate: simulate_icarus

simulate_gui_icarus:
	echo "Icarus simulator does't have a GUI mode."

simulate_gui_modelsim: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -wlf $(WLF_FILE) -l $(LOG_FILE) -do "log -r * ; run -all" $(OPTIMIZED_TOP)

simulate_gui_visualizer: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -l $(LOG_FILE) -qwavedb=+signal -qwavedb=+wavefile="$(QWAVE_FILE)" -visualizer -do "run -all" $(OPTIMIZED_TOP)

simulate_gui: simulate_gui_visualizer

waves_gtkwave:
	gtkwave $(GTKW_FILE) &

waves_modelsim:
	vsim $(WLF_FILE)

waves_visualizer:
	visualizer -wavefile $(QWAVE_FILE) -designfile $(DESIGN_FILE)

waves: waves_gtkwave

clean:
	rm -rf ./$(WORK_LIBRARY)
	rm -f ./$(VVP_FILE)
	rm -f ./$(DESIGN_FILE)
	rm -f ./$(WLF_FILE)
	rm -f ./$(QWAVE_FILE)
	rm -f ./$(VCD_FILE)
	rm -f ./$(LOG_FILE)
	rm -f ./visualizer.log
	rm -f ./sysinfo.log
