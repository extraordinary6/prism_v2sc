# ICB-to-APB Bridge Real-design Evaluation

Date: 2026-07-10

## Case

External RTL under
`/home/MicroE/ai_proj/Design-and-Verification-of-ICB-to-APB-Bus-Bridge/uvm_project/my_design/rtl`:

- Design top: `dut_top`
- Verification top: generated `prism_icb_apb_flat_top`
- Sources: `icb_bus.sv`, `apb_bus.sv`, `fifo.sv`, `codec_des.sv`,
  `icb_slave.sv`, `apb_master.sv`, and `top.sv`
- Design shape: SystemVerilog interfaces/modports, ICB register interface,
  DES command codec, asynchronous FIFO crossing, and four APB masters

The external RTL is not modified. The consistency script copies it into a
temporary snapshot, removes only the `` `define CHECK`` verification switch,
keeps `` `define DES``, and adds a flat top wrapper for the current SystemC
testbench. Assertion/property/bind/UVM content is outside the synthesizable
design view and is not converted.

## Command

```bash
.venv/bin/python verification/cases/consistency/icb_apb_bridge_consistency.py
```

## Conversion Result

- 8 input sources including the generated flat wrapper
- 6 visited modules
- 7 instances, 53 processes, 117 signals, and 182 ports
- 0 error diagnostics and 18 warnings
- generated `prism_icb_apb_flat_top.hpp` compiles as C++14/SystemC
- generated output passes static fallback checks

Warning breakdown:

```text
 7 slang_NewlineEOF
 6 slang_LogicalOpParentheses
 4 event_scheduler_approximated
 1 slang_ArithOpMismatch
```

These warnings remain visible because they describe source formatting/style or
the known multi-process scheduling approximation. None blocked the tested
transaction behavior.

## Consistency Result

RTL is simulated with VCS and compared with generated SystemC at meaningful
transaction events rather than requiring every internal cycle to match.

Current result:

```text
ICB-to-APB consistency passed: 36 events
```

The 36 matched events contain 28 ICB responses and 8 completed APB transfers.
Coverage includes:

- ICB command/response handshake, masked register write/read, read-only write
  errors, key register access, and unknown-address behavior
- DES-enabled command header/data decoding
- asynchronous ICB/APB clocks and FIFO crossing
- all four APB outputs
- one read and one write per APB output
- distinct programmed APB wait-state lengths across the four outputs
- independent semantic checks for expected address, data, direction, and error
  behavior in addition to RTL/SystemC event equality

## Issues Found And Fixed

This design exposed defects that smaller fixtures did not cover:

- interface instance members and modport references could collapse to raw zero
- interface constructor connections and cross-level forwarding were incomplete
- direct slang `StatementList` nodes and function-local variables were lost
- invalid continuous assignments could crash instead of producing diagnostics
- multidimensional unpacked assignment patterns did not emit per-cell writes
- ascending packed ranges used the wrong SystemC bit order
- parameter-dependent child port widths and concrete parameter overrides were
  not consistently specialized across bridges
- symbolic widths above 64 bits selected `sc_int/sc_uint` instead of
  `sc_bigint/sc_biguint`

Focused unit coverage is in `tests/test_interface_array_hardening.py` and
`tests/test_codegen.py`.

## Assessment

For the exercised synthesizable behavior, the bridge is converted correctly and
matches RTL at the protocol events that matter. This is stronger than a compile
smoke because it covers encryption, CDC, register semantics, routing, reads,
writes, and backpressure on every APB path.

It is not a formal proof or an exhaustive cycle-by-cycle equivalence result.
Internal delta-cycle ordering may differ, and the current workload uses a fixed
set of deterministic transactions. Broader confidence would require randomized
transaction ordering, reset during traffic, FIFO-full/empty stress, and formal
or assertion-based verification performed on the original RTL side.
