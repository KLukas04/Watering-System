import threading
from water import Water
from communication import Communication
from db import Connection
from sensoren import Sensoren

com = Communication("RPI", "192.168.2.156")
sensoren = Sensoren(pinRain=22, pinVent1=17, pinVent2=27)
water = Water(com)

t_com = threading.Thread(target=com.server)
t_water = threading.Thread(target=water.main)

if __name__ == '__main__':
    print("Starting")
    t_com.start()
    t_water.start()
