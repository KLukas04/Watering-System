import time
import datetime as datetime
import RPi.GPIO as GPIO

from sensoren import Sensoren
from communication import Communication

class Water:
    def __init__(self, com, sensoren):
        print("Water")
        self.sensoren = sensoren
        self.com = com

    def main(self):
        print("Thread3 activated")
        while True:
            while self.com.get_isActive():
                
                state_rain = self.sensoren.get_state_rain()
                now = datetime.datetime.today()
                
                if self.com.get_time_to_water() != None:
                    if now.hour == self.com.get_time_to_water().hour and now.minute ==  self.com.get_time_to_water().minute and state_rain == 1 and self.com.get_isActive():
                        print("Water now!")

                        self.com.send_succes(temp=self.sensoren.get_temperature(), hum=self.sensoren.get_humidity())

                        self.water_now(self.com.get_dauer())

    def water_now(self, dauer):
        print("water_now")

        print("System start on", self.sensoren.get_pinVent1())
        self.control(self.sensoren.get_pinVent1(), self.com.get_dauer())
        print("System over on", self.sensoren.get_pinVent1())
        
        print("System start on", self.sensoren.get_pinVent2())
        self.control(self.sensoren.get_pinVent2(), self.com.get_dauer())
        print("System over on", self.sensoren.get_pinVent2())

    def control(self, pin, duration):
        self.on(pin)
        print("Dauer:", duration)
        time_left = duration
        while time_left > 0 and self.com.get_isActive():
            time.sleep(15)
            time_left -= 15
            print(time_left)
        self.off(pin)

    def on(self, pin):
        print("ON", pin)
        GPIO.output(pin, GPIO.LOW)

    def off(self, pin):
        print("OFF", pin)
        GPIO.output(pin, GPIO.HIGH)
