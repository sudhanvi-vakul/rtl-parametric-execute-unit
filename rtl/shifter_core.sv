`timescale 1ns/1ps

module shifter_core #(
  parameter int DATA_W = 32
) (
  input  logic [DATA_W-1:0]                                 op_a_i,
  input  logic [((DATA_W <= 1) ? 1 : $clog2(DATA_W))-1:0]   shamt_i,
  input  logic [1:0]                                        shift_sel_i,
  output logic [DATA_W-1:0]                                 result_o
);

  localparam logic [1:0] SH_SLL = 2'd0;
  localparam logic [1:0] SH_SRL = 2'd1;
  localparam logic [1:0] SH_SRA = 2'd2;

  always_comb begin
    result_o = '0;
    unique case (shift_sel_i)
      SH_SLL: result_o = op_a_i << shamt_i;
      SH_SRL: result_o = op_a_i >> shamt_i;
      SH_SRA: result_o = $signed(op_a_i) >>> shamt_i;
      default: result_o = '0;
    endcase
  end

endmodule
