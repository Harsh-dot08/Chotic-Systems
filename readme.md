# Lorenz Attractor: A Multi-Platform Implementation

This repository explores the **Lorenz System**, a set of three coupled, non-linear differential equations known for their chaotic behavior and "Butterfly Effect." This project provides a comprehensive look at chaos through three distinct implementation lenses: **Digital Simulation (Python)**, **Hardware Logic (Verilog)**, and **Analog Circuitry (LTspice)**.

---

## 🌀 Mathematical Foundation
The Lorenz equations are defined by:

$$
\begin{aligned} 
\frac{dx}{dt} &= \sigma(y - x) \\ 
\frac{dy}{dt} &= x(\rho - z) - y \\ 
\frac{dz}{dt} &= xy - \beta z 
\end{aligned}
$$



### Standard Parameters Used:
| Parameter | Value | Description |
| :--- | :--- | :--- |
| $\sigma$ | 10 | Prandtl number |
| $\rho$ | 28 | Rayleigh number (Chaotic Regime) |
| $\beta$ | 8/3 | Geometric factor |

---

## 🛠 Project Implementations

### 1. Python Implementation
* **Method:** Numerical integration using `scipy.integrate.odeint`.
* **Features:** High-precision floating-point simulation and 3D visualization using Matplotlib.
* **Use Case:** Establishing a "Golden Reference" for hardware comparison.

### 2. Verilog (RTL) Implementation
* **Method:** Euler integration using **Fixed-Point Arithmetic**.
* **Architecture:** A pipelined design to handle non-linear multiplication ($xy$ and $xz$) and integration steps.
* **Files:** Includes the RTL source (`lorenz.v`) and a testbench for waveform verification.

### 3. LTspice Implementation
* **Method:** Analog computation using active components.
* **Components:** * **Op-Amps:** Used as integrators and summers.
    * **Analog Multipliers:** Used to solve the $xy$ and $xz$ terms.
* **Analysis:** Transient analysis demonstrating real-time chaotic oscillation.



---

## 📉 Lyapunov Analysis & Fractal Dimension
To quantify the chaos, the **Kaplan-Yorke Dimension** ($D_{KY}$) was calculated based on the system's Lyapunov exponents ($\lambda_1, \lambda_2, \lambda_3$).

The dimension is defined as:
$$D_{KY} = k + \frac{\sum_{i=1}^{k} \lambda_i}{|\lambda_{k+1}|}$$

**Calculated Result:** $D_{KY} \approx 2.06$
This result confirms that the system settles on a **strange attractor** with a fractional (fractal) dimension, sitting between a 2D plane and a 3D volume.

---

## 🚀 Getting Started

### Prerequisites
* **Python 3.x** (`numpy`, `matplotlib`, `scipy`)
* **Verilog Simulator** (Vivado, Icarus Verilog, or ModelSim)
* **LTspice** (XVII or higher)

### Execution
1.  **Python:** Run `python lorenz_main.py`
2.  **Verilog:** Compile and simulate the testbench to view the digital trajectory in your waveform viewer.
3.  **LTspice:** Open the `.asc` file and hit **Run**.

---

## 📜 License
This project is licensed under the MIT License - see the LICENSE file for details.
