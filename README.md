# Parametric Integer Execute Unit

![SystemVerilog](https://img.shields.io/badge/Language-SystemVerilog-blue)
![Microarchitecture](https://img.shields.io/badge/Focus-Execute%20Stage-success)
![Verification](https://img.shields.io/badge/Verification-Directed%20%2B%20Self--Checking-orange)
![Status](https://img.shields.io/badge/Project-In%20Progress-yellow)

A reusable **opcode-driven integer execute-stage RTL block** built in **SystemVerilog** with:
- arithmetic operations
- logic operations
- logical and arithmetic shifts
- signed and unsigned compare logic
- explicit branch-condition evaluation
- status flag generation
- optional multiply support

This project demonstrates practical RTL design for **datapath partitioning**, **opcode/control organization**, **signed/unsigned correctness**, **flag generation**, and **structured verification** across width sweeps, semantic corner cases, and representative waveform inspection.

---

## Table of Contents

- [Overview](#overview)
- [Project Goals](#project-goals)
- [Architecture](#architecture)
- [Implemented Modules](#implemented-modules)
- [Key Design Ideas](#key-design-ideas)
- [Verification Strategy](#verification-strategy)
- [Test Results Summary](#test-results-summary)
- [Testcase Coverage](#testcase-coverage)
- [Verification Depth and Closure Intent](#verification-depth-and-closure-intent)
- [Waveform Inspection Goals](#waveform-inspection-goals)
- [Repository Structure](#repository-structure)
- [How to Run](#how-to-run)
- [Expected Outputs](#expected-outputs)
- [What This Project Demonstrates](#what-this-project-demonstrates)
- [Key Learnings](#key-learnings)
- [Future Improvements](#future-improvements)
- [Summary](#summary)

---

## Overview

A good execute unit should be more than a classroom ALU.  
This project builds a reusable integer execute-stage block that is large enough to feel **microarchitecture-ready**, but still small enough to verify thoroughly and reuse in later stages.

The design supports:
- arithmetic operations
- logic operations
- logical and arithmetic shifts
- signed and unsigned comparisons
- explicit branch-condition evaluation
- architectural-style flag generation
- optional multiply support
- parameterized operation across multiple data widths

This makes the project a strong foundational block for later:
- valid/ready pipeline stages
- microcoded datapaths
- integer pipelines
- scoreboarded issue engines
- backend execution clusters

---

## Project Goals

- Build a reusable execute-stage RTL block
- Keep opcode and control organization clean and scalable
- Support arithmetic, logic, shift, compare, and branch operations
- Generate meaningful flags: zero, negative, carry, overflow
- Support optional multiply through parameter control
- Verify correctness across width sweeps and semantic corner cases
- Produce structured verification evidence using logs and waveforms

---

## Architecture

```text
                     +----------------------------+
                     |      exec_defs_pkg.sv      |
                     |  opcode / control enums    |
                     +-------------+--------------+
                                   |
                                   v
         +------------------------------------------------------+
         |                    exec_unit.sv                      |
         |                                                      |
 op_a_i -----> +----------------+                               |
 op_b_i -----> | operation decode| --------------------------+  |
 op_sel_i ---> +----------------+                           |  |
         |                                                |  |
         |   +------------------+    +------------------+ |  |
         |   |    alu_core.sv   |    | shifter_core.sv  | |  |
         |   | add/sub/logic    |    | sll/srl/sra      | |  |
         |   +---------+--------+    +---------+--------+ |  |
         |             |                       |          |  |
         |             +-----------+-----------+          |  |
         |                         |                      |  |
         |   +---------------------v-------------------+  |  |
         |   |         cmp_branch_core.sv             |  |  |
         |   | eq / slt / sltu / branch evaluation    |  |  |
         |   +---------------------+-------------------+  |  |
         |                         |                      |  |
         |   +---------------------v-------------------+  |  |
         |   |              mul_core.sv               |  |  |
         |   |        optional multiply path          |  |  |
         |   +---------------------+-------------------+  |  |
         |                         |                      |  |
         |               +---------v---------+            |  |
         |               | result / flags    | <----------+  |
         |               | mux + flag logic  |               |
         |               +---------+---------+               |
         |                         |                         |
         +-------------------------+-------------------------+
                                   |
                                   v
                  result_o, zero_o, negative_o, carry_o,
                  overflow_o, cmp_*_o, branch_taken_o,
                  illegal_op_o
```

---

## Implemented Modules

### RTL

#### `rtl/exec_defs_pkg.sv`
Opcode and control package containing:
- operation definitions
- operation classes
- shared constants and typedefs

**Purpose**
- keep opcode naming consistent across RTL and testbench
- prevent ad hoc control encoding
- make later reuse cleaner in pipeline and backend projects

---

#### `rtl/alu_core.sv`
Arithmetic and logic block for:
- add
- sub
- and
- or
- xor

**Purpose**
- handle integer arithmetic and logic cleanly
- provide arithmetic-side status information for flag generation
- isolate datapath functionality from top-level decode clutter

---

#### `rtl/shifter_core.sv`
Shift block for:
- logical left shift
- logical right shift
- arithmetic right shift

**Purpose**
- isolate shift behavior from ALU logic
- keep edge-case handling readable and verifiable
- make logical and arithmetic right-shift semantics explicit

---

#### `rtl/cmp_branch_core.sv`
Comparator and branch-condition block for:
- equality compare
- signed less-than
- unsigned less-than
- branch decision generation

**Purpose**
- keep compare semantics explicit
- ensure branch decisions are not inferred indirectly from unrelated datapath outputs
- make signed vs unsigned intent visible in both RTL and verification

---

#### `rtl/mul_core.sv`
Optional multiplier block controlled by parameter.

**Purpose**
- support an optional multiply path
- allow the first version to remain simple and verifiable
- keep multiply support explicit rather than mixed into the base ALU path

---

#### `rtl/exec_unit.sv`
Top-level execute unit that integrates:
- opcode decode
- ALU path
- shift path
- compare/branch path
- optional multiply
- result selection
- flag generation
- illegal opcode handling

**Purpose**
- provide a reusable execute-stage foundation
- become the base block for later microarchitecture projects
- demonstrate clean datapath/control separation at a small but meaningful scale

---

### Testbench

#### `tb/exec_unit_tb.sv`
Main self-checking directed testbench covering:
- arithmetic correctness
- flag behavior
- shifts
- compare semantics
- branch-condition evaluation
- multiply enable/disable behavior
- width sweeps
- illegal opcode handling

**Purpose**
- provide deterministic baseline verification first
- make mismatches easy to diagnose
- support regression-ready closure before randomization is added later

---

## Key Design Ideas

### Why split the execute unit into sub-blocks?
A microarchitecture-ready block should not collapse all behavior into one giant unreadable `case` statement.  
Splitting the design into ALU, shifter, compare/branch, and multiply paths makes the RTL easier to verify, debug, maintain, and reuse later.

### Why keep compare and branch logic explicit?
Branch behavior should be based on explicit comparison intent, not on accidental reuse of ALU result bits.  
This becomes especially important later in pipelines and backend control, where wrong control semantics are harder to debug than simple datapath bugs.

### Why parameterize width?
A reusable execute block should work across multiple widths without cloning the design.  
Width sweeps also expose truncation, sign, carry, and overflow corner cases that small fixed-width tests may miss.

### Why support signed and unsigned semantics separately?
The same bit pattern can mean very different things under signed and unsigned interpretation.  
Keeping those rules explicit is essential for:
- compare correctness
- branch correctness
- arithmetic-right-shift expectations
- explanation quality during interviews

### Why make illegal/unsupported behavior explicit?
A disciplined block should define what happens on unsupported operations.  
That includes:
- illegal opcode indication
- deterministic outputs
- no stale or misleading result behavior
- clean handling when multiply is disabled

### Why waveform inspection matters?
Self-checking tests prove correctness, but waveforms help confirm the **internal behavior**:
- datapath selection
- carry and overflow generation
- compare signal stability
- branch decision behavior
- shift edge cases
- illegal opcode response

---

## Verification Strategy

Verification uses **directed self-checking simulation** plus **waveform-based inspection**.

### Functional checks include
- arithmetic correctness
- zero and negative flag behavior
- carry and overflow behavior
- logic operation correctness
- shift amount edge cases
- signed compare correctness
- unsigned compare correctness
- branch-condition correctness
- multiply enable behavior
- multiply disable behavior
- illegal opcode handling
- parameter sweeps across 8/16/32-bit widths

### Semantic checks include
- signed vs unsigned interpretation on the same bit patterns
- carry-out vs signed overflow distinction
- arithmetic-right-shift sign extension
- branch decisions driven by explicit compare intent
- deterministic behavior for unsupported operations

### Structural waveform checks include
- opcode decode select behavior
- ALU result path selection
- shift result path selection
- compare output transitions
- branch decision generation
- flag generation around arithmetic corner cases
- illegal opcode response behavior

---

## Test Results Summary

- **Top-level testcases planned:** 20
- **Expanded checked scenarios targeted:** 35+
- **Pass:** 0
- **Fail:** 0
- **Status:** Verification plan defined; implementation and execution in progress

> Update this section after regression is run.

---

## Testcase Coverage

| Test ID | Name | Status |
|---------|------|--------|
| TC01 | Add Basic | TODO |
| TC02 | Add Carry-Out | TODO |
| TC03 | Add Signed Overflow | TODO |
| TC04 | Sub Basic | TODO |
| TC05 | Sub Carry/Borrow Convention | TODO |
| TC06 | Logic AND/OR/XOR | TODO |
| TC07 | Shift Left Logical | TODO |
| TC08 | Shift Right Logical | TODO |
| TC09 | Shift Right Arithmetic | TODO |
| TC10 | Compare Equal | TODO |
| TC11 | Compare Signed Less-Than | TODO |
| TC12 | Compare Unsigned Less-Than | TODO |
| TC13 | Branch Equal / Not Equal | TODO |
| TC14 | Branch Signed / Unsigned Less-Than | TODO |
| TC15 | Multiply Enabled | TODO |
| TC16 | Multiply Disabled | TODO |
| TC17 | Width Sweep - 8-bit | TODO |
| TC18 | Width Sweep - 16-bit | TODO |
| TC19 | Width Sweep - 32-bit | TODO |
| TC20 | Illegal Opcode Handling | TODO |

---

## Verification Depth and Closure Intent

The 20 testcase IDs above are the **top-level verification groups**.  
To make the project interview-ready, each group is expected to contain multiple directed sub-scenarios rather than only one nominal check.

Examples of deeper sub-scenario coverage include:

### Arithmetic depth
- `0 + 0`
- small positive + positive
- max unsigned + 1 for carry-out
- max signed positive + 1 for overflow
- equal-operand subtraction producing zero
- subtraction producing a negative result

### Shift depth
- shift by `0`
- shift by `1`
- shift by `DATA_W-1`
- arithmetic right shift on negative values
- logical right shift zero-fill verification

### Compare and branch depth
- equal vs not equal
- signed less-than on negative vs positive
- unsigned less-than on large unsigned values
- same bit pattern interpreted differently in signed vs unsigned mode

### Flag depth
- zero flag from arithmetic and logic results
- negative flag on MSB-set results
- carry vs overflow checked separately
- flags verified only where meaningful and explicitly defined

### Parameter depth
- representative operation checks at 8-bit
- representative operation checks at 16-bit
- representative operation checks at 32-bit
- width-specific truncation/overflow behavior

### Illegal/unsupported behavior depth
- unsupported opcode handling
- disabled multiply behavior when `HAS_MUL = 0`
- deterministic output resolution under invalid control values

This project therefore emphasizes not only **functional operation coverage**, but also **semantic correctness**, **flag correctness**, and **parameter robustness**.

---

## Waveform Inspection Goals

Waveform evidence is used to inspect:
- add and sub datapath behavior
- carry and overflow generation
- zero and negative flag behavior
- logic operation selection
- shift result correctness
- signed and unsigned compare behavior
- branch decision generation
- optional multiply behavior
- illegal opcode/default handling

Suggested screenshot categories:
- basic add operation
- signed overflow case
- carry-out case
- logical right vs arithmetic right shift
- signed compare vs unsigned compare
- branch taken and branch not taken
- multiply enabled operation
- illegal opcode behavior

---

## Repository Structure

```text
rtl-parametric-execute-unit/
├── ci/
├── docs/
│   └── verification_notes.md
├── evidence/
│   └── waveforms/
├── reports/
│   └── run_*/
├── rtl/
│   ├── exec_defs_pkg.sv
│   ├── alu_core.sv
│   ├── shifter_core.sv
│   ├── cmp_branch_core.sv
│   ├── mul_core.sv
│   └── exec_unit.sv
├── scripts/
├── tb/
│   ├── assertions/
│   └── exec_unit_tb.sv
├── tests/
├── tools/
├── tests.yaml
├── README.md
└── requirements.txt
```

---

## How to Run

Example simulation command:

```bash
python3 -m scripts.run --tool verilator --suite smoke --test exec_unit --waves
```

### Typical workflow
1. Compile RTL and testbench
2. Run simulation
3. Generate logs and waveform files
4. Inspect waveform output in GTKWave
5. Capture verification evidence in `docs/verification_notes.md`

### Alternate portability check
If the backbone supports multiple simulators, a secondary check can be run with Icarus to catch coding assumptions that may differ between tools.

---

## Expected Outputs

Typical generated artifacts include:
- compile logs
- simulation logs
- waveform dump files
- run-specific report folders under `reports/run_*`
- testcase status summaries
- rerun command records

Example artifact types:
- `compile.log`
- `sim.log`
- waveform dump (`.vcd` or `.fst`)
- summary report
- rerun command record

---

## What This Project Demonstrates

- reusable **execute-stage RTL**
- practical **opcode/control organization**
- explicit **signed/unsigned datapath reasoning**
- clean **flag generation**
- explicit **compare and branch semantics**
- **parameterized RTL design and verification**
- structured **verification planning** for later pipeline reuse

---

## Key Learnings

- A good execute block should be reusable, not throwaway
- Signed and unsigned interpretation must remain explicit
- Compare and branch logic should be treated as first-class logic
- Width sweeps are useful for exposing corner-case behavior
- Carry and overflow must be distinguished carefully
- Illegal/unsupported behavior should be deterministic and documented
- Clean opcode organization matters for long-term reuse

---

## Future Improvements

- add randomized verification after directed baseline is stable
- add assertions for illegal opcode and flag consistency
- add valid/ready wrapper for easier Project 2 reuse
- evaluate a multi-cycle multiply option
- add cocotb reference-model checking
- run portability checks with Icarus in addition to Verilator
- add functional coverage for opcode/flag/corner-case combinations

---

## Summary

This project implements a **parametric integer execute unit** using modular datapath blocks for arithmetic, logic, shifts, compare/branch evaluation, flags, and optional multiply support. The design and verification flow are intended to create a reusable execute-stage foundation for later microarchitecture projects, while also demonstrating disciplined signed/unsigned reasoning, flag correctness, parameter robustness, and structured verification planning.
