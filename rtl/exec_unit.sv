`timescale 1ns/1ps

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

  import exec_defs_pkg::*;

  localparam int SHAMT_W = (DATA_W <= 1) ? 1 : $clog2(DATA_W);

  localparam logic [2:0] ALU_ADD = 3'd0;
  localparam logic [2:0] ALU_SUB = 3'd1;
  localparam logic [2:0] ALU_AND = 3'd2;
  localparam logic [2:0] ALU_OR  = 3'd3;
  localparam logic [2:0] ALU_XOR = 3'd4;

  localparam logic [1:0] SH_SLL = 2'd0;
  localparam logic [1:0] SH_SRL = 2'd1;
  localparam logic [1:0] SH_SRA = 2'd2;

  localparam logic [2:0] BR_NONE = 3'd0;
  localparam logic [2:0] BR_EQ   = 3'd1;
  localparam logic [2:0] BR_NE   = 3'd2;
  localparam logic [2:0] BR_LT   = 3'd3;
  localparam logic [2:0] BR_LTU  = 3'd4;

  logic [2:0] alu_sel;
  logic [1:0] shift_sel;
  logic [2:0] branch_sel;

  logic [DATA_W-1:0] alu_result;
  logic [DATA_W-1:0] shift_result;
  logic [DATA_W-1:0] mul_result;
  logic              alu_carry;
  logic              alu_overflow;
  logic              branch_taken_int;

  logic [DATA_W-1:0] result_next;
  logic              carry_next;
  logic              overflow_next;
  logic              illegal_next;

  always_comb begin
    alu_sel    = ALU_ADD;
    shift_sel  = SH_SLL;
    branch_sel = BR_NONE;

    unique case (op_sel_i)
      OP_ADD: alu_sel = ALU_ADD;
      OP_SUB: alu_sel = ALU_SUB;
      OP_AND: alu_sel = ALU_AND;
      OP_OR : alu_sel = ALU_OR;
      OP_XOR: alu_sel = ALU_XOR;

      OP_SLL: shift_sel = SH_SLL;
      OP_SRL: shift_sel = SH_SRL;
      OP_SRA: shift_sel = SH_SRA;

      OP_BR_EQ : branch_sel = BR_EQ;
      OP_BR_NE : branch_sel = BR_NE;
      OP_BR_LT : branch_sel = BR_LT;
      OP_BR_LTU: branch_sel = BR_LTU;

      default: begin
        alu_sel    = ALU_ADD;
        shift_sel  = SH_SLL;
        branch_sel = BR_NONE;
      end
    endcase
  end

  alu_core #(
    .DATA_W(DATA_W)
  ) u_alu_core (
    .op_a_i     (op_a_i),
    .op_b_i     (op_b_i),
    .alu_sel_i  (alu_sel),
    .result_o   (alu_result),
    .carry_o    (alu_carry),
    .overflow_o (alu_overflow)
  );

  shifter_core #(
    .DATA_W(DATA_W)
  ) u_shifter_core (
    .op_a_i      (op_a_i),
    .shamt_i     (op_b_i[SHAMT_W-1:0]),
    .shift_sel_i (shift_sel),
    .result_o    (shift_result)
  );

  cmp_branch_core #(
    .DATA_W(DATA_W)
  ) u_cmp_branch_core (
    .op_a_i            (op_a_i),
    .op_b_i            (op_b_i),
    .branch_sel_i      (branch_sel),
    .cmp_eq_o          (cmp_eq_o),
    .cmp_lt_signed_o   (cmp_lt_signed_o),
    .cmp_lt_unsigned_o (cmp_lt_unsigned_o),
    .branch_taken_o    (branch_taken_int)
  );

  mul_core #(
    .DATA_W(DATA_W)
  ) u_mul_core (
    .op_a_i   (op_a_i),
    .op_b_i   (op_b_i),
    .result_o (mul_result)
  );

  always_comb begin
    result_next    = '0;
    carry_next     = 1'b0;
    overflow_next  = 1'b0;
    illegal_next   = 1'b0;
    branch_taken_o = 1'b0;

    unique case (op_sel_i)
      OP_ADD,
      OP_SUB,
      OP_AND,
      OP_OR,
      OP_XOR: begin
        result_next   = alu_result;
        carry_next    = alu_carry;
        overflow_next = alu_overflow;
      end

      OP_SLL,
      OP_SRL,
      OP_SRA: begin
        result_next = shift_result;
      end

      OP_CMPEQ: begin
        result_next = {{(DATA_W-1){1'b0}}, cmp_eq_o};
      end

      OP_CMPLT: begin
        result_next = {{(DATA_W-1){1'b0}}, cmp_lt_signed_o};
      end

      OP_CMPLTU: begin
        result_next = {{(DATA_W-1){1'b0}}, cmp_lt_unsigned_o};
      end

      OP_BR_EQ,
      OP_BR_NE,
      OP_BR_LT,
      OP_BR_LTU: begin
        result_next    = {{(DATA_W-1){1'b0}}, branch_taken_int};
        branch_taken_o = branch_taken_int;
      end

      OP_MUL: begin
        if (HAS_MUL) begin
          result_next = mul_result;
        end else begin
          result_next = '0;
          illegal_next = 1'b1;
        end
      end

      default: begin
        result_next   = '0;
        illegal_next  = 1'b1;
      end
    endcase
  end

  always_comb begin
    result_o     = result_next;
    carry_o      = carry_next;
    overflow_o   = overflow_next;
    illegal_op_o = illegal_next;
    zero_o       = (result_next == '0);
    negative_o   = result_next[DATA_W-1];
  end

endmodule
