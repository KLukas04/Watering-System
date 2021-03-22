import threading
from water import Water
from communication import Communication
from db import Connection
from sensoren import Sensoren
import time
from apiMain import start

#com = Communication("RPI", "192.168.2.156

com = Communication("RPI", "0.0.0.0")
sensoren = Sensoren(pinRain=22, pinVent1=17, pinVent2=27)
water = Water(com, sensoren)

db = Connection(host="localhost", user="adminLukas", password="IbdtLmmB.11", database="sensor_data")

t_com = threading.Thread(target=com.server)
t_sensoren = threading.Thread(target=sensoren.update_data)
t_water = threading.Thread(target=water.main)
t_api = threading.Thread(target=start)

if __name__ == '__main__':
    print("Starting")
    t_com.start()
    t_sensoren.start()
    t_water.start()
    t_api.start()
    
    while True:
        db.save_data()
        time.sleep(300)
