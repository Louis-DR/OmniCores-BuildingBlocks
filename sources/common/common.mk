RTL_SOURCES   ?= $(DESIGN_NAME).v $(DESIGN_NAME)_tb.sv
VVP_FILE      ?= $(DESIGN_NAME)_tb.vvp
VCD_FILE      ?= $(DESIGN_NAME)_tb.vcd
GTKW_FILE     ?= $(DESIGN_NAME)_tb.gtkw
COMPILE_FLAGS ?=

compile:
	iverilog $(COMPILE_FLAGS) -o $(VVP_FILE) $(RTL_SOURCES)

simulate:
	vvp $(VVP_FILE)

waves:
	gtkwave $(GTKW_FILE) &

clean:
	rm -f ./$(VVP_FILE)
	rm -f ./$(VCD_FILE)
