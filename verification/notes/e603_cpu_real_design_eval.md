# E603 CPU Real-Design Evaluation

## Scope

- Original read-only RTL provenance: `/home/MicroE/ai_proj/e603_hbird`
- Converted top: `e603_core_rams`
- Maintained self-contained RTL snapshot and project-owned inputs:
  `examples/e603_cpu/`
- Filelist and model rules: `examples/e603_cpu/sources.f` and
  `examples/e603_cpu/models.json`

The conversion defines `SYNTHESIS`, excludes verification-only assertions, and
does not modify the external RTL. The latest compile-friendly conversion emits
235 modules with zero conversion errors.

## Result

The optimized SystemC build completed and the 64-cycle key-event run matched
the cached VCS reference at the first fetch request:

```text
address = 0x80000000
RTL cycle = 18
SystemC cycle = 18
cycle delta = 0
```

The maintained harness is
`verification/cases/consistency/e603_cpu_consistency.py`. On 2026-07-18 it
also passed as part of the unified eight-design benchmark suite in 14.300 s;
that hot run reused 254 SystemC objects and the cached link result.

The final full build compiled 256 implementation/testbench translation units
in 456.519 s with two jobs. After targeted frontend changes, an incremental
build took 117.658 s and reused 91 objects. An unchanged hot rerun took 0.046 s,
compiled no sources, reused 254 objects, and reused the link result.

Reproduce the SystemC side with bounded resources:

```bash
prlimit --as=1879048192 -- timeout 300s nice -n 15 \
  .venv/bin/python -m prism_v2sc \
  --top e603_core_rams \
  --filelist examples/e603_cpu/sources.f \
  --model-manifest examples/e603_cpu/models.json \
  --compile-friendly --incremental-codegen --no-ir \
  --out /tmp/e603_systemc_optimized
```

## Converter Defects Found

The E603 run exposed and regression-pinned these general conversion defects:

- constant concat/repeat expressions expanded into very large C++ trees;
- folded 64-bit unsigned constants above `INT64_MAX` needed explicit `ULL`
  typing to avoid ambiguous SystemC constructors;
- one-dimensional unpacked-array cells could create duplicate child bridges;
- concat lvalues writing disjoint vector bits needed one shadow-backed parent
  writer;
- procedural `for` indices inside renamed generate scopes were unrolled without
  substituting the per-iteration constant;
- child-output and local sliced writes to one parent needed a shared assembler.

## Boundary

This is approximate cycle consistency at an architectural key event, not full
per-cycle or formal equivalence. The run proves reset release, first fetch
control, address, burst length, and ID behavior for the exercised configuration.
It does not cover instruction execution, all bus traffic, debug, interrupts,
cache/MMU behavior, or every warning emitted by the conversion audit.
