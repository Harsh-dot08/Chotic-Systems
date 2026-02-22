`timescale 1ns/1ps
module tb_lorenz_rk4;
reg clk;
reg rst_n;
wire signed [31:0] x;
wire signed [31:0] y;
wire signed [31:0] z;

lorenz_rk4 uut (
    .clk(clk),
    .rst_n(rst_n),
    .x(x),
    .y(y),
    .z(z)
);

initial clk = 0;
always #5 clk = ~clk; // 10 ns period -> faster stepping for more points

initial begin
    $dumpfile("lorenz_rk4.vcd");
    $dumpvars(0, tb_lorenz_rk4);
    rst_n = 0;
    #100;
    rst_n = 1;
    // run for many cycles
    #2000000; // ~2 ms
    $display("done");
    $finish;
end

integer step;
initial begin
    step = 0;
    @(posedge rst_n);
    forever begin
        @(posedge clk);
        // print every step (or change modulo if too verbose)
        $display("t=%0t ns x=%0f y=%0f z=%0f", $time, $itor(x)/65536.0, $itor(y)/65536.0, $itor(z)/65536.0);
        step = step + 1;
    end
end

endmodule
