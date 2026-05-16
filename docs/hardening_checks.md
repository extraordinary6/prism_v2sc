# Hardening Checks

Use these commands to reproduce the current post-Phase 8 checks.

## Unit and Regression Suite

```powershell
D:\anaconda\envs\pytorch\python.exe -m pytest -q --basetemp=build\pytest_tmp_pytorch_hardening
```

## Metrics Smoke

```powershell
$env:PYTHONPATH='src'
D:\anaconda\envs\pytorch\python.exe -m prism_v2sc --top pipeline_top --metrics --compare-verilator --out build/phase5_smoke tests/rtl/phase5_pipeline.v
```

Expected `metrics.json` fields include:

- `source_index`
- `traversal`
- `source_parse_count`
- `module_lower_count`
- `verilator_lint.stdout_truncated`
- `verilator_lint.stderr_truncated`

On the current Windows/MSYS2 setup, Verilator discovery resolves the Perl wrapper to:

```text
D:\MinGW\mingw\mingw64\share\verilator\bin\verilator_bin.exe
```

## Static Generated-Code Checks

`prism_v2sc.verify.static_checks.check_generated_systemc()` flags obvious generated-code fallback markers:

- `TODO:` text in generated output
- `// Unsupported statement:` comments
- missing `<systemc>` include
- missing `SC_MODULE`

## Diagnostic Policy

Warnings identify approximations that still emit SystemC. Error diagnostics identify unsupported constructs or unsafe lowering cases. Use `--fail-on-diagnostics` in CI when unsupported constructs should fail conversion.
