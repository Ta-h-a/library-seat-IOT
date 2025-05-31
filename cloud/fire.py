#firebase and serila port connection

import serial
import requests
import time
import json
import time

# CONFIGURATION
SERIAL_PORT = 'COM5'  # Replace with your ESP32 port
BAUD_RATE = 115200
FIREBASE_URL = 'https://hotel-occup-default-rtdb.asia-southeast1.firebasedatabase.app/distance.json'
# Replace with your DB URL

def send_to_firebase(distance_cm):
    data = {
        "inch": distance_cm
    }
    try:
        response = requests.put(FIREBASE_URL, json=data)
        if response.status_code == 200:
            print(f"✅ Uploaded {distance_cm} cm to Firebase")
        else:
            print(f"❌ Failed to upload: {response.status_code}")
    except Exception as e:
        print(f"🔥 Error uploading data: {e}")

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2)
        print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} baud.")
    except Exception as e:
        print(f"⚠️ Serial connection error: {e}")
        return

    while True:
        line = ser.readline().decode('utf-8').strip()
        print(f"Raw: {line}")
        try:
            distance = float(line)
            send_to_firebase(distance)
            print("sent")
            time.sleep(0.5)
        except ValueError:
            # Skip lines that can't be parsed
            continue

if __name__ == "__main__":
    main()


