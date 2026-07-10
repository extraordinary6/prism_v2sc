# prism_v2sc Power Diagnostics 实现计划

最后更新：2026-07-09。

本文把 `docs/power_diagnostics.md` 的方法学拆成可落地的 phase
清单。它和 `plan.md` 分工不同：`plan.md` 记录转换器当前已实现状态；
本文记录功耗诊断能力的实施路线。

## 总体定位

Power diagnostics 是 RTL 设计期的相对诊断工具，目标是指出活动热点、
结构风险和改写建议，不做 absolute watts / signoff。

基本原则：

- 以 toggle activity 作为动态功耗的核心代理量。
- 用户日常分析路径保持 SC-only；RTL/SystemC 协同仿真只作为 CI 中的
  模型可信度验证。
- 在 clock boundary 采样，不从 VCD 事件流统计，避免 delta-cycle 虚高。
- glitch 只作为静态结构风险标注，不宣称实测毛刺功耗。
- workload 是一等输入；所有动态结论都只对对应激励成立。

## 当前项目基线

已有基础：

- `pyslang` 是唯一 frontend，已能解析并 elaboration 以 `--top` 为根的可达设计。
- `ModuleIR` 已携带 ports、signals、parameters、continuous assigns、
  processes、instances、subroutines、diagnostics 和 `source_path`。
- 表达式已经是结构化 dict 树（`identifier` / `binop` / `cond` /
  `concat` / `bitselect` / `partselect` / `cast` 等），适合做依赖图和
  表达式复杂度分析。
- `ProcessIR` 已区分 `always_ff` / `always_comb`，并记录
  edge-sensitive `SensitivityIR`。
- codegen 已输出层级化 one-module-per-header SystemC，模块成员为 public，
  统一注册 `SC_METHOD`，并已有 `__next_*` staging 与 `__shadow_*`
  slice 多写者聚合机制。
- 当前 equivalence harness 可导入 40 个 trace fixtures、5 个
  conversion fixtures、14 个 diagnostic fixtures；`pytest` 当前收集 185 个
  unit/integration tests。
- `analysis/drivers.py` 已有真实分析 pass，可作为遍历结构化语句的风格参考；
  `analysis/dependencies.py` / `analysis/sensitivity.py` 已经是真实实现。

计划启动时的主要缺口：

- 除 `ModuleIR.source_path` 外，signals、processes、statements、expressions
  没有 `loc`，还不能稳定反标到 RTL 行号。
- 没有 power 专用 CLI、report schema、workload schema、score model。
- 没有可选 SystemC instrumentation，也没有计数器 dump API。
- 没有把 codegen 合成名（`__next_*`、`__shadow_*`、bridge signals）过滤或
  归因回原始 RTL 信号的映射层。

上面的缺口是计划启动时的基线；P1-P9 已经补齐 source location、依赖图、
静态指标、power CLI、插桩、profile/report、合成名过滤和 guardrails。

## Phase P0 - 产品契约与测试样例

**状态**: ✅ 已完成 (2026-06-08)

目标：先冻结第一版用户可见形态，再改内部实现。

清单：

- [x] 定义输出产物：
  - `power_static.json`：静态嫌疑、原因、可用的源码位置；
  - `power_profile.json`：逐 instance / signal / workload 的原始实测计数；
  - `power_report.json`：已打分热点和模块/全设计聚合；
  - 可选 `power_report.md`：面向人阅读的摘要。
- [x] 定义不破坏现有 converter 的 CLI 入口。建议第一版保持保守：
  - `--power-static`：lowering 后运行 IR-only 静态分析；
  - `--power-instrument <manifest>`：按 probe manifest 生成插桩 SystemC；
  - `--power-report <profile.json>`：对采集到的 profile 打分。
- [x] 增加 2-3 个小 RTL 样例：
  - 宽无 enable 寄存器；
  - 带 enable 的 counter；
  - 宽 mux / case feeding register。
- [x] 明确文档声明：动态报告必须依赖用户 workload / testbench。

验收：

- [x] schema 有文档或短 docs stub 固化。
- [x] CLI help 测试固定新增 flags。
- [x] 空设计 / unsupported design 给出可读 diagnostics，不崩溃。

注：CLI 函数已实现，但未集成到主 CLI 入口（可在后续 PR 中完成）。

## Phase P1 - Source Location 打通

**状态**: ✅ 已完成 (2026-06-08)

目标：让热点反标具备数据基础。

清单：

- [x] 新增小型 `SourceLocIR(file, line, column)` dataclass。
- [x] 给以下结构增加可选 `loc`：
  - `PortIR` / `SignalIR`（能取到的位置先接）；
  - `ContinuousAssignIR`；
  - `ProcessIR`；
  - structured statement dict。
- [x] 在 lowering 中增加 source-location helper，从 slang
  `sourceRange.start` 提取 `(file, line, column)`，复用当前
  `_resolve_source_path` 访问 source manager 的路径。
- [x] `loc` 默认 `None`，保持 JSON 向后兼容。
- [x] 增加单测，确认 declaration、continuous assign、procedural assign 的
  loc 能进入 `--dump-ir`。

验收：

- [x] 静态嫌疑至少能输出 `(module, signal, file, line)`。
- [x] 现有测试不要求每个 IR 节点都有 loc，避免脆弱化。

详细文档：`docs/phase_p1_source_location.md`

## Phase P2 - 依赖图与静态指标

**状态**: ✅ 已完成 (2026-06-08)

目标：建立 IR-only power analysis 的底座。

清单：

- [x] 用真实实现替换 `analysis/dependencies.py` placeholder：
  - 表达式 identifier 收集；
  - assignment target 提取；
  - driver-to-dependency edges；
  - per-module fanin/fanout summary。
- [x] 用真实实现替换 `analysis/sensitivity.py` placeholder：
  - 从 `always_ff` LHS 识别 state signals；
  - 从 `ProcessIR.sensitivity` 提取 clock/reset；
  - best-effort 给 state signal 归属 clock domain。
- [x] 增加表达式指标：
  - expression tree node count；
  - operator family count；
  - max expression depth；
  - mux/case 宽度与分支数。
- [x] 复用或封装 `ModuleContext` 中已有 width 信息，给 analysis/scoring
  共享使用。
- [x] analysis 输出显式过滤合成信号名。

验收：

- [x] 单测覆盖 nested `if`、`case`、continuous assign、bit/part-select LHS、
  function call arguments、memory、generated slice writers。
- [x] 依赖图输出确定性稳定，可做 snapshot / golden 测试。

详细文档：`docs/phase_p2_dependency_analysis.md`

## Phase P3 - 静态功耗嫌疑分析

**状态**: ✅ 已完成 (2026-06-08)

目标：先在零仿真条件下产出有用结果。

清单：

- [x] 新增 `analysis/power_static.py`，输出 ranked suspect records：
  - 无 enable 守护的宽寄存器；
  - counter 形态（`reg <= reg + const` / `reg - const`）；
  - 宽 mux / 宽 case；
  - 高 fanout 信号；
  - 深组合 cone；
  - 证据足够强的过宽信号候选。
- [x] 给每条 suspect 附 reason code 和建议文本：
  - `clock_gating_candidate`；
  - `counter_activity_candidate`；
  - `wide_mux_candidate`；
  - `high_fanout_candidate`；
  - `glitch_risk_structural`；
  - `width_reduction_candidate`。
- [x] `--power-static` 输出 `power_static.json`。
- [x] 如果 lowering 已有 error diagnostics，动态分析退化为 static-only，
  不声称可实测 activity。
- [x] 增加阈值配置对象，默认值保守。

验收：

- [x] P0 三个样例能产出预期 suspects 和建议。
- [x] 静态分析不依赖 SystemC、Icarus、Verilator 或 VCD。

详细文档：`docs/phase_p3_power_static.md`

## Phase P4 - Probe Planning

**状态**: ✅ 已完成 (2026-06-08)

目标：先决定”插什么”，再改 codegen。

清单：

- [x] 新增 `PowerProbePlan` / manifest model，字段包括：
  - hierarchical instance path；
  - module name；
  - RTL signal name；
  - generated SystemC member name；
  - width；
  - signal class（`state` / `comb` / `memory_cell` / `port`）；
  - clock domain 或 sample strobe；
  - source loc 与 static reason codes。
- [x] 默认 probe policy：
  - 所有 state registers 做 coarse probe；
  - combinational signals 只 probe 静态嫌疑；
  - 提供 all-signal coarse mode 给彻底审计场景。
- [x] 对组合嫌疑增加 top-K 选择。
- [x] 增加合成名过滤 / 归因规则：
  - 跳过 `__next_*`；
  - 跳过 `__shadow_*` 和 bridge signals，除非内部实现确实需要；
  - 报告活动时归因回原始 RTL signal。
- [x] 定义纯组合模块采样方式：使用显式 sample strobe，不回退 VCD。

验收：

- [x] probe manifest 输出稳定、可 diff。
- [x] probe planning 可完全基于 `DesignIR` 单测，不需要 SystemC。

## Phase P5 - 可选 SystemC 插桩

**状态**: ✅ 已完成 (2026-06-08)

目标：生成计数器，同时不扰动功能行为。

清单：

- [x] 给 SystemC emission 线程传入可选 instrumentation config。
- [x] 每个 probe 生成普通 C++ 成员，不新增 `sc_signal` driver：
  - previous sampled value；
  - sample count；
  - value-change cycle count；
  - bit-toggle count；
  - 后续可选 high-cycle count，用于 SAIF-like T1/T0。
- [x] 生成 clock-boundary sampling `SC_METHOD`：
  - 按 domain 使用 `sensitive << clk.pos()` / `clk.neg()`；
  - 需要时加 `dont_initialize()`；
  - 纯组合设计使用显式 sample strobe。
- [x] 实现当前 emitted type 可用的 width-safe popcount；第一版只做
  per-signal coarse totals，per-bit counters 放到 P8。
- [x] 生成稳定 dump API，例如
  `void prism_power_dump(std::ostream&) const`，并输出可机器解析的 manifest
  把 dump row 映射回 probe metadata。
- [x] 插桩必须 opt-in；默认生成 SystemC 路径尽量不受影响。

验收：

- [x] header shape tests 覆盖 counters、sampling methods、sensitivity、dump API。
- [x] equivalence harness 能对部分 fixtures 开启 instrumentation，并确认功能 trace
  不变化。

## Phase P6 - SC-only Profile 采集路径

**状态**: ✅ 已完成 (2026-06-08)

目标：无需 RTL 仿真也能采集实测 activity。

清单：

- [x] 为项目 fixtures 增加小型 SystemC runner，复用现有 deterministic stimulus。
- [x] 面向用户设计提供两个初始路径：
  - 用户自带 SystemC testbench，链接 instrumented top 并调用 dump；
  - 简单 vector-file runner，支持 flat top-level scalar/vector ports。
- [x] 记录 workload metadata：
  - workload name；
  - seed 或 vector file hash；
  - cycle count / sample count；
  - reset policy；
  - top module 与 source list。
- [x] 如果用户请求 dynamic profile 但没有 workload 路径，明确失败并解释。

验收：

- [x] P0 fixtures 能生成 `power_profile.json`，且过程不跑 Icarus / RTL co-sim。
- [x] profile collection 与 equivalence CI 解耦，只在验证 instrumentation 时复用 CI。

## Phase P7 - Scoring、热点与报告

**状态**: ✅ 已完成 (2026-06-08)

目标：把 raw counters + static suspects 转成可行动诊断。

清单：

- [x] 计算 per-probe metrics：
  - `total_bit_toggles`；
  - `toggle_rate`；
  - `change_rate`；
  - `idle_ratio`；
  - `width_weighted_activity`。
- [x] 将 profile counters 与 static metadata / source loc join。
- [x] 实现方法学中的 score dimensions：
  - toggle activity；
  - clock-gating opportunity；
  - operand-isolation opportunity（依赖图证据足够时）；
  - structural complexity / fanout；
  - glitch risk，标为 static-only；
  - memory activity（存在 memory probes 时）。
- [x] 按 workload 做 percentile 或 z-score 归一化，再聚合到 signal、
  instance、module、design。
- [x] 输出 ranked hotspots：
  - module / instance path；
  - signal；
  - source loc；
  - triggering dimensions；
  - measured activity；
  - recommendation；
  - limitations / confidence label。
- [x] 报告必须明确写出 relative、workload-scoped、non-signoff。

验收：

- [x] P0 fixtures 的报告能识别预期热点。
- [x] static-only 和 dynamic report 使用同一 hotspot schema。

## Phase P8 - 深度 Profiling 与多 Workload

**状态**: ✅ 已完成 (2026-06-08)

目标：在 coarse path 可信后增加高价值分析。

清单：

- [x] 增加 two-pass profiling：
  - pass 1：所有选中信号做 coarse counters；
  - pass 2：top-K 增加 per-bit 或 conditional counters。
- [x] 增加 bit-level utilization，用于 width-reduction candidates。
- [x] 在当前 per-cell `sc_signal` memory lowering 基础上，增加 memory
  read/write 与 per-cell aggregation。
- [x] 增加 workload comparison report：
  - 单 workload 热点；
  - 跨 workload 稳定热点；
  - workload-specific outliers。
- [x] TC/T1/T0 数据成熟后增加可选 SAIF-like export。
- [x] 零仿真概率活动估计只作为后续补充，等实测 profiling 与静态报告稳定后再做。

验收：

- [x] deep profiling 可单独开启，不改变默认 fast path。
- [x] 多 workload 报告显式呈现 workload dependence，而不是粗暴平均。

实现证据：

- `InstrumentationConfig(per_bit_counters=True, track_high_cycles=True)` 与
  CLI `--power-deep-profile` 单独开启 per-bit / T1-like counters，默认
  fast path 仍只生成 coarse counters。
- `select_deep_profile_targets()` 从 coarse report 选 top-K pass-2 probes。
- `parse_power_dump()` / `create_power_profile_json()` 支持 per-bit、
  high-cycle、vector hash 与 memory per-cell aggregation。
- `generate_workload_comparison_report()` 输出 per-workload top hotspots、
  stable hotspots 与 workload-specific outliers。
- `export_saif_like()` 从 `TC/T1/T0` 成熟计数导出 SAIF-like 文本。

## Phase P9 - Hardening、Docs 与发布门槛

**状态**: ✅ 已完成 (2026-06-08)

目标：让能力可维护、可验证、不过度宣称。

清单：

- [x] 文档已覆盖已实现行为、命令入口、限制与验证证据；当前 README、
  `docs/power_diagnostics.md`、`docs/plan.md`、`docs/correctness_strategy.md`
  和 `verification/` 文档会随实现状态同步更新。
- [x] 增加 CI 覆盖：
  - static analysis / scoring 单测；
  - instrumentation codegen conversion tests；
  - 至少一个 Linux SystemC profile collection smoke；
  - instrumentation 不改变 trace 的 equivalence guard。
- [x] 增加性能护栏：
  - 报告 probe count；
  - 尽量报告采样开销；
  - 对病态 probe plans 拒绝或 warning。
- [x] 持续文档化限制：
  - 不做 absolute watts；
  - 不实测 glitch power；
  - 动态结论 workload-scoped；
  - unsupported RTL 退化为 static-only diagnostics。
- [x] 收敛影响 power 准确性的 converter hardening，尤其是 width inference
  和 concat-LHS driver analysis。

验收：

- [x] 新用户能按文档完成 convert、instrument、run workload、拿 ranked report。
- [x] CI 同时保护功能等价性和 power report schema 稳定性。

实现证据：

- 主 CLI 已集成 power flags：
  `--power-static`、`--power-instrument <manifest>`、
  `--power-report <profile.json>`、`--power-report-static <json>`、
  `--power-all-signals`、`--power-probe-ports`、`--power-memory-cells`、
  `--power-deep-profile`。
- `--power-instrument` 现在实际写出 instrumented SystemC headers 与 probe
  manifest；默认未传 instrumentation config 时 `generate_systemc_header()`
  不包含 `prism_power_dump`。
- `PowerProbePlan` manifest 报告 `probe_count`、分类 probe count、
  `estimated_counter_count`、`estimated_storage_bytes` 与 warnings；超出
  `max_total_probes` 的病态 plan 会拒绝。
- `power_report.json` summary 与 hotspot limitations 明确 relative、
  workload-scoped、non-signoff、glitch static-only、unsupported RTL
  degrade-to-static。
- CI 证据由现有 Linux `equivalence.yml` 覆盖：安装 `libsystemc-dev` 后运行
  full pytest（包含 Linux-only SystemC profile smoke）并继续运行 RTL vs
  SystemC equivalence harness。
- 新增测试覆盖：
  `tests/test_power_p8_p9.py`（deep profiling、workload comparison、
  SAIF-like export、probe guardrails、CLI instrument、Linux SystemC smoke、
  concat-LHS analysis）以及既有 power/static/scoring/instrumentation tests。

验证命令：

- `python -m py_compile src\prism_v2sc\analysis\dependencies.py src\prism_v2sc\analysis\sensitivity.py src\prism_v2sc\analysis\expression_metrics.py src\prism_v2sc\analysis\probe_planning.py src\prism_v2sc\codegen\instrumentation.py src\prism_v2sc\codegen\systemc.py src\prism_v2sc\power\runner.py src\prism_v2sc\power\scoring.py src\prism_v2sc\power\cli.py src\prism_v2sc\cli.py tests\test_power_p8_p9.py`
- `python -m pytest tests\test_power_p8_p9.py`：当前收集 10 个 P8/P9 测试；
  Linux SystemC 相关用例会按宿主环境可用性运行或跳过。
- `python -m pytest`：当前全仓收集 185 个测试；最新本机完整回归为
  `185 passed`。

## 历史建议首批 PR 顺序

1. P1：source location plumbing，小范围测试。
2. P2：dependency graph 与 static metrics。
3. P3：static report CLI。
4. P4：probe manifest。
5. P5：coarse instrumentation 与 equivalence guard。
6. P6：fixture-only SC profile runner。
7. P7：第一版 scored report。

这个顺序保证每个 PR 都有独立价值：静态诊断在动态插桩前就能使用；
插桩则先被 probe manifest 约束，避免直接在 codegen 里堆临时开关。
