# E203 ICB DMA Real-design Evaluation

## Input

- External RTL: `/home/MicroE/ai_proj/DMA-Design-Based-on-E203-and-ICB-Bus/rtl/e203_dma.v`
- Project filelist: `verification/cases/dma_e203/dma_e203.f`
- Consistency gate: `verification/cases/consistency/dma_e203_consistency.py`
- Top: `e203_dma`
- Fixed E203 macros: `E203_ADDR_SIZE=32`, `E203_XLEN=32`

The external RTL is not modified. The repository contains one RTL module and
no testbench, so the consistency gate supplies an ICB configuration driver and
a deterministic memory responder.

## Conversion result

- 1 source
- 1 reachable/generated SystemC module
- 13 sequential processes
- 0 error diagnostics
- 2 warnings: `event_scheduler_approximated` and slang `WidthExpand`
- Generated C++14/SystemC header compiles successfully

## Consistency contract

The gate programs source `0x40`, destination `0x80`, and length `2`, reads
configuration registers, starts the DMA, and supplies source words
`0x11223344`, `0xaabbccdd`, and `0x55667788` through an ICB responder.

It compares 45 sampled cycles and ten externally visible fields:

- memory command valid/address/read/write-data
- response ready
- configuration response valid/data/error
- DMA interrupt

After simulator banners and numeric formatting are normalized, all 45 RTL and
generated-SystemC samples match.

## RTL findings

These are source-design behaviors reproduced by both RTL and SystemC, not
converter mismatches. The external RTL remains unchanged.

1. `dma_icb_cmd_valid` can remain asserted while `dma_icb_cmd_ready` is high,
   allowing the same ICB command to be accepted repeatedly before the state
   transition observes a response.
2. `cnt` resets to `32'hffffffff`, while command addresses use
   `(cnt - 1) * 4`. The observed first commands target `src_addr-4` and
   `dst_addr-4` (`0x3c` and `0x7c` in this test).
3. The observed completion sequence contains a final source read without a
   corresponding destination write before IRQ/completion.
4. `dma_cfg_icb_rsp_ready` and `dma_cfg_icb_cmd_wmask` do not participate in
   the RTL control behavior, so configuration response backpressure and masked
   writes are not implemented.
5. The design ignores `dma_cfg_icb_rsp_ready` when generating response valid;
   response valid is a one-cycle reflection of command valid rather than a
   held valid/ready handshake.

These findings should be treated as integration risks when this DMA is attached
to an ICB slave that accepts every `valid && ready` command.
