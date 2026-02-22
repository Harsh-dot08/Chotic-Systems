`timescale 1ns/1ps
module lorenz_rk4 (
    input  wire        clk,
    input  wire        rst_n,       // active low reset
    output reg signed [31:0] x,     // Q16.16 signed
    output reg signed [31:0] y,     // Q16.16 signed
    output reg signed [31:0] z      // Q16.16 signed
);

// --------- PARAMETERS (Q16.16) ----------
parameter signed [31:0] SIGMA = 32'sd655360;   // 10.0 * 2^16
parameter signed [31:0] RHO   = 32'sd1835008;  // 28.0 * 2^16
// BETA = 8/3 ≈ 2.6666666667 -> 2.6666667 * 65536 ≈ 174763
parameter signed [31:0] BETA  = 32'sd174763;   
parameter signed [31:0] DT    = 32'sd655;      // 0.01 * 2^16 ≈ 655 (integration step)
parameter signed [31:0] DT_HALF = 32'sd328;   // DT/2 ≈ 0.005 * 2^16
reg signed [31:0] sumx, sumy, sumz;
reg signed [31:0] incr_x, incr_y, incr_z;
// --------- helper fixed-point multiply function (Q16.16 * Q16.16 -> Q16.16) ----------
function signed [31:0] fx_mul;
    input signed [31:0] a;
    input signed [31:0] b;
    reg   signed [63:0] tmp;
begin
    tmp = $signed(a) * $signed(b);         // Q32.32 in tmp
    fx_mul = tmp >>> 16;                    // shift down to Q16.16
end
endfunction

// divide by small integer (signed) -- result stays Q16.16
function signed [31:0] fx_div_int;
    input signed [31:0] a;
    input integer n;
begin
    fx_div_int = $signed(a) / n;
end
endfunction

// ---------- derivative functions (return Q16.16) ----------
function signed [31:0] dxdt;
    input signed [31:0] xv, yv, zv;
    reg signed [31:0] y_minus_x;
begin
    y_minus_x = $signed(yv) - $signed(xv);
    dxdt = fx_mul(SIGMA, y_minus_x);   // sigma*(y-x)
end
endfunction

function signed [31:0] dydt;
    input signed [31:0] xv, yv, zv;
    reg signed [31:0] rho_minus_z;
    reg signed [31:0] tmp;
begin
    rho_minus_z = $signed(RHO) - $signed(zv);        // Q16.16
    tmp = fx_mul(xv, rho_minus_z);                   // x*(rho - z)
    dydt = tmp - yv;                                 // minus y
end
endfunction

function signed [31:0] dzdt;
    input signed [31:0] xv, yv, zv;
    reg signed [31:0] tmp;
begin
    tmp = fx_mul(xv, yv);         // x*y
    dzdt = tmp - fx_mul(BETA, zv); // x*y - beta*z
end
endfunction

// ---------- internal regs for RK4 ----------
reg signed [31:0] k1x, k1y, k1z;
reg signed [31:0] k2x, k2y, k2z;
reg signed [31:0] k3x, k3y, k3z;
reg signed [31:0] k4x, k4y, k4z;

reg signed [31:0] xtmp, ytmp, ztmp;

// initialization on reset
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // choose some initial condition (Q16.16)
        x <= 32'sd65536;   // 1.0
        y <= 32'sd0;       // 0.0
        z <= 32'sd0;       // 0.0
    end else begin
        // --- Compute k1 ---
        k1x = dxdt(x, y, z);    // Q16.16
        k1y = dydt(x, y, z);
        k1z = dzdt(x, y, z);

        // --- Compute k2 at (x + k1*DT/2) ---
        xtmp = x + fx_mul(k1x, DT_HALF);
        ytmp = y + fx_mul(k1y, DT_HALF);
        ztmp = z + fx_mul(k1z, DT_HALF);

        k2x = dxdt(xtmp, ytmp, ztmp);
        k2y = dydt(xtmp, ytmp, ztmp);
        k2z = dzdt(xtmp, ytmp, ztmp);

        // --- Compute k3 at (x + k2*DT/2) ---
        xtmp = x + fx_mul(k2x, DT_HALF);
        ytmp = y + fx_mul(k2y, DT_HALF);
        ztmp = z + fx_mul(k2z, DT_HALF);

        k3x = dxdt(xtmp, ytmp, ztmp);
        k3y = dydt(xtmp, ytmp, ztmp);
        k3z = dzdt(xtmp, ytmp, ztmp);

        // --- Compute k4 at (x + k3*DT) ---
        xtmp = x + fx_mul(k3x, DT);
        ytmp = y + fx_mul(k3y, DT);
        ztmp = z + fx_mul(k3z, DT);

        k4x = dxdt(xtmp, ytmp, ztmp);
        k4y = dydt(xtmp, ytmp, ztmp);
        k4z = dzdt(xtmp, ytmp, ztmp);

        // --- combine to next state ---
        // tmp_sum = k1 + 2*k2 + 2*k3 + k4   (Q16.16)
        // increment = DT * tmp_sum / 6
        

        sumx = k1x + (k2x <<< 1) + (k3x <<< 1) + k4x;
        sumy = k1y + (k2y <<< 1) + (k3y <<< 1) + k4y;
        sumz = k1z + (k2z <<< 1) + (k3z <<< 1) + k4z;

        // multiply by DT then divide by 6
        incr_x = fx_div_int( fx_mul(sumx, DT), 6 );
        incr_y = fx_div_int( fx_mul(sumy, DT), 6 );
        incr_z = fx_div_int( fx_mul(sumz, DT), 6 );

        x <= x + incr_x;
        y <= y + incr_y;
        z <= z + incr_z;
    end
end

endmodule
