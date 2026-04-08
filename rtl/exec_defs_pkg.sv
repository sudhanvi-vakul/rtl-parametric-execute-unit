`timescale 1ns/1ps

package exec_defs_pkg;

  typedef enum logic [4:0] {
    OP_ADD    = 5'd0,
    OP_SUB    = 5'd1,
    OP_AND    = 5'd2,
    OP_OR     = 5'd3,
    OP_XOR    = 5'd4,
    OP_SLL    = 5'd5,
    OP_SRL    = 5'd6,
    OP_SRA    = 5'd7,
    OP_CMPEQ  = 5'd8,
    OP_CMPLT  = 5'd9,
    OP_CMPLTU = 5'd10,
    OP_BR_EQ  = 5'd11,
    OP_BR_NE  = 5'd12,
    OP_BR_LT  = 5'd13,
    OP_BR_LTU = 5'd14,
    OP_MUL    = 5'd15
  } exec_op_e;

endpackage
