import numpy as np
from keras.layers import Dense, LSTM
from keras.models import Sequential

# Generate some synthetic data
data = np.arange(10)

# Split the data into training and testing sets
X_train, X_test = data[:6], data[6:]

# Define the model
model = Sequential()
model.add(LSTM(10, input_shape=(1, 1)))
model.add(Dense(1))
model.compile(loss='mean_squared_error', optimizer='adam')

# Reshape the data for input to the LSTM layer
X_train = X_train.reshape((6, 1, 1))
X_test = X_test.reshape((4, 1, 1))

# Fit the model to the training data
model.fit(X_train, X_train, epochs=50, verbose=0)

# Make predictions on the test data
y_pred = model.predict(X_test)

# Print the predictions
print(y_pred)
