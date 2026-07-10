# RTL 功耗诊断方法学（Power Diagnostics Methodology）

> 本文描述一个**已集成在 `prism_v2sc` 中的 RTL 功耗热点诊断器**的方法学与设计边界。
>
> 说明：
> - 该能力已经实现：`--power-static` 做静态嫌疑分析，`--power-instrument` 生成插桩 SystemC，`--power-profile-dump` / `--power-report` 生成 workload-scoped profile/report。
> - 本文仍以方法学和诚实边界为主；命令入口示例见顶层 README 和 `examples/power_multimodule_demo/README.md`，实施记录见 `docs/plan2.md`。
> - 本文**不含新的实施计划 / 阶段排期**；方法学与计划分开维护。
> - 阅读前置：`docs/correctness_strategy.md`（等价性如何建立）、`docs/known_differences.md`（生成 SystemC 的近似语义边界）。这两份文档直接决定了本方法学"能测什么、不能测什么"。

---

## 1. 定位：相对的、设计期的功耗热点诊断器

这个工具的目标是：**在 RTL 设计阶段，指出功耗热点、给出多维度评分、并把可疑语句反标回 RTL 源码，用以指导设计**。

它**有意**被定位成一个*相对的、advisory（建议性）* 的诊断器——类似"功耗 linter / 体检器"——而**不是**一个 absolute-watts 的功耗签核（signoff）工具。这个定位不是能力不足的妥协，而是 RTL 抽象层次的客观边界（见 §2）。一旦定位摆正，工具的每一条结论都站得住；若误定位成签核工具，则每一条都会是软肋。

输出形态：
- 一个按功耗影响排序的**热点清单**，每条热点连到 `(模块, 信号, RTL 源码行)`；
- 每条热点附带**触发它的维度**与**具体的 RTL 改写建议**（加 clock gating、operand isolation、收窄位宽等）；
- 一个可选的全设计 / 逐模块 **功耗健康评分**。

---

## 2. 为什么 activity 是 RTL 层唯一正确的功耗量

数字电路动态功耗的一阶模型：

```
P_dyn ≈ α · C · V² · f
```

其中 `C`（电容 / 负载）、`V`（电压）、`f`（频率）**全部依赖工艺库与门级网表**，在 RTL 阶段根本不可得。任何号称从纯 RTL 直接给出瓦特数的工具，本质上都在对这些量拍脑袋。

但其中的 `α`——**switching / toggle activity（翻转活动率）**——是 RTL 阶段**唯一真正可控、且与工艺无关**的量。它也恰好是设计者在 RTL 上能直接影响的旋钮（少翻转 = 少动态功耗）。

因此本工具的方法学根基是：

> **以 activity 为核心代理量，产出相对功耗排序与结构性改进建议；绝对功耗交给下游的门级 / 物理签核工具。**

这与工业界 RTL 功耗早期评估（power-aware RTL）的通行做法一致：在 RTL 阶段用活动量驱动相对优化，而非追求绝对精度。

---

## 3. 信任基础：被等价性验证背书的活动量

这是本方法学相对于普通未验证快速模型的**核心优势**，但它不是对任意用户 RTL 的形式证明。

`prism_v2sc` 的等价性 CI（`tests/equivalence/run_equivalence.py`，见 `docs/correctness_strategy.md` 的 "Golden Loop"）对已注册 fixtures 覆盖的支持面证明：**生成的 SystemC 与原始 RTL 在采样点输出一致**。由此可以推出一条强结论：

> 功能逐周期等价 ⟹ 所有寄存器 / 状态的逐周期取值序列等价 ⟹ **寄存器 / 状态的翻转活动 = RTL 的真实翻转活动**。

也就是说，本工具采集到的状态活动量**不是纯结构估计**，而是来自经过 trace-equivalence、diagnostic contract 和必要时 real-design keypoint gate 约束过的 generated SystemC 模型。一般 RTL 功耗工具的活动量来自一个未必与 RTL 行为对齐的快速模型；而这里的活动量建立在一个持续回归验证的转换器之上。这一点在方法学层面是决定性的差异。

> 注意边界：上述结论只覆盖当前支持面、已验证 fixtures 和用户实际通过的转换/验证 gate；它不替代对任意新 RTL 的形式等价。对**周期内的毛刺（glitch）活动不成立**（见 §9）。

---

## 4. "信任模型" vs "使用模型"：生产路径是 SC-only

必须把两件事分开，否则会误以为每次功耗分析都要跑 RTL：

| 活动 | 目的 | 何时发生 | 是否跑 RTL 仿真 |
| --- | --- | --- | --- |
| **等价性验证** | 建立"SC 模型可信"这一信任 | 一次性 / 改了 codegen 时，在 CI 上对**小 fixture** 跑 | 是（iverilog + SystemC 协同仿真） |
| **功耗分析** | *使用*可信模型做活动量采集与诊断 | 每次分析，对**用户的大设计**跑 | **否，SC-only** |

结论：**RTL 协同仿真只属于"信任模型"这一层，不在"使用模型"的热路径上。** 日常功耗分析全程只跑编译后的 SystemC（C++，快），完全不碰 iverilog / RTL。把等价性 CI 当成"模型可信度的体检"偶尔跑即可——它跑的是几个小 fixture，不是用户的大设计。

---

## 5. 活动量采集方法学：in-model instrumentation，而非 VCD

### 5.1 为什么不用 VCD

VCD 波形记录的是 **O(信号数 × 周期数)** 量级的*逐事件波形*。大设计动辄几个 GB，落盘与解析都成为瓶颈。

但功耗诊断**根本不需要波形**，只需要 **O(信号数)** 量级的*聚合统计*（每信号的 toggle 数等）。把"聚合"这一步从"事后解析 VCD"提前到"仿真运行时在线累加"，就把 O(信号×周期) 的波形直接坍缩成 O(信号) 的计数器。

### 5.2 做法：把统计计数器直接插桩进生成的 SystemC

`prism_v2sc` 本身就是 codegen 工具，生成可读的、一模块一 `SC_MODULE` 的 SystemC，内部信号都是 `sc_signal` 成员（且 `SC_MODULE` 展开为 `struct`，成员默认 public，外部可访问）。利用这一点，为每个被监测信号生成：

- 一个 `prev`（上一周期采样值）成员；
- 若干**普通 C++ 计数器**成员（非 `sc_signal`）；
- 一个对**时钟 `posedge` 敏感**的监测 `SC_METHOD`，每个时钟沿执行：

```cpp
auto cur = sig.read();
total_bit_toggles += popcount(prev ^ cur);   // 本周期翻转的 bit 数，累加
if (cur != prev) change_cycles++;            // 值发生变化的周期数
prev = cur;
```

（对宽度 > 64-bit 的信号，`popcount(prev ^ cur)` 按字分块累加。）

这种插桩相对 VCD 的优势：

- **更小**：只存计数器，不存波形——KB~MB 级，而非 GB 级。
- **更快**：无波形 I/O、无格式化——**插桩跑比 VCD 跑更快**，不仅是文件更小。
- **可选择**：只插想看的信号（这是 §6 两级方法学的前提）。
- **不扰动功能**：监测方法**只读 `sc_signal`、只写普通成员**，不新增任何 `sc_signal` 的 driver，因此**不可能改变仿真结果**。这一性质可以用等价性 CI 验证（"插桩开 / 关，输出必须一致"）。

### 5.3 clock-boundary sampling：避开 delta-cycle 虚高

生成的组合逻辑是 `sc_signal` + `SC_METHOD`（见 `docs/known_differences.md` 的 "Process Semantics"）。一个时钟周期内，组合节点在多个 `SC_METHOD` 收敛过程中可能被写多次——VCD 会把这些**收敛中间态**也记成翻转，导致组合活动量系统性虚高。

方法学规定：**只在时钟边界（`posedge` 后稳定时）采样**，对相邻周期的稳定值做比较。这样得到的就是与 RTL 一致的*功能翻转*，自动滤掉 delta-cycle 噪声。现有等价性 harness 对输出的采样也正是这种"稳定后采样"（驱动于 `negedge`、采样于 `posedge` 之后），方法论现成。

- 纯组合模块（无时钟）：由 testbench 在每个输入向量施加并稳定后，打一个 **sample strobe** 触发采样。
- 多时钟域：各信号按其所属时钟域的边界采样。`prism_v2sc` 的 lowerer 已识别 `posedge` / `negedge`（记录在 `ProcessIR` 的 sensitivity 中），可据此确定时钟。

### 5.4 与 SAIF 的关系

工业界标准的活动量交换格式是 **SAIF（Switching Activity Interchange Format）**，它逐信号记录 toggle count（TC）与高 / 低电平占空（T1 / T0 等）。常规流程是 `仿真 → VCD → vcd2saif → 功耗工具`。

本方法学的 in-model 计数器本质上是**在线计算 SAIF 等价的活动统计**：`total_bit_toggles` 对应 TC；`change_cycles / sample_count` 与"值变化频度"对应活动占比；如需要，可再加"高电平周期数"对应 T1 占空。也就是说，我们用一步插桩仿真**替代了 `仿真 → VCD → SAIF` 的整条管线**，且产物可直接喂给打分器。

### 5.5 层级汇总与合成信号归因

- 计数器挂在**每个 module 实例**上。因为 `prism_v2sc` 实例化了真实层级，逐实例 / 逐模块 / 全设计的活动量**自动**得到（可直接说"`u_alu.u_add` 占全设计翻转的 40%"）。
- codegen 会引入 `__next_*` / `__shadow_*` 等**合成信号**（多写者聚合、staging 等，见 `codegen/systemc.py`）。活动量归因时必须**映射回原始 RTL 信号名、跳过合成信号**，否则统计与反标都会错位。

### 5.6 度量的物理含义

`popcount(prev ^ cur)` 逐周期累加 = 该信号的**总 bit 翻转数**，正是门级功耗工具所累计的 toggle count（差一个电容权重 `C_i`，而 `C_i` 在 RTL 不可得）。可用信号**位宽**作为电容的粗代理，对 toggle 数加权，得到 activity-weighted 的动态功耗代理。这与标准实践一脉相承，只是把权重显式标注为"代理"。

---

## 6. 两级方法学：静态预筛 → 选择性插桩 → 实测确认

全设计无差别插桩虽可行，但开销与产物随设计规模线性增长。更好的方法学是**两级筛选**：

1. **静态预筛（IR-only，零仿真）**
   直接在 IR 上挑出**结构性嫌疑**并排序（规则见 §7）。这一步不需要任何工具链、不需要仿真，能在纯 Python 下完成，本身就能产出第一版"可疑语句"清单。

2. **选择性插桩**
   codegen **只对嫌疑信号**生成监测器 → 插桩开销正比于*嫌疑数*，而非*全设计信号数*。

3. **实测确认（SC-only）**
   跑用户激励 → 计数器确认哪些嫌疑在该负载下**真的热**，给出量化排序。

4. **反标**
   把确认的热点连回 RTL 源码行（见 §8）。

### 6.1 盲区控制（关键）

只插"静态嫌疑"会漏掉"静态没看出来、但负载下真的热"的信号（**假阴性**）。方法学对策：

> **所有状态寄存器默认全插**（数量有界、是动态功耗骨干、且活动量被等价性背书），**只有组合节点才走选择性插桩**。

这样把盲区严格框定在"组合逻辑里静态规则没标到的那一小块"，而非整个设计。

### 6.2 彻底审计时的两遍法

需要高覆盖时采用 profiler 式的"先广采样、再聚焦"：

- **第一遍**：全设计**粗粒度**（每信号仅 1 个 total toggle 计数器，极廉价）→ 找出 top-K；
- **第二遍**：只对 top-K 上**细粒度**（逐 bit、带条件）插桩。

全程不碰 VCD。

### 6.3 零仿真档（可选，进阶）

在还没有激励、或想先扫一眼时，可对输入假设翻转概率，沿依赖图传播，估算每个节点的 **transition density**（Najm 的概率活动估计方法学）。完全不跑仿真即可给出一版活动估计，精度低于真实激励，作为"第三档"补充，而非核心。

---

## 7. 静态分析方法学：怎么从 IR 预判热点

`prism_v2sc` 的 IR 把表达式表示成**结构化的树**（`identifier / binop / unop / cond / concat / repeat / bitselect / partselect / ...`，schema 见 `codegen/expr.py` 顶部），这对静态结构分析非常友好。

当前实现的基础设施：

- **信号依赖图 / 扇入扇出**：`analysis/dependencies.py` 遍历表达式树与过程语句，建立"谁驱动谁"的有向图；`analysis/sensitivity.py` 给状态信号做 clock-domain 归属。
- **表达式复杂度 / 深度指标**：`analysis/expression_metrics.py` 从表达式树直接得到节点数、深度和操作符族统计。
- **Probe planning 与合成名过滤**：`analysis/probe_planning.py` 选择 state / comb / memory / port probes，并过滤 `__next_*`、`__shadow_*` 和 bridge 类实现细节。

在此之上的启发式规则（每条都对应一类真实功耗问题与一种 RTL 改法）：

| 静态规则 | 检测什么（IR 信号） | 对应功耗问题 | RTL 改法 |
| --- | --- | --- | --- |
| 无 `enable` 守护的宽寄存器 | `always_ff` 中对某宽 `reg` 的赋值是无条件的（或仅 reset 守护） | 时钟每周期翻动该 flop，但数据未必变 → 浪费时钟与 flop 功耗 | 加 clock gating / load-enable（**头号候选**） |
| 计数器 | `reg <= reg + const` 形态 | 每周期翻转，低位翻得最凶 | 评估是否需要持续计数 / gating |
| 宽 mux / 宽 case | `cond` / `case` 选择宽数据 | 大量组合切换 | 减少选择宽度 / 分级 |
| 高扇出网络 | 依赖图中出度高的信号 | 高负载（C 代理大） | 拆分 / buffer / 复用 |
| 深组合链 | 依赖图中长链 + 重收敛扇出 | 时延 + glitch 风险 | 切流水 / 平衡逻辑 |
| 明显过宽的信号 | 声明位宽 ≫ 实际取值范围 | 多余 bit 持续参与运算 | 收窄位宽 |

静态结果有两个用途：**(a)** 作为选择性插桩的嫌疑列表；**(b)** 作为多维打分中的"结构维度"，并解释*为什么*某处结构上有风险（与"实测维度"互补：静态解释 why，实测确认 whether/how much）。

---

## 8. 反标方法学：把热点连回 RTL 源码

| 反标粒度 | 现状 | 方法 |
| --- | --- | --- |
| 模块级 | **已可** | 每个 `ModuleIR` 带 `source_path` |
| 信号级 | **已可** | `SignalIR` / `PortIR` 带可选 `loc`，并可按名映射到声明 |
| **语句 / 行级** | **已接入** | `ContinuousAssignIR`、`ProcessIR` 和结构化 statement dict 带可选 `loc`；覆盖取决于 slang 是否能提供对应 source range |

行级反标是"指出 RTL 内可疑语句"这句话能否兑现的**命门**。当前 IR 已把 slang `sourceRange` 中的 `(file, line, col)` 作为可选 `loc` 接到声明、连续赋值、过程和结构化语句上。它是 best-effort：不是每个表达式节点都保证有独立位置，但热点至少可以稳定落到模块、信号和主要驱动语句。

方法学：

- 在 lowering 阶段，从 slang 的 `syntax.sourceRange.start` 取出 `(file, line, col)`，作为可选的 `loc` 字段挂到语句 / 信号 IR 节点上。数据 slang 已提供，属于"把已有信息接出来"。
- 反标时，热点的 `sc_signal` 名先**映射回原始 RTL 信号名**（跳过 §5.5 的合成信号），再经 `loc` 定位到源码行。
- 最终每条热点输出：`(模块, 信号, 源码行) + 触发维度 + 量化活动 + 建议`。

---

## 9. 多维打分方法学

把**实测活动**与**静态结构**结合成多个维度，逐信号 / 逐寄存器 / 逐模块 / 全设计聚合：

| 维度 | 数据来源 | 度量 | 对应建议 |
| --- | --- | --- | --- |
| **Toggle activity**（动态功耗主项） | 实测 | `total_bit_toggles`（×位宽权重） | 高活动热点 |
| **Clock-gating 机会** | 实测 + IR | 寄存器 idle 占比 `1 − change_cycles/sample_count` 高、且无 enable 守护 | 加 clock gating |
| **Operand-isolation 机会** | 实测 + 依赖图 | 组合锥每周期切换，但其结果寄存器常被 disable（结果被丢弃） | 用 enable 隔离操作数 |
| **位宽利用率** | 实测（逐 bit） | 高位 bit 在负载下从不翻转 | 收窄位宽（需对全范围复核） |
| **结构复杂度 / 扇出**（C 代理） | 静态 IR | 表达式树规模 + 依赖图扇出 | 拆分 / 复用 |
| **Glitch 风险** | 静态 IR | 组合深度 + 重收敛扇出 | 标注风险（**非实测**，见 §10） |
| **存储活动** | 实测 | 逐 cell 读写活动（memory 是 per-cell `sc_signal`，可观测） | memory 划分 / gating |

打分聚合方法学：

- 每个维度在**全设计内做百分位 / z-score 归一化** → 0–100，避免量纲不可比；
- 加权汇总成"功耗健康分"，并产出**按影响排序的热点清单**；
- 权重可配置（不同设计 / 关注点权重不同）。

> **工作负载相关性（必须声明）**：功耗高度依赖激励。同一 RTL 在不同 workload 下活动差异巨大。因此**激励是一等输入**，工具应支持多 workload 分别报告与对比；任何活动类结论都**只在所给激励下成立**。

---

## 10. 边界与诚实声明（Out of Scope）

方法学的诚实边界必须写明，避免越界解读：

- **不做 absolute watts**：`C / V / f` 需要工艺库 / 门级网表，RTL 不可得。本工具只给相对排序与结构建议。
- **Glitch / 竞争功耗系统性不可见**：`SC_METHOD` + `__next_` staging 抹平了周期内的毛刺（见 `docs/known_differences.md`）。本工具**不假装能测毛刺功耗**，改用静态 **glitch-risk 代理**（§7 / §9），并明确标注为"结构风险，非实测"。
- **不覆盖物理量**：时钟树功耗、互连功耗、leakage 的物理估计均超出 RTL 抽象层。leakage 至多用面积 / 门数粗代理。
- **覆盖面受限于 prism 可转换的 RTL 子集**：不支持的构造已由 `prism_v2sc` 以 diagnostics 形式暴露；对这类模块，诊断退化为 **static-only**（无实测活动）。
- **结论的工作负载相关性**：见 §9。

---

## 11. 与现有文档的关系

- `docs/correctness_strategy.md` —— 等价性 CI 是本方法学 §3"活动量可信"的**唯一来源**；没有它，活动量就只是又一个未经验证的估计。
- `docs/known_differences.md` —— 生成 SystemC 的近似语义（`SC_METHOD` 调度、`__next_` staging、X/Z 近似）**直接决定了本工具能测什么、不能测什么**（§5.3 的 delta-cycle、§10 的 glitch 不可见均源于此）。
- `analysis/` —— 静态分析（依赖图、扇入扇出、结构规则）、probe planning 和合成名过滤的落点；`drivers.py` 提供同源风格参考。
