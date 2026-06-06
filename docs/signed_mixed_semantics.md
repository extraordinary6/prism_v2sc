# Signed / Unsigned 混合语义边界

本文说明 `prism_v2sc` 对 Verilog/SystemVerilog `signed` 的支持边界，重点是 mixed signed/unsigned 表达式。这里的风险通常不是“语法不能解析”，而是“RTL 能转换成 SystemC，但隐式 signedness / width / context sizing 语义不一定和 SystemVerilog 完全等价”。

## 当前可靠支持

当前工具已经覆盖这些 signed 场景：

- `input wire signed [7:0] a`、`reg signed [8:0] acc` 等 signed 端口/信号会降低为 `sc_int<W>`。
- unsigned 1-bit 端口/信号仍使用 `bool`；signed 1-bit 不再退化成 `bool`，而是 `sc_int<1>`。
- signed based literal，例如 `8'shFF`，IR 保留原始 bit pattern `value=255`，同时记录 signed 解释 `signed_value=-1`。
- `$signed(x)` / `$unsigned(x)` 和显式 SV cast `signed'(x)` / `unsigned'(x)` 会生成真实的 `sc_int<W>(...)` / `sc_uint<W>(...)` cast。
- equivalence harness 已支持 signed 端口，并有 `signed_declared_arith` fixture 覆盖 signed 声明、signed 比较、算术右移和 signed literal。

## 不完整支持的地方

SystemVerilog 的表达式类型规则是上下文相关的。一个表达式的结果宽度和 signedness 可能由操作数、目标赋值类型、运算符种类、literal 种类共同决定。当前 `prism_v2sc` 还没有对所有中间表达式做完整的 SV signedness / width 传播，所以 mixed signed/unsigned 的隐式写法需要谨慎。

推荐原则：**在 signed/unsigned 边界显式 cast，并把扩展位宽写清楚。**

## 例 1：signed 和 unsigned 混合比较

风险写法：

```verilog
module mixed_cmp(
  input  wire signed [7:0] s,
  input  wire        [7:0] u,
  output wire              lt
);
  assign lt = s < u;
endmodule
```

这个表达式的语义容易和直觉不一致。比如 `s = -1`、`u = 1` 时，如果比较按 unsigned 解释，`s` 的 bit pattern 是 `8'hFF`，会被当成 255，比较结果就是 `255 < 1 == 0`。

如果想做“数学意义上的有符号比较”，推荐写成：

```verilog
wire signed [8:0] s_ext = s;
wire signed [8:0] u_ext = $signed({1'b0, u});

assign lt = s_ext < u_ext;
```

这里 `{1'b0, u}` 明确把 unsigned 值零扩展到 9 位，再 cast 成 signed。不要直接写 `$signed(u)`，因为当 `u[7] == 1` 时它会把 `u` 解释成负数。

如果想做 unsigned bit-pattern 比较，推荐写成：

```verilog
assign lt = $unsigned(s) < u;
```

## 例 2：signed 和 unsigned 混合加法

风险写法：

```verilog
module mixed_add(
  input  wire signed [7:0] s,
  input  wire        [7:0] u,
  output wire signed [8:0] y
);
  assign y = s + u;
endmodule
```

这里 `s + u` 的中间结果 signedness 和 width 不能简单理解成“因为 `y` 是 signed，所以 RHS 就是 signed”。不同工具会按 SV 规则对操作数扩展和结果类型做推导。

推荐写成：

```verilog
wire signed [8:0] s_ext = s;
wire signed [8:0] u_ext = $signed({1'b0, u});

assign y = s_ext + u_ext;
```

这样 SystemC 端会更接近设计意图：两个操作数都是同宽 signed 值。

## 例 3：part-select 后继续当 signed 使用

风险写法：

```verilog
module part_signed(
  input  wire signed [15:0] s,
  input  wire        [2:0]  sh,
  output wire signed [7:0]  y
);
  assign y = s[7:0] >>> sh;
endmodule
```

在 SystemVerilog 中，part-select / bit-select 的 signedness 通常不会自动继承原始 signed 变量。`s[7:0]` 可能按 unsigned 子表达式参与后续运算，导致 `>>>` 不按预期做符号扩展。

推荐写成：

```verilog
assign y = $signed(s[7:0]) >>> sh;
```

如果还需要固定宽度，也可以先声明中间信号：

```verilog
wire signed [7:0] lo = s[7:0];
assign y = lo >>> sh;
```

## 例 4：三目表达式两边 signedness 不一致

风险写法：

```verilog
module mixed_cond(
  input  wire              sel,
  input  wire signed [7:0] s,
  input  wire        [7:0] u,
  output wire signed [8:0] y
);
  assign y = sel ? s : u;
endmodule
```

`?:` 的结果类型也需要按 SV 规则推导。两边一个 signed、一个 unsigned 时，隐式结果类型不应靠工具猜。

推荐写成：

```verilog
wire signed [8:0] s_ext = s;
wire signed [8:0] u_ext = $signed({1'b0, u});

assign y = sel ? s_ext : u_ext;
```

## 例 5：unsized literal 参与 mixed 表达式

风险写法：

```verilog
module unsized_lit(
  input  wire signed [7:0] s,
  output wire signed [8:0] y
);
  assign y = s + 1;
endmodule
```

unsized decimal literal 在 SV 中有默认宽度和 signedness，和 `8'd1`、`8'sd1`、`9'sd1` 的语义不完全相同。对于转换器，显式写出宽度和 signedness 更稳。

推荐写成：

```verilog
assign y = $signed({s[7], s}) + 9'sd1;
```

或者使用中间信号：

```verilog
wire signed [8:0] s_ext = s;
assign y = s_ext + 9'sd1;
```

## 什么时候需要改 RTL

如果 signed/unsigned 混合表达式只出现在非关键路径，且已经被现有 equivalence fixture 覆盖，风险较低。但遇到以下情况，建议显式改写：

- signed 和 unsigned 变量直接比较。
- signed 和 unsigned 变量直接加减乘。
- 对 signed 变量做 part-select 后继续右移或比较。
- `?:` 两个分支 signedness 不一致。
- unsized literal 和 signed/unsigned mixed 表达式混用。

## 推荐检查方式

1. 优先使用 `$signed(...)` / `$unsigned(...)` 或 `signed'(...)` / `unsigned'(...)` 表达意图。
2. 对 mixed 算术先扩展到同一宽度，再运算。
3. 新增 RTL 风格进入项目时，给 `tests/equivalence/fixtures/` 增加最小 fixture。
4. 本地无 SystemC 头文件时，先跑 `tests/equivalence/run_equivalence.py --dry-run --keep-going`；完整 RTL/SystemC trace diff 依赖 CI。

