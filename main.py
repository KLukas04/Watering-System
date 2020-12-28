import threading
from water import Water
from communication import Communication
from db import Connection

com = Communication()
water = Water()

t_com = threading.Thread(target= com.server())
t_water = threading.Thread(target=water.main())

if __name__ == '__main__':
    print("Starting")
    t_deviceCommunication.start()
    t_bewässern.start()