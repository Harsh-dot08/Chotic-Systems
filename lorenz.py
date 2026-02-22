import numpy as np
import matplotlib.pyplot as plt

# Lorenz parameters
sigma = 10.0
rho = 28.0
beta = 8.0 / 3.0

# Time settings
dt = 0.01
num_steps = 10000
time = np.linspace(0, num_steps*dt, num_steps)

# Initial conditions
x, y, z = 1.0, 1.0, 1.0

# Storage
xs, ys, zs = [], [], []

def lorenz_deriv(x, y, z):
    dx = sigma * (y - x)
    dy = x * (rho - z) - y
    dz = x * y - beta * z
    return dx, dy, dz

# RK4 integration
for _ in range(num_steps):
    xs.append(x)
    ys.append(y)
    zs.append(z)

    dx1, dy1, dz1 = lorenz_deriv(x, y, z)
    dx2, dy2, dz2 = lorenz_deriv(x + dx1*dt/2, y + dy1*dt/2, z + dz1*dt/2)
    dx3, dy3, dz3 = lorenz_deriv(x + dx2*dt/2, y + dy2*dt/2, z + dz2*dt/2)
    dx4, dy4, dz4 = lorenz_deriv(x + dx3*dt, y + dy3*dt, z + dz3*dt)

    x += (dt/6)*(dx1 + 2*dx2 + 2*dx3 + dx4)
    y += (dt/6)*(dy1 + 2*dy2 + 2*dy3 + dy4)
    z += (dt/6)*(dz1 + 2*dz2 + 2*dz3 + dz4)

# Plot x(t), y(t), and z(t) on the same graph
plt.figure(figsize=(10, 6))
plt.plot(time, xs, label='x(t)', color='blue')
plt.plot(time, ys, label='y(t)', color='green')
plt.plot(time, zs, label='z(t)', color='red')

plt.title("Lorenz Attractor: x(t), y(t), z(t)")
plt.xlabel("Time")
plt.ylabel("Value")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
