# prism_v2sc Plan

## 1. 目标与判断

`prism_v2sc` 的目标是把现有 RTL Verilog 代码转换成更高层次、层次化的 SystemC 模型。与 Verilator 的周期精确、全局 flatten/unroll 模型不同，本项目优先追求：

- 低内存占用：避免全设计一次性 elaboration、flatten 和 unroll。
- 层次保留：每个 Verilog module 生成独立 `sc_module`。
- 可读可改：生成的 SystemC 尽量接近源 RTL 的模块边界和控制结构。
- 可验证近似：先实现可运行、可对照的近似周期精确模型，重点保证主要状态转移和端口行为合理，而不是追求 Verilator 级 cycle-by-cycle 完全一致。
- 长期兼容仿真模型：最终希望能解析工艺厂、IP 厂商提供的 Verilog 仿真模型，例如 memory compiler 生成的模型；但这类代码通常不是 RTL，早期不进入 MVP。

总体判断：这个思路可行，但不应把目标定成完全替代 Verilator 的 cycle-accurate 仿真语义。更合理的定位是“层次化 RTL-to-SystemC 近似建模器”，先覆盖可综合 Verilog 子集，并通过差分测试和静态诊断明确支持边界。核心难点不在 AST 打印，而在 Verilog 事件调度、非阻塞赋值、四值逻辑、宽度推导、参数展开、generate 展开和跨模块 elaboration 的语义取舍。

对 TSMC 28nm memory compiler 等工艺厂仿真模型，需要单独看待。它们往往包含 `initial`、`delay`、`specify`、`notifier`、timing check、`force/release`、`$display/$finish/$setuphold` 等仿真专用语句，本质上不是可综合 RTL。把这类模型转换成高层次 SystemC 是长期目标，但不应阻塞第一阶段。合理路径是先支持 RTL 子集，再增加“仿真模型兼容层”：能解析、分类、保留黑盒接口、跳过 timing-only 语句，并为 memory/PLL/IO 等常见 macro 提供行为级 SystemC 替代模型。

## 2. 可行性评估

### 2.1 可行部分

Pyverilog 可以解析 Verilog 并提供 AST，适合做第一版转换前端。对常见可综合 RTL 子集，可以映射到 SystemC：

- `module` -> `SC_MODULE` / `sc_module`
- `input/output/inout` -> `sc_in` / `sc_out` / 后续限制性支持 `sc_inout`
- `wire/reg/logic` -> `sc_signal`、局部变量或状态成员
- `assign` -> `SC_METHOD` 组合逻辑或直接连接
- `always @(posedge clk)` -> `SC_METHOD` + `sensitive << clk.pos()` 或 `SC_CTHREAD`
- `always @(*)` -> `SC_METHOD` 组合逻辑
- 阻塞赋值 `=` -> 组合过程内临时变量或直接赋值
- 非阻塞赋值 `<=` -> next-state 暂存，再在时钟边沿提交
- module instance -> 子 `sc_module` 成员和端口绑定

只要第一阶段限制输入 RTL 为常见可综合风格，项目可以较快做出可用 MVP。

### 2.2 不应低估的部分

以下问题决定了模型是否能稳定做到“近似周期精确”，而不是在常见 RTL 上产生明显错误行为：

- Verilog event scheduling：同一时刻 active/NBA/update 区域的顺序在 SystemC 中不能直接靠简单 C++ 赋值表达；第一版只需要保留常见同步 RTL 的近似行为。
- 非阻塞赋值批量提交：同一个 always block 或多个 always block 对状态的并发更新需要统一 next-state 语义；如果不追求严格周期精确，可以先对复杂多进程交互给出诊断或保守降级。
- 组合逻辑收敛：`always @(*)`、连续赋值和模块间信号可能形成组合链甚至组合环。
- 位宽和符号规则：Verilog 的 unsized constant、signed cast、part-select、concat、replicate 容易和 C++/SystemC 默认规则不一致。
- 四值逻辑：SystemC `sc_logic`/`sc_lv` 可表达 X/Z，但性能和代码复杂度较高；`sc_uint`/`sc_bv` 更快但会丢失 X/Z。
- 参数化与 generate：不做 elaboration 就很难生成确定结构；全局 flatten 不需要，但每个模块局部 elaboration 基本不可避免。
- 多文件宏和 include：Pyverilog 前端依赖预处理流程，宏条件会影响 AST。
- SystemVerilog 支持有限：Pyverilog 主要面向 Verilog，若输入大量使用 SV，需要前置降级、Slang/UHDM 或 Surelog 支持。

结论：轻量级、层次化转换可行；完全语义等价很难。项目应明确支持子集，用验证闭环逐步扩大覆盖。

## 3. 建议架构

### 3.1 Pipeline

```text
Verilog files
  -> Preprocess
  -> Parse AST with Pyverilog
  -> Module index
  -> Per-module IR
  -> Local elaboration
  -> SystemC codegen
  -> Build + differential tests
```

### 3.2 关键原则

- 保留模块层次，不做全局 flatten。
- 允许局部 elaboration：参数替换、generate 展开、端口方向解析必须在 module 级完成。
- AST 不长期驻留全设计：先建立轻量 module index，再按 module 转换和释放中间结构。
- 中间 IR 不应照搬 Pyverilog AST：需要抽象出信号、端口、过程块、连续赋值、实例、表达式宽度等信息。
- 先支持二值快速模式：默认生成 `sc_uint`/`sc_int`/`bool`，后续增加四值 `sc_lv` 模式。

### 3.3 推荐目录

```text
prism_v2sc/
  pyproject.toml
  README.md
  plan.md
  src/prism_v2sc/
    __init__.py
    cli.py
    frontend/
      preprocess.py
      pyverilog_parser.py
      module_index.py
    ir/
      model.py
      widths.py
      expressions.py
    analysis/
      sensitivity.py
      drivers.py
      dependencies.py
    codegen/
      systemc.py
      templates/
    verify/
      harness.py
  tests/
    rtl/
    expected/
    test_codegen.py
```

## 4. 转换语义设计

### 4.1 模块映射

每个 Verilog module 生成一个独立 SystemC 类：

```cpp
SC_MODULE(foo) {
  sc_in<bool> clk;
  sc_in<bool> rst_n;
  sc_in<sc_uint<8>> a;
  sc_out<sc_uint<8>> y;

  sc_signal<sc_uint<8>> internal;

  void comb();
  void seq();

  SC_CTOR(foo) {
    SC_METHOD(comb);
    sensitive << a << internal;

    SC_METHOD(seq);
    sensitive << clk.pos();
  }
};
```

生成策略上优先使用 `SC_METHOD`，因为它更接近 RTL always block，并且易于组合多个敏感信号。时序逻辑可以先用 `SC_METHOD` + `clk.pos()`，后续再评估 `SC_CTHREAD` 是否更适合 reset 语义。

### 4.2 组合逻辑

`always @(*)` 和 `assign` 转成组合 `SC_METHOD`。需要注意：

- 方法开头给所有输出/临时 next 值默认赋值，避免 latch 被错误生成或遗漏。
- 阻塞赋值按顺序生成 C++ 语句。
- if/case/for 可按结构化 C++ 输出。
- 不支持或检测组合环，至少要给出诊断。

### 4.3 时序逻辑

`always @(posedge clk)` 转成时钟敏感方法。推荐第一版采用 next-state 暂存：

- 对每个寄存器声明当前值 signal/member。
- 在时序方法内计算局部 `next_*`。
- 方法末尾统一写回。
- 非阻塞赋值写 `next_*`，阻塞赋值写局部变量或直接更新过程内临时值。

多个 always block 写同一寄存器应报错或降级为保守模式。RTL 合法性检查应尽早发现多驱动、混合阻塞/非阻塞等风险。

### 4.4 表达式与位宽

必须单独实现宽度推导，不能依赖 C++ 默认整数规则。第一版至少支持：

- 常量：based/unsized decimal/binary/hex
- 标识符
- unary/binary operator
- part-select/index
- concat/replicate
- conditional operator
- signed/unsigned 基础传播

生成 SystemC 表达式时优先显式 cast：

- `sc_uint<N>` 用于无符号二值信号。
- `sc_int<N>` 用于 signed 信号。
- `.range(hi, lo)` 处理 part-select。
- concat 需要 helper 或逐步拼接。

### 4.5 参数和 generate

不建议跳过 elaboration。可采取“模块局部 elaboration”：

- 解析 `parameter/localparam`。
- 实例化时用参数覆盖生成 module specialization key。
- `generate for/if/case` 在当前模块上下文中展开。
- 输出文件名可带参数签名，避免同名 module 不同参数冲突。

第一版可以先支持简单常量 parameter 和 generate-for，复杂表达式报错。

## 5. 流式与内存策略

Pyverilog 本身通常会一次解析输入文件集合，无法天然做到真正 token-level streaming。因此项目的“流式”应定义为转换阶段的流式，而不是前端解析阶段完全流式：

- 预处理阶段按文件处理 include/macro，避免手工拼接巨大中间文件。
- 解析后只保留 module definition 的轻量索引。
- 按拓扑顺序或用户指定 top，自顶向下逐模块转换。
- 每个模块转换完成后释放 IR 和代码生成临时对象。
- 不做全局 netlist flatten，不展开所有实例树成一个大图。

如果 Pyverilog 解析阶段仍成为瓶颈，可以预留替代前端：

- Surelog/UHDM：更强 SystemVerilog 支持，但集成复杂。
- Slang：现代 SV 前端，适合后续扩展。
- tree-sitter-verilog：适合轻量解析，但语义分析需自建。

## 6. MVP 范围

第一版应聚焦“可综合 Verilog-2005 小子集”：

支持：

- module/port/wire/reg/parameter/localparam
- continuous assign
- always @(*)
- always @(posedge clk) 和可选 async reset
- if/case/for
- arithmetic/bitwise/logical/compare/shift
- part-select、bit-select、concat、replicate
- module instantiation
- 简单 generate-for

暂不支持或只诊断：

- UDP、specify、primitive gate delay
- force/release、initial 仿真激励语义
- real/time、event、fork/join
- tri-state/inout 完整总线解析
- 四值 X/Z 精确传播
- SystemVerilog class/interface/package/assertion
- 任意动态数组或复杂 SV 类型
- 工艺厂或 IP 厂商仿真模型中的 timing check、notifier、path delay、`celldefine` 模型行为

这些暂不支持项不是永久排除项。其中工艺厂仿真模型应作为后期专项阶段处理，而不是混入 RTL MVP。

## 6.1 长期目标：仿真模型兼容层

工艺厂 memory compiler、standard cell library、IO pad、PLL 等 Verilog 仿真模型通常服务于事件驱动仿真器，而不是综合或高层建模。对这类模型，推荐目标不是逐句等价转换，而是分层处理：

- Parser compatibility：前端能解析或容忍仿真模型语法，至少不因 timing-only 结构直接崩溃。
- Classification：识别模型类型，例如 memory macro、standard cell、pad、PLL、blackbox。
- Interface extraction：抽取 module 名称、parameter、端口方向、位宽，生成 SystemC wrapper。
- Behavior replacement：对 memory macro 等常见模型生成行为级 SystemC 替代实现，而不是翻译其全部仿真语句。
- Timing stripping：对 `specify`、path delay、`$setuphold`、notifier 等 timing-only 内容默认剥离或记录为注释。
- Diagnostic retention：保留被忽略语句清单，避免用户误以为模型已完整等价转换。

建议后期按模型类别推进，而不是一次性支持所有不可综合语法：

1. Memory macro：优先级最高，支持同步读写、byte enable、chip enable、write mask、read latency 等行为。
2. Simple standard cells：可选，AND/OR/MUX/DFF 等可映射到简单 SystemC 行为。
3. IO pad/PLL/analog-ish macro：优先生成 blackbox wrapper 或用户自定义替代模型。
4. Timing annotation：只保留元数据，不作为默认 SystemC 行为执行。

## 7. 验证策略

项目成败取决于“可解释的近似”和回归验证，而不是单纯代码生成。验证目标不是所有 case 都逐周期完全一致，而是能识别哪些设计在当前语义子集内可近似、哪些需要报错或降级。

### 7.1 单模块 golden tests

为每类语法准备小 RTL：

- 组合 assign
- if/case
- part-select/concat
- 同步寄存器
- 带 reset 的寄存器
- 子模块实例
- parameterized module
- generate-for

每个样例生成 SystemC，编译并跑 testbench。

### 7.2 与参考仿真器对比

建议用 Icarus Verilog 或 Verilator 作为小设计参考：

- 对同一 RTL 生成随机输入。
- 记录关键周期、稳定点或事务边界上的输出。
- SystemC 输出同样 trace。
- 优先比较最终状态、事务结果和关键端口行为；cycle-by-cycle 比较只作为可选严格模式。

注意：Verilator 仅作为验证小样例的参考工具，不作为转换路径，也不作为必须完全一致的语义标准。

### 7.3 语义差异白名单

建立 `unsupported` 和 `known_differences` 机制：

- 遇到不支持语法必须 fail fast。
- 不允许静默生成错误模型。
- 对 X/Z、delay、initial 等差异明确记录。

## 8. 实施里程碑

### Phase 0: 项目骨架

- 建立 Python package、CLI 和测试目录。
- 固定 Python 解释器：`D:\anaconda\envs\pytorch\python.exe`。
- 检查依赖：Pyverilog 当前可用版本为 `1.3.0`。
- CLI 形态：

```powershell
D:\anaconda\envs\pytorch\python.exe -m prism_v2sc --top top --out build/systemc rtl/top.v
```

### Phase 1: AST 探索与 IR

- 用 Pyverilog 解析小 RTL，打印 AST。
- 建立 module index。
- 定义 IR：Module、Port、Signal、Process、Assign、Instance、Expr。
- 实现基本宽度推导。

交付标准：可以把简单 module 解析成稳定 JSON IR。

### Phase 2: 基础 SystemC codegen

- 生成 `.h/.cpp` 或单文件 `.hpp`。
- 支持端口、内部信号、连续赋值、组合 always。
- 支持表达式映射和基础控制流。

交付标准：组合逻辑样例可编译、可跑。

### Phase 3: 时序语义

- 支持 `posedge` always。
- 实现非阻塞赋值 next-state。
- 支持同步/异步 reset 模式识别。
- 检测多驱动寄存器。

交付标准：寄存器、计数器、简单 FSM 的主要状态转移和端口结果与 Verilog 仿真一致；逐周期一致只作为可选增强目标。

### Phase 4: 层次与参数

- 支持 module instantiation。
- 生成层次化 `sc_module` 成员。
- 支持 parameter override。
- 支持简单 generate-for 展开。

交付标准：小型层次化 RTL 可转换并运行。

### Phase 5: 鲁棒性与规模测试

- 加入真实 RTL 子集测试。
- 记录峰值内存和转换时间。
- 与 Verilator 在同设计上的内存占用做对比。
- 完善不支持语法诊断。

交付标准：证明在选定设计上显著降低转换峰值内存，同时输出可验证模型。

## 9. 主要风险与缓解

| 风险 | 影响 | 缓解 |
| --- | --- | --- |
| Pyverilog SV 支持不足 | 大量现代 RTL 无法解析 | MVP 限 Verilog-2005；后续增加 Slang/UHDM 前端 |
| Verilog 调度语义不完整 | 复杂边界条件下结果不一致 | 明确支持子集；实现常见 NBA next-state；对复杂调度给出诊断或降级 |
| 位宽规则错误 | 生成模型隐蔽错误 | 独立宽度推导；大量表达式单测 |
| generate/parameter 复杂 | 层次实例无法确定 | 局部 elaboration；复杂情况 fail fast |
| 四值逻辑缺失 | X/Z 行为不一致 | 默认二值高性能模式；后续四值模式 |
| 工艺厂仿真模型不可综合 | 前端能解析但很难逐句转换 | 后期做仿真模型兼容层；优先抽接口和替换行为，不追求逐句翻译 |
| SystemC 编译链复杂 | 用户难以使用 | 提供最小 CMake/testbench 模板 |
| “流式”受 Pyverilog 限制 | 解析阶段仍耗内存 | 转换阶段流式；预留替代前端 |

## 10. 推荐下一步

先不要从完整 RTL 直接开做。建议按以下顺序推进：

1. 写 8 到 12 个最小 RTL 样例，覆盖 MVP 语法。
2. 实现 `parse -> IR JSON`，先不生成 SystemC。
3. 对 IR 做宽度和 driver 检查。
4. 生成组合逻辑 SystemC。
5. 加入时序 always 和 NBA。
6. 用差分测试和结果检查锁定每次扩展的近似语义边界。

最小可验证目标：

```text
输入：一个带 parameter、组合逻辑、posedge always、子模块实例的小型 Verilog 设计
输出：保留模块层次的 SystemC 工程
验证：随机输入 1000 cycles，关键状态、事务结果和主要端口输出与 Verilog 仿真一致；不强制所有中间周期完全一致
```
