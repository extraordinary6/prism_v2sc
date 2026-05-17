# Sources for the multi_file equivalence fixture.
# Exercises +incdir+ with a subdir, -D, and a multi-folder RTL layout
# (include/ + primitives/ + top/). The output mirrors this structure under
# the SystemC build dir, so the equivalence harness exercises real
# directory-mirror behavior end-to-end.

+incdir+include
-D USE_REG

primitives/sub_mux.v
primitives/sub_register.v
top/top_datapath.v
