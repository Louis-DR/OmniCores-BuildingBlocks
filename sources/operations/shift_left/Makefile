DESIGN_NAME = shift_left

VERIFICATION_FILES  = $(DESIGN_NAME).tc.sv
VERIFICATION_FILES += $(DESIGN_NAME).tb.sv

TESTBENCH_NAME = $(DESIGN_NAME).tb

include ../../common/common.mk

preprocess:
	j2gpp shift_left.tb.sv.j2
