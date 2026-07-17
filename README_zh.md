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
  <img alt="255 tests" src="https://img.shields.io/badge/tests-255%20collected-0EA5E9">
  <img alt="Power diagnostics" src="https://img.shields.io/badge/power-diagnostics-F59E0B">
</p>

# prism_v2sc

`prism_v2sc` 把可综合 Verilog / SystemVerilog RTL 子集转换成层级化、近似的 SystemC 模型。它会为每个从顶层可达的模块生成一个 `.hpp`，并镜像 RTL 源码目录结构。

转换器只接收 Verilog/SystemVerilog RTL，不负责编译或转换 Chisel、FIRRTL、Scala 等 RTL 生成器源码。像香山这样的设计，只有在外部流程生成固定的 `.v`/`.sv` RTL 快照后，才属于本项目的输入范围。

前端使用 [slang](https://sv-lang.com/) 和 [pyslang](https://pypi.org/project/pyslang/) 绑定。slang 会先对整个设计做解析和 elaboration，因此参数覆盖、`generate if`、`generate for` 和具体端口位宽都会在 lowering 之前解析完成。

这个项目定位是实用 RTL 子集转换器，不是完整 SystemVerilog 语义等价器。不支持的构造会以 diagnostics 暴露，而不是静默误编译。

## 安装

```powershell
python -m pip install -e .
```

要求：Python 3.10+ 和 `pyslang>=11.0,<12.0`。只有在本地编译/运行生成的 SystemC 时才需要 SystemC；Linux CI 会安装 SystemC 并做完整验证。

## CLI

基本转换：

```powershell
python -m prism_v2sc --top <module> [options] [<sources...>]
```

通过 filelist 做多文件转换：

```powershell
python -m prism_v2sc --top top_datapath `
  --filelist examples\filelist_demo\rtl\sources.f `
  --out build\systemc_filelist
```

核心选项：

| 参数 | 作用 |
| --- | --- |
| `--top <name>` | RTL 顶层模块名。转换、静态功耗分析和插桩生成时需要。 |
| `<sources...>` | 位置参数形式的 Verilog/SystemVerilog 源文件。可以和 `--filelist` 混用；重复文件会去重。 |
| `--filelist <path>` | `.f` 风格 filelist。可以重复指定。filelist 内部路径相对于该 filelist 解析。 |
| `--out <dir>` | 生成的 SystemC 和 `ir.json` 输出目录。默认是 `build/systemc`。 |
| `--dump-ir` | 把 JSON IR 打印到 stdout，而不是写入 `ir.json`。 |
| `--metrics` | 写出包含耗时、内存和遍历计数的 `metrics.json`。 |
| `--compare-verilator` | 对同一批输入运行 best-effort `verilator --lint-only` 并记录耗时。 |
| `--fail-on-diagnostics` | 出现 error-level diagnostics 时返回退出码 `2`。 |
| `--diagnostic-policy <json>` | 应用 version 1 的 diagnostics allow/deny/fatal policy；policy 失败时返回退出码 `2`。 |
| `--conversion-audit <json>` | 写出机器可读的源码/模块覆盖、provider、diagnostics 和 policy 结果。 |
| `--model-manifest <json/toml>` | 应用显式源码过滤和外部模型 provider，并写出 `model_report.json`。 |
| `--model-audit` | 不替换模块，只分类模型/testbench 候选并写出 `model_report.json`。 |
| `--version` | 打印包版本。 |

filelist 支持：

```text
# 注释和空行会被忽略
+incdir+include
-I ../shared/include
-D USE_FAST_PATH
-D WIDTH=32
-f nested_sources.f
rtl/child.v
rtl/top.v
```

功耗相关选项：

| 参数 | 作用 |
| --- | --- |
| `--power-static` | 运行静态 RTL 功耗嫌疑分析并写出 `power_static.json`。 |
| `--power-static-output <file>` | 静态分析输出路径。默认是 `power_static.json`。 |
| `--power-instrument <manifest>` | 生成插桩 SystemC，并写出 probe manifest。 |
| `--power-all-signals` | 探测所有符合条件的信号，而不只是状态寄存器和组合嫌疑信号。 |
| `--power-probe-ports` | 把模块端口也纳入 probe plan。 |
| `--power-memory-cells` | 对 unpacked-array memory 加入受限数量的 per-cell probes。 |
| `--power-deep-profile` | 加入 per-bit toggle counters 和 high-cycle counters，用于更深 profiling。 |
| `--power-profile-dump <csv>` | 把真实 SystemC workload 产生的 `prism_power_dump` CSV 转成 `power_profile.json`。 |
| `--power-profile-output <file>` | `--power-profile-dump` 的输出路径。默认是 `power_profile.json`。 |
| `--power-workload-name <name>` | 写入 `power_profile.json` 的 workload 名称。 |
| `--power-workload-cycles <n>` | 写入 `power_profile.json` 的 workload 总周期数。 |
| `--power-profile-top <module>` | profile 转换命令使用的顶层模块元数据。 |
| `--power-profile-source <path>` | profile 转换命令记录的源码或 filelist 元数据。可重复。 |
| `--power-vector-file <path>` | 可选 workload vector 文件路径；转换时会记录它的 SHA-256。 |
| `--power-seed <n>` | 可选 workload 随机种子元数据。 |
| `--power-reset-cycles <n>` | reset 周期数元数据。 |
| `--power-report <profile.json>` | 对已采集 profile 打分并写出 `power_report.json`。 |
| `--power-report-static <json>` | 和动态活动量合并使用的静态分析 JSON。 |
| `--power-report-output <file>` | 打分报告输出路径。默认是 `power_report.json`。 |

`--model-manifest` 和 `--model-audit` 可以与 `--power-static` 或
`--power-instrument` 组合使用。功耗分析使用 provider 处理后的设计，并在
`--out` 目录写出 `model_report.json`。

## 输出布局

```text
build/systemc/
|-- ir.json
|-- model_report.json       # 可选的模型 manifest/audit 输出
|-- <module>.hpp
`-- <nested>/<module>.hpp
```

每个生成的模块 header 会 include 它实例化的子模块 header。SystemC testbench 只需要 include 生成的顶层 header，子模块 header 会传递引入。

## 工作方式

1. slang 一次性读取所有源文件并创建 elaborated `Compilation`。
2. `prism_v2sc` 从 `--top` 指定的 instance tree 开始遍历，只把可达模块 lowering 成 `ModuleIR`。
3. 启用 model manifest 时，显式 provider 会把匹配模块替换成规范化 `ModuleIR`，并把全部决策记录到 `model_report.json`。
4. Codegen 按后序 DFS 写出每个模块的 `.hpp`，因此父模块引用子模块 header 时，子模块文件已经存在。
5. slang、lowerer 和 model provider 产生的 diagnostics 会保存在 IR 中，并在运行结束时汇总。

## 大型项目与可审计转换

### Model provider

大型 RTL 仓库经常包含仅用于仿真的 memory、vendor primitive、testbench、assertion 或 timing model。`--model-audit` 只分类这些源码和模块候选，不会过滤源码或替换模块：

```powershell
python -m prism_v2sc --top cpu_top `
  --filelist synthesis.f `
  --model-audit `
  --out build\cpu_audit
```

需要显式控制转换决策时，使用 version 1 的 JSON 或 TOML model manifest。source rule 可以忽略指定文件，module rule 则选择已注册的 provider。内置 `memory` provider 会在其文档化 contract 范围内生成有功能的规范化 memory model；`blackbox` 会保留参数和端口，但没有功能体，并且在 strict mode 下必须显式允许。

```powershell
python -m prism_v2sc --top cpu_top `
  --filelist synthesis.f `
  --model-manifest models.json `
  --fail-on-diagnostics `
  --out build\cpu_systemc
```

两种模式都会写出 `model_report.json`，让每项分类、忽略的源码、provider 替换、warning 和 approximation 都可见。自动分类只用于 audit，绝不会仅凭文件名 heuristic 删除 RTL。manifest schema 和 provider contract 详见 `docs/model_providers.md`。

### Conversion audit 与 diagnostic policy

`--conversion-audit` 会写出机器可读报告，其中包含源码数量和分类、可达及已生成模块、provider 决策、diagnostics、policy failure 和最终 pass/fail 状态。version 1 diagnostic policy 可以定义 fatal severity，以及显式允许或拒绝的 diagnostic code：

```powershell
python -m prism_v2sc --top cpu_top `
  --filelist synthesis.f `
  --diagnostic-policy docs\diagnostic_policy.example.json `
  --conversion-audit build\conversion_audit.json `
  --out build\cpu_systemc
```

policy 失败时返回退出码 `2`，因此同一套规则可以同时作为本地转换和 CI gate。仓库中的 `docs/rtl_coverage_registry.json` 把 support claim 关联到 evidence，`docs/diagnostic_policy.example.json` 则提供最小 policy 模板。

### Staged project 转换

大型设计可以拆成有序 stage，每个 stage 使用独立的 top、sources 或 filelists、model manifest 和 diagnostic policy。project manifest 支持 JSON 和 TOML，所有相对路径都相对于 manifest 所在目录解析。

```json
{
  "version": 1,
  "name": "cpu",
  "output_root": "build/project_conversion",
  "stages": [
    {
      "name": "leaf",
      "top": "leaf_top",
      "filelists": ["rtl/leaf.f"],
      "model_manifest": "models.json",
      "diagnostic_policy": "policy.json"
    },
    {
      "name": "integration",
      "top": "cpu_top",
      "filelists": ["rtl/cpu.f"],
      "depends_on": ["leaf"],
      "model_manifest": "models.json",
      "diagnostic_policy": "policy.json",
      "no_ir": true
    }
  ]
}
```

运行 project：

```powershell
python -m prism_v2sc.project project.json
```

每个 stage 都会在 `<output_root>/<stage>/` 下写出生成的 SystemC 和 `conversion_audit.json`，runner 还会写出 `project_report.json`。超大 stage 可以设置 `no_ir: true`，避免序列化 `ir.json`。如果某个 stage 的依赖失败或被跳过，该 stage 会记为 `skipped_dependency`，且不会运行。

## 示例

| 位置 | 范围 |
| --- | --- |
| `examples/alu_demo/` | 单文件 8-bit ALU，展示 `case`、concat 和 bit-select。 |
| `examples/filelist_demo/` | 由 `.f` filelist 驱动的多文件构建，包含 `+incdir+` 和 `-D`。 |
| `examples/power_demo/` | 用于静态功耗嫌疑分析的小型单模块 RTL 示例。 |
| `examples/power_multimodule_demo/` | filelist 驱动的多模块功耗 demo，包含生成好的报告和插桩 SystemC。 |
| `examples/e203_cpu/` | 自包含 E203 CPU 快照，包含 model provider、生成 SystemC 和 staged-project 输出。 |
| `examples/e603_cpu/` | 自包含 E603 CPU/SRAM wrapper 快照，包含生成 SystemC 和受控大设计命令。 |

## 功耗诊断

功耗诊断是 RTL 阶段的建议性热点诊断。它报告相对的、workload-scoped 的活动量和结构风险；它不输出 absolute watts，不做 signoff power，也不宣称实测 glitch power。

### 1. 静态分析

静态分析不需要 SystemC：

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --power-static `
  --power-static-output build\power_static.json
```

输出的 `power_static.json` 会包含这类静态嫌疑：

- `clock_gating_candidate`：较宽的状态寄存器，可能适合 enable/clock gating。
- `counter_activity_candidate`：类似计数器的状态更新模式。
- `wide_mux_candidate`：宽 mux 逻辑。
- `high_fanout_candidate`：驱动很多目的端的控制信号。
- `glitch_risk_structural`：较深的组合逻辑，可能存在 glitch 风险。

### 2. 生成插桩 SystemC

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --out build\power_systemc `
  --power-instrument build\probe_manifest.json `
  --power-all-signals `
  --power-deep-profile
```

这个命令会在 `build/power_systemc/` 下写出插桩 header，并写出 `probe_manifest.json`。默认 probe plan 一定包含状态寄存器，并加入选中的组合嫌疑信号。`--power-all-signals` 会扩大到所有符合条件的组合信号；`--power-deep-profile` 会加入 per-bit 和 high-cycle counters。

如果生成的顶层模块暴露了 `__power_sample_strobe`，需要在 SystemC workload 里绑定它，并在每个采样点 pulse 一次。生成的父模块会自动把这个 strobe 传给需要它的插桩子模块。

### 3. 运行真实 workload

你的 workload/testbench 用真实 vector 或流量驱动生成的顶层模块。运行结束后，只需要调用顶层 dump API：

```cpp
#include "top/power_soc_top.hpp"
#include <systemc>
#include <fstream>

int sc_main(int argc, char** argv) {
  sc_clock clk("clk", 10, SC_NS);
  sc_signal<bool> rst_n, start, power_sample_strobe;
  sc_signal<sc_uint<4>> command;
  sc_signal<sc_uint<64>> data_a, data_b, data_c, data_d, result;
  sc_signal<sc_uint<16>> packets;

  power_soc_top dut("dut");
  dut.clk(clk);
  dut.rst_n(rst_n);
  dut.start(start);
  dut.command(command);
  dut.data_a(data_a);
  dut.data_b(data_b);
  dut.data_c(data_c);
  dut.data_d(data_d);
  dut.result(result);
  dut.packets(packets);
  dut.__power_sample_strobe(power_sample_strobe);

  // 在这里驱动 reset 和真实 workload vectors。组合 probe 的采样点
  // 由 power_sample_strobe 的 pulse 决定。

  std::ofstream csv("build/power_dump.csv");
  dut.prism_power_dump(csv);
  return 0;
}
```

`dut.prism_power_dump(csv)` 会递归 dump 所有从顶层可达的已插桩子模块，并且只写一个 CSV header。CSV 同时包含 `module` 和 `instance_path`，因此报告可以定位到类似 `dut.u_alu` 的层级位置。

### 4. 把 CSV 转成 profile JSON

```powershell
python -m prism_v2sc --power-profile-dump build\power_dump.csv `
  --power-profile-output build\power_profile.json `
  --power-workload-name real_vectors_smoke `
  --power-workload-cycles 1000 `
  --power-profile-top power_soc_top `
  --power-profile-source examples/power_multimodule_demo/rtl/sources.f `
  --power-vector-file vectors/real_vectors.txt `
  --power-seed 1 `
  --power-reset-cycles 5
```

这个命令会解析 `prism_power_dump` 的原始 CSV，保留每个 probe 的 counters，记录 workload 元数据，并在提供 vector 文件时记录其 SHA-256。

### 5. 生成 power report

```powershell
python -m prism_v2sc --power-report build\power_profile.json `
  --power-report-static build\power_static.json `
  --power-report-output build\power_report.json
```

报告包含 ranked hotspots、per-probe metrics（`total_bit_toggles`、`toggle_rate`、`change_rate`、`idle_ratio`、`width_weighted_activity`）、静态 reason codes、建议、confidence labels、instance paths 和明确限制。

## 测试

```powershell
python -m pytest -q
```

当前测试套件收集 255 个测试，覆盖 IR lowering、codegen 输出形态、CLI 行为、多文件输出布局、表达式覆盖、diagnostics、hardening、subroutines、model providers、conversion audits、staged projects、静态功耗分析、probe planning、instrumentation、递归 power dump、profile parsing、scoring、deep profiling、workload comparison 和 report 稳定性。

## 等价性 CI

`.github/workflows/equivalence.yml` 在 Linux 上运行。它用 Icarus Verilog 协同仿真 RTL fixtures，并用 `libsystemc-dev` 编译运行生成的 SystemC，然后 diff per-cycle traces。CI 也包含 Linux-only power checks：编译并运行插桩 SystemC，解析 `prism_power_dump` 输出，并比较插桩和未插桩 traces。

本地 trace-equivalence 和动态功耗 smoke 需要 SystemC headers 和 libraries。没有 `<systemc>` 的机器可以本地运行 Python unit suite，并依赖 Linux CI 做最终 SystemC compile/run 检查。

对于较大的生成设计，`--compile-friendly` 会生成共享 SystemC runtime header，并把非模板方法拆到实现分片中。等价性、MHSA、E203 和 E603 consistency harness 还支持 `--sc-build-mode optimized --sc-build-jobs N`，用于开启受控并行编译、PCH 复用、基于依赖文件的对象缓存和链接缓存。这些开关保持 opt-in，因为极小设计通常无法摊薄额外 translation unit 的固定开销。

更深入的探索性验证和真实设计检查放在 `verification/` 下，包括外部 MHSA、OFDM FFT/IFFT、带 interface 的 ICB-to-APB bridge、4x4/8x8 tinyNPU，以及 E203 CPU 转换和一致性 gate。E203 使用 model provider 替换 ITCM/DTCM 仿真模型，并按架构关键事件比较，不要求严格逐拍对齐。

## 延伸阅读

- `docs/README.md`：文档索引和推荐阅读入口。
- `docs/correctness_strategy.md`：correctness 策略和 golden loop。
- `docs/syntax_coverage.md`：已验证 RTL surface 和待支持内容。
- `docs/known_differences.md`：相对完整 Verilog/SV 的已知语义差异。
- `docs/signed_mixed_semantics.md`：signed/unsigned mixed-expression 说明。
- `docs/hardening_checks.md`：可复现的本地检查。
- `docs/power_diagnostics.md`：RTL 功耗热点诊断方法学。
- `docs/model_providers.md`：外部仿真模型 manifest 与 provider 框架。
- `docs/rtl_conversion_roadmap.md`：当前四阶段能力建设路线和证据跟踪。
- `verification/README.md`：更深入的 verification 工作区和真实设计检查。
