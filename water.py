import time
import datetime as datetime
import RPi.GPIO as GPIO

from sensoren import Sensoren
from communication import Communication

class Water:
    def __init__(self, com):
        print("Water")
        self.sensoren = Sensoren(pinRain=22, pinVent1=17, pinVent2=27)
        self.com = com

    def main(self):
        print("Thread2 activated")
        #sensoren.setup_GPIO()

        while True:
            while self.com.get_isActive():
                state_rain = sensoren.get_state_rain()
                now = datetime.datetime.today()

                if now.hour == self.com.get_time_to_water().hour and now.minute ==  self.com.get_time_to_water().minute and state_rain == 1 and self.com.get_isActive():
                    print("Water now!")

                    #message = "YES," + str(current_temperature) + "," + str(Sensor.get_humidity()
                    #message = "On"
                    #print(message)
                    #dC.mqttClient.publish("ios/water_now", message)
                    # !!! AUSLAGERN NACH DEVICE !!!

                    self.water_now(com.get_dauer())

                time.sleep(0.01)
            if self.sensoren.find_temp_sensor() is not None:
                current_temperature = self.sensoren.get_temperature()
                print("System not active! Es sind momentan", current_temperature, "C. Der Boden hat eine Feuchte von", self.sensoren.get_humidity())
            else:
                print("Temperatursensor nicht gefunden!!!")

    def water_now(self, dauer):
        print("water_now")

        print("System start on", self.sensoren.get_pinVent1())
        self.control(self.sensoren.get_pinVent1(), self.com.get_dauer())
        print("System over on", self.sensoren.get_pinVent1())
        
        print("System start on", self.sensoren.get_pinVent2())
        self.control(self.sensoren.get_pinVent2(), self.com.get_dauer())
        print("System over on", self.sensoren.get_pinVent2())

    def sleep_plus_control(self, pin, duration):
        self.on(pin)
        print("Dauer:", duration)
        time_left = duration
        while time_left > 0 and self.com.get_isActive():
            time.sleep(15)
            time_left -= 15
            print(time_left)
        self.off(pin)

    def on(pin):
        print("ON", pin)
        GPIO.output(pin, GPIO.LOW)

    def off(pin):
        print("OFF", pin)
        GPIO.output(pin, GPIO.HIGH)