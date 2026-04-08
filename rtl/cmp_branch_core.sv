`timescale 1ns/1ps

module cmp_branch_core #(
  parameter int DATA_W = 32
) (
  input  logic [DATA_W-1:0] op_a_i,
  input  logic [DATA_W-1:0] op_b_i,
  input  logic [2:0]        branch_sel_i,
  output logic              cmp_eq_o,
  output logic              cmp_lt_signed_o,
  output logic              cmp_lt_unsigned_o,
  output logic              branch_taken_o
);

  localparam logic [2:0] BR_NONE = 3'd0;
  localparam logic [2:0] BR_EQ   = 3'd1;
  localparam logic [2:0] BR_NE   = 3'd2;
  localparam logic [2:0] BR_LT   = 3'd3;
  localparam logic [2:0] BR_LTU  = 3'd4;

  always_comb begin
    cmp_eq_o          = (op_a_i == op_b_i);
    cmp_lt_signed_o   = ($signed(op_a_i) < $signed(op_b_i));
    cmp_lt_unsigned_o = (op_a_i < op_b_i);

    unique case (branch_sel_i)
      BR_EQ:   branch_taken_o = cmp_eq_o;
      BR_NE:   branch_taken_o = ~cmp_eq_o;
      BR_LT:   branch_taken_o = cmp_lt_signed_o;
      BR_LTU:  branch_taken_o = cmp_lt_unsigned_o;
      default: branch_taken_o = 1'b0;
    endcase
  end

endmodule
