`timescale 1ns/1ns
`include "mini2.sv"

module mini2_tb;

    parameter PWM_PERIOD = 1200;

    logic clk = 0;
    logic RGB_R, RGB_G, RGB_B;

    top # (
        .PWM_PERIOD   (PWM_PERIOD)
    ) u0 (
        .clk            (clk), 
        .RGB_R            (RGB_R),
        .RGB_G            (RGB_G),
        .RGB_B            (RGB_B)
    );

    initial begin
        $dumpfile("mini2.vcd");
        $dumpvars(0, mini2_tb);
        #2000000000
        $finish;
    end

    always begin
        #41.666667
        clk = ~clk;
    end

endmodule

