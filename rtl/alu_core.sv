`timescale 1ns/1ps

module alu_core #(
  parameter int DATA_W = 32
) (
  input  logic [DATA_W-1:0] op_a_i,
  input  logic [DATA_W-1:0] op_b_i,
  input  logic [2:0]        alu_sel_i,
  output logic [DATA_W-1:0] result_o,
  output logic              carry_o,
  output logic              overflow_o
);

  localparam logic [2:0] ALU_ADD = 3'd0;
  localparam logic [2:0] ALU_SUB = 3'd1;
  localparam logic [2:0] ALU_AND = 3'd2;
  localparam logic [2:0] ALU_OR  = 3'd3;
  localparam logic [2:0] ALU_XOR = 3'd4;

  logic [DATA_W:0] ext_add;
  logic [DATA_W:0] ext_sub;

  always_comb begin
    ext_add = {1'b0, op_a_i} + {1'b0, op_b_i};
    ext_sub = {1'b0, op_a_i} + {1'b0, ~op_b_i} + {{DATA_W{1'b0}}, 1'b1};

    result_o   = '0;
    carry_o    = 1'b0;
    overflow_o = 1'b0;

    unique case (alu_sel_i)
      ALU_ADD: begin
        result_o   = ext_add[DATA_W-1:0];
        carry_o    = ext_add[DATA_W];
        overflow_o = (~(op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1])) &
                     (result_o[DATA_W-1] ^ op_a_i[DATA_W-1]);
      end

      ALU_SUB: begin
        result_o   = ext_sub[DATA_W-1:0];
        carry_o    = ext_sub[DATA_W]; // carry=1 means no borrow under this convention
        overflow_o = (op_a_i[DATA_W-1] ^ op_b_i[DATA_W-1]) &
                     (result_o[DATA_W-1] ^ op_a_i[DATA_W-1]);
      end

      ALU_AND: begin
        result_o = op_a_i & op_b_i;
      end

      ALU_OR: begin
        result_o = op_a_i | op_b_i;
      end

      ALU_XOR: begin
        result_o = op_a_i ^ op_b_i;
      end

      default: begin
        result_o   = '0;
        carry_o    = 1'b0;
        overflow_o = 1'b0;
      end
    endcase
  end

endmodule
