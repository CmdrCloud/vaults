import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

# -----------------------------
# GENERATE DATA
# -----------------------------

np.random.seed(42)

# X values
X = np.random.rand(100) * 10

# y = 4x + 3 + noise
y = 4 * X + 3 + np.random.randn(100) * 2

# -----------------------------
# PREPARE DATA
# -----------------------------

# sklearn needs 2D input
X_reshaped = X.reshape(-1, 1)

# -----------------------------
# TRAIN MODEL
# -----------------------------

model = LinearRegression()

model.fit(X_reshaped, y)

# -----------------------------
# PRINT RESULTS
# -----------------------------

print("Slope:", model.coef_[0])
print("Intercept:", model.intercept_)

# -----------------------------
# CREATE LINE
# -----------------------------

line_x = np.linspace(0, 10, 100)

line_x_reshaped = line_x.reshape(-1, 1)

line_y = model.predict(line_x_reshaped)

# -----------------------------
# PLOT EVERYTHING
# -----------------------------

plt.scatter(X, y)

plt.plot(line_x, line_y)

plt.xlabel("X")
plt.ylabel("y")

plt.title("Linear Regression")

plt.show()
