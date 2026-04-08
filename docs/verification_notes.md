# verification_notes.md

## Parametric Integer Execute Unit — Detailed Verification Notes

This file is the execution-facing verification plan for the **Parametric Integer Execute Unit**.
It is intentionally deeper than the README and is meant to support step-by-step verification closure, evidence capture, and interview-ready project documentation.

## How to Use This File

- Keep the README as the project-facing summary.
- Use this file as the real verification closure document.
- Update each testcase with `PASS`, `FAIL`, `PARTIAL`, `TODO`, or `BLOCKED`.
- Attach evidence paths for logs, waveforms, and screenshots.

## Suggested Result Values

- `PASS`
- `FAIL`
- `PARTIAL`
- `TODO`
- `BLOCKED`

## Suggested Evidence Naming

- `evidence/waveforms/TCxxx_<short_name>.png`
- `reports/TCxxx_<short_name>/`
- `docs/commands.md` should record the exact rerun command

## Closure Goal

A strong Stage 1 closure should show:

- arithmetic, logic, shifts, compares, branches, multiply, and illegal-op behavior all exercised
- zero, negative, carry, and overflow checked explicitly
- signed vs unsigned semantics proven with representative edge cases
- 8/16/32-bit parameterization demonstrated
- deterministic unsupported-operation behavior
- representative waveform evidence saved

## Verification Cases

## A. Smoke / Basic Structural Bring-Up

### TC001 — Single ADD smoke test

**Purpose**
Prove the DUT is alive and decode basically works.

**Stimulus**
- Apply a simple ADD vector such as `2 + 3`.
- Observe result and flags.

**Checks**
- Result matches expected sum
- Outputs are deterministic
- No illegal opcode indication for legal ADD

**Expected**
- `result_o = 5`
- `illegal_op_o = 0`
- Relevant flags match arithmetic result

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC002 — One representative vector per legal opcode

**Purpose**
Sanity check opcode-to-function mapping across all supported operations.

**Stimulus**
- Apply one directed vector for each legal opcode.
- Cover ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, EQ, signed LT, unsigned LT, BR_EQ, BR_NE, BR_LT, BR_LTU, MUL if enabled.

**Checks**
- Each opcode selects intended datapath behavior
- No opcode aliasing or decode mix-up

**Expected**
- Every legal opcode produces its intended output class

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC003 — Back-to-back opcode switching

**Purpose**
Ensure result path changes correctly when opcode changes each cycle or step.

**Stimulus**
- Drive the same operands while changing opcode across consecutive operations.

**Checks**
- No stale result carryover
- Correct mux selection between operation classes

**Expected**
- Output changes according to selected opcode every time

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC004 — Back-to-back operand switching under same opcode

**Purpose**
Ensure output tracks operand changes cleanly under a fixed opcode.

**Stimulus**
- Hold opcode constant.
- Change operands across consecutive operations.

**Checks**
- No stale result behavior
- Result tracks operands immediately

**Expected**
- Output always reflects current operands

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC005 — Basic illegal opcode smoke

**Purpose**
Prove unsupported opcode policy exists and is deterministic.

**Stimulus**
- Apply at least one undefined opcode value.

**Checks**
- `illegal_op_o` asserted
- Outputs are deterministic
- No valid-looking stale behavior

**Expected**
- Unsupported opcode is flagged and handled cleanly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## B. Addition

### TC006 — ADD small positive numbers

**Purpose**
Verify normal addition behavior on simple positive values.

**Stimulus**
- Try vectors such as `2 + 3`, `5 + 4`.

**Checks**
- Result correctness
- Zero/negative/carry/overflow consistent

**Expected**
- Correct arithmetic result with no false overflow

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC007 — ADD zero plus zero

**Purpose**
Verify neutral zero-add case.

**Stimulus**
- Apply `0 + 0`.

**Checks**
- Result equals zero
- Zero asserted
- Negative deasserted

**Expected**
- `result_o = 0`, `zero_o = 1`

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC008 — ADD zero plus positive

**Purpose**
Verify additive identity.

**Stimulus**
- Apply `0 + N` for one or more positive `N` values.

**Checks**
- Result equals positive operand
- Flags are correct

**Expected**
- Pass-through style behavior for addition with zero

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC009 — ADD positive plus negative without overflow

**Purpose**
Verify mixed-sign addition without signed overflow.

**Stimulus**
- Apply vectors such as `7 + (-2)`.

**Checks**
- Result correct
- Overflow remains deasserted

**Expected**
- Mixed-sign result correct without false overflow

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC010 — ADD negative plus positive without overflow

**Purpose**
Verify opposite mixed-sign ordering.

**Stimulus**
- Apply vectors such as `(-7) + 2`.

**Checks**
- Result correct
- Overflow remains deasserted

**Expected**
- Mixed-sign result correct without false overflow

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC011 — ADD negative plus negative without overflow

**Purpose**
Verify two's-complement addition of negative values when range allows.

**Stimulus**
- Apply moderate negative operands that do not overflow.

**Checks**
- Result correct
- Negative flag behavior correct

**Expected**
- Negative result represented correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC012 — ADD max unsigned plus 1

**Purpose**
Verify unsigned carry generation on wraparound.

**Stimulus**
- Apply all-ones operand plus one for the selected width.

**Checks**
- Carry-out asserted
- Result wraps to zero
- Overflow not confused with carry

**Expected**
- Unsigned wraparound handled correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC013 — ADD max signed positive plus 1

**Purpose**
Verify classic signed overflow case.

**Stimulus**
- For each width, apply max positive signed value plus one.

**Checks**
- Overflow asserted
- Result wraps into negative range

**Expected**
- Signed overflow is detected correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC014 — ADD min signed negative plus negative

**Purpose**
Verify negative-side signed overflow style case.

**Stimulus**
- Add the most negative value to another negative value where overflow should occur.

**Checks**
- Overflow asserted
- Result truncation follows width

**Expected**
- Signed overflow behavior correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC015 — ADD result exactly zero through cancellation

**Purpose**
Verify addition cancellation into zero.

**Stimulus**
- Add `+N` and `-N` where representable.

**Checks**
- Result zero
- Zero asserted
- Overflow absent

**Expected**
- Exact cancellation produces correct flags

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## C. Subtraction

### TC016 — SUB small positive numbers

**Purpose**
Verify normal subtraction on simple positive values.

**Stimulus**
- Apply vectors such as `7 - 2`.

**Checks**
- Result correctness
- Relevant flags correct

**Expected**
- Positive subtraction behaves correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC017 — SUB equal operands

**Purpose**
Verify subtraction that should produce zero.

**Stimulus**
- Apply `N - N`.

**Checks**
- Result zero
- Zero asserted

**Expected**
- Equal-operand subtraction produces zero

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC018 — SUB producing negative result

**Purpose**
Verify subtraction that yields a negative two's-complement result.

**Stimulus**
- Apply `2 - 7` or equivalent.

**Checks**
- Result correct
- Negative asserted

**Expected**
- Negative subtraction result correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC019 — SUB zero minus positive

**Purpose**
Verify subtraction from zero into negative range.

**Stimulus**
- Apply `0 - N` for positive `N`.

**Checks**
- Result correct
- Negative asserted

**Expected**
- Two's-complement negative result correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC020 — SUB positive minus zero

**Purpose**
Verify subtraction by zero as identity behavior.

**Stimulus**
- Apply `N - 0`.

**Checks**
- Result equals `N`
- Flags correct

**Expected**
- Positive minus zero unchanged

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC021 — SUB no-borrow style case

**Purpose**
Verify subtraction carry/borrow convention for a no-borrow case.

**Stimulus**
- Apply one case where no borrow is expected under your chosen convention.

**Checks**
- Carry/borrow semantics match design definition

**Expected**
- Subtraction status matches documented convention

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC022 — SUB borrow style case

**Purpose**
Verify subtraction carry/borrow convention for a borrow case.

**Stimulus**
- Apply one case where borrow is expected under your chosen convention.

**Checks**
- Carry/borrow semantics match design definition

**Expected**
- Subtraction status matches documented convention

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC023 — SUB max positive minus (-1)

**Purpose**
Verify signed overflow style case on subtraction.

**Stimulus**
- Apply max positive signed value minus `-1`.

**Checks**
- Overflow asserted if design defines signed subtraction overflow convention

**Expected**
- Signed subtraction overflow detected correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC024 — SUB min negative minus 1

**Purpose**
Verify negative-side subtraction overflow.

**Stimulus**
- Apply most negative signed value minus `1`.

**Checks**
- Overflow asserted

**Expected**
- Signed subtraction overflow detected correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC025 — SUB all-ones minus one

**Purpose**
Verify wrap/truncation and carry/borrow documentation alignment.

**Stimulus**
- Apply all-ones operand minus one.

**Checks**
- Result correct
- Carry/borrow meaning still consistent

**Expected**
- All-ones subtraction behaves as documented

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## D. Logic Operations

### TC026 — AND mixed patterns

**Purpose**
Verify bitwise AND on mixed input patterns.

**Stimulus**
- Apply representative nontrivial bit patterns.

**Checks**
- Result equals bitwise AND
- Zero/negative correct

**Expected**
- AND logic correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC027 — OR mixed patterns

**Purpose**
Verify bitwise OR on mixed input patterns.

**Stimulus**
- Apply representative nontrivial bit patterns.

**Checks**
- Result equals bitwise OR
- Zero/negative correct

**Expected**
- OR logic correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC028 — XOR mixed patterns

**Purpose**
Verify bitwise XOR on mixed input patterns.

**Stimulus**
- Apply representative nontrivial bit patterns.

**Checks**
- Result equals bitwise XOR
- Zero/negative correct

**Expected**
- XOR logic correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC029 — AND all zeros

**Purpose**
Verify AND on all-zero input case.

**Stimulus**
- Apply `0 & 0` and optionally `0 & N`.

**Checks**
- Result zero
- Zero asserted

**Expected**
- AND zero case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC030 — OR all zeros

**Purpose**
Verify OR on all-zero input case.

**Stimulus**
- Apply `0 | 0`.

**Checks**
- Result zero
- Zero asserted

**Expected**
- OR zero case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC031 — XOR identical operands

**Purpose**
Verify XOR self-cancelation behavior.

**Stimulus**
- Apply `A ^ A`.

**Checks**
- Result zero
- Zero asserted

**Expected**
- XOR identical operands collapses to zero

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC032 — OR all ones

**Purpose**
Verify OR on all-ones behavior.

**Stimulus**
- Apply all-ones with one or more other operands.

**Checks**
- Result all ones
- Negative tracks MSB for chosen width

**Expected**
- OR all-ones case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC033 — AND all ones with mixed operand

**Purpose**
Verify all-ones AND behaves like pass-through.

**Stimulus**
- Apply all-ones AND mixed operand.

**Checks**
- Result equals mixed operand

**Expected**
- AND all-ones pass-through correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## E. Shift Left

### TC034 — SLL by 0

**Purpose**
Verify left shift by zero leaves operand unchanged.

**Stimulus**
- Apply shift-left logical with shift amount 0.

**Checks**
- Result unchanged

**Expected**
- SLL by zero correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC035 — SLL by 1

**Purpose**
Verify left shift by one bit.

**Stimulus**
- Apply representative operand and shift amount 1.

**Checks**
- Result equals operand shifted left by 1

**Expected**
- SLL by one correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC036 — SLL by small nonzero amount

**Purpose**
Verify typical left shift behavior.

**Stimulus**
- Apply shift amounts such as 2 or 3.

**Checks**
- Result correct

**Expected**
- Typical SLL case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC037 — SLL by DATA_W-1

**Purpose**
Verify extreme boundary left shift.

**Stimulus**
- Apply shift amount `DATA_W-1`.

**Checks**
- Result matches width-limited left shift semantics

**Expected**
- Boundary SLL case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC038 — SLL with high-bit spill/truncation

**Purpose**
Verify truncation when shifted bits spill out of width.

**Stimulus**
- Use an operand with high bits set and shift left sufficiently.

**Checks**
- Result truncates consistently with width

**Expected**
- Truncation behavior correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## F. Shift Right Logical

### TC039 — SRL by 0

**Purpose**
Verify logical right shift by zero leaves operand unchanged.

**Stimulus**
- Apply SRL with shift amount 0.

**Checks**
- Result unchanged

**Expected**
- SRL by zero correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC040 — SRL by 1

**Purpose**
Verify logical right shift by one.

**Stimulus**
- Apply representative operand and shift amount 1.

**Checks**
- Result correct
- Zero fill from MSB side

**Expected**
- SRL by one correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC041 — SRL by small nonzero amount

**Purpose**
Verify typical logical right shift.

**Stimulus**
- Apply shift amounts such as 2 or 3.

**Checks**
- Result correct

**Expected**
- Typical SRL case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC042 — SRL by DATA_W-1

**Purpose**
Verify extreme boundary logical right shift.

**Stimulus**
- Apply shift amount `DATA_W-1`.

**Checks**
- Result matches width-limited logical shift semantics

**Expected**
- Boundary SRL case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC043 — SRL on all-ones operand

**Purpose**
Verify zero-fill semantics clearly on all-ones operand.

**Stimulus**
- Apply all-ones operand and right-shift logically.

**Checks**
- Zeros enter from MSB side

**Expected**
- Logical, not arithmetic, semantics preserved

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## G. Shift Right Arithmetic

### TC044 — SRA by 0

**Purpose**
Verify arithmetic right shift by zero leaves operand unchanged.

**Stimulus**
- Apply SRA with shift amount 0.

**Checks**
- Result unchanged

**Expected**
- SRA by zero correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC045 — SRA positive operand by 1

**Purpose**
Verify arithmetic right shift on positive values behaves as expected.

**Stimulus**
- Apply positive operand and shift by 1.

**Checks**
- Result correct
- No erroneous sign fill

**Expected**
- Positive SRA case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC046 — SRA negative operand by 1

**Purpose**
Verify arithmetic right shift sign extension on negative input.

**Stimulus**
- Apply negative operand and shift by 1.

**Checks**
- Sign bit replicated
- Result correct

**Expected**
- Negative SRA sign extension correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC047 — SRA negative operand by multiple bits

**Purpose**
Verify repeated sign extension for larger shifts.

**Stimulus**
- Apply negative operand and shift by multiple bits.

**Checks**
- Sign extension preserved across multiple positions

**Expected**
- Multi-bit negative SRA correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC048 — SRA by DATA_W-1

**Purpose**
Verify extreme boundary arithmetic right shift on both positive and negative inputs.

**Stimulus**
- Apply positive and negative operands with shift amount `DATA_W-1`.

**Checks**
- Result matches arithmetic shift semantics at width boundary

**Expected**
- Boundary SRA case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## H. Compare - Equality

### TC049 — EQ equal operands

**Purpose**
Verify equality comparator for equal values.

**Stimulus**
- Apply identical operands.

**Checks**
- `cmp_eq_o` asserted

**Expected**
- Equality detection correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC050 — EQ non-equal operands

**Purpose**
Verify equality comparator for non-equal values.

**Stimulus**
- Apply distinct operands.

**Checks**
- `cmp_eq_o` deasserted

**Expected**
- Non-equality detection correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC051 — EQ zero vs zero

**Purpose**
Verify equality on neutral special value.

**Stimulus**
- Apply `0` and `0`.

**Checks**
- `cmp_eq_o` asserted

**Expected**
- Zero equality correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC052 — EQ all ones vs all ones

**Purpose**
Verify equality on fully set pattern.

**Stimulus**
- Apply all-ones to both operands.

**Checks**
- `cmp_eq_o` asserted

**Expected**
- All-ones equality correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## I. Compare - Signed Less-Than

### TC053 — signed LT negative vs positive

**Purpose**
Verify signed less-than true case across sign boundary.

**Stimulus**
- Apply negative `op_a` and positive `op_b`.

**Checks**
- `cmp_lt_signed_o` asserted

**Expected**
- Signed negative < positive is true

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC054 — signed LT positive vs negative

**Purpose**
Verify signed less-than false case across sign boundary.

**Stimulus**
- Apply positive `op_a` and negative `op_b`.

**Checks**
- `cmp_lt_signed_o` deasserted

**Expected**
- Signed positive < negative is false

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC055 — signed LT equal operands

**Purpose**
Verify signed less-than false on equal values.

**Stimulus**
- Apply equal operands.

**Checks**
- `cmp_lt_signed_o` deasserted

**Expected**
- Equal values are not less-than

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC056 — signed LT small positive vs larger positive

**Purpose**
Verify signed ordering within positive range.

**Stimulus**
- Apply smaller positive and larger positive operands.

**Checks**
- `cmp_lt_signed_o` asserted when expected

**Expected**
- Positive signed ordering correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC057 — signed LT larger negative vs smaller negative

**Purpose**
Verify ordering among negative values.

**Stimulus**
- Apply two negative values with different magnitudes.

**Checks**
- `cmp_lt_signed_o` matches signed ordering

**Expected**
- Negative signed ordering correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## J. Compare - Unsigned Less-Than

### TC058 — unsigned LT small vs large

**Purpose**
Verify unsigned less-than true case.

**Stimulus**
- Apply smaller unsigned value in `op_a` and larger in `op_b`.

**Checks**
- `cmp_lt_unsigned_o` asserted

**Expected**
- Unsigned ordering correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC059 — unsigned LT large vs small

**Purpose**
Verify unsigned less-than false case.

**Stimulus**
- Apply larger unsigned value in `op_a` and smaller in `op_b`.

**Checks**
- `cmp_lt_unsigned_o` deasserted

**Expected**
- Unsigned ordering correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC060 — unsigned LT equal operands

**Purpose**
Verify unsigned less-than false on equality.

**Stimulus**
- Apply equal operands.

**Checks**
- `cmp_lt_unsigned_o` deasserted

**Expected**
- Equal values are not less-than

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC061 — same bit pattern, different signed vs unsigned meaning

**Purpose**
Verify semantic distinction between signed and unsigned compare on same bits.

**Stimulus**
- Use an example such as `8'hFF` vs `8'h01` during width sweep or directed compare.

**Checks**
- Signed LT and unsigned LT differ as expected

**Expected**
- Semantic distinction is explicit and correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## K. Branch Equality / Inequality

### TC062 — BR_EQ taken case

**Purpose**
Verify branch-equal taken behavior.

**Stimulus**
- Apply equal operands under BR_EQ opcode.

**Checks**
- `branch_taken_o` asserted

**Expected**
- BR_EQ taken only when operands are equal

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC063 — BR_EQ not taken case

**Purpose**
Verify branch-equal non-taken behavior.

**Stimulus**
- Apply non-equal operands under BR_EQ opcode.

**Checks**
- `branch_taken_o` deasserted

**Expected**
- BR_EQ not taken when operands differ

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC064 — BR_NE taken case

**Purpose**
Verify branch-not-equal taken behavior.

**Stimulus**
- Apply non-equal operands under BR_NE opcode.

**Checks**
- `branch_taken_o` asserted

**Expected**
- BR_NE taken when operands differ

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC065 — BR_NE not taken case

**Purpose**
Verify branch-not-equal non-taken behavior.

**Stimulus**
- Apply equal operands under BR_NE opcode.

**Checks**
- `branch_taken_o` deasserted

**Expected**
- BR_NE not taken when operands are equal

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## L. Branch Signed / Unsigned Less-Than

### TC066 — BR_LT signed true case

**Purpose**
Verify signed branch-less-than taken case.

**Stimulus**
- Apply negative vs positive operands under BR_LT.

**Checks**
- `branch_taken_o` asserted

**Expected**
- Signed branch uses signed compare intent

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC067 — BR_LT signed false case

**Purpose**
Verify signed branch-less-than non-taken case.

**Stimulus**
- Apply operands where signed LT is false under BR_LT.

**Checks**
- `branch_taken_o` deasserted

**Expected**
- Signed branch false case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC068 — BR_LTU unsigned true case

**Purpose**
Verify unsigned branch-less-than taken case.

**Stimulus**
- Apply smaller unsigned vs larger unsigned under BR_LTU.

**Checks**
- `branch_taken_o` asserted

**Expected**
- Unsigned branch uses unsigned compare intent

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC069 — BR_LTU unsigned false case

**Purpose**
Verify unsigned branch-less-than non-taken case.

**Stimulus**
- Apply larger unsigned vs smaller unsigned under BR_LTU.

**Checks**
- `branch_taken_o` deasserted

**Expected**
- Unsigned branch false case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC070 — same operands, BR_LT != BR_LTU

**Purpose**
Verify branch semantic distinction for same bit patterns.

**Stimulus**
- Use operands where signed and unsigned ordering differ.

**Checks**
- BR_LT and BR_LTU decisions differ as expected

**Expected**
- Branch semantic distinction is explicit and correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## M. Flags - Zero

### TC071 — zero flag from ADD

**Purpose**
Verify zero flag assertion from arithmetic addition result.

**Stimulus**
- Use operands that sum to zero where representable.

**Checks**
- `zero_o` asserted when `result_o == 0`

**Expected**
- Zero flag matches result

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC072 — zero flag from SUB

**Purpose**
Verify zero flag assertion from subtraction result.

**Stimulus**
- Apply equal operands under SUB.

**Checks**
- `zero_o` asserted

**Expected**
- Zero flag matches subtraction result

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC073 — zero flag from XOR identical operands

**Purpose**
Verify zero flag from logic-generated zero.

**Stimulus**
- Apply `A ^ A`.

**Checks**
- `zero_o` asserted

**Expected**
- Logic-generated zero handled correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC074 — zero flag deasserted on nonzero result

**Purpose**
Verify zero flag negative testing.

**Stimulus**
- Apply one or more operations with clearly nonzero results.

**Checks**
- `zero_o` deasserted

**Expected**
- Zero flag not falsely asserted

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## N. Flags - Negative

### TC075 — negative flag from arithmetic result

**Purpose**
Verify negative flag from arithmetic MSB-set result.

**Stimulus**
- Use ADD or SUB producing MSB-set result.

**Checks**
- `negative_o` tracks MSB of result

**Expected**
- Negative flag correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC076 — negative flag from logic result

**Purpose**
Verify negative flag from logic-generated MSB-set result.

**Stimulus**
- Use OR or XOR producing MSB-set result.

**Checks**
- `negative_o` asserted

**Expected**
- Negative flag correct for logic output

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC077 — negative flag from shift result

**Purpose**
Verify negative flag from shift-generated MSB-set result.

**Stimulus**
- Use SLL or SRA producing MSB-set result.

**Checks**
- `negative_o` asserted when MSB is high

**Expected**
- Negative flag correct for shift output

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC078 — negative flag cleared on positive result

**Purpose**
Verify negative flag negative testing.

**Stimulus**
- Use results with MSB cleared.

**Checks**
- `negative_o` deasserted

**Expected**
- Negative flag not falsely asserted

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## O. Flags - Carry

### TC079 — carry on ADD wraparound

**Purpose**
Verify carry flag on unsigned addition wraparound.

**Stimulus**
- Apply all-ones plus one.

**Checks**
- `carry_o` asserted

**Expected**
- Carry behavior correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC080 — carry absent on non-wrapping ADD

**Purpose**
Verify no false carry on safe addition.

**Stimulus**
- Apply moderate addition without wraparound.

**Checks**
- `carry_o` deasserted

**Expected**
- Carry not falsely asserted

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC081 — subtraction carry/borrow convention documented case 1

**Purpose**
Verify subtraction status behavior against first documented reference case.

**Stimulus**
- Apply one subtraction case from your carry/borrow convention notes.

**Checks**
- `carry_o` meaning matches documented convention

**Expected**
- Convention remains consistent

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC082 — subtraction carry/borrow convention documented case 2

**Purpose**
Verify subtraction status behavior against second documented reference case.

**Stimulus**
- Apply another subtraction case from your carry/borrow convention notes.

**Checks**
- `carry_o` meaning matches documented convention

**Expected**
- Convention remains consistent

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## P. Flags - Overflow

### TC083 — overflow on positive + positive -> negative

**Purpose**
Verify classic signed addition overflow case.

**Stimulus**
- Apply max positive signed plus positive increment.

**Checks**
- `overflow_o` asserted

**Expected**
- Signed overflow detected

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC084 — overflow on negative + negative -> positive

**Purpose**
Verify classic negative-side signed addition overflow case.

**Stimulus**
- Add two sufficiently negative values causing overflow.

**Checks**
- `overflow_o` asserted

**Expected**
- Signed overflow detected

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC085 — no overflow on mixed-sign addition

**Purpose**
Verify no false overflow on mixed-sign sum.

**Stimulus**
- Apply positive + negative and negative + positive cases without overflow.

**Checks**
- `overflow_o` deasserted

**Expected**
- Overflow not falsely asserted

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC086 — overflow on subtraction positive - negative

**Purpose**
Verify signed subtraction overflow case.

**Stimulus**
- Apply max positive minus negative one or similar.

**Checks**
- `overflow_o` asserted

**Expected**
- Signed subtraction overflow detected

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC087 — overflow on subtraction negative - positive

**Purpose**
Verify opposite signed subtraction overflow case.

**Stimulus**
- Apply min negative minus positive one or similar.

**Checks**
- `overflow_o` asserted

**Expected**
- Signed subtraction overflow detected

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC088 — no overflow on safe subtraction

**Purpose**
Verify no false overflow on safe subtract cases.

**Stimulus**
- Apply moderate subtraction cases within range.

**Checks**
- `overflow_o` deasserted

**Expected**
- Overflow not falsely asserted

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## Q. Multiply Enabled

### TC089 — MUL small positive numbers

**Purpose**
Verify basic multiply operation when `HAS_MUL = 1`.

**Stimulus**
- Apply small positive operands under MUL.

**Checks**
- Result correct
- Illegal not asserted

**Expected**
- Basic multiply works

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC090 — MUL by zero

**Purpose**
Verify multiply by zero behavior.

**Stimulus**
- Apply `A * 0` and `0 * A` under MUL.

**Checks**
- Result zero
- Zero flag follows result if defined that way

**Expected**
- Zero multiply correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC091 — MUL by one

**Purpose**
Verify multiply-by-one behavior.

**Stimulus**
- Apply `A * 1` under MUL.

**Checks**
- Result equals operand within width semantics

**Expected**
- Multiply-by-one correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC092 — MUL negative and positive operand case

**Purpose**
Verify signedness or documented bit-vector multiply policy.

**Stimulus**
- Apply one negative-looking bit pattern and one positive-looking pattern under MUL.

**Checks**
- Result follows documented multiply interpretation

**Expected**
- Multiply semantics remain explicit and documented

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC093 — MUL overflow/truncation case

**Purpose**
Verify product truncation when full product exceeds `DATA_W`.

**Stimulus**
- Use operands whose full product exceeds width.

**Checks**
- Result matches documented truncation policy

**Expected**
- Width-limited multiply behavior correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## R. Multiply Disabled

### TC094 — MUL opcode with HAS_MUL=0

**Purpose**
Verify unsupported multiply handling when multiply is disabled.

**Stimulus**
- Configure `HAS_MUL = 0`.
- Apply MUL opcode.

**Checks**
- `illegal_op_o` asserted or documented unsupported behavior observed
- No misleading valid-looking result

**Expected**
- Disabled multiply handled deterministically

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC095 — non-MUL opcode still works with HAS_MUL=0

**Purpose**
Verify disabling multiply does not break other operations.

**Stimulus**
- Configure `HAS_MUL = 0`.
- Run one or more non-MUL opcodes.

**Checks**
- Other legal operations still function correctly

**Expected**
- Non-MUL ops unaffected by disabled MUL

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## S. Illegal / Unsupported Opcodes

### TC096 — One illegal opcode value

**Purpose**
Verify deterministic handling for a single undefined encoding.

**Stimulus**
- Apply one unsupported opcode value.

**Checks**
- Illegal asserted
- Outputs deterministic

**Expected**
- Single illegal opcode case correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC097 — Several illegal opcode values

**Purpose**
Verify policy consistency across multiple undefined encodings.

**Stimulus**
- Apply several different undefined opcode values.

**Checks**
- Behavior consistent for all illegal encodings

**Expected**
- Unsupported-op policy is stable

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC098 — Illegal opcode after legal opcode

**Purpose**
Verify no stale valid result leaks into illegal-op case.

**Stimulus**
- Run a legal opcode then immediately an illegal opcode.

**Checks**
- Illegal case does not inherit previous legal result unexpectedly

**Expected**
- No stale-result leakage

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC099 — Legal opcode after illegal opcode

**Purpose**
Verify clean recovery from illegal opcode back to legal behavior.

**Stimulus**
- Run an illegal opcode then immediately a legal opcode.

**Checks**
- Legal op executes correctly afterward

**Expected**
- Recovery from illegal control is clean

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## T. Width Parameterization

### TC100 — DATA_W=8 arithmetic sanity

**Purpose**
Verify arithmetic behavior at 8-bit width.

**Stimulus**
- Configure `DATA_W = 8`.
- Run representative ADD/SUB cases including one carry or overflow case.

**Checks**
- 8-bit arithmetic semantics correct

**Expected**
- 8-bit arithmetic supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC101 — DATA_W=8 shift sanity

**Purpose**
Verify shift behavior at 8-bit width.

**Stimulus**
- Configure `DATA_W = 8`.
- Run representative SLL/SRL/SRA cases including boundary shift.

**Checks**
- 8-bit shift semantics correct

**Expected**
- 8-bit shift behavior supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC102 — DATA_W=8 compare signed/unsigned distinction

**Purpose**
Verify explicit signed-vs-unsigned behavior at 8-bit width.

**Stimulus**
- Configure `DATA_W = 8`.
- Use a case such as `8'hFF` vs `8'h01`.

**Checks**
- Signed and unsigned comparisons differ as expected

**Expected**
- 8-bit compare semantics correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC103 — DATA_W=16 arithmetic sanity

**Purpose**
Verify arithmetic behavior at 16-bit width.

**Stimulus**
- Configure `DATA_W = 16`.
- Run representative ADD/SUB cases including one carry or overflow case.

**Checks**
- 16-bit arithmetic semantics correct

**Expected**
- 16-bit arithmetic supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC104 — DATA_W=16 shift sanity

**Purpose**
Verify shift behavior at 16-bit width.

**Stimulus**
- Configure `DATA_W = 16`.
- Run representative shift cases including boundary shift.

**Checks**
- 16-bit shift semantics correct

**Expected**
- 16-bit shift behavior supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC105 — DATA_W=16 compare signed/unsigned distinction

**Purpose**
Verify explicit signed-vs-unsigned behavior at 16-bit width.

**Stimulus**
- Configure `DATA_W = 16`.
- Use a representative signed/unsigned distinction case.

**Checks**
- Signed and unsigned comparisons differ as expected

**Expected**
- 16-bit compare semantics correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC106 — DATA_W=32 arithmetic sanity

**Purpose**
Verify arithmetic behavior at 32-bit width.

**Stimulus**
- Configure `DATA_W = 32`.
- Run representative ADD/SUB cases including one carry or overflow case.

**Checks**
- 32-bit arithmetic semantics correct

**Expected**
- 32-bit arithmetic supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC107 — DATA_W=32 shift sanity

**Purpose**
Verify shift behavior at 32-bit width.

**Stimulus**
- Configure `DATA_W = 32`.
- Run representative shift cases including boundary shift.

**Checks**
- 32-bit shift semantics correct

**Expected**
- 32-bit shift behavior supported correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC108 — DATA_W=32 compare signed/unsigned distinction

**Purpose**
Verify explicit signed-vs-unsigned behavior at 32-bit width.

**Stimulus**
- Configure `DATA_W = 32`.
- Use a representative signed/unsigned distinction case.

**Checks**
- Signed and unsigned comparisons differ as expected

**Expected**
- 32-bit compare semantics correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## U. Result / Flag Consistency

### TC109 — Result and zero consistency

**Purpose**
Verify zero flag always matches zero-valued result for relevant operations.

**Stimulus**
- Run a mix of zero and nonzero result cases.

**Checks**
- `zero_o` asserted iff `result_o == 0` where flag is defined

**Expected**
- Zero flag consistent with result

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC110 — Result and negative consistency

**Purpose**
Verify negative flag tracks result MSB for relevant operations.

**Stimulus**
- Run a mix of MSB-set and MSB-clear result cases.

**Checks**
- `negative_o` matches result MSB where flag is defined

**Expected**
- Negative flag consistent with result

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC111 — Branch matches compare intent

**Purpose**
Verify branch outputs agree with selected comparison semantics.

**Stimulus**
- For each branch opcode, apply one taken and one not-taken case.

**Checks**
- Branch decision matches intended compare rule

**Expected**
- Branch output aligned with compare meaning

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC112 — Compare outputs stable across unrelated opcodes

**Purpose**
Verify compare outputs are always driven deterministically if exposed continuously.

**Stimulus**
- Exercise unrelated opcodes around compare cases.

**Checks**
- Compare outputs remain deterministic
- No residue/ambiguity

**Expected**
- Compare-side outputs stable and well-defined

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## V. Robustness / Regression-Style Sequences

### TC113 — Mixed opcode directed sequence

**Purpose**
Verify a compact mixed sequence of operation classes behaves correctly end-to-end.

**Stimulus**
- Run add, logic, shift, compare, branch in one directed sequence.

**Checks**
- Each step correct
- No stale behavior across op-class transitions

**Expected**
- Mixed sequence handled correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC114 — Repeated same opcode with different operands

**Purpose**
Verify repeated same-op runs with changing operands remain clean.

**Stimulus**
- Hold opcode fixed and vary operands across multiple vectors.

**Checks**
- No hidden state or stale data behavior

**Expected**
- Repeated same-op sequence correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC115 — Alternating legal and illegal opcodes

**Purpose**
Verify clean deterministic transitions across legal/illegal opcode boundaries.

**Stimulus**
- Alternate supported and unsupported opcode values.

**Checks**
- Illegal cases flagged
- Legal cases still correct

**Expected**
- Transition robustness correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC116 — Sequence including width-boundary values

**Purpose**
Verify robustness on all-zero, all-ones, max positive, and min negative patterns.

**Stimulus**
- Run a short sequence using boundary operand values.

**Checks**
- Results and flags remain correct for each boundary pattern

**Expected**
- Boundary sequence handled correctly

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC117 — Sequence including compare/branch alternation

**Purpose**
Verify compare outputs and branch decisions remain aligned across alternating operations.

**Stimulus**
- Alternate compare-style and branch-style opcodes using related operands.

**Checks**
- Compare semantics and branch outputs remain aligned

**Expected**
- Compare/branch alternation correct

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

## W. Optional Waveform-Evidence Testcases

### TC118 — Waveform: carry-out case

**Purpose**
Capture visual evidence for unsigned carry generation.

**Stimulus**
- Run a carry-out addition case such as all-ones plus one.
- Open waveform.

**Checks**
- Operands, result, carry, overflow visible and aligned

**Expected**
- Screenshot saved showing carry-out behavior

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC119 — Waveform: signed overflow case

**Purpose**
Capture visual evidence for signed overflow generation.

**Stimulus**
- Run max signed positive plus one or equivalent.
- Open waveform.

**Checks**
- Operands, result wrap, and overflow visible together

**Expected**
- Screenshot saved showing signed overflow

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC120 — Waveform: arithmetic right shift on negative number

**Purpose**
Capture visual evidence for sign extension under SRA.

**Stimulus**
- Run SRA on a negative operand.
- Open waveform.

**Checks**
- Input sign bit and shifted sign extension visible

**Expected**
- Screenshot saved showing arithmetic-right-shift semantics

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC121 — Waveform: signed vs unsigned compare distinction

**Purpose**
Capture visual evidence that signed and unsigned compare differ on same operand bits.

**Stimulus**
- Run a compare case such as `8'hFF` vs `8'h01`.
- Open waveform.

**Checks**
- Signed and unsigned compare outputs visible together

**Expected**
- Screenshot saved showing semantic distinction

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC122 — Waveform: branch taken / not taken contrast

**Purpose**
Capture visual evidence of branch decision behavior.

**Stimulus**
- Run one taken and one not-taken branch case.
- Open waveform.

**Checks**
- Operands, opcode, and `branch_taken_o` visible together

**Expected**
- Screenshot saved showing branch contrast

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---

### TC123 — Waveform: illegal opcode response

**Purpose**
Capture visual evidence for deterministic illegal-op behavior.

**Stimulus**
- Run an unsupported opcode case.
- Open waveform.

**Checks**
- Opcode, `illegal_op_o`, result, and relevant flags visible

**Expected**
- Screenshot saved showing illegal-op handling

**Result**
TODO

**Evidence**
- Log:
- Waveform:
- Screenshot:

**Notes**
-

---
