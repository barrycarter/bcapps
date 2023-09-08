# written entirely by ChatGPT (except this line) after several tweaks

import tkinter as tk
import time

class Stopwatch(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Stopwatch")
        self.geometry("300x100")
        self.time_elapsed = 0.0
        self.running = False

        self.time_label = tk.Label(self, text="00:00.00", font=("Helvetica", 36))
        self.time_label.pack(pady=10)

        self.start_button = tk.Button(self, text="Start", command=self.start_stop)
        self.reset_button = tk.Button(self, text="Reset", command=self.reset)

        self.start_button.pack(side="left", padx=10)
        self.reset_button.pack(side="right", padx=10)

        self.update_time()

    def start_stop(self):
        if self.running:
            self.running = False
            self.start_button.config(text="Start")
        else:
            self.running = True
            self.start_button.config(text="Stop")
            self.start_time = time.time() - self.time_elapsed
            self.update_time()

    def reset(self):
        if not self.running:
            self.time_elapsed = 0.0
            self.update_time()

    def update_time(self):
        if self.running:
            self.time_elapsed = time.time() - self.start_time
            self.after(10, self.update_time)  # Update every 10 milliseconds for hundredths of a second
        minutes, seconds = divmod(int(self.time_elapsed), 60)
        hundredths = int((self.time_elapsed - int(self.time_elapsed)) * 100)
        time_str = f"{minutes:02d}:{seconds:02d}.{hundredths:02d}"
        self.time_label.config(text=time_str)

if __name__ == "__main__":
    app = Stopwatch()
    app.mainloop()
