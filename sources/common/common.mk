DESIGN_EXTENSION        ?= v
TESTBENCH_EXTENSION     ?= sv
TESTBENCH_NAME          ?= $(DESIGN_NAME)_tb
DESIGN_FILES            ?= $(DESIGN_NAME).$(DESIGN_EXTENSION)
VERIFICATION_FILES      ?= $(TESTBENCH_NAME).$(TESTBENCH_EXTENSION)
RTL_SOURCES             ?= $(DESIGN_FILES) $(VERIFICATION_FILES)
RTL_SOURCES             := $(RTL_SOURCES) $(ADDITIONAL_RTL_SOURCES)
RTL_INCLUDES            ?=
RTL_INCLUDES_ICARUS     := $(addprefix -I ,$(RTL_INCLUDES))
RTL_INCLUDES_MODELSIM   := $(addprefix +incdir+,$(RTL_INCLUDES))
RTL_DEFINES             ?=
RTL_DEFINES_ICARUS      := $(addprefix -D ,$(RTL_DEFINES))
RTL_DEFINES_MODELSIM    := $(addprefix +define+,$(RTL_DEFINES))
OPTIMIZED_TOP           ?= $(TESTBENCH_NAME)_opt
WORK_LIBRARY            ?= $(TESTBENCH_NAME).lib
VVP_FILE                ?= $(TESTBENCH_NAME).vvp
DESIGN_FILE             ?= $(TESTBENCH_NAME).design.bin
WLF_FILE                ?= $(TESTBENCH_NAME).wlf
QWAVE_FILE              ?= $(TESTBENCH_NAME).qwave.db
VCD_FILE                ?= $(TESTBENCH_NAME).vcd
LOG_FILE                ?= $(TESTBENCH_NAME).log
GTKW_FILE               ?= $(TESTBENCH_NAME).gtkw
RON_FILE                ?= $(TESTBENCH_NAME).ron
COMPILE_FLAGS           ?=
COMPILE_FLAGS_ICARUS    ?=
COMPILE_FLAGS_ICARUS    += -g2012
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_BREAK
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_RANDOMIZE
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_CONCURRENT_ASSERTION
COMPILE_FLAGS_MODELSIM  ?=
COMPILE_FLAGS_MODELSIM  += +define+SIMUMLATOR_NO_BOOL

preprocess:

compile_icarus: preprocess
	iverilog $(COMPILE_FLAGS_ICARUS) -o $(VVP_FILE) $(RTL_INCLUDES_ICARUS) $(RTL_DEFINES_ICARUS) $(RTL_SOURCES)

compile_modelsim: preprocess
	vlog -work $(WORK_LIBRARY) +acc $(COMPILE_FLAGS_MODELSIM) $(RTL_INCLUDES_MODELSIM) $(RTL_DEFINES_MODELSIM) $(RTL_SOURCES)

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

waves_surfer:
	surfer $(VCD_FILE) -s $(RON_FILE) &

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
