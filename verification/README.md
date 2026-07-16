# Verification Workspace

这个目录用于放置比常规 pytest 更深入的正确性验证计划、探索性 RTL
用例和失败分析记录。它刻意独立于 `tests/`，避免尚未稳定的 corner-case
探索污染现有 Python 测试入口。

主要入口：

- `../docs/rtl_conversion_roadmap.md` - 四阶段能力建设路线、覆盖状态和证据要求。
- `benchmarks.json` / `benchmark_baseline.json` - 真实设计 benchmark 清单和证据基线。
- `cases/conversion/mhsa_icb_smoke.py` - 引用外部 `/home/MicroE/MHSA`
  ICB MHSA 加速器，执行真实设计转换和生成 SystemC 顶层 C++14 编译 smoke。
- `cases/conversion/ofdm_fft_smoke.py` - 引用外部
  `/home/MicroE/ai_proj/Simulation-and-FFT-Implementation-of-OFDM-Communication-System/hardware/src`
  OFDM FFT/IFFT RTL，执行真实设计转换、real 常量 LUT 检查和生成 SystemC
  顶层 C++14 编译 smoke。
- `cases/consistency/mhsa_keypoint_consistency.py` - 引用外部 `/home/MicroE/MHSA`
  运行 RTL(VCS) vs generated SystemC 的关键节点一致性检查；默认覆盖
  `icb_mhsa`、`pe` 和 `scale_core`，不做逐拍全 trace diff。
- `cases/consistency/ofdm_fft_trace_consistency.py` - 引用外部 OFDM FFT/IFFT
  RTL，运行 RTL(VCS) vs generated SystemC 的 sampled per-cycle trace diff；
  默认驱动 9 个确定性 64 点 FFT/IFFT 输入 case，并比较 380 个周期的
  `data_out_valid/re/im` trace。
- `cases/consistency/icb_apb_bridge_consistency.py` - 引用外部带 SystemVerilog
  `interface` 的 ICB-to-APB bridge，在临时目录构造可综合快照和平坦 wrapper，
  保留 DES 功能并忽略 `CHECK`/bind 验证内容；比较 36 个 ICB/APB 事务事件。
- `cases/consistency/tinynpu_consistency.py` - 引用外部
  `/home/MicroE/ai_proj/tinyNPU`，在 4x4 和 8x8 两种阵列配置下运行
  RTL(VCS)、generated SystemC 与独立 Python golden 三方一致性检查；覆盖
  APB、SRAM loader、GEMM、K/N tiling、bias、ReLU、全局/逐通道重定量、
  back-to-back job、OFM 写事件和非法维度错误路径。
- `cases/consistency/dma_e203_consistency.py` - 转换 E203 ICB DMA，并比较配置、memory command/response 和 IRQ 的 45 周期 RTL/SystemC trace；同时输出 RTL 协议风险。
- `cases/consistency/model_memory_provider_consistency.py` - 对内置 memory
  provider 运行 RTL(VCS) vs generated SystemC 契约级差分检查，覆盖同步单口
  memory 的 `read_first`、`write_first` 和 `no_change` 三种同地址写行为。
- `cases/consistency/e203_cpu_consistency.py` - 引用外部
  `/home/MicroE/e203/e203_hbirdv2-master/rtl/e203`，使用固定 filelist 和 model
  manifest 转换 `e203_cpu_top`，一次编译后运行 6 个 RV32 程序场景；比较关键
  PC 首次出现顺序和 10 个 DTCM 结果点，覆盖 ALU/分支、M 扩展、byte/halfword
  访存、CSR 和 timer interrupt trap，不要求逐拍响应完全相同。
- `notes/mhsa_icb_real_design_eval.md` - 记录 MHSA ICB smoke/keypoint 结果、
  已修复的真实设计问题、当前证明范围和后续建议。
- `notes/ofdm_fft_real_design_eval.md` - 记录 OFDM FFT/IFFT smoke 结果、
  real-valued twiddle LUT 修复、trace consistency 结果、当前证明范围和后续建议。
- `notes/icb_apb_bridge_real_design_eval.md` - 记录 interface flatten、DES/FIFO/APB
  一致性结果、修复项和当前证明边界。
- `notes/tinynpu_real_design_eval.md` - 记录 tinyNPU 4x4/8x8 三方一致性结果、
  真实设计暴露的转换器缺陷、warning 分类和当前证明边界。
- `notes/e203_cpu_real_design_eval.md` - 记录 E203 大型层次转换、外部 memory
  provider 契约、6 个 CPU 执行场景、修复项和当前证明边界。

本目录按可综合设计视图工作：assertion/property/sequence、bind 和 UVM/testbench
内容不属于转换目标。用例应只把 RTL design sources 交给 converter；若验证宏与
设计源码共存，真实设计脚本会在临时快照中关闭验证宏，绝不修改外部 RTL。

后续建议布局：

- `cases/trace/` - 预期可以跑 RTL vs generated SystemC trace equivalence 的
  RTL 候选用例。
- `cases/conversion/` - 应该能 clean conversion，但不适合用当前 RTL simulator
  做 golden trace 的用例。
- `cases/diagnostics/` - 应该被明确拒绝或产生 warning/error diagnostic 的用例。
- `notes/` - 需要先分析或做设计决策的失败记录。

当某个用例已经稳定且属于项目承诺支持的范围，把它迁移到
`tests/equivalence/fixtures/`，并在 `tests/equivalence/run_equivalence.py`
注册成正式回归测试。
