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

        self.i2c = busio.I2C(board.SCL, board.SDA) #ADS
        self.ads = ADS.ADS1015(i2c)
        self.chan = AnalogIn(ads, ADS.P0)   #Feuchtesensor

        self.tempSensor = find_temp_sensor()

        self.pinVent1 = pinVent1 # Ventil 1
        self.pinVent2 = pinVent2 # Ventil 2

        setup_GPIO(self, pinTemp, pinHum, pinRain, pinVent1, pinVent2)

    def setup_GPIO(self, pinTemp, pinHum, pinRain, pinVent1, pinVent2):
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(pinVent1, GPIO.OUT, initial=1)
        GPIO.setup(pinVent2, GPIO.OUT, initial=1)
        GPIO.setup(pinRain, GPIO.IN)

    def get_state_rain(self):
        return GPIO.input(self.pinRain)


    def get_humidity(self):
        zwischen_wert = 0
        i = 0
        while i < 6000:
            zwischen_wert += self.chan.value
            time.sleep(0.01)
            i += 1
        humidity_value = round(zwischen_wert / 6000 / 1000, 2)

        return humidity_value

    def get_temperatur(self):
        location = '/sys/bus/w1/devices/' + self.tempSensor + '/w1_slave'
        tfile = open(location)
        text = tfile.read()
        tfile.close()
        secondline = text.split("\n")[1]
        temperaturedata = secondline.split(" ")[9]
        temperature = float(temperaturedata[2:]) / 1000

        return temperature

    def get_pinRain(self):
        return self.pinRain

    def get_pinVent1(self):
        return self.pinVent1

    def get_pinVent2(self):
        return self.pinVent2
    
    def find_temp_sensor():
        temperatur_sensor = None
        for i in os.listdir('/sys/bus/w1/devices'):
            if i != 'w1_bus_master1':
                temperatur_sensor = i
        return temperatur_sensor
