# Sources for the filelist_demo build.
# Paths and include dirs are resolved relative to this file's directory.

# Include search path for `include "defs.vh"`.
+incdir+.

# Preprocessor define: select the register-feeding-mux variant of the top.
-D USE_REG

# Sources listed once each; deduplicated by the harness.
sub_mux.v
sub_register.v
top_datapath.v
