`timescale 1ns/1ps

module exec_unit_tb;
  exec_unit_testbench #(
    .DATA_W (32),
    .HAS_MUL(1)
  ) u_tb ();
endmodule
