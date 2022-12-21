import numpy as np
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

# Load the Iris dataset
iris = load_iris()

print(iris)

X = iris["data"]
y = iris["target"]

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Preprocess the data using a pipeline
pipeline = Pipeline([
    ("scaler", StandardScaler()),
    ("classifier", RandomForestClassifier())
])

# Evaluate the model using cross-validation
scores = cross_val_score(pipeline, X_train, y_train, cv=5)

# Print the mean and standard deviation of the scores
print(f"Mean: {scores.mean():.2f}")
print(f"Std Dev: {scores.std():.2f}")

# Train the model on the training data
pipeline.fit(X_train, y_train)

# Make predictions on the test data
y_pred = pipeline.predict(X_test)

# Calculate the accuracy of the model
accuracy = np.mean(y_pred == y_test)
print(f"Accuracy: {accuracy:.2f}")
