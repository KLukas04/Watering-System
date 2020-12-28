import threading
from water import Water
from communication import Communication
from db import Connection

com = Communication("RPI", "192.168.2.156")
water = Water(com)

t_com = threading.Thread(target=com.server
t_water = threading.Thread(target=water.main)

if __name__ == '__main__':
    print("Starting")
    t_com.start()
    t_water.start()