# External Model Providers

Large RTL projects often include simulation-only memories, vendor primitives,
testbenches, assertions, and timing models. These files must not be handled by
one-off conversion scripts. `prism_v2sc` provides a versioned model manifest,
source audit, and provider registry so those decisions are reproducible.

## CLI

```bash
.venv/bin/python -m prism_v2sc \
  --top cpu_top \
  --filelist synthesis.f \
  --model-manifest models.json \
  --fail-on-diagnostics \
  --out build/cpu_systemc
```

This writes the normal `ir.json` and per-module headers plus
`model_report.json`. To classify sources without replacement rules, use
`--model-audit`.

## Manifest

JSON and TOML are supported. Version 1 has two explicit rule groups:

```json
{
  "version": 1,
  "strict": true,
  "source_rules": [
    {
      "glob": "*/tb/*",
      "action": "ignore",
      "reason": "testbench sources are not part of the synthesizable view"
    }
  ],
  "module_rules": [
    {
      "module": "foundry_sram_1rw",
      "provider": "memory",
      "reason": "replace the vendor simulation model",
      "config": {
        "clock": "clk",
        "enable": "cen",
        "write_enable": "wen",
        "address": "addr",
        "write_data": "din",
        "read_data": "dout",
        "depth": 1024,
        "read_latency": 1,
        "write_mode": "read_first"
      }
    }
  ]
}
```

Automatic classification is audit-only. A path that looks like a testbench or
memory model remains included unless an explicit source or module rule applies.
This prevents filename heuristics from silently removing functional RTL.

## Built-in Providers

### `memory`

The initial provider supports a synchronous single-port memory contract:

- one clock;
- one enable and write enable;
- one address and write-data input;
- one read-data output;
- one-cycle synchronous read;
- `read_first`, `write_first`, or `no_change` same-address write behavior.
- either a positive integer depth, or a module-parameter name when using the
  masked registered-address contract;
- an optional masked-write mode with configurable lane width and a registered
  read address, matching the E203 `sirv_sim_ram` contract.

The provider replaces the original module body with canonical `ModuleIR`. The
normal SystemC backend then emits the storage array and clocked process. Missing
ports, invalid depth, unsupported latency, or unknown write mode are errors.

Masked writes use these additional keys:

```json
{
  "byte_enable": "wem",
  "lane_width": 8,
  "read_address_register": true,
  "write_mode": "no_change",
  "depth": "DP"
}
```

The current masked contract requires `read_address_register=true`,
`read_latency=1`, and `write_mode=no_change`. It is differential-tested through
the E203 ITCM/DTCM execution gate. Independent read/write ports, true dual-port
collision policies, initialization files, and longer output pipelines remain
unsupported and require separate provider contracts.

### `blackbox`

The blackbox provider preserves module parameters and ports but removes the
body. Under the default `strict: true`, it produces an error unless the rule has
`"config": {"allow": true}`. Even when allowed, it emits a warning because
functional outputs are not modeled.

Blackbox is suitable only for components whose behavior is supplied externally
or is irrelevant to the selected workload. It is not a valid replacement for a
functional memory or arithmetic macro.

## Provider Extension

Python integrations can construct a `ModelProviderRegistry`, register objects
implementing `apply(module, rule, strict=...)`, and pass the registry to
`convert_with_metrics`. Providers return canonical replacement `ModuleIR`, so
they automatically reuse normal code generation, diagnostics, metrics, and IR
serialization.

## Precision Policy

The framework does not claim exact conversion for arbitrary simulation models.
Exactness is defined per provider contract and must be backed by RTL/SystemC
differential tests. Unsupported functional models fail loudly; verification-only
sources can be explicitly ignored; permitted approximations remain visible in
`model_report.json` and diagnostics.
