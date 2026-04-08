`timescale 1ns/1ps

module mul_core #(
  parameter int DATA_W = 32
) (
  input  logic [DATA_W-1:0] op_a_i,
  input  logic [DATA_W-1:0] op_b_i,
  output logic [DATA_W-1:0] result_o
);

  logic [(2*DATA_W)-1:0] full_product;

  always_comb begin
    // This stage-1 implementation treats multiply as bit-vector multiply
    // and returns the low DATA_W bits of the full product.
    full_product = op_a_i * op_b_i;
    result_o     = full_product[DATA_W-1:0];
  end

endmodule
