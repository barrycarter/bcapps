import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import quad, fixed_quad

def func(x):
    return np.sin(x)

# Use fixed quadrature
x = np.linspace(0, np.pi, 50)
y_fixed = fixed_quad(func, 0, np.pi, n=5)[0]

# Use adaptive quadrature
x_adapt, y_adapt = quad(func, 0, np.pi)

plt.plot(x, func(x), label='True Function')
plt.plot(x, y_fixed, label='Fixed Quadrature')
plt.plot(x_adapt, y_adapt, 'o', label='Adaptive Quadrature')
plt.legend()
plt.show()
