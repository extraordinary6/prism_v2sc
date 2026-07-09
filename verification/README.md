# Verification Plan Workspace

这个目录用于放置比常规 pytest 更深入的正确性验证计划、探索性 RTL
用例和失败分析记录。它刻意独立于 `tests/`，避免尚未稳定的 corner-case
探索污染现有 Python 测试入口。

主要入口：

- `systemc_corner_case_plan.md` - 在本地已有 SystemC 和 VCS 后，继续寻找
  RTL 到 SystemC 转换语义缺口的分阶段计划。

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
