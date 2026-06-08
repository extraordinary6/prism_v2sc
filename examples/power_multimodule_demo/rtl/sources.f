# Multi-module power diagnostics demo.
# Paths are resolved relative to this file. Include dirs are passed to slang.

+incdir+include

control/control_sequencer.v
datapath/reg_bank.v
datapath/vector_alu.v
datapath/wide_crossbar.v
datapath/wide_accumulator.v
top/power_soc_top.v

