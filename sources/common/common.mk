RTL_SOURCES   ?= $(DESIGN_NAME).v $(DESIGN_NAME)_tb.sv
RTL_SOURCES   := $(RTL_SOURCES) $(ADDITIONAL_RTL_SOURCES)
RTL_INCLUDES  := $(addprefix -I ,$(RTL_INCLUDES))
VVP_FILE      ?= $(DESIGN_NAME)_tb.vvp
VCD_FILE      ?= $(DESIGN_NAME)_tb.vcd
GTKW_FILE     ?= $(DESIGN_NAME)_tb.gtkw
COMPILE_FLAGS ?=

compile:
	iverilog $(COMPILE_FLAGS) -o $(VVP_FILE) $(RTL_INCLUDES) $(RTL_SOURCES)

simulate:
	vvp $(VVP_FILE)

waves:
	gtkwave $(GTKW_FILE) &

clean:
	rm -f ./$(VVP_FILE)
	rm -f ./$(VCD_FILE)
