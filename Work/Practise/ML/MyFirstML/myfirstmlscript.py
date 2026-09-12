import numpy as np

# Simple dataset: hours studied -> exam score

X = np.array([1, 2, 3, 4, 5], dtype=float)
Y = np.array([52, 57, 63, 68, 75], dtype=float)

# Initialise Params
w = 0.0
b = 0.0
learningRate = 0.01
epochs = 1000
n = len(X)

for epoch in range(epochs):
    # Prediction
    yPred = w * X + b

    # Error
    error = yPred - Y

    # MSE
    mse = np.mean(error**2)

    # Gradients
    dw = (2 / n) * np.sum(error * X)
    db = (2 / n) * np.sum(error)

    # Update params
    w = w - learningRate * dw
    b = b - learningRate * db

    if epoch % 100 == 0:
        print(f"Epoch {epoch}: MSE={mse:.4f}, w={w:.4f}, b={b:.4f}")


print("\nFinal model:")
print(f"y = {w:.4f}x + {b:.4f}")

hours = 6
prediction = w * hours + b
print(f"\nPredicted score for {hours} hours: {prediction:.2f}")
