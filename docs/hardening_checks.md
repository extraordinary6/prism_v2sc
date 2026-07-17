# Hardening Checks

Reproducible local checks you can run while developing. The default pytest suite is the fast local guardrail; Linux hosts with SystemC available may also exercise the power instrumentation smoke tests. Full RTL/SystemC trace equivalence still lives in `tests/equivalence/README.md`.

## Unit Suite

```powershell
D:\anaconda\envs\pytorch\python.exe -m pytest -q
```

Covers IR lowering, codegen text, multi-file output layout, CLI behavior, expression coverage, diagnostics policy, model providers, staged projects, static power analysis, instrumentation, reporting, and real SystemC smoke paths when available. The current baseline collects 218 tests.

For a hermetic temporary build directory:

```powershell
D:\anaconda\envs\pytorch\python.exe -m pytest -q --basetemp=build\pytest_tmp_hardening
```

## Metrics Smoke

Exercises the full conversion pipeline on a representative pipeline RTL, including the Verilator comparison hook on Windows/MSYS2:

```powershell
$env:PYTHONPATH = 'src'
D:\anaconda\envs\pytorch\python.exe -m prism_v2sc `
  --top pipeline_top `
  --metrics --compare-verilator `
  --out build\phase5_smoke `
  tests\rtl\phase5_pipeline.v
```

Expected fields in the resulting `metrics.json`:

- `source_index` — elapsed time for slang's parse + elaborate step
- `traversal` — elapsed time for the top-driven instance-tree walk
- `source_parse_count` — number of input source files fed to slang
- `module_lower_count` — number of modules lowered after repeated-instantiation dedup
- `verilator_lint.stdout_truncated` / `stderr_truncated` — truncation flags when Verilator's output exceeded the configured cap

On the maintainer's Windows/MSYS2 setup Verilator discovery resolves to:

```
D:\MinGW\mingw\mingw64\share\verilator\bin\verilator_bin.exe
```

If your environment reports `verilator_lint.available = false`, confirm `verilator --version` works from the same shell that ran Python.

## Static Generated-Code Checks

`prism_v2sc.verify.static_checks.check_generated_systemc()` flags obvious miscompile markers in any generated header:

- `TODO:` text in the emitted output
- `// Unsupported statement:` comments
- missing `<systemc>` include
- missing `SC_MODULE`

Useful when you're triaging a regression and want a quick "is the output even structurally valid" answer.

## Diagnostic Policy Check

Run the CLI with `--fail-on-diagnostics` to assert no error-level diagnostics surface:

```powershell
D:\anaconda\envs\pytorch\python.exe -m prism_v2sc `
  --top <top> --fail-on-diagnostics `
  --out build\diag_check <sources...>
```

Warnings (e.g. `event_scheduler_approximated`) are informational and do not fail the run; errors (e.g. unsupported construct, `slang_UnknownModule`) cause exit code 2.
