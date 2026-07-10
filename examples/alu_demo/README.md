# `alu_demo` — single-file RTL → SystemC walkthrough

A self-contained example: a small 8-bit ALU in synthesizable Verilog, the **exact** SystemC header `prism_v2sc` emits for it, and the one-line command that reproduces the conversion.

The ALU is intentionally compact but exercises most of the non-trivial Verilog constructs the converter supports.

| construct | where it shows up |
| --- | --- |
| `case` statement | `result` always block, 8 ops |
| concatenation `{1'b0, a}` | `add_full` continuous assign |
| bit-select read `add_full[8]` | `carry` always block |
| one always block per output | `result`, `zero`, and `carry` each get their own block |
| equality `==` | `zero` flag and `carry` guard |
| async-reset-free combinational | `always @(*)` throughout |

## Layout

```
examples/alu_demo/
├── alu.v                  # 38-line ALU RTL
├── expected/
│   ├── ir.json            # JSON IR
│   └── alu.hpp            # Generated SystemC header
└── README.md              # This file
```

## RTL

```verilog
module alu (
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire [2:0] op,
  output reg  [7:0] result,
  output reg        zero,
  output reg        carry
);
  wire [8:0] add_full;
  assign add_full = {1'b0, a} + {1'b0, b};

  always @(*) begin
    case (op)
      3'b000:  result = a + b;
      3'b001:  result = a - b;
      3'b010:  result = a & b;
      3'b011:  result = a | b;
      3'b100:  result = a ^ b;
      3'b101:  result = ~a;
      3'b110:  result = a << 1;
      3'b111:  result = a >> 1;
      default: result = 8'h00;
    endcase
  end

  always @(*) begin
    zero = (result == 8'h00);
  end

  always @(*) begin
    if (op == 3'b000) carry = add_full[8];
    else              carry = 1'b0;
  end
endmodule
```

(Full source: [`alu.v`](alu.v).)

## Reproducing the conversion

From the repository root:

```bash
python -m prism_v2sc --top alu --out examples/alu_demo/expected examples/alu_demo/alu.v
```

On Windows / conda:

```powershell
$env:PYTHONPATH = 'src'
D:/anaconda/envs/pytorch/python.exe -m prism_v2sc `
  --top alu --out examples/alu_demo/expected examples/alu_demo/alu.v
```

Two files are written:

- `expected/ir.json` — the JSON IR.
- `expected/alu.hpp` — the per-module SystemC header below.

Single-module design ⇒ flat output, no subdirectory. Re-running the command should produce a byte-identical header — codegen is deterministic.

## Generated SystemC

The full output lives at [`expected/alu.hpp`](expected/alu.hpp). Shape:

```cpp
SC_MODULE(alu) {
  sc_in<sc_uint<8>> a;
  sc_in<sc_uint<8>> b;
  sc_in<sc_uint<3>> op;
  sc_out<sc_uint<8>> result;
  sc_out<bool> zero;
  sc_out<bool> carry;

  sc_signal<sc_uint<9>> add_full;

  void assign_0() {
    // Concatenation lowers to a shift-OR of sc_uint<TOTAL_WIDTH> casts.
    add_full.write((((sc_uint<9>(0b0) << 8) | sc_uint<9>(a.read()))
                  + ((sc_uint<9>(0b0) << 8) | sc_uint<9>(b.read()))));
  }

  void always_comb_0() {
    auto __next_result = result.read();
    switch (op.read()) {
    case 0b000: __next_result = (a.read() + b.read()); break;
    case 0b001: __next_result = (a.read() - b.read()); break;
    // ...
    default:    __next_result = 0x00;                 break;
    }
    result.write(__next_result);
  }

  void always_comb_1() {
    auto __next_zero = zero.read();
    __next_zero = (result.read() == 0x00);
    zero.write(__next_zero);
  }

  void always_comb_2() {
    auto __next_carry = carry.read();
    if ((op.read() == 0b000)) {
      __next_carry = add_full.read()[8];  // bit-select read
    } else {
      __next_carry = 0b0;
    }
    carry.write(__next_carry);
  }

  SC_CTOR(alu) {
    SC_METHOD(assign_0);    sensitive << a << b;
    SC_METHOD(always_comb_0); sensitive << op << a << b;
    SC_METHOD(always_comb_1); sensitive << result;
    SC_METHOD(always_comb_2); sensitive << op << add_full;
  }
};
```

Things to notice:

- slang resolves `[7:0]` and `[8:0]` to concrete widths during elaboration, so the ports come out as `sc_uint<8>` / `sc_uint<9>` directly — no width arithmetic in the type names.
- The Verilog **concatenation** `{1'b0, a}` becomes `((sc_uint<9>(0b0) << 8) | sc_uint<9>(a.read()))` — explicit shift-OR with each operand cast to the result width so the sum stays a clean 9-bit value.
- The Verilog **bit-select** `add_full[8]` becomes `add_full.read()[8]` (sc_uint's `operator[]` returning a bit-ref).
- Each `always @(*)` block lowers to its own `SC_METHOD` with a per-output `__next_<signal>` staging pattern, so `case` `default:` and `if`/`else` overwrites all interact correctly.
- The sensitivity list only contains real signals — sized literals like `1'b0`, `8'h00`, `3'b000` no longer leak their base prefix into the list.

## Diagnostic

The ALU has three procedural blocks, so the converter records one warning:

```
event_scheduler_approximated: module contains multiple procedural blocks;
generated SystemC uses SC_METHOD scheduling and may differ from full Verilog
event ordering
```

It is informational — every output is driven by exactly one block, so there is no driver conflict and `SC_METHOD` scheduling is functionally equivalent for this design. See [`docs/known_differences.md`](../../docs/known_differences.md).

## Functional equivalence

The same ALU is registered as the `alu` fixture in `tests/equivalence/run_equivalence.py`. On Linux with `iverilog` + `libsystemc-dev` (or by using a branch/PR covered by the `equivalence` workflow):

```bash
python tests/equivalence/run_equivalence.py --fixtures alu
```

This drives 256 random `(a, b, op)` stimulus rows through both the Verilog simulation (Icarus Verilog) and the generated SystemC simulation (libsystemc-dev), then diffs the per-cycle output traces. A passing run is the actual correctness signal — the generated header above is just the human-readable artifact along the way.
