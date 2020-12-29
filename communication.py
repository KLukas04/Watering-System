import paho.mqtt.client as mqtt
import datetime

class Communication:
    def __init__(self, clientName, serverAddress):
        print("Com")
        self.mqttClient = mqtt.Client(clientName)
        self.mqttClient.connect(serverAddress, 1883)

        self.stunde = None
        self.minute = None
        self.active = False
        self.time_to_water = None
        self.dauer = None

    def server(self):
        print("Thread1 activated")
        self.mqttClient.on_connect = self.connectionStatus
        self.mqttClient.on_message = self.messageDecoder
        self.mqttClient.loop_forever()    
    
    def connectionStatus(self, client, userdata, flags, rc):
        print("Subscribe")
        self.mqttClient.subscribe("time")
        self.mqttClient.subscribe("rpi/gpio")
        self.mqttClient.subscribe("duration")
        self.mqttClient.subscribe("connection/stop")


    def messageDecoder(self, client, userdata, msg):
        print("topic: ", msg.topic, "payload: ", msg.payload, )

        if msg.topic == "time":
            message_time = str(msg.payload.decode(encoding='UTF-8'))
            times = message_time.split(':')

            stunde = int(times[0])
            minute = int(times[1])
            
            print(f"Stunde: {stunde}, Minute: {minute}")
            self.time_to_water = datetime.time(stunde, minute, 0)
            print(time_to_water)

        elif msg.topic == "rpi/gpio":
            message_active = str(msg.payload.decode(encoding='UTF-8'))

            if message_active == "on":
                self.active = True
                print(active)
            elif message_active == "off":
                self.active = False
                print(active)
            else:
                print("Unknown message!")

        elif msg.topic == "duration":
            message_duration = str(msg.payload.decode(encoding='UTF-8'))
            print("Hallo")
            d = int(message_duration)
            print(d)
            x = d * 60
            print(x)
            self.dauer = x
            print(self.dauer)
    def send_succes(self, temp, hum):
        message = "YES," + str(temp) + "," + str(hum)
        print(message)
        self.mqttClient.publish("ios/water_now", message)

    def get_time_to_water(self):
        return self.time_to_water


    def get_isActive(self):
        return self.active


    def get_dauer(self):
        print(self.dauer)
        return self.dauer

    def time_in_minutes(duration):
        return duration * 60
