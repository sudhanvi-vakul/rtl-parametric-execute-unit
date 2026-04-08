# Code Package Notes

This package includes:

- `README.md`
- `docs/design_notes.md`
- `docs/verification_notes.md`
- RTL source files for the execute unit
- a parameterized self-checking testbench
- wrapper tops for 8/16/32-bit and no-MUL runs
- an example `tests.yaml` manifest to adapt into your backbone flow

## Coverage intent

The testbench explicitly maps to the testcase IDs in `docs/verification_notes.md`.

Important notes:

- TC100–TC102 run only when `DATA_W == 8`
- TC103–TC105 run only when `DATA_W == 16`
- TC106–TC108 run only when `DATA_W == 32`
- TC094–TC095 run only when `HAS_MUL == 0`

All other testcase IDs are exercised in the shared parameterized testbench.

## Suggested bring-up order

1. `tb/exec_unit_tb.sv`
2. `tb/exec_unit_nomul_tb.sv`
3. `tb/exec_unit_8b_tb.sv`
4. `tb/exec_unit_16b_tb.sv`
5. `tb/exec_unit_32b_tb.sv`
