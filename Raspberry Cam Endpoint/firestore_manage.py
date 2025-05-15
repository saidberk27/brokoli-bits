import firebase_admin
from firebase_admin import credentials, firestore
import time
import serial
from typing import Optional
from datetime import datetime

# Configuration
CONFIG = {
    'SERIAL_PORT': '/dev/ttyUSB1',
    'BAUD_RATE': 9600,
    'RETRY_DELAY': 0.5,
    'FIREBASE_COLLECTION': 'motor',
    'FIREBASE_DOCUMENT': 'su'
}

class ArduinoController:
    def __init__(self):
        self.ser: Optional[serial.Serial] = None
        self.last_status = None
        self.setup_firebase()

    def setup_firebase(self):
        cred = credentials.Certificate("brokoli01-8887d-firebase-adminsdk-fbsvc-6df1eaff76.json")
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()
        self.doc_ref = self.db.collection(CONFIG['FIREBASE_COLLECTION']).document(CONFIG['FIREBASE_DOCUMENT'])

    def connect_serial(self) -> bool:
        try:
            self.ser = serial.Serial(CONFIG['SERIAL_PORT'], CONFIG['BAUD_RATE'], timeout=1)
            time.sleep(2)
            return self.ser.is_open
        except serial.SerialException as e:
            print(f"Serial connection error: {e}")
            self.ser = None
            return False

    def send_command(self, status: bool) -> bool:
        if not self.ser or not self.ser.is_open:
            return False
        try:
            command = b'0\n' if status else b'1\n'
            self.ser.write(command)
            return True
        except serial.SerialException as e:
            print(f"Serial write error: {e}")
            self.ser = None
            return False

    def save_soil_moisture(self, percentage):
        try:
            soil_data = {
                'percentage': float(percentage),
                'timestamp': firestore.SERVER_TIMESTAMP
            }
            self.db.collection('sensor/soil/soil_logs').add(soil_data)
            print(f"Soil moisture data saved: {percentage}%")
        except Exception as e:
            print(f"Error saving soil moisture data: {e}")

    def save_temperature_humidity(self, temperature, humidity):
        try:
            temp_humidity_data = {
                'temperature': float(temperature),
                'humidity': float(humidity),
                'timestamp': firestore.SERVER_TIMESTAMP
            }
            self.db.collection('sensor/temperature/temperature_logs').add(temp_humidity_data)
            print(f"Temperature and humidity data saved: {temperature}°C, {humidity}%")
        except Exception as e:
            print(f"Error saving temperature and humidity data: {e}")

    def read_serial_data(self):
        if self.ser and self.ser.in_waiting:
            try:
                data = self.ser.readline().decode('utf-8').strip()
                if data:
                    print(f"Received from Arduino: {data}")
                    incoming_data = data.split(",")
                    if len(incoming_data) == 2:
                        incoming_data_type = incoming_data[0]
                        incoming_data_val = incoming_data[1]

                        if incoming_data_type == 'Toprak Nem':
                            print(f"Toprak Nemi = {incoming_data_val}")
                            self.save_soil_moisture(incoming_data_val)

                        elif incoming_data_type == 'Hava Nemi':
                            self.current_humidity = incoming_data_val
                            print(f"Hava Nemi = {incoming_data_val}")
                            # Store temporarily and wait for temperature to save together

                        elif incoming_data_type == 'Sicaklik':
                            print(f"Sıcaklık = {incoming_data_val}")
                            if hasattr(self, 'current_humidity'):
                                self.save_temperature_humidity(incoming_data_val, self.current_humidity)
                                delattr(self, 'current_humidity')

            except serial.SerialException as e:
                print(f"Error reading serial data: {e}")

    def run(self):
        while True:
            if not self.ser or not self.ser.is_open:
                if not self.connect_serial():
                    time.sleep(CONFIG['RETRY_DELAY'])
                    continue

            try:
                doc = self.doc_ref.get()
                if doc.exists:
                    data = doc.to_dict()
                    calis_status = data.get('calis', False)

                    if calis_status != self.last_status:
                        if self.send_command(calis_status):
                            print(f"Sent {'ON' if calis_status else 'OFF'} command to Arduino")
                            self.last_status = calis_status

                self.read_serial_data()

            except Exception as e:
                print(f"Error in main loop: {e}")

            time.sleep(CONFIG['RETRY_DELAY'])

if __name__ == "__main__":
    controller = ArduinoController()
    controller.run()