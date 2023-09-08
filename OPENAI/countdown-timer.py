# written entirely by ChatGPT (except this line) after several tweaks

import tkinter as tk
from datetime import datetime, timedelta
import sys
import sounddevice as sd
import numpy as np
import time

last_second = None  # Declare last_second as a global variable

def update_timer():
    global last_second  # Declare last_second as a global variable
    remaining_time = end_time - datetime.now()
    if remaining_time.total_seconds() <= 0:
        timer_label.config(text="Time's up!")
        play_alert_sound()
    else:
        remaining_time_str = str(remaining_time).split(".")[0] + f'.{remaining_time.microseconds // 10000:02}'
        timer_label.config(text=remaining_time_str)
        if remaining_time.seconds != last_second:
            play_tick_sound()
            last_second = remaining_time.seconds
        root.after(10, update_timer)

def play_alert_sound():
    sample_rate = 44100
    duration = 1.0
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    beep_sound = np.sin(2 * np.pi * 1000 * t)
    
    sd.play(beep_sound, sample_rate)
    sd.wait()

def play_tick_sound():
    sample_rate = 44100
    duration = 0.1  # Adjust duration for the tick sound
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    tick_sound = np.sin(2 * np.pi * 500 * t)  # Adjust frequency for the tick sound
    
    sd.play(tick_sound, sample_rate)
    sd.wait()

if len(sys.argv) != 2:
    print("Usage: python countdown_timer.py <seconds>")
    sys.exit(1)

try:
    countdown_seconds = int(sys.argv[1])
except ValueError:
    print("Invalid input. Please enter a valid number of seconds.")
    sys.exit(1)

end_time = datetime.now() + timedelta(seconds=countdown_seconds)

root = tk.Tk()
root.title("Countdown Timer")

frame = tk.Frame(root)
frame.pack(padx=20, pady=20)

timer_label = tk.Label(frame, text="", font=("Helvetica", 48))
timer_label.pack()

update_timer()

root.mainloop()
