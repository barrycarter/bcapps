# written entirely by ChatGPT (except this line) after several tweaks

import tkinter as tk

class DecimalCounter(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Decimal Counter")
        self.geometry("400x150")  # Reduced horizontal size

        self.digit1 = 0
        self.digit2 = 0
        self.digit3 = 0
        self.digit4 = 0
        self.digit5 = 0
        
        self.label = tk.Label(self, text=f"{self.digit1}{self.digit2}{self.digit3}.{self.digit4}{self.digit5}", font=("Helvetica", 36))
        self.label.grid(row=1, column=0, columnspan=5, pady=(10, 5))  # Reduced vertical spacing

        self.decrement_digit1_button = tk.Button(self, text="▼", font=("Helvetica", 18), command=self.decrement_digit1)
        self.increment_digit1_button = tk.Button(self, text="▲", font=("Helvetica", 18), command=self.increment_digit1)
        self.decrement_digit2_button = tk.Button(self, text="▼", font=("Helvetica", 18), command=self.decrement_digit2)
        self.increment_digit2_button = tk.Button(self, text="▲", font=("Helvetica", 18), command=self.increment_digit2)
        self.decrement_digit3_button = tk.Button(self, text="▼", font=("Helvetica", 18), command=self.decrement_digit3)
        self.increment_digit3_button = tk.Button(self, text="▲", font=("Helvetica", 18), command=self.increment_digit3)
        self.decrement_digit4_button = tk.Button(self, text="▼", font=("Helvetica", 18), command=self.decrement_digit4)
        self.increment_digit4_button = tk.Button(self, text="▲", font=("Helvetica", 18), command=self.increment_digit4)
        self.decrement_digit5_button = tk.Button(self, text="▼", font=("Helvetica", 18), command=self.decrement_digit5)
        self.increment_digit5_button = tk.Button(self, text="▲", font=("Helvetica", 18), command=self.increment_digit5)

        self.decrement_digit1_button.grid(row=2, column=0)
        self.increment_digit1_button.grid(row=0, column=0)
        self.decrement_digit2_button.grid(row=2, column=1)
        self.increment_digit2_button.grid(row=0, column=1)
        self.decrement_digit3_button.grid(row=2, column=2)
        self.increment_digit3_button.grid(row=0, column=2)
        self.decrement_digit4_button.grid(row=2, column=3)
        self.increment_digit4_button.grid(row=0, column=3)
        self.decrement_digit5_button.grid(row=2, column=4)
        self.increment_digit5_button.grid(row=0, column=4)

    def increment_digit1(self):
        self.digit1 = (self.digit1 + 1) % 10
        self.update_label()

    def decrement_digit1(self):
        self.digit1 = (self.digit1 - 1) % 10
        self.update_label()

    def increment_digit2(self):
        self.digit2 = (self.digit2 + 1) % 10
        self.update_label()

    def decrement_digit2(self):
        self.digit2 = (self.digit2 - 1) % 10
        self.update_label()

    def increment_digit3(self):
        self.digit3 = (self.digit3 + 1) % 10
        self.update_label()

    def decrement_digit3(self):
        self.digit3 = (self.digit3 - 1) % 10
        self.update_label()

    def increment_digit4(self):
        self.digit4 = (self.digit4 + 1) % 10
        self.update_label()

    def decrement_digit4(self):
        self.digit4 = (self.digit4 - 1) % 10
        self.update_label()
        
    def increment_digit5(self):
        self.digit5 = (self.digit5 + 1) % 10
        self.update_label()

    def decrement_digit5(self):
        self.digit5 = (self.digit5 - 1) % 10
        self.update_label()

    def update_label(self):
        self.label.config(text=f"{self.digit1}{self.digit2}{self.digit3}.{self.digit4}{self.digit5}")

if __name__ == "__main__":
    app = DecimalCounter()
    app.mainloop()

# Click the button below to copy the code
