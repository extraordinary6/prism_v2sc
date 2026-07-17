# E203 CPU Real-Design Evaluation

## Scope

- External RTL: `/home/MicroE/e203/e203_hbirdv2-master/rtl/e203`
- Converted top: `e203_cpu_top`
- Project-owned input view: `verification/cases/e203/e203_core.f`
- External-model rules: `verification/cases/e203/e203_models.json`
- Consistency gate: `verification/cases/consistency/e203_cpu_consistency.py`
- External RTL remains read-only. Assertions and other verification-only code
  are excluded from the functional reference simulation.

The filelist contains 51 design sources and defines `SYNTHESIS`. Conversion
produces 94 reachable or parameter-specialized modules, 278 instances, 42
procedural processes, and 2731 continuous assignments. The generated
`e203_cpu_top.hpp` dependency tree compiles as C++14 against SystemC 2.3.4.

Conversion has zero error diagnostics. Seven warnings remain: five
`event_scheduler_approximated` warnings on specialized ICB arbiter/splitter
modules and two `model_memory_applied` warnings for ITCM/DTCM simulation RAMs.

## Memory Model

The E203 `sirv_sim_ram` simulation model is replaced through the normal model
manifest, not by test-script source rewriting. The provider contract uses:

- parameterized depth (`DP`);
- one-cycle synchronous behavior;
- registered read address;
- byte write enable with 8-bit lanes;
- `no_change` behavior on writes.

The same provider storage is preloaded by the SystemC testbench, while the VCS
testbench preloads the untouched RTL model hierarchically. DTCM byte/halfword
updates are checked through architectural load results and final memory words.

## Execution Scenarios

The harness compiles RTL and SystemC once, then runs six deterministic programs
from reset PC `0x80000000`:

| Scenario | Covered behavior | Checked DTCM result |
| --- | --- | --- |
| `baseline` | `addi`, `add`, `lui`, `sw`, `lw`, taken `beq`, terminal `jal` | word 0 = `0x0000000c` |
| `alu_branch` | SRA/SRL, signed/unsigned SLT, XOR/OR, taken and not-taken branches | word 1 = `0xe0000003` |
| `muldiv_bytes` | MUL/DIV/REM, SW/SB/SH, LW/LBU/LHU, write masks and load extension | word 2 = `0x00645dbc`, word 3 = `0x000000c1` |
| `signed_divzero` | signed DIV/REM and RISC-V divide-by-zero special results | words 4-7 = `fffffffa`, `fffffffe`, `ffffffff`, `ffffffec` |
| `csr` | `csrrw`/`csrrs` using `mscratch` | word 8 = `0x0000005a` |
| `timer_irq` | `mtvec`, `mie`, `mstatus`, synchronized timer IRQ and trap-handler entry at `0x80000080` | word 9 = `0x00000066` |

All six scenarios pass. RTL produced 81 sampled PC changes and SystemC produced
82; the only count difference is one extra wait-loop iteration before timer
trap entry. Ordered first occurrence of common PC events matches, all required
entry/terminal or handler PCs are present, and all 10 checked DTCM words match.
This is key-event and architectural-result consistency, not strict per-cycle or
formal equivalence.

## Optimized SystemC Build

The E203 harness supports the compile-oriented generator and cached builder:

```bash
.venv/bin/python verification/cases/consistency/e203_cpu_consistency.py \
  --sc-build-mode optimized --sc-build-jobs 1

.venv/bin/python verification/cases/consistency/e203_cpu_consistency.py \
  --keep-out --skip-rtl --sc-build-mode optimized --sc-build-jobs 1
```

On the local machine, the optimized cold SystemC build compiled 40 translation
units in 83.346 s with one bounded build job. The unchanged hot rerun took
0.007 s, reused all 40 objects and the link result, and reran all six SystemC
scenarios successfully. `--skip-rtl` reuses the cached VCS scenario logs; it
does not weaken the architectural comparisons.

The RTL reference build defines `DISABLE_SV_ASSERTION`. E203's simulation-only
signed-division golden assertion computes `-20 / 3` incorrectly and calls
`$fatal` even though the actual datapath returns the correct RISC-V result.
Disabling it removes verification-only behavior without modifying functional
RTL.

## Converter Defects Found

This design exposed and now regression-pins several general defects:

- internal modules could not reliably be selected as slang roots;
- one module instantiated with multiple parameter sets needed stable
  specialization names and correct formal-order template arguments;
- scalar versus explicit `[0:0]` ports needed typed bridges;
- array-element, output part-select, and width-mismatched child bindings needed
  bindable proxy signals;
- disjoint child output slices targeting one parent needed one SystemC writer;
- net declaration assignments (`wire n = expr`) were silently dropped;
- parenthesized sized literals such as `(4'b1111)` were parsed as zero;
- known-width bitwise complement was vulnerable to C++ integral promotion;
- transient zero denominators in delta-cycle combinational settling could raise
  host `SIGFPE`;
- localparam-derived widths, leading-zero decimal constants, integer
  part-selects, and generated instance names needed C++-safe emission.

Focused unit tests and the `net_decl_assign` VCS equivalence fixture cover the
generic forms. The E203 programs cover their interaction in a large hierarchy.

## Remaining Boundary

This gate does not prove exact event scheduling, every CSR/exception type,
debug mode, NICE custom instructions, all external ICB targets, PMP behavior,
or formal state equivalence. The five ICB scheduler warnings remain visible,
and the timer case demonstrates the accepted near-cycle timing policy. New CPU
coverage should add architectural result checks rather than weaken diagnostics
or compare every internal delta cycle.

Reproduce with:

```bash
.venv/bin/python verification/cases/consistency/e203_cpu_consistency.py
```

Run artifacts are written under `/tmp/prism_e203_cpu_consistency`.
