`timescale 1ns/1ps

module exec_unit_testbench #(
  parameter int DATA_W = 32,
  parameter bit HAS_MUL = 1
);

  import exec_defs_pkg::*;

  localparam int SHAMT_W = (DATA_W <= 1) ? 1 : $clog2(DATA_W);

  logic [DATA_W-1:0] op_a;
  logic [DATA_W-1:0] op_b;
  logic [4:0]        op_sel;

  logic [DATA_W-1:0] result;
  logic              zero;
  logic              negative;
  logic              carry;
  logic              overflow;
  logic              cmp_eq;
  logic              cmp_lt_signed;
  logic              cmp_lt_unsigned;
  logic              branch_taken;
  logic              illegal_op;

  int subcase_count;
  int pass_count;
  int error_count;
  int skip_count;

  logic [DATA_W-1:0] ones_v;
  logic [DATA_W-1:0] max_pos_v;
  logic [DATA_W-1:0] min_neg_v;
  logic [DATA_W-1:0] pat_a_v;
  logic [DATA_W-1:0] pat_b_v;

  exec_unit #(
    .DATA_W (DATA_W),
    .HAS_MUL(HAS_MUL)
  ) dut (
    .op_a_i            (op_a),
    .op_b_i            (op_b),
    .op_sel_i          (op_sel),
    .result_o          (result),
    .zero_o            (zero),
    .negative_o        (negative),
    .carry_o           (carry),
    .overflow_o        (overflow),
    .cmp_eq_o          (cmp_eq),
    .cmp_lt_signed_o   (cmp_lt_signed),
    .cmp_lt_unsigned_o (cmp_lt_unsigned),
    .branch_taken_o    (branch_taken),
    .illegal_op_o      (illegal_op)
  );

  function automatic logic [DATA_W-1:0] mk_ones();
    mk_ones = {DATA_W{1'b1}};
  endfunction

  function automatic logic [DATA_W-1:0] mk_max_pos();
    mk_max_pos = {1'b0, {(DATA_W-1){1'b1}}};
  endfunction

  function automatic logic [DATA_W-1:0] mk_min_neg();
    mk_min_neg = {1'b1, {(DATA_W-1){1'b0}}};
  endfunction

  function automatic logic [DATA_W-1:0] mk_pat_a();
    logic [DATA_W-1:0] tmp;
    int idx;
    begin
      tmp = '0;
      for (idx = 0; idx < DATA_W; idx = idx + 1) begin
        tmp[idx] = (idx % 2 == 0);
      end
      mk_pat_a = tmp;
    end
  endfunction

  function automatic logic [DATA_W-1:0] mk_pat_b();
    logic [DATA_W-1:0] tmp;
    int idx;
    begin
      tmp = '0;
      for (idx = 0; idx < DATA_W; idx = idx + 1) begin
        tmp[idx] = (idx % 4 == 1) || (idx % 4 == 2);
      end
      mk_pat_b = tmp;
    end
  endfunction

  function automatic logic ref_cmp_eq(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b
  );
    ref_cmp_eq = (a == b);
  endfunction

  function automatic logic ref_cmp_lt_signed(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b
  );
    ref_cmp_lt_signed = ($signed(a) < $signed(b));
  endfunction

  function automatic logic ref_cmp_lt_unsigned(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b
  );
    ref_cmp_lt_unsigned = (a < b);
  endfunction

  function automatic logic ref_branch_taken(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b,
    input logic [4:0]        op
  );
    begin
      unique case (op)
        OP_BR_EQ : ref_branch_taken = ref_cmp_eq(a, b);
        OP_BR_NE : ref_branch_taken = ~ref_cmp_eq(a, b);
        OP_BR_LT : ref_branch_taken = ref_cmp_lt_signed(a, b);
        OP_BR_LTU: ref_branch_taken = ref_cmp_lt_unsigned(a, b);
        default  : ref_branch_taken = 1'b0;
      endcase
    end
  endfunction

  function automatic logic ref_illegal(
    input logic [4:0] op
  );
    begin
      unique case (op)
        OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR,
        OP_SLL, OP_SRL, OP_SRA,
        OP_CMPEQ, OP_CMPLT, OP_CMPLTU,
        OP_BR_EQ, OP_BR_NE, OP_BR_LT, OP_BR_LTU:
          ref_illegal = 1'b0;
        OP_MUL:
          ref_illegal = (HAS_MUL == 1'b0);
        default:
          ref_illegal = 1'b1;
      endcase
    end
  endfunction

  function automatic logic [DATA_W-1:0] ref_result(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b,
    input logic [4:0]        op
  );
    logic [DATA_W:0]       tmp_add;
    logic [DATA_W:0]       tmp_sub;
    logic [(2*DATA_W)-1:0] tmp_mul;
    begin
      tmp_add = {1'b0, a} + {1'b0, b};
      tmp_sub = {1'b0, a} + {1'b0, ~b} + {{DATA_W{1'b0}}, 1'b1};
      tmp_mul = a * b;

      unique case (op)
        OP_ADD   : ref_result = tmp_add[DATA_W-1:0];
        OP_SUB   : ref_result = tmp_sub[DATA_W-1:0];
        OP_AND   : ref_result = a & b;
        OP_OR    : ref_result = a | b;
        OP_XOR   : ref_result = a ^ b;
        OP_SLL   : ref_result = a << b[SHAMT_W-1:0];
        OP_SRL   : ref_result = a >> b[SHAMT_W-1:0];
        OP_SRA   : ref_result = $signed(a) >>> b[SHAMT_W-1:0];
        OP_CMPEQ : ref_result = {{(DATA_W-1){1'b0}}, ref_cmp_eq(a, b)};
        OP_CMPLT : ref_result = {{(DATA_W-1){1'b0}}, ref_cmp_lt_signed(a, b)};
        OP_CMPLTU: ref_result = {{(DATA_W-1){1'b0}}, ref_cmp_lt_unsigned(a, b)};
        OP_BR_EQ,
        OP_BR_NE,
        OP_BR_LT,
        OP_BR_LTU: ref_result = {{(DATA_W-1){1'b0}}, ref_branch_taken(a, b, op)};
        OP_MUL   : ref_result = HAS_MUL ? tmp_mul[DATA_W-1:0] : '0;
        default  : ref_result = '0;
      endcase
    end
  endfunction

  function automatic logic ref_carry(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b,
    input logic [4:0]        op
  );
    logic [DATA_W:0] tmp;
    begin
      ref_carry = 1'b0;
      unique case (op)
        OP_ADD: begin
          tmp = {1'b0, a} + {1'b0, b};
          ref_carry = tmp[DATA_W];
        end
        OP_SUB: begin
          tmp = {1'b0, a} + {1'b0, ~b} + {{DATA_W{1'b0}}, 1'b1};
          ref_carry = tmp[DATA_W];
        end
        default: ref_carry = 1'b0;
      endcase
    end
  endfunction

  function automatic logic ref_overflow(
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b,
    input logic [4:0]        op
  );
    logic [DATA_W-1:0] res;
    begin
      res = ref_result(a, b, op);
      unique case (op)
        OP_ADD:
          ref_overflow = (~(a[DATA_W-1] ^ b[DATA_W-1])) &
                         (res[DATA_W-1] ^ a[DATA_W-1]);
        OP_SUB:
          ref_overflow = (a[DATA_W-1] ^ b[DATA_W-1]) &
                         (res[DATA_W-1] ^ a[DATA_W-1]);
        default:
          ref_overflow = 1'b0;
      endcase
    end
  endfunction

  task automatic skip_case(
    input string tc_id,
    input string reason
  );
    begin
      skip_count++;
      $display("SKIP [%0s] %0s", tc_id, reason);
    end
  endtask

  task automatic run_case(
    input string             tc_id,
    input string             desc,
    input logic [DATA_W-1:0] a,
    input logic [DATA_W-1:0] b,
    input logic [4:0]        op
  );
    logic [DATA_W-1:0] exp_result;
    logic              exp_zero;
    logic              exp_negative;
    logic              exp_carry;
    logic              exp_overflow;
    logic              exp_cmp_eq;
    logic              exp_cmp_lt_signed;
    logic              exp_cmp_lt_unsigned;
    logic              exp_branch_taken;
    logic              exp_illegal;
    begin
      exp_result          = ref_result(a, b, op);
      exp_zero            = (exp_result == '0);
      exp_negative        = exp_result[DATA_W-1];
      exp_carry           = ref_carry(a, b, op);
      exp_overflow        = ref_overflow(a, b, op);
      exp_cmp_eq          = ref_cmp_eq(a, b);
      exp_cmp_lt_signed   = ref_cmp_lt_signed(a, b);
      exp_cmp_lt_unsigned = ref_cmp_lt_unsigned(a, b);
      exp_branch_taken    = ref_branch_taken(a, b, op);
      exp_illegal         = ref_illegal(op);

      op_a   = a;
      op_b   = b;
      op_sel = op;
      #1;

      subcase_count++;

      if (result !== exp_result ||
          zero !== exp_zero ||
          negative !== exp_negative ||
          carry !== exp_carry ||
          overflow !== exp_overflow ||
          cmp_eq !== exp_cmp_eq ||
          cmp_lt_signed !== exp_cmp_lt_signed ||
          cmp_lt_unsigned !== exp_cmp_lt_unsigned ||
          branch_taken !== exp_branch_taken ||
          illegal_op !== exp_illegal) begin
        error_count++;
        $display("FAIL [%0s] %0s", tc_id, desc);
        $display("  DATA_W=%0d HAS_MUL=%0d a=0x%0h b=0x%0h op=0x%0h", DATA_W, HAS_MUL, a, b, op);
        $display("  result      got=0x%0h exp=0x%0h", result, exp_result);
        $display("  zero        got=%0b exp=%0b", zero, exp_zero);
        $display("  negative    got=%0b exp=%0b", negative, exp_negative);
        $display("  carry       got=%0b exp=%0b", carry, exp_carry);
        $display("  overflow    got=%0b exp=%0b", overflow, exp_overflow);
        $display("  cmp_eq      got=%0b exp=%0b", cmp_eq, exp_cmp_eq);
        $display("  cmp_lt_s    got=%0b exp=%0b", cmp_lt_signed, exp_cmp_lt_signed);
        $display("  cmp_lt_u    got=%0b exp=%0b", cmp_lt_unsigned, exp_cmp_lt_unsigned);
        $display("  branch      got=%0b exp=%0b", branch_taken, exp_branch_taken);
        $display("  illegal     got=%0b exp=%0b", illegal_op, exp_illegal);
      end else begin
        pass_count++;
        $display("PASS [%0s] %0s", tc_id, desc);
      end
    end
  endtask

  initial begin
    subcase_count = 0;
    pass_count    = 0;
    error_count   = 0;
    skip_count    = 0;

    op_a          = '0;
    op_b          = '0;
    op_sel        = '0;

    ones_v        = mk_ones();
    max_pos_v     = mk_max_pos();
    min_neg_v     = mk_min_neg();
    pat_a_v       = mk_pat_a();
    pat_b_v       = mk_pat_b();

    $display("============================================================");
    $display("Starting exec_unit_testbench DATA_W=%0d HAS_MUL=%0d", DATA_W, HAS_MUL);
    $display("============================================================");

    run_case("TC001", "Single ADD smoke test", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC002", "One representative vector per legal opcode - ADD", DATA_W'(9), DATA_W'(4), OP_ADD);
    run_case("TC002", "One representative vector per legal opcode - SUB", DATA_W'(9), DATA_W'(4), OP_SUB);
    run_case("TC002", "One representative vector per legal opcode - AND", pat_a_v, pat_b_v, OP_AND);
    run_case("TC002", "One representative vector per legal opcode - OR", pat_a_v, pat_b_v, OP_OR);
    run_case("TC002", "One representative vector per legal opcode - XOR", pat_a_v, pat_b_v, OP_XOR);
    run_case("TC002", "One representative vector per legal opcode - SLL", pat_a_v, DATA_W'(1), OP_SLL);
    run_case("TC002", "One representative vector per legal opcode - SRL", pat_a_v, DATA_W'(1), OP_SRL);
    run_case("TC002", "One representative vector per legal opcode - SRA", min_neg_v, DATA_W'(1), OP_SRA);
    run_case("TC002", "One representative vector per legal opcode - CMPEQ", DATA_W'(5), DATA_W'(5), OP_CMPEQ);
    run_case("TC002", "One representative vector per legal opcode - CMPLT", DATA_W'(-2), DATA_W'(1), OP_CMPLT);
    run_case("TC002", "One representative vector per legal opcode - CMPLTU", DATA_W'(1), ones_v, OP_CMPLTU);
    run_case("TC002", "One representative vector per legal opcode - BR_EQ", DATA_W'(5), DATA_W'(5), OP_BR_EQ);
    run_case("TC002", "One representative vector per legal opcode - BR_NE", DATA_W'(5), DATA_W'(6), OP_BR_NE);
    run_case("TC002", "One representative vector per legal opcode - BR_LT", DATA_W'(-1), DATA_W'(1), OP_BR_LT);
    run_case("TC002", "One representative vector per legal opcode - BR_LTU", DATA_W'(1), ones_v, OP_BR_LTU);
    run_case("TC003", "Back-to-back opcode switching - ADD", DATA_W'(4), DATA_W'(2), OP_ADD);
    run_case("TC003", "Back-to-back opcode switching - XOR", pat_a_v, pat_b_v, OP_XOR);
    run_case("TC003", "Back-to-back opcode switching - SRA", min_neg_v, DATA_W'(1), OP_SRA);
    run_case("TC003", "Back-to-back opcode switching - BR_EQ", DATA_W'(8), DATA_W'(8), OP_BR_EQ);
    run_case("TC004", "Back-to-back operand switching under same opcode - ADD #1", DATA_W'(1), DATA_W'(2), OP_ADD);
    run_case("TC004", "Back-to-back operand switching under same opcode - ADD #2", DATA_W'(7), DATA_W'(9), OP_ADD);
    run_case("TC004", "Back-to-back operand switching under same opcode - ADD #3", ones_v, DATA_W'(1), OP_ADD);
    run_case("TC005", "Basic illegal opcode smoke", DATA_W'(0), DATA_W'(0), 5'h1F);
    run_case("TC006", "ADD small positive numbers #1", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC006", "ADD small positive numbers #2", DATA_W'(5), DATA_W'(4), OP_ADD);
    run_case("TC007", "ADD zero plus zero", DATA_W'(0), DATA_W'(0), OP_ADD);
    run_case("TC008", "ADD zero plus positive", DATA_W'(0), DATA_W'(9), OP_ADD);
    run_case("TC009", "ADD positive plus negative without overflow", DATA_W'(7), DATA_W'(-2), OP_ADD);
    run_case("TC010", "ADD negative plus positive without overflow", DATA_W'(-7), DATA_W'(2), OP_ADD);
    run_case("TC011", "ADD negative plus negative without overflow", DATA_W'(-4), DATA_W'(-3), OP_ADD);
    run_case("TC012", "ADD max unsigned plus 1", ones_v, DATA_W'(1), OP_ADD);
    run_case("TC013", "ADD max signed positive plus 1", max_pos_v, DATA_W'(1), OP_ADD);
    run_case("TC014", "ADD min signed negative plus negative", min_neg_v, ones_v, OP_ADD);
    run_case("TC015", "ADD result exactly zero through cancellation", DATA_W'(5), DATA_W'(-5), OP_ADD);
    run_case("TC016", "SUB small positive numbers", DATA_W'(7), DATA_W'(2), OP_SUB);
    run_case("TC017", "SUB equal operands", DATA_W'(5), DATA_W'(5), OP_SUB);
    run_case("TC018", "SUB producing negative result", DATA_W'(2), DATA_W'(7), OP_SUB);
    run_case("TC019", "SUB zero minus positive", DATA_W'(0), DATA_W'(9), OP_SUB);
    run_case("TC020", "SUB positive minus zero", DATA_W'(9), DATA_W'(0), OP_SUB);
    run_case("TC021", "SUB no-borrow style case", DATA_W'(9), DATA_W'(4), OP_SUB);
    run_case("TC022", "SUB borrow style case", DATA_W'(4), DATA_W'(9), OP_SUB);
    run_case("TC023", "SUB max positive minus (-1)", max_pos_v, ones_v, OP_SUB);
    run_case("TC024", "SUB min negative minus 1", min_neg_v, DATA_W'(1), OP_SUB);
    run_case("TC025", "SUB all-ones minus one", ones_v, DATA_W'(1), OP_SUB);
    run_case("TC026", "AND mixed patterns", pat_a_v, pat_b_v, OP_AND);
    run_case("TC027", "OR mixed patterns", pat_a_v, pat_b_v, OP_OR);
    run_case("TC028", "XOR mixed patterns", pat_a_v, pat_b_v, OP_XOR);
    run_case("TC029", "AND all zeros", DATA_W'(0), DATA_W'(0), OP_AND);
    run_case("TC030", "OR all zeros", DATA_W'(0), DATA_W'(0), OP_OR);
    run_case("TC031", "XOR identical operands", pat_a_v, pat_a_v, OP_XOR);
    run_case("TC032", "OR all ones", ones_v, pat_a_v, OP_OR);
    run_case("TC033", "AND all ones with mixed operand", ones_v, pat_a_v, OP_AND);
    run_case("TC034", "SLL by 0", pat_a_v, DATA_W'(0), OP_SLL);
    run_case("TC035", "SLL by 1", DATA_W'(1), DATA_W'(1), OP_SLL);
    run_case("TC036", "SLL by small nonzero amount", pat_b_v, DATA_W'(2), OP_SLL);
    run_case("TC037", "SLL by DATA_W-1", DATA_W'(1), DATA_W'(DATA_W-1), OP_SLL);
    run_case("TC038", "SLL with high-bit spill/truncation", ones_v, DATA_W'(1), OP_SLL);
    run_case("TC039", "SRL by 0", pat_b_v, DATA_W'(0), OP_SRL);
    run_case("TC040", "SRL by 1", pat_b_v, DATA_W'(1), OP_SRL);
    run_case("TC041", "SRL by small nonzero amount", pat_b_v, DATA_W'(3), OP_SRL);
    run_case("TC042", "SRL by DATA_W-1", ones_v, DATA_W'(DATA_W-1), OP_SRL);
    run_case("TC043", "SRL on all-ones operand", ones_v, DATA_W'(1), OP_SRL);
    run_case("TC044", "SRA by 0", min_neg_v, DATA_W'(0), OP_SRA);
    run_case("TC045", "SRA positive operand by 1", DATA_W'(16), DATA_W'(1), OP_SRA);
    run_case("TC046", "SRA negative operand by 1", min_neg_v, DATA_W'(1), OP_SRA);
    run_case("TC047", "SRA negative operand by multiple bits", ones_v, DATA_W'(3), OP_SRA);
    run_case("TC048", "SRA by DATA_W-1", ones_v, DATA_W'(DATA_W-1), OP_SRA);
    run_case("TC049", "EQ equal operands", DATA_W'(5), DATA_W'(5), OP_CMPEQ);
    run_case("TC050", "EQ non-equal operands", DATA_W'(5), DATA_W'(6), OP_CMPEQ);
    run_case("TC051", "EQ zero vs zero", DATA_W'(0), DATA_W'(0), OP_CMPEQ);
    run_case("TC052", "EQ all ones vs all ones", ones_v, ones_v, OP_CMPEQ);
    run_case("TC053", "signed LT negative vs positive", DATA_W'(-1), DATA_W'(1), OP_CMPLT);
    run_case("TC054", "signed LT positive vs negative", DATA_W'(1), DATA_W'(-1), OP_CMPLT);
    run_case("TC055", "signed LT equal operands", DATA_W'(4), DATA_W'(4), OP_CMPLT);
    run_case("TC056", "signed LT small positive vs larger positive", DATA_W'(2), DATA_W'(7), OP_CMPLT);
    run_case("TC057", "signed LT larger negative vs smaller negative", DATA_W'(-2), DATA_W'(-7), OP_CMPLT);
    run_case("TC058", "unsigned LT small vs large", DATA_W'(1), ones_v, OP_CMPLTU);
    run_case("TC059", "unsigned LT large vs small", ones_v, DATA_W'(1), OP_CMPLTU);
    run_case("TC060", "unsigned LT equal operands", DATA_W'(4), DATA_W'(4), OP_CMPLTU);
    run_case("TC061", "same bit pattern, different signed vs unsigned meaning", ones_v, DATA_W'(1), OP_CMPLT);
    run_case("TC061", "same bit pattern, different signed vs unsigned meaning (unsigned view)", ones_v, DATA_W'(1), OP_CMPLTU);
    run_case("TC062", "BR_EQ taken case", DATA_W'(5), DATA_W'(5), OP_BR_EQ);
    run_case("TC063", "BR_EQ not taken case", DATA_W'(5), DATA_W'(6), OP_BR_EQ);
    run_case("TC064", "BR_NE taken case", DATA_W'(5), DATA_W'(6), OP_BR_NE);
    run_case("TC065", "BR_NE not taken case", DATA_W'(5), DATA_W'(5), OP_BR_NE);
    run_case("TC066", "BR_LT signed true case", DATA_W'(-1), DATA_W'(1), OP_BR_LT);
    run_case("TC067", "BR_LT signed false case", DATA_W'(1), DATA_W'(-1), OP_BR_LT);
    run_case("TC068", "BR_LTU unsigned true case", DATA_W'(1), ones_v, OP_BR_LTU);
    run_case("TC069", "BR_LTU unsigned false case", ones_v, DATA_W'(1), OP_BR_LTU);
    run_case("TC070", "same operands, BR_LT != BR_LTU (signed view)", ones_v, DATA_W'(1), OP_BR_LT);
    run_case("TC070", "same operands, BR_LT != BR_LTU (unsigned view)", ones_v, DATA_W'(1), OP_BR_LTU);
    run_case("TC071", "zero flag from ADD", DATA_W'(5), DATA_W'(-5), OP_ADD);
    run_case("TC072", "zero flag from SUB", DATA_W'(9), DATA_W'(9), OP_SUB);
    run_case("TC073", "zero flag from XOR identical operands", pat_b_v, pat_b_v, OP_XOR);
    run_case("TC074", "zero flag deasserted on nonzero result", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC075", "negative flag from arithmetic result", DATA_W'(2), DATA_W'(7), OP_SUB);
    run_case("TC076", "negative flag from logic result", ones_v, DATA_W'(0), OP_OR);
    run_case("TC077", "negative flag from shift result", DATA_W'(1), DATA_W'(DATA_W-1), OP_SLL);
    run_case("TC078", "negative flag cleared on positive result", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC079", "carry on ADD wraparound", ones_v, DATA_W'(1), OP_ADD);
    run_case("TC080", "carry absent on non-wrapping ADD", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC081", "subtraction carry/borrow convention documented case 1", DATA_W'(9), DATA_W'(4), OP_SUB);
    run_case("TC082", "subtraction carry/borrow convention documented case 2", DATA_W'(4), DATA_W'(9), OP_SUB);
    run_case("TC083", "overflow on positive + positive -> negative", max_pos_v, DATA_W'(1), OP_ADD);
    run_case("TC084", "overflow on negative + negative -> positive", min_neg_v, min_neg_v, OP_ADD);
    run_case("TC085", "no overflow on mixed-sign addition", DATA_W'(7), DATA_W'(-2), OP_ADD);
    run_case("TC086", "overflow on subtraction positive - negative", max_pos_v, ones_v, OP_SUB);
    run_case("TC087", "overflow on subtraction negative - positive", min_neg_v, DATA_W'(1), OP_SUB);
    run_case("TC088", "no overflow on safe subtraction", DATA_W'(9), DATA_W'(4), OP_SUB);
    run_case("TC096", "One illegal opcode value", DATA_W'(0), DATA_W'(0), 5'h1F);
    run_case("TC097", "Several illegal opcode values #1", DATA_W'(0), DATA_W'(0), 5'h1E);
    run_case("TC097", "Several illegal opcode values #2", DATA_W'(1), DATA_W'(2), 5'h1D);
    run_case("TC098", "Illegal opcode after legal opcode", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC098", "Illegal opcode after legal opcode - illegal", DATA_W'(0), DATA_W'(0), 5'h1F);
    run_case("TC099", "Legal opcode after illegal opcode", DATA_W'(0), DATA_W'(0), 5'h1F);
    run_case("TC099", "Legal opcode after illegal opcode - recovery", DATA_W'(7), DATA_W'(2), OP_SUB);
    run_case("TC109", "Result and zero consistency", DATA_W'(9), DATA_W'(9), OP_SUB);
    run_case("TC109", "Result and zero consistency nonzero", DATA_W'(9), DATA_W'(4), OP_SUB);
    run_case("TC110", "Result and negative consistency", DATA_W'(2), DATA_W'(7), OP_SUB);
    run_case("TC111", "Branch matches compare intent - EQ", DATA_W'(6), DATA_W'(6), OP_BR_EQ);
    run_case("TC111", "Branch matches compare intent - LT", DATA_W'(-1), DATA_W'(1), OP_BR_LT);
    run_case("TC112", "Compare outputs stable across unrelated opcodes - AND", pat_a_v, pat_b_v, OP_AND);
    run_case("TC112", "Compare outputs stable across unrelated opcodes - SLL", pat_a_v, DATA_W'(1), OP_SLL);
    run_case("TC113", "Mixed opcode directed sequence - ADD", DATA_W'(2), DATA_W'(3), OP_ADD);
    run_case("TC113", "Mixed opcode directed sequence - XOR", pat_a_v, pat_b_v, OP_XOR);
    run_case("TC113", "Mixed opcode directed sequence - SRA", min_neg_v, DATA_W'(1), OP_SRA);
    run_case("TC113", "Mixed opcode directed sequence - BR_NE", DATA_W'(5), DATA_W'(6), OP_BR_NE);
    run_case("TC114", "Repeated same opcode with different operands #1", DATA_W'(1), DATA_W'(2), OP_ADD);
    run_case("TC114", "Repeated same opcode with different operands #2", DATA_W'(3), DATA_W'(4), OP_ADD);
    run_case("TC114", "Repeated same opcode with different operands #3", DATA_W'(5), DATA_W'(6), OP_ADD);
    run_case("TC115", "Alternating legal and illegal opcodes - legal", DATA_W'(3), DATA_W'(4), OP_ADD);
    run_case("TC115", "Alternating legal and illegal opcodes - illegal", DATA_W'(0), DATA_W'(0), 5'h1F);
    run_case("TC115", "Alternating legal and illegal opcodes - legal2", pat_a_v, pat_b_v, OP_XOR);
    run_case("TC116", "Sequence including width-boundary values - all zeros", DATA_W'(0), DATA_W'(0), OP_ADD);
    run_case("TC116", "Sequence including width-boundary values - all ones", ones_v, ones_v, OP_XOR);
    run_case("TC116", "Sequence including width-boundary values - max positive", max_pos_v, DATA_W'(1), OP_ADD);
    run_case("TC116", "Sequence including width-boundary values - min negative", min_neg_v, DATA_W'(1), OP_SUB);
    run_case("TC117", "Sequence including compare/branch alternation - compare", ones_v, DATA_W'(1), OP_CMPLT);
    run_case("TC117", "Sequence including compare/branch alternation - branch", ones_v, DATA_W'(1), OP_BR_LT);
    run_case("TC118", "Waveform: carry-out case", ones_v, DATA_W'(1), OP_ADD);
    run_case("TC119", "Waveform: signed overflow case", max_pos_v, DATA_W'(1), OP_ADD);
    run_case("TC120", "Waveform: arithmetic right shift on negative number", min_neg_v, DATA_W'(1), OP_SRA);
    run_case("TC121", "Waveform: signed vs unsigned compare distinction", ones_v, DATA_W'(1), OP_CMPLT);
    run_case("TC121", "Waveform: signed vs unsigned compare distinction (unsigned view)", ones_v, DATA_W'(1), OP_CMPLTU);
    run_case("TC122", "Waveform: branch taken / not taken contrast - taken", DATA_W'(5), DATA_W'(5), OP_BR_EQ);
    run_case("TC122", "Waveform: branch taken / not taken contrast - not taken", DATA_W'(5), DATA_W'(6), OP_BR_EQ);
    run_case("TC123", "Waveform: illegal opcode response", DATA_W'(0), DATA_W'(0), 5'h1F);

    if (HAS_MUL) begin
      run_case("TC002", "One representative vector per legal opcode - MUL", DATA_W'(3), DATA_W'(7), OP_MUL);
      run_case("TC089", "MUL small positive numbers", DATA_W'(3), DATA_W'(7), OP_MUL);
      run_case("TC090", "MUL by zero", DATA_W'(9), DATA_W'(0), OP_MUL);
      run_case("TC090", "MUL by zero swapped", DATA_W'(0), DATA_W'(9), OP_MUL);
      run_case("TC091", "MUL by one", pat_a_v, DATA_W'(1), OP_MUL);
      run_case("TC092", "MUL negative and positive operand case", DATA_W'(-3), DATA_W'(7), OP_MUL);
      run_case("TC093", "MUL overflow/truncation case", ones_v, DATA_W'(3), OP_MUL);
    end else begin
      skip_case("TC002", "MUL representative subcase only executed when HAS_MUL == 1");
      skip_case("TC089", "Only executed when HAS_MUL == 1");
      skip_case("TC090", "Only executed when HAS_MUL == 1");
      skip_case("TC091", "Only executed when HAS_MUL == 1");
      skip_case("TC092", "Only executed when HAS_MUL == 1");
      skip_case("TC093", "Only executed when HAS_MUL == 1");
    end

    if (DATA_W == 8) begin
      run_case("TC100", "DATA_W=8 arithmetic sanity", 8'(2), 8'(3), OP_ADD);
      run_case("TC100", "DATA_W=8 arithmetic sanity overflow", max_pos_v, 8'(1), OP_ADD);
      run_case("TC101", "DATA_W=8 shift sanity", 8'h81, 8'(1), OP_SRA);
      run_case("TC101", "DATA_W=8 shift sanity boundary", 8'h01, 8'(7), OP_SLL);
      run_case("TC102", "DATA_W=8 compare signed/unsigned distinction (signed view)", 8'hFF, 8'h01, OP_CMPLT);
      run_case("TC102", "DATA_W=8 compare signed/unsigned distinction (unsigned view)", 8'hFF, 8'h01, OP_CMPLTU);
    end else begin
      skip_case("TC100", "Only executed when DATA_W == 8");
      skip_case("TC101", "Only executed when DATA_W == 8");
      skip_case("TC102", "Only executed when DATA_W == 8");
    end

    if (DATA_W == 16) begin
      run_case("TC103", "DATA_W=16 arithmetic sanity", 16'(2), 16'(3), OP_ADD);
      run_case("TC103", "DATA_W=16 arithmetic sanity overflow", max_pos_v, 16'(1), OP_ADD);
      run_case("TC104", "DATA_W=16 shift sanity", 16'h8001, 16'(1), OP_SRA);
      run_case("TC104", "DATA_W=16 shift sanity boundary", 16'h0001, 16'(15), OP_SLL);
      run_case("TC105", "DATA_W=16 compare signed/unsigned distinction (signed view)", 16'hFFFF, 16'h0001, OP_CMPLT);
      run_case("TC105", "DATA_W=16 compare signed/unsigned distinction (unsigned view)", 16'hFFFF, 16'h0001, OP_CMPLTU);
    end else begin
      skip_case("TC103", "Only executed when DATA_W == 16");
      skip_case("TC104", "Only executed when DATA_W == 16");
      skip_case("TC105", "Only executed when DATA_W == 16");
    end

    if (DATA_W == 32) begin
      run_case("TC106", "DATA_W=32 arithmetic sanity", 32'(2), 32'(3), OP_ADD);
      run_case("TC106", "DATA_W=32 arithmetic sanity overflow", max_pos_v, 32'(1), OP_ADD);
      run_case("TC107", "DATA_W=32 shift sanity", 32'h8000_0001, 32'(1), OP_SRA);
      run_case("TC107", "DATA_W=32 shift sanity boundary", 32'h0000_0001, 32'(31), OP_SLL);
      run_case("TC108", "DATA_W=32 compare signed/unsigned distinction (signed view)", 32'hFFFF_FFFF, 32'h0000_0001, OP_CMPLT);
      run_case("TC108", "DATA_W=32 compare signed/unsigned distinction (unsigned view)", 32'hFFFF_FFFF, 32'h0000_0001, OP_CMPLTU);
    end else begin
      skip_case("TC106", "Only executed when DATA_W == 32");
      skip_case("TC107", "Only executed when DATA_W == 32");
      skip_case("TC108", "Only executed when DATA_W == 32");
    end

    if (HAS_MUL == 0) begin
      run_case("TC094", "MUL opcode with HAS_MUL=0", DATA_W'(3), DATA_W'(7), OP_MUL);
      run_case("TC095", "non-MUL opcode still works with HAS_MUL=0", DATA_W'(9), DATA_W'(4), OP_ADD);
    end else begin
      skip_case("TC094", "Only executed when HAS_MUL == 0");
      skip_case("TC095", "Only executed when HAS_MUL == 0");
    end

    $display("============================================================");
    $display("Completed exec_unit_testbench DATA_W=%0d HAS_MUL=%0d", DATA_W, HAS_MUL);
    $display("  subcases = %0d", subcase_count);
    $display("  pass     = %0d", pass_count);
    $display("  fail     = %0d", error_count);
    $display("  skip     = %0d", skip_count);
    $display("============================================================");

    if (error_count != 0) begin
      $fatal(1, "exec_unit_testbench failed with %0d mismatches", error_count);
    end

    $finish;
  end

endmodule
