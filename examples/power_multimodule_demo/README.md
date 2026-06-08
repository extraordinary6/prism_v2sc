# 多模块功耗诊断 Demo

这个示例展示 `prism_v2sc` 如何处理由 `.f` filelist 驱动的多文件、多模块 RTL 设计，并给出静态诊断、插桩 SystemC、profile JSON 和 power report 的完整示例产物。

## 目录结构

```text
power_multimodule_demo/
|-- rtl/
|   |-- sources.f
|   |-- include/power_defs.vh
|   |-- control/control_sequencer.v
|   |-- datapath/reg_bank.v
|   |-- datapath/vector_alu.v
|   |-- datapath/wide_crossbar.v
|   |-- datapath/wide_accumulator.v
|   `-- top/power_soc_top.v
`-- generated/
    |-- power_static.json
    |-- probe_manifest_all.json
    |-- power_profile_synthetic.json
    |-- power_report_synthetic.json
    `-- systemc_all/
```

`rtl/` 是原始 RTL。`generated/` 是已经生成好的演示产物，方便直接查看功耗诊断输出和插桩后的 SystemC 代码。

## 设计内容

顶层模块是 `power_soc_top`，通过 `rtl/sources.f` 引入所有子模块：

- `control_sequencer`：控制状态、选择信号和包计数器。
- `reg_bank`：4 路 64-bit 寄存器组，其中 `q0` 故意无 enable 更新。
- `wide_crossbar`：64-bit 4:1 宽 mux。
- `vector_alu`：较深的组合表达式，用于触发结构性 glitch 风险诊断。
- `wide_accumulator`：64-bit 累加器，用于触发宽寄存器和计数/活动类热点。

这个 RTL 里刻意放了几类功耗嫌疑：宽寄存器、宽 mux、深组合逻辑、计数器模式和高扇出控制信号。

## 复现静态功耗诊断

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --power-static `
  --power-static-output examples\power_multimodule_demo\generated\power_static.json
```

当前 `power_static.json` 会分析 6 个从 `power_soc_top` 可达的模块，并报告 12 条静态功耗嫌疑：

```text
clock_gating_candidate: 5
counter_activity_candidate: 1
glitch_risk_structural: 4
high_fanout_candidate: 1
wide_mux_candidate: 1
```

## 复现插桩 SystemC 生成

```powershell
python -m prism_v2sc --top power_soc_top `
  --filelist examples\power_multimodule_demo\rtl\sources.f `
  --out examples\power_multimodule_demo\generated\systemc_all `
  --power-instrument examples\power_multimodule_demo\generated\probe_manifest_all.json `
  --power-all-signals `
  --power-deep-profile
```

这个命令会生成：

- `generated/systemc_all/**/*.hpp`：插桩后的多模块 SystemC header。
- `generated/probe_manifest_all.json`：probe manifest，当前包含 34 个 probe，其中 9 个 state probe、25 个 comb probe。

生成的 `top/power_soc_top.hpp` 已经包含自动递归 dump 逻辑。真实 workload 结束后只需要调用顶层：

```cpp
std::ofstream csv("build/power_dump.csv");
dut.prism_power_dump(csv);
```

顶层会递归 dump `u_ctrl`、`u_regs`、`u_xbar`、`u_alu` 和 `u_accum` 的 counters，并且只写一次 CSV header。CSV 里会同时包含 `module` 和 `instance_path`。

如果顶层 header 暴露 `__power_sample_strobe`，workload 需要绑定它并在组合 probe 的采样点 pulse 一次；生成的父模块会自动把 strobe 接到需要它的子模块。

## 从真实 workload 得到 power report

真实流程是：

1. 用上面的命令生成 `power_static.json` 和插桩 SystemC。
2. 在有 SystemC 的环境里编译 `generated/systemc_all/`，运行真实 workload/testbench。
3. workload 结束时调用 `dut.prism_power_dump(csv)` 生成 `power_dump.csv`。
4. 用 CLI 把 CSV 转成 `power_profile.json`。
5. 用 `--power-report` 生成最终报告。

CSV 转 profile：

```powershell
python -m prism_v2sc --power-profile-dump build\power_dump.csv `
  --power-profile-output build\power_profile.json `
  --power-workload-name real_vectors `
  --power-workload-cycles 1000 `
  --power-profile-top power_soc_top `
  --power-profile-source examples/power_multimodule_demo/rtl/sources.f `
  --power-vector-file vectors/real_vectors.txt `
  --power-reset-cycles 5
```

生成 power report：

```powershell
python -m prism_v2sc --power-report build\power_profile.json `
  --power-report-static examples\power_multimodule_demo\generated\power_static.json `
  --power-report-output build\power_report.json
```

## 关于 synthetic 报告

`generated/power_profile_synthetic.json` 和 `generated/power_report_synthetic.json` 是演示用 synthetic profile/report，用于展示 JSON 格式、热点排序、`instance_path` 和静态/动态信息合并后的报告形态。

它们不是从真实 SystemC workload 采样得到的结果，不能作为实际功耗结论。真实结论必须来自你自己的 workload 产生的 `power_dump.csv`。

本地没有 SystemC 库时，可以复现静态诊断、插桩代码生成和 CSV/profile/report 的 Python 侧处理；SystemC 编译运行路径由 Linux CI 覆盖。
