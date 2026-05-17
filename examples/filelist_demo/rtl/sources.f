# Sources for the filelist_demo build.
# Paths and include dirs are resolved relative to this file's directory.

# Include search path: include/ subdir holds the macro header.
+incdir+include

# Preprocessor define: select the register-feeding-mux variant of the top.
-D USE_REG

# Sources organized by role; one module per file, deeper directory layout
# than a flat dump so the converter's RTL-mirroring output is non-trivial.
primitives/sub_mux.v
primitives/sub_register.v
top/top_datapath.v
