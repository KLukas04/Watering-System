import pymysql
import time
from sensoren import Sensoren

class Connection:
    def __init__(self, host, user, password, database):
        self.conn = pymysql.connect(host, user, password, database) #hier vielleicht anderes
        self.myCursor = self.conn.cursor()

    def save_data(self):
        sensoren = Sensoren(pinRain=22, pinVent1=17, pinVent2=27)

        temp = sensoren.get_temperature()
        humidity = sensoren.get_humidity()
        rain = sensoren.get_state_rain()

        self.myCursor.execute(f"INSERT INTO SensorData(temperatur, feuchtigkeit, regen) VALUES ({temp}, {humidity}, {rain});")
        print("Saved data!")
        self.conn.commit()
        #conn.close()
