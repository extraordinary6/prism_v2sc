```text
 ____  ____  ___ ____  __  __     __     ______ ____   ____ 
|  _ \|  _ \|_ _/ ___||  \/  |    \ \   / /___ \ ___| / ___|
| |_) | |_) || |\___ \| |\/| |     \ \ / /  __) \___ \| |    
|  __/|  _ < | | ___) | |  | |      \ V /  / __/ ___) | |___ 
|_|   |_| \_\___|____/|_|  |_|       \_/  |_____|____/ \____|
```

<p align="center">
  <a href="README.md">English</a> |
  <a href="README_zh.md">中文</a>
</p>

<p align="center">
  <img alt="Python 3.10+" src="https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white">
  <img alt="pyslang 11.x" src="https://img.shields.io/badge/pyslang-11.x-4B5563">
  <img alt="SystemC CI verified" src="https://img.shields.io/badge/SystemC-CI%20verified-16A34A">
  <img alt="154 tests" src="https://img.shields.io/badge/tests-154%20collected-0EA5E9">
  <img alt="Power diagnostics" src="https://img.shields.io/badge/power-diagnostics-F59E0B">
</p>

# prism_v2sc

`prism_v2sc` 将可综合 Verilog / SystemVerilog RTL 子集转换成层级化的近似 SystemC 模型。输出为每个模块一个 `.hpp`，并镜像原始源码目录布局。

它使用 [slang](https://sv-lang.com/) 以及 [pyslang](https://pypi.org/project/pyslang/) Python 绑定进行解析和 elaboration。slang 会在 lowerer 看到设计之前解析参数覆盖、折叠 `generate if`、展开 `generate for`，并把端口位宽具体化为整数。

这个工具有意定位为**实用 RTL 子集转换器**，不是完整 SystemVerilog 语义等价器。不支持的构造会以 diagnostics 暴露，而不是静默误编译。

## 安装

```powershell
python -m pip install -e .
```

要求：Python 3.10+；`pyslang>=11.0,<12.0`（作为依赖自动安装，在 Windows 和 Linux 上提供预编译 wheel）。

## CLI

```powershell
python -m prism_v2sc --top <module> [options] [<sources...>]
```

| flag | 用途 |
| --- | --- |
| `--top <name>` | 顶层模块名（必需） |
| `--filelist <path>` | `.f` 风格 filelist（可重复指定） |
| `--out <dir>` | 输出目录（默认 `build/systemc`） |
| `--dump-ir` | 将 JSON IR 打印到 stdout，而不是写入 `ir.json` |
| `--metrics` | 额外写出 `metrics.json`（时间、内存、遍历计数） |
| `--compare-verilator` | 同步运行 `verilator --lint-only` 并记录耗时 |
| `--fail-on-diagnostics` | 存在 error-level diagnostics 时以非零状态退出 |
| `--power-static` | 运行 IR-only 功耗嫌疑分析并写出 `power_static.json` |
| `--power-instrument <manifest>` | 生成插桩 SystemC 并写出 probe manifest |
| `--power-report <profile.json>` | 对已采集 profile 打分并写出 `power_report.json` |

`.f` filelist 支持每行一个文件，也支持 `-I` / `+incdir+` include 目录、`-D` 宏定义、`-f` 嵌套 filelist，以及 `#` / `//` 注释。

Power 相关选项还包括 `--power-report-static <json>`、`--power-all-signals`、`--power-probe-ports`、`--power-memory-cells` 和 `--power-deep-profile`。

## 输出布局

```
build/systemc/
├── ir.json                       # Phase 1 JSON IR（所有可达模块）
├── <module>.hpp                  # 每模块一个 SystemC header
└── <nested>/<module>.hpp         # 嵌套路径镜像源码树
```

每个模块 header 会 `#include` 它实例化的所有子模块 header，所以用户只需要 include 顶层 header，其余会传递引入。当前不生成 umbrella header。

## 工作方式

1. slang 一次性读入所有源码文件并产生 elaborated `Compilation`（参数覆盖已应用，generate 构造已解析，位宽已具体化）。
2. 流程从 `--top` 指定的 elaborated instance tree 开始遍历，把每个可达模块 lowering 成 `ModuleIR`。不可达定义会被忽略；重复实例化的模块只 lower 一次。
3. Codegen 按**后序 DFS**（子模块先于父模块）为每个模块生成一个 `.hpp`，所以父模块的 `#include` 路径总是指向已经落盘的文件。
4. slang elaboration 和 lowerer 自身产生的 diagnostics 会挂到 `DesignIR` 上，并在运行结束时汇总。

## 示例

| 位置 | 范围 |
| --- | --- |
| `examples/alu_demo/` | 单文件 8-bit ALU，展示 `case`、concat、bit-select |
| `examples/filelist_demo/` | 由 `.f` filelist 驱动的多文件构建，包含 `+incdir+` 和 `-D` |
| `examples/power_demo/` | 用于静态功耗嫌疑分析的小 RTL 示例 |

## 功耗诊断

Power diagnostics 已实现为 RTL 阶段的建议性热点诊断工具。它报告相对的、workload-scoped 的活动量和结构风险；它不输出 absolute watts、不做 signoff power，也不宣称实测 glitch power。

静态分析是纯 Python 路径，不需要 SystemC：

```powershell
python -m prism_v2sc --top wide_reg_no_enable --power-static `
  --power-static-output build/power_static.json `
  examples/power_demo/wide_reg_no_enable.v
```

动态 profiling 是 opt-in。第一步先生成插桩 SystemC 和 probe manifest：

```powershell
python -m prism_v2sc --top wide_reg_no_enable --out build/power_systemc `
  --power-instrument build/probe_manifest.json `
  examples/power_demo/wide_reg_no_enable.v
```

然后把生成的顶层 header 链接进用户的 SystemC workload / testbench，运行该 workload，并调用 `dut.prism_power_dump(std::ostream&)` dump 计数器。可以用 `prism_v2sc.power.runner.create_power_profile_json(...)` 把 dump 转成 `power_profile.json`，也可以提供等价的 JSON profile，只要包含 `workload` metadata 和 `probes` counters。

最后对 profile 打分：

```powershell
python -m prism_v2sc --power-report build/power_profile.json `
  --power-report-static build/power_static.json `
  --power-report-output build/power_report.json
```

生成的 report 包含 ranked hotspots、per-probe metrics（`total_bit_toggles`、`toggle_rate`、`change_rate`、`idle_ratio`、`width_weighted_activity`）、静态 reason codes、建议、confidence labels 和明确限制。`--power-deep-profile` 可开启 deep profiling，为 top-K 后续分析加入 per-bit 和 T1-style counters。Memory-cell probes 是 opt-in，并受 probe planner guardrails 限制。

## 测试

```powershell
python -m pytest -q
```

当前测试套件收集 154 个测试，覆盖 IR lowering、codegen 输出形态、CLI 行为、多文件输出布局、表达式覆盖、diagnostics、hardening、subroutines、静态功耗分析、probe planning、instrumentation 形态、profile parsing、scoring、deep profiling、workload comparison 和 power report 稳定性。

## 等价性 CI

`.github/workflows/equivalence.yml` 在 Linux 上运行。它会对 `tests/equivalence/fixtures/` 下的每个 fixture，用同一份 deterministic stimulus 协同仿真原始 RTL（Icarus Verilog）和生成的 SystemC（libsystemc-dev），并 diff per-cycle output traces。fixture 列表、本地用法和环境变量覆盖见 `tests/equivalence/README.md`。

本地 trace-equivalence 和动态功耗 smoke 都需要 SystemC headers 和 libraries。没有 `<systemc>` 的机器可以先跑 Python unit suite，再用 `tests/equivalence/run_equivalence.py --dry-run --keep-going` 做 conversion coverage，最终 SystemC compile/run 检查依赖 CI。

Linux CI 会安装 `libsystemc-dev`，运行完整 pytest，然后运行 `tests/equivalence/run_equivalence.py --keep-going`。完整 pytest 里包含 Linux-only power checks：编译/运行插桩 SystemC 设计、解析 `prism_power_dump` 输出，并比较插桩与未插桩 SystemC traces。对于本地没装 SystemC 的环境，这是预期的验证路径。

## 延伸阅读

- `docs/correctness_strategy.md` — correctness 如何建立，以及 golden loop 的形态。
- `docs/syntax_coverage.md` — equivalence CI 已验证的 RTL surface、明确拒绝的内容，以及 Phase 11 队列。
- `docs/known_differences.md` — 生成 SystemC 和完整 Verilog/SV 语义差异的明确列表。
- `docs/signed_mixed_semantics.md` — signed / unsigned mixed-expression 语义和剩余 context-sizing 限制。
- `docs/hardening_checks.md` — 可复现的本地检查（unit suite、metrics smoke、static checks）。
- `docs/power_diagnostics.md` — RTL 功耗热点诊断层的方法学。
- `docs/pyslang_migration.md` — pyverilog 到 pyslang 迁移的历史记录（Phases A/B/C，已完成）。
- `docs/plan.md` — 当前 converter phase 状态和已完成 SV feature rollout 列表。
- `docs/plan2.md` — power diagnostics feature 的已完成分阶段实现清单。
