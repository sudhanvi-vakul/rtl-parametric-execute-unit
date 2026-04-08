# design_notes.md

## Parametric Integer Execute Unit — Design Notes

This document is the design-facing companion to the project README and `verification_notes.md`.

Use the documents in this way:

- `README.md` — portfolio-facing summary
- `design_notes.md` — architecture, design intent, semantics, and implementation notes
- `verification_notes.md` — testcase execution, evidence, and closure tracking

---

## 1. Design Objective

The goal of this project is to build a **reusable parametric integer execute-stage RTL block** that is larger and more structured than a toy ALU, but still small enough to verify deeply and explain clearly.

This block is intended to serve as the first reusable datapath block in a staged RTL microarchitecture portfolio flow.

The execute unit is designed to support:

- arithmetic operations
- logic operations
- logical and arithmetic shifts
- signed and unsigned comparisons
- explicit branch-condition evaluation
- architectural-style flag generation
- optional multiply support
- parameterized width reuse

This project should read as a **microarchitecture-ready execute block**, not as a full CPU.

---

## 2. Design Intent

The design is built with three major goals:

### 2.1 Reuse
The execute unit should be reusable later in:

- valid/ready pipeline stages
- microcoded datapaths
- integer pipelines
- scoreboard-driven issue engines
- execution clusters

### 2.2 Semantic clarity
The design should make these distinctions explicit:

- signed vs unsigned interpretation
- carry vs overflow
- logical vs arithmetic right shift
- compare result vs branch decision
- legal vs illegal opcode behavior

### 2.3 Verification friendliness
The RTL should be structured so that:

- each operation class is easy to isolate
- expected results are easy to model in the testbench
- corner-case behavior is explainable
- waveform inspection is meaningful
- parameter sweeps are practical

---

## 3. Project Scope

### 3.1 Supported operation classes

#### Arithmetic
- ADD
- SUB

#### Logic
- AND
- OR
- XOR

#### Shift
- SLL
- SRL
- SRA

#### Compare
- EQ
- signed LT
- unsigned LT

#### Branch-condition evaluation
- BR_EQ
- BR_NE
- BR_LT
- BR_LTU

#### Multiply
- MUL, enabled by parameter

#### Status outputs
- zero
- negative
- carry
- overflow

#### Control robustness
- illegal opcode handling
- unsupported operation behavior

---

## 4. Top-Level Design Philosophy

A good execute block should not collapse every operation into one giant unreadable combinational `case` statement.

This project therefore encourages a modular structure:

- one package for opcode and control definitions
- one block for arithmetic/logic
- one block for shifts
- one block for compare and branch
- one optional block for multiply
- one top-level block for decode, result selection, and flag output

This makes the design:

- easier to debug
- easier to verify
- easier to explain in interviews
- easier to reuse in later stages

---

## 5. Recommended File Structure

```text
rtl/
├── exec_defs_pkg.sv
├── alu_core.sv
├── shifter_core.sv
├── cmp_branch_core.sv
├── mul_core.sv
└── exec_unit.sv
```

### File roles

#### `exec_defs_pkg.sv`
Contains:
- operation enum / opcode constants
- shared typedefs
- parameter-related helper constants if needed

#### `alu_core.sv`
Contains:
- ADD
- SUB
- AND
- OR
- XOR

#### `shifter_core.sv`
Contains:
- SLL
- SRL
- SRA

#### `cmp_branch_core.sv`
Contains:
- equality compare
- signed less-than compare
- unsigned less-than compare
- branch-condition evaluation

#### `mul_core.sv`
Contains:
- multiply path used only if `HAS_MUL = 1`

#### `exec_unit.sv`
Contains:
- opcode decode
- sub-block integration
- output selection
- flag generation
- illegal opcode handling

---

## 6. Assumed Top-Level Interface

The exact interface may evolve slightly, but the intended form is:

```systemverilog
module exec_unit #(
    parameter int DATA_W = 32,
    parameter bit HAS_MUL = 1
) (
    input  logic [DATA_W-1:0] op_a_i,
    input  logic [DATA_W-1:0] op_b_i,
    input  logic [4:0]        op_sel_i,

    output logic [DATA_W-1:0] result_o,
    output logic              zero_o,
    output logic              negative_o,
    output logic              carry_o,
    output logic              overflow_o,

    output logic              cmp_eq_o,
    output logic              cmp_lt_signed_o,
    output logic              cmp_lt_unsigned_o,

    output logic              branch_taken_o,
    output logic              illegal_op_o
);
```

---

## 7. Architecture

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
 op_sel_i ---> +----------------+                            |  |
         |                                                   |  |
         |   +------------------+    +------------------+    |  |
         |   |    alu_core.sv   |    | shifter_core.sv  |    |  |
         |   | add/sub/logic    |    | sll/srl/sra      |    |  |
         |   +---------+--------+    +---------+--------+    |  |
         |             |                       |             |  |
         |             +-----------+-----------+             |  |
         |                         |                         |  |
         |   +---------------------v-------------------+     |  |
         |   |         cmp_branch_core.sv              |     |  |
         |   | eq / slt / sltu / branch evaluation     |     |  |
         |   +---------------------+-------------------+     |  |
         |                         |                         |  |
         |   +---------------------v-------------------+     |  |
         |   |              mul_core.sv                |     |  |
         |   |        optional multiply path           |     |  |
         |   +---------------------+-------------------+     |  |
         |                         |                         |  |
         |               +---------v---------+               |  |
         |               | result / flags    | <-------------+  |
         |               | mux + flag logic  |                  |
         |               +---------+---------+                  |
         |                         |                            |
         +-------------------------+----------------------------+
                                   |
                                   v
                  result_o, zero_o, negative_o, carry_o,
                  overflow_o, cmp_*_o, branch_taken_o,
                  illegal_op_o
```

---

## 8. Data Path Partitioning

### 8.1 ALU path
Responsible for:
- ADD
- SUB
- AND
- OR
- XOR

This path is the main arithmetic/logic datapath.

### 8.2 Shift path
Responsible for:
- SLL
- SRL
- SRA

This path exists separately so that:
- shift semantics stay explicit
- arithmetic and logic path complexity does not grow unnecessarily
- right-shift behavior is easy to reason about

### 8.3 Compare path
Responsible for:
- equality
- signed less-than
- unsigned less-than

This path should compute compare outputs directly rather than inferring them from unrelated datapath outputs.

### 8.4 Branch path
Responsible for:
- translating compare intent into `branch_taken_o`

This is intentionally separate in concept from the result datapath.

### 8.5 Multiply path
Responsible for:
- optional MUL support

The first version should stay simple and honest.
If multiply is included, the first implementation can be combinational unless you explicitly decide otherwise.

---

## 9. Opcode and Control Strategy

### 9.1 Why use a package?
Opcode definitions should live in one package so that:

- RTL and testbench use the same symbolic names
- opcode values do not drift
- future reuse stays clean

### 9.2 Recommended grouping
It is good practice to group opcodes by function class:

- arithmetic
- logic
- shift
- compare
- branch
- multiply

### 9.3 Design rule
Do not scatter raw opcode literals throughout the code.
Use named constants or enums.

---

## 10. Parameterization Strategy

### 10.1 `DATA_W`
This parameter controls the operand and result width.

Expected widths to verify:
- 8
- 16
- 32

### 10.2 `HAS_MUL`
This parameter controls whether multiply support exists.

- `HAS_MUL = 1` → MUL legal
- `HAS_MUL = 0` → MUL unsupported / illegal per project policy

### 10.3 Parameterization intent
Parameterization should be real, not cosmetic.
The design should behave correctly without duplicating separate versions of the module.

---

## 11. Arithmetic Semantics

### 11.1 ADD
The ADD operation should:
- produce width-limited result
- support carry generation
- support signed overflow detection

### 11.2 SUB
The SUB operation should:
- produce width-limited result
- document carry/borrow convention clearly
- support signed overflow detection if defined

### 11.3 Carry vs overflow
This distinction must be explicit:

#### Carry
Primarily meaningful for unsigned arithmetic.

#### Overflow
Primarily meaningful for signed arithmetic.

These are **not the same thing** and should not be treated interchangeably.

---

## 12. Logic Semantics

### 12.1 AND
Standard bitwise AND.

### 12.2 OR
Standard bitwise OR.

### 12.3 XOR
Standard bitwise XOR.

Logic operations should still produce deterministic flag outputs where your design defines them, especially:
- zero
- negative

---

## 13. Shift Semantics

### 13.1 SLL
Logical left shift.

### 13.2 SRL
Logical right shift with zero-fill from the MSB side.

### 13.3 SRA
Arithmetic right shift with sign extension.

### 13.4 Shift amount handling
The shift amount should be limited appropriately for the selected width.
A typical implementation uses the low `$clog2(DATA_W)` bits of the shift operand or control.

### 13.5 Why SRA matters
Arithmetic right shift is a common source of mistakes because it must preserve sign semantics, unlike logical right shift.

---

## 14. Compare Semantics

### 14.1 Equality
`cmp_eq_o` should be asserted when operands are equal.

### 14.2 Signed less-than
`cmp_lt_signed_o` should use signed interpretation.

### 14.3 Unsigned less-than
`cmp_lt_unsigned_o` should use unsigned interpretation.

### 14.4 Important design principle
The same bit pattern can mean different things under signed and unsigned interpretation.
The design should make this distinction explicit in both RTL and documentation.

Example:
- `8'hFF` signed = `-1`
- `8'hFF` unsigned = `255`

So:
- signed `8'hFF < 8'h01` → true
- unsigned `8'hFF < 8'h01` → false

---

## 15. Branch Semantics

### 15.1 BR_EQ
Taken when operands are equal.

### 15.2 BR_NE
Taken when operands are not equal.

### 15.3 BR_LT
Taken when signed less-than is true.

### 15.4 BR_LTU
Taken when unsigned less-than is true.

### 15.5 Important design rule
Branch decisions should be derived from explicit compare meaning, not from accidental datapath side effects.

---

## 16. Flag Semantics

### 16.1 Zero flag
Recommended definition:
```text
zero_o = (result_o == 0)
```

### 16.2 Negative flag
Recommended definition:
```text
negative_o = result_o[DATA_W-1]
```

### 16.3 Carry flag
Recommended use:
- meaningful primarily for ADD
- meaningful for SUB only if carry/borrow convention is clearly documented

### 16.4 Overflow flag
Recommended use:
- meaningful primarily for signed ADD/SUB overflow cases

### 16.5 Design note
If flags are not meaningful for a certain opcode, the design should still define deterministic outputs rather than leaving ambiguity.

---

## 17. Multiply Policy

### 17.1 Initial implementation
The first multiply implementation can be combinational.

### 17.2 Why keep it simple first?
Because this project is about building a reusable execute block with clear semantics.
A multi-cycle multiply would add control complexity that is not necessary for the first version.

### 17.3 Truncation
If the full product exceeds `DATA_W`, the truncation policy should be documented clearly.

### 17.4 Disabled multiply
When `HAS_MUL = 0`, MUL should not silently behave like a legal arithmetic op.
It should follow your defined unsupported-operation policy.

---

## 18. Illegal Opcode Policy

A professional RTL block should define behavior for unsupported opcodes.

Recommended policy:
- assert `illegal_op_o`
- drive `result_o` to a deterministic safe value
- drive flags deterministically
- do not leak stale result behavior from the previous legal operation

This is important for:
- verification clarity
- future integration discipline
- interview explanation quality

---

## 19. Timing / Latency Assumption

### Initial version
The first version of this execute unit is intended to be **single-cycle combinational**.

That means:
- inputs are applied
- outputs reflect combinational result
- no internal pipeline stage is required in this first project

### Why this is okay
The goal here is correctness, structure, and reuse.
Pipelining can come later when this block is inserted into a stage-based microarchitecture flow.

---

## 20. Coding Style Intent

Recommended coding style choices:

- use `always_comb` for combinational behavior
- assign every output in every path
- avoid latch inference
- use explicit signed casting only where intended
- centralize opcode definitions
- separate function classes into logical blocks
- keep default / illegal behavior deterministic

---

## 21. Design Risks / Common Failure Modes

These are the most common issues this design should avoid:

### 21.1 Signed/unsigned confusion
A classic bug source in compare and arithmetic logic.

### 21.2 Carry/overflow confusion
Another classic bug source.
These must be treated separately.

### 21.3 Incorrect arithmetic right shift
Using logical shift where arithmetic shift was intended causes sign bugs.

### 21.4 Stale result behavior
If illegal or unsupported operations reuse old data accidentally, the block becomes unsafe and hard to debug.

### 21.5 Opcode drift
If opcode names or values diverge between RTL and testbench, verification becomes unreliable.

### 21.6 Superficial parameterization
A design that claims to be parameterized but is only really tested at one width is weaker and easier to challenge in interviews.

---

## 22. Verification Hooks Designed Into the Block

The design should be verification-friendly.

Useful observable outputs include:
- `result_o`
- `zero_o`
- `negative_o`
- `carry_o`
- `overflow_o`
- `cmp_eq_o`
- `cmp_lt_signed_o`
- `cmp_lt_unsigned_o`
- `branch_taken_o`
- `illegal_op_o`

These make it possible to verify:
- datapath result correctness
- flag correctness
- semantic correctness
- branch/compare consistency
- illegal-op handling

---

## 23. Relationship to Verification Plan

The design is intentionally structured to align with the verification plan.

Examples:

- separate compare outputs make signed vs unsigned verification easier
- explicit illegal-op output makes unsupported behavior testable
- parameterization makes width sweeps meaningful
- modular datapath structure makes operation-class debugging easier
- separated shift logic makes SRA/SRL distinction easier to prove

---

## 24. Reuse in Later Projects

This block is designed to be reused later in:

### 24.1 Pipeline slice integration
The execute unit can be wrapped in a valid/ready boundary.

### 24.2 Microcoded datapath
A sequencer can drive operation select and operands into this block.

### 24.3 Integer pipeline
This block can act as the execute stage in a small 3-stage or 5-stage pipeline.

### 24.4 Scoreboard / backend flow
This block can become one of the execution resources used by a scheduler or issue structure.

### 24.5 Execution cluster
Later projects can place this alongside other functional units with arbitration and writeback control.

---

## 25. Evidence Expectations

This design document should eventually be supported by:

- clean RTL module partitioning
- a self-checking testbench
- width-sweep regression logs
- waveform evidence for important corner cases
- verification notes with testcase-by-testcase status

Recommended representative waveform captures:
- carry-out addition
- signed overflow addition
- arithmetic right shift on negative input
- signed vs unsigned compare distinction
- branch taken vs not taken
- illegal opcode handling

---

## 26. Final Design Closure Criteria

A strong design closure for Stage 1 should show:

### Design closure
- clear opcode/control structure
- modular datapath partitioning
- explicit signed/unsigned semantics
- documented flag rules
- documented multiply policy
- documented illegal-op behavior
- real parameterization

### Verification-aligned closure
- every supported operation class implemented
- deterministic unsupported behavior
- compare and branch outputs aligned with intended semantics
- width sweeps planned and executed
- representative corner cases explainable

---

## 27. Final Positioning Statement

This project should be presented as:

> A reusable parametric integer execute-stage RTL block with modular datapath structure, explicit signed/unsigned semantics, architectural-style flag generation, deterministic unsupported-operation handling, and verification-oriented design partitioning.

That is a strong and truthful way to describe it in a portfolio or interview.

---

## 28. Next Companion Documents

After this file, the main companion documents are:

- `README.md`
- `docs/verification_notes.md`
- `docs/commands.md`

Together, these three documents should present:
- what the project is
- how it is designed
- how it is verified
- how it is rerun and reproduced
