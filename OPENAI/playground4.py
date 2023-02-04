import numpy as np
import matplotlib.pyplot as plt
import adaptive

def func(x):
    return np.sin(x)

x = np.linspace(0, np.pi, 50)

result, error = adaptive.quadrature(func, 0, np.pi)

plt.plot(x, func(x), label='True Function')
plt.plot(result[:,0], result[:,1], 'o', label='Adaptive Quadrature')
plt.legend()
plt.show()
