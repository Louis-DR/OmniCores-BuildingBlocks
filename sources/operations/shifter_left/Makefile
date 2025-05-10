DESIGN_NAME = shifter_left

VERIFICATION_FILES  = $(DESIGN_NAME).tc.sv
VERIFICATION_FILES += $(DESIGN_NAME).tb.sv

TESTBENCH_NAME = $(DESIGN_NAME).tb

include ../../common/common.mk

preprocess:
	j2gpp shifter_left.tb.sv.j2
