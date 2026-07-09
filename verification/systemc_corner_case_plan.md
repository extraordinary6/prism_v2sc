# SystemC Corner-case 验证计划

## 目标

现在本机已经可以使用 SystemC，并且有 VCS 可以作为 RTL golden runner，下一阶段的重点不是单纯增加单测数量，而是系统性找出 RTL 到 SystemC 转换中可能存在的语义缺口。

本计划覆盖三类结果：

- trace-equivalence：RTL 仿真 trace 和 generated SystemC trace 应逐周期一致。
- conversion-only：转换产物和 IR/header 结构应正确，但当前 golden simulator 不适合作 trace 对比。
- diagnostic：不应静默转换，必须产生明确 warning/error diagnostic。

稳定用例最终应迁移到 `tests/equivalence/fixtures/`，并注册到 `tests/equivalence/run_equivalence.py`，成为常规回归。

## 当前基线

已有基础：

- Python 单测：`python -m pytest -q`
- 等价 harness：`tests/equivalence/run_equivalence.py`
- 本机 SystemC：`/usr/local/systemc-2.3.4`
- 本机 RTL simulator：VCS，使用 `--rtl-sim vcs`
- 已知覆盖面：见 `docs/syntax_coverage.md`
- 已知语义差异：见 `docs/known_differences.md`

本机建议命令：

```bash
SC_CXXFLAGS="-std=c++14 -I/usr/local/systemc-2.3.4/include" \
SC_LDFLAGS="-L/usr/local/systemc-2.3.4/lib64 -Wl,-rpath,/usr/local/systemc-2.3.4/lib64" \
SC_LIBS="-lsystemc -pthread" \
.venv/bin/python tests/equivalence/run_equivalence.py --rtl-sim vcs
```

单个探索用例稳定后，先用 `--fixtures <name> --rtl-sim vcs` 跑通，再纳入全量回归。

## 当前进展

- 2026-07-09：新增并注册 `signed_mixed_context` trace fixture，覆盖显式扩展/cast 后的 signed/unsigned 加减、signed 数学比较、unsigned bit-pattern 比较、part-select 算术右移和 signed 三目选择。修复 generated SystemC 中 signed ternary 分支类型不一致导致的 C++ conditional 编译歧义；本地 VCS/SystemC 验证 `256` cycles match。
- 2026-07-09：新增并注册 `width_boundaries` trace fixture，覆盖 1/2/31/32/33/63/64/65-bit packed 表达式、concat、shift 和 compare。修复 `>64` 位 SystemC 类型选择为 `sc_biguint/sc_bigint`，并增强 equivalence harness 的宽端口 hex stimulus/trace 路径；本地 VCS/SystemC 验证 `256` cycles match。
- 2026-07-09：完成 P0 trace 扩展：`nested_selects`、`staged_read_after_write`、`part_select_assembly`、`procedural_for_edges`、`memory_edges`、`param_hierarchy_edges`、`filelist_edges`、`inout_edges` 均已注册为正式 equivalence fixture，并分别通过本地 VCS/SystemC trace。期间修复递减 procedural-for unroll、unrolled block sensitivity、跨层 parameter template 默认值、以及 comb blocking read-after-write 文档状态。
- 2026-07-09：完成 P1 调度风险轮次：`nba_chain`、`blocking_comb_chain`、`async_reset_edges`、`latch_edges`、`sensitivity_edges` 已注册为正式 trace fixture，并通过本地 VCS/SystemC trace；`comb_process_order` 已注册为 diagnostic fixture，固定 `event_scheduler_approximated` warning。期间修复 FF nonblocking RHS 读取 `__next_*` 导致 NBA 链错误的问题，并修复 equivalence Verilog TB reset deassert race。
- 2026-07-09：完成 P2 diagnostic 轮次：`xz_logic_rejected`、`overlap_slice_writers`、`mixed_assignment_deeper`、`while_repeat_rejected`、`interface_complex_rejected`、`task_system_task_rejected`、`dynamic_sv_rejected` 均已注册为 diagnostic fixture；harness 现在同时校验 `ir.json` diagnostic code 和 `--fail-on-diagnostics` 的 warning/error 退出码。期间新增 `overlapping_procedural_writes` 和 `unsupported_expression_statement_<kind>` 诊断路径。
- 2026-07-09：完成 P3 conversion-only 轮次：`interface_modport_variants`、`package_multifile`、`generate_named_blocks`、`typedef_package_enum` 均已注册为 conversion fixture，断言无 error diagnostic、`ir.json` 生成、top header 关键片段稳定。

## 验证原则

1. 每个用例只打一个主要语义点，避免失败时难以归因。
2. trace fixture 优先，因为它能直接证明行为一致。
3. 对四态 X/Z、复杂调度、unsupported SV surface 等非承诺范围，用 diagnostic fixture 固化“必须响亮失败或警告”的契约。
4. 随机刺激要可复现，seed 固定；发现失败后保留最小复现。
5. 每次发现 corner case，先分类为 bug、known difference、unsupported diagnostic 或测试问题，再决定是否修 converter。

## P0：先扩大现有支持面的 trace 覆盖

这些用例都属于项目当前宣称或接近宣称支持的 synthesizable subset，应优先做 trace-equivalence。

| 主题 | 建议 fixture | 重点检查 |
| --- | --- | --- |
| signed/unsigned 混合表达式 | `signed_mixed_context` | 比较、加减、移位、ternary 中的宽度和符号传播 |
| 窄宽度/宽宽度边界 | `width_boundaries` | 1-bit、2-bit、31/32/33-bit、63/64/65-bit 表达式和 concat |
| 嵌套 ternary 和 case 默认值 | `nested_selects` | default 分支、未覆盖分支、嵌套条件优先级 |
| staged assignment 读写顺序 | `staged_read_after_write` | combinational block 内先写后读同一信号的已知差异是否需要 diagnostic |
| 多个 part-select 写同一 vector | `part_select_assembly` | 非重叠 slice 聚合、边界 slice、乱序 slice |
| procedural for 变体 | `procedural_for_edges` | 递减循环、非零起点、多层循环、局部临时变量 |
| unpacked memory 读写 | `memory_edges` | 同周期 read/write、不同地址、写使能、复位初始化策略 |
| hierarchy 参数传播 | `param_hierarchy_edges` | 多层 parameter/localparam、derived width、实例 override |
| filelist 复杂度 | `filelist_edges` | 嵌套 `-f`、相对路径、`+incdir+`、宏控制源选择 |
| inout 边界 | `inout_edges` | whole-vector high-Z、外部/DUT 互斥驱动、输出采样 resolved value |

完成标准：

- 每个 fixture 在 VCS 和 SystemC trace 下通过。
- 若失败且属于 converter bug，修复后把 fixture 注册为正式回归。
- 若失败但属于明确不支持范围，转入 P2 diagnostic。

## P1：调度和 SystemC delta-cycle 风险

这些最容易出现“能编译但行为不完全等价”的问题，需要小心建最小用例。

| 主题 | 建议 fixture | 预期处理 |
| --- | --- | --- |
| 多个 combinational always 互相依赖 | `comb_process_order` | 如果 SystemC `SC_METHOD` 顺序导致差异，应 diagnostic 或调整调度策略 |
| sequential NBA 链 | `nba_chain` | `a <= b; b <= c;` 这类寄存器链必须保留旧值语义 |
| blocking in comb chain | `blocking_comb_chain` | `a = in; y = a;` 应符合 Verilog blocking 语义；若当前 staged 模型不支持，要 loud diagnostic |
| async reset 边界 | `async_reset_edges` | reset 与 clock 临近变化、reset polarity、reset 分支覆盖 |
| latch 行为 | `latch_edges` | enable hold、partial assignment、初始未知值的项目策略 |
| sensitivity 推导 | `sensitivity_edges` | RHS 中函数调用、select、concat、package function 的 sensitivity 是否完整 |

完成标准：

- 支持范围内的行为必须 trace match。
- 当前建模策略不能保证的行为，必须进入 `docs/known_differences.md`，并补 diagnostic 测试防止静默误用。

## P2：必须响亮失败或警告的用例

这些不一定要支持，但不能静默产生看似可用的 SystemC。

| 主题 | 建议 fixture | 期望 |
| --- | --- | --- |
| X/Z 非 inout 逻辑传播 | `xz_logic_rejected` | warning/error diagnostic，不能声称 trace 等价 |
| overlapping procedural writes | `overlap_slice_writers` | error diagnostic |
| mixed blocking/nonblocking 同信号 | `mixed_assignment_deeper` | error 或 warning diagnostic |
| unsupported loops | `while_repeat_rejected` | unsupported diagnostic |
| complex interface | `interface_complex_rejected` | unsupported diagnostic |
| task/system task | `task_system_task_rejected` | unsupported diagnostic |
| dynamic SV constructs | `dynamic_sv_rejected` | unsupported diagnostic |

完成标准：

- `ir.json` 中有稳定 diagnostic code。
- CLI 在 `--fail-on-diagnostics` 模式下行为明确。
- 文档说明该行为是 intentional rejection 还是待支持缺口。

## P3：conversion-only 覆盖

有些 SV 构造 pyslang 可以 lower，但当前 RTL simulator 不适合作 golden runner，或者 trace TB 很难构造。此类先做 conversion-only，后续再决定是否找其他 golden flow。

| 主题 | 建议 fixture | 检查点 |
| --- | --- | --- |
| simple interface 变体 | `interface_modport_variants` | flatten 后端口/信号命名、binding 方向 |
| package 多文件组织 | `package_multifile` | import 解析、函数/typedef/parameter 提取 |
| generate 命名层级 | `generate_named_blocks` | 输出 header 路径和实例命名稳定 |
| enum/typedef 组合 | `typedef_package_enum` | IR type_aliases 和 enum member value |

完成标准：

- conversion 无 error diagnostic。
- top header 和 `ir.json` 中的关键片段可断言。
- 如果后续能 trace，就升级为 trace fixture。

## 执行节奏

建议分四轮推进：

1. P0 宽度/符号/参数/内存/inout：这些最贴近日常 RTL，收益最高。
2. P1 调度风险：重点找“静默错”的地方。
3. P2 diagnostic：把不支持或近似语义固定成测试契约。
4. P3 conversion-only：补齐当前 trace harness 不方便覆盖的 SV surface。

每轮结束都更新：

- `docs/syntax_coverage.md`
- `docs/known_differences.md`
- `tests/equivalence/README.md`
- 本文件的完成状态

## 失败 triage 模板

每个失败记录到 `verification/notes/`，建议格式：

```text
case:
command:
rtl simulator:
SystemC flags:
observed mismatch:
minimal stimulus:
classification: converter bug | known difference | unsupported | test issue
next action:
```

## 目录使用约定

探索阶段可先把候选 RTL 放在：

- `verification/cases/trace/`
- `verification/cases/conversion/`
- `verification/cases/diagnostics/`

不要长期把稳定回归留在这里。稳定后应迁移到 `tests/equivalence/fixtures/`，由正式 harness 统一执行。
