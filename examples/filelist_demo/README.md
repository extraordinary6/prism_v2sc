# `filelist_demo` &mdash; multi-file build via a `.f` filelist

A walk-through showing how prism_v2sc consumes a Verilog **filelist**
(`.f`) instead of positional source arguments. The same `.f` carries the
include-search path and the preprocessor define, so an `\`include` header
and an `\`ifdef`-gated top body both resolve consistently across the
converter and any downstream Verilog simulator.

The design is intentionally small but covers everything you typically want
out of a real `.f`:

| filelist construct          | where it shows up                                          |
| --------------------------- | ---------------------------------------------------------- |
| `+incdir+<dir>`             | resolves `\`include "defs.vh"` inside each `.v`            |
| `-D <macro>`                | picks the `\`ifdef USE_REG` branch in `top_datapath.v`     |
| multi-file source list      | three `.v` files + a header, all listed in `sources.f`     |
| paths relative to the `.f`  | every entry is resolved against `rtl/`, not the `cwd`      |
| comment lines (`#` or `//`) | the file is human-readable                                 |

## Layout

```
examples/filelist_demo/
├── rtl/
│   ├── defs.vh             # `define WIDTH 8
│   ├── sub_mux.v           # vector-width 2:1 mux
│   ├── sub_register.v      # write-enable register, async reset
│   ├── top_datapath.v      # mux feeding the register when USE_REG defined
│   └── sources.f           # the filelist itself
├── expected/
│   ├── ir.json             # Phase 1 JSON IR
│   └── prism_v2sc.hpp      # Generated SystemC header
└── README.md               # This file
```

## The filelist

```
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
```

(Full source: [`rtl/sources.f`](rtl/sources.f).)

Supported line forms (also documented in the top README):

- `path/to/file.v` &mdash; one source per line.
- `-I <dir>`, `-I<dir>`, `+incdir+<dir>` &mdash; include search path.
- `-D <macro>`, `-D<macro=value>`, `-D<macro>` &mdash; preprocessor defines.
- `-f <other.f>` &mdash; nested filelist (cycle-detected).
- Blank lines and lines starting with `#` or `//` are ignored.

## One-line reproduction

From the repository root:

```bash
python -m prism_v2sc --top top_datapath \
                    --out examples/filelist_demo/expected \
                    --filelist examples/filelist_demo/rtl/sources.f
```

On Windows / conda with the project source on `PYTHONPATH`:

```powershell
PYTHONPATH=src D:/anaconda/envs/pytorch/python.exe -m prism_v2sc `
  --top top_datapath `
  --out examples/filelist_demo/expected `
  --filelist examples/filelist_demo/rtl/sources.f
```

Two files are written (regenerating them byte-identically each run):

- `expected/ir.json` &mdash; Phase 1 JSON IR (all three modules merged).
- `expected/prism_v2sc.hpp` &mdash; single-header SystemC model with
  `sub_mux`, `sub_register`, and `top_datapath` in dependency order.

You can also combine `--filelist` with positional source arguments &mdash;
prism-v2sc merges them and deduplicates the resulting set. Multiple
`--filelist` flags are accepted and parsed in order.

## Generated SystemC (highlights)

The full output is committed at [`expected/prism_v2sc.hpp`](expected/prism_v2sc.hpp).
Three SystemC modules are emitted from the three Verilog modules:

```cpp
SC_MODULE(sub_mux) {
  sc_in<bool> sel;
  sc_in<sc_uint<(((8 - 1)) - (0) + 1)>> a;
  sc_in<sc_uint<(((8 - 1)) - (0) + 1)>> b;
  sc_out<sc_uint<(((8 - 1)) - (0) + 1)>> y;

  void assign_0() {
    y.write((sel.read() ? b.read() : a.read()));
  }
  // ...
};

SC_MODULE(sub_register) {
  sc_in<bool> clk;
  sc_in<bool> rst_n;
  sc_in<bool> en;
  sc_in<sc_uint<(((8 - 1)) - (0) + 1)>> data_in;
  sc_out<sc_uint<(((8 - 1)) - (0) + 1)>> data_out;

  void always_ff_0() {
    auto __next_data_out = data_out.read();
    if ((!rst_n.read())) {
      __next_data_out = 0x00;
    } else if (en.read()) {
      __next_data_out = data_in.read();
    }
    data_out.write(__next_data_out);
  }
  // ...
};

SC_MODULE(top_datapath) {
  // ...
  sc_signal<sc_uint<(((8 - 1)) - (0) + 1)>> mux_out;
  sub_mux       u_mux;
  sub_register  u_reg;

  SC_CTOR(top_datapath)
    : u_mux("u_mux"), u_reg("u_reg")
  {
    u_mux.sel(sel); u_mux.a(a); u_mux.b(b); u_mux.y(mux_out);
    u_reg.clk(clk); u_reg.rst_n(rst_n); u_reg.en(en);
    u_reg.data_in(mux_out); u_reg.data_out(y);
  }
};
```

Things to notice:

- The `\`include "defs.vh"` got resolved via `+incdir+.`, so `\`WIDTH`
  shows up as `8` in the generated port widths.
- The `\`ifdef USE_REG` branch was selected, so `top_datapath` instantiates
  both `sub_mux` and `sub_register` and threads an internal `mux_out`
  wire between them. Drop `-D USE_REG` from the `.f` and the generated
  top would instead route the mux output straight to `y`.
- All three modules are emitted in dependency order in a single header
  (`sub_mux`, `sub_register`, then `top_datapath`).

## Verifying functional equivalence

The same multi-file design is registered as the `multi_file` fixture in
`tests/equivalence/run_equivalence.py` (sourced from
`tests/equivalence/fixtures/multi_file/` &mdash; effectively a mirror of
the files here). On Linux with `iverilog` + `libsystemc-dev`, or simply by
pushing &mdash; the `equivalence` GitHub Actions workflow runs it on
every push:

```bash
python tests/equivalence/run_equivalence.py --fixtures multi_file
```

The harness reuses `prism_v2sc.frontend.preprocess.collect_sources` to
parse the filelist exactly once, then feeds the same `-I` / `-D` set to
**both** the prism-v2sc CLI and `iverilog`, so the converter and the
golden Verilog simulator see identical preprocessing. Stimulus is
deterministic and the per-cycle output traces are diffed line-by-line.
