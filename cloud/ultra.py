import serial
import requests
import time
import sys

# Replace these with your settings
SERIAL_PORT = 'COM5'       # Change to your ESP32 COM port
BAUD_RATE = 115200
THINGSPEAK_API_KEY = 'Z76ASXKO1G3WBL19'
THINGSPEAK_URL = 'https://api.thingspeak.com/update'

def send_to_thingspeak(distance_cm):
    payload = {
        'api_key': THINGSPEAK_API_KEY,
        'field1': distance_cm
    }
    try:
        response = requests.post(THINGSPEAK_URL, data=payload)
        if response.status_code == 200:
            print(f"Uploaded {distance_cm} cm to ThingSpeak")
        else:
            print(f"Failed to upload: {response.status_code}")
    except Exception as e:
        print(f"Error uploading data: {e}")

def main():
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=2)
        print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} baud.")
    except Exception as e:
        print(f"Error opening serial port: {e}")
        return

    while True:
        line = ser.readline().decode('utf-8').strip()
        print(line)
        try:
            distance = float(line)
            send_to_thingspeak(distance)
        except ValueError:
            # Not a valid float, just skip
            continue


            

    ser.close()

if __name__ == "__main__":
    main()
