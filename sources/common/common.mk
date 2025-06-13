DESIGN_EXTENSION        ?= v
TESTBENCH_EXTENSION     ?= sv
TESTBENCH_MODULE        ?= $(DESIGN_NAME)__testbench
TESTBENCH_BASENAME      ?= $(DESIGN_NAME).testbench

# Filelist and include list file paths
DESIGN_FILELIST         ?= $(DESIGN_NAME).design.filelist
DESIGN_INCLIST          ?= $(DESIGN_NAME).design.inclist
TESTBENCH_FILELIST      ?= $(DESIGN_NAME).testbench.filelist
TESTBENCH_INCLIST       ?= $(DESIGN_NAME).testbench.inclist

# Read design files from filelist(s)
ifdef DESIGN_FILELISTS
# Multiple design filelists provided - combine them
DESIGN_FILES            := $(foreach filelist,$(DESIGN_FILELISTS),$(shell cat $(filelist)))
else
# Single design filelist or default pattern
ifneq (,$(wildcard $(DESIGN_FILELIST)))
DESIGN_FILES            := $(shell cat $(DESIGN_FILELIST))
else
DESIGN_FILES            ?= $(DESIGN_NAME).$(DESIGN_EXTENSION)
endif
endif

# Read testbench files from filelist if it exists, otherwise use default pattern
ifneq (,$(wildcard $(TESTBENCH_FILELIST)))
TESTBENCH_FILES         := $(shell cat $(TESTBENCH_FILELIST))
else
TESTBENCH_FILES         ?= $(TESTBENCH_BASENAME).$(TESTBENCH_EXTENSION)
endif

# Combine design and testbench files for verification
VERIFICATION_FILES      := $(DESIGN_FILES) $(TESTBENCH_FILES)

# Read design include directories from inclist(s)
DESIGN_INCLUDES         ?=
ifdef DESIGN_INCLISTS
# Multiple design inclists provided - combine them
DESIGN_INCLUDES         += $(foreach inclist,$(DESIGN_INCLISTS),$(shell cat $(inclist)))
else
# Single design inclist
ifneq (,$(wildcard $(DESIGN_INCLIST)))
DESIGN_INCLUDES         += $(shell cat $(DESIGN_INCLIST))
endif
endif

# Read testbench include directories from inclist if it exists
TESTBENCH_INCLUDES      ?=
ifneq (,$(wildcard $(TESTBENCH_INCLIST)))
TESTBENCH_INCLUDES      += $(shell cat $(TESTBENCH_INCLIST))
endif

# Combine design and testbench include directories for verification, and remove duplicates
VERIFICATION_INCLUDES   := $(DESIGN_INCLUDES) $(TESTBENCH_INCLUDES)
VERIFICATION_INCLUDES   := $(sort $(VERIFICATION_INCLUDES))

# Include directories for each tool
INCLUDES_VERILATOR      := $(addprefix +incdir+,$(VERIFICATION_INCLUDES))
INCLUDES_ICARUS         := $(addprefix -I ,$(VERIFICATION_INCLUDES))
INCLUDES_MODELSIM       := $(addprefix +incdir+,$(VERIFICATION_INCLUDES))

# Macro definitions for each tool
DEFINES                 ?=
DEFINES_VERILATOR       := $(addprefix +define+,$(DEFINES))
DEFINES_ICARUS          := $(addprefix -D ,$(DEFINES))
DEFINES_MODELSIM        := $(addprefix +define+,$(DEFINES))

# Output files for each tool
OBJ_DIRECTORY           ?= obj_dir/
EXE_FILE                ?= $(OBJ_DIRECTORY)/V$(DESIGN_NAME)
OPTIMIZED_TOP           ?= $(TESTBENCH_MODULE)_opt
WORK_LIBRARY            ?= $(TESTBENCH_BASENAME).lib
VVP_FILE                ?= $(TESTBENCH_BASENAME).vvp
DESIGN_FILE             ?= $(TESTBENCH_BASENAME).design.bin
WLF_FILE                ?= $(TESTBENCH_BASENAME).wlf
QWAVE_FILE              ?= $(TESTBENCH_BASENAME).qwave.db
VCD_FILE                ?= $(TESTBENCH_BASENAME).vcd
LOG_FILE                ?= $(TESTBENCH_BASENAME).log
GTKW_FILE               ?= $(TESTBENCH_BASENAME).gtkw
RON_FILE                ?= $(TESTBENCH_BASENAME).ron

# Compilation flags for each tool
COMPILE_FLAGS           ?=
COMPILE_FLAGS_VERILATOR ?=
COMPILE_FLAGS_VERILATOR += --trace
COMPILE_FLAGS_VERILATOR += --timescale 1ns/1ns
COMPILE_FLAGS_VERILATOR += -Wno-fatal
COMPILE_FLAGS_VERILATOR += +define+SIMUMLATOR_NO_BOOL
COMPILE_FLAGS_ICARUS    ?=
COMPILE_FLAGS_ICARUS    += -g2012
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_BREAK
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_RANDOMIZE
COMPILE_FLAGS_ICARUS    += -D SIMUMLATOR_NO_CONCURRENT_ASSERTION
COMPILE_FLAGS_MODELSIM  ?=
COMPILE_FLAGS_MODELSIM  += +define+SIMUMLATOR_NO_BOOL

# Preprocessing operations
preprocess:

# Compilation of the testbench
compile_verilator: preprocess
	verilator $(COMPILE_FLAGS_VERILATOR) --binary $(INCLUDES_VERILATOR) $(DEFINES_VERILATOR) $(VERIFICATION_FILES)

compile_icarus: preprocess
	iverilog $(COMPILE_FLAGS_ICARUS) -o $(VVP_FILE) $(INCLUDES_ICARUS) $(DEFINES_ICARUS) $(VERIFICATION_FILES)

compile_modelsim: preprocess
	vlog -work $(WORK_LIBRARY) +acc $(COMPILE_FLAGS_MODELSIM) $(INCLUDES_MODELSIM) $(DEFINES_MODELSIM) $(VERIFICATION_FILES)

compile: compile_icarus

# Optimization of the testbench
optimize_verilator: compile_verilator

optimize_icarus: compile_icarus

optimize_modelsim: compile_modelsim
	vopt -work $(WORK_LIBRARY) -designfile $(DESIGN_FILE) -o $(OPTIMIZED_TOP) $(TOP_TESTBENCH)

optimize: optimize_icarus

# Simulation of the testbench
simulate_verilator: optimize_verilator
	$(EXE_FILE) | tee $(LOG_FILE)

simulate_icarus: optimize_icarus
	vvp -l $(LOG_FILE) $(VVP_FILE)

simulate_modelsim: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -wlf $(WLF_FILE) -l $(LOG_FILE) -c -do "log -r * ; run -all" $(OPTIMIZED_TOP)

simulate_visualizer: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -l $(LOG_FILE) -qwavedb=+signal -qwavedb=+wavefile="$(QWAVE_FILE)" -c -do "run -all" $(OPTIMIZED_TOP)

simulate: simulate_icarus

# Simulation of the testbench with GUI
simulate_gui_icarus:
	echo "Icarus simulator does't have a GUI mode."

simulate_gui_modelsim: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -wlf $(WLF_FILE) -l $(LOG_FILE) -do "log -r * ; run -all" $(OPTIMIZED_TOP)

simulate_gui_visualizer: optimize_modelsim
	vsim -work $(WORK_LIBRARY) -l $(LOG_FILE) -qwavedb=+signal -qwavedb=+wavefile="$(QWAVE_FILE)" -visualizer -do "run -all" $(OPTIMIZED_TOP)

simulate_gui: simulate_gui_visualizer

# Visualization of the testbench waveforms
waves_gtkwave:
	gtkwave $(GTKW_FILE) &

waves_surfer:
	surfer $(VCD_FILE) -s $(RON_FILE) &

waves_modelsim:
	vsim $(WLF_FILE)

waves_visualizer:
	visualizer -wavefile $(QWAVE_FILE) -designfile $(DESIGN_FILE)

waves: waves_gtkwave

# Clean-up the generated files
clean:
	rm -rf ./$(OBJ_DIRECTORY)
	rm -rf ./$(WORK_LIBRARY)
	rm -f ./$(VVP_FILE)
	rm -f ./$(DESIGN_FILE)
	rm -f ./$(WLF_FILE)
	rm -f ./$(QWAVE_FILE)
	rm -f ./$(VCD_FILE)
	rm -f ./$(LOG_FILE)
	rm -f ./visualizer.log
	rm -f ./sysinfo.log
