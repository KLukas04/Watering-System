import os
import board
import busio
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import RPi.GPIO as GPIO
import time

class Sensoren:
    def __init__(self, pinRain, pinVent1, pinVent2):
        self.pinRain = pinRain #Regensensor

        i2c = busio.I2C(board.SCL, board.SDA) #ADS
        ads = ADS.ADS1015(i2c)
        self.chan = AnalogIn(ads, ADS.P0)   #Feuchtesensor

        self.tempSensor = self.find_temp_sensor()

        self.pinVent1 = pinVent1 # Ventil 1
        self.pinVent2 = pinVent2 # Ventil 2

        self.setup_GPIO(pinRain, pinVent1, pinVent2)
        
        self.state_rain = self.set_state_rain()
        self.temperature = self.set_temperature()
        self.humidity = self.set_humidity(1)

    def setup_GPIO(self, pinRain, pinVent1, pinVent2):
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(pinVent1, GPIO.OUT, initial=1)
        GPIO.setup(pinVent2, GPIO.OUT, initial=1)
        GPIO.setup(pinRain, GPIO.IN)

    def update_data(self):
        print("Thread2 activated")
        while True:     
            self.state_rain = self.set_state_rain()
            self.temperature = self.set_temperature()
            self.humidity = self.set_humidity(6000)
            time.sleep(240)

    def set_state_rain(self):
        return GPIO.input(self.pinRain)

    def get_state_rain(self):
        return self.state_rain

    def set_humidity(self, accuracy):
        zwischen_wert = 0
        i = 0
        while i < accuracy:
            print(i)
            zwischen_wert += self.chan.value
            time.sleep(0.01)
            i += 1
        humidity_value = round(zwischen_wert / accuracy / 1000, 2)
        
        print(humidity_value)
        return humidity_value
    
    def get_humidity(self):
        return self.humidity

    def set_temperature(self):
        location = '/sys/bus/w1/devices/' + self.tempSensor + '/w1_slave'
        tfile = open(location)
        text = tfile.read()
        tfile.close()
        secondline = text.split("\n")[1]
        temperaturedata = secondline.split(" ")[9]
        temperature = float(temperaturedata[2:]) / 1000

        return temperature
    
    def get_temperature(self):
        return self.temperature

    def get_pinRain(self):
        return self.pinRain

    def get_pinVent1(self):
        return self.pinVent1

    def get_pinVent2(self):
        return self.pinVent2
    
    def find_temp_sensor(self):
        temperatur_sensor = None
        for i in os.listdir('/sys/bus/w1/devices'):
            if i != 'w1_bus_master1':
                temperatur_sensor = i
        return temperatur_sensor
