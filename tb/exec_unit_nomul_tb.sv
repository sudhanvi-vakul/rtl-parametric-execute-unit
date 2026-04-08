`timescale 1ns/1ps

module exec_unit_nomul_tb;
  exec_unit_testbench #(
    .DATA_W (32),
    .HAS_MUL(0)
  ) u_tb ();
endmodule
