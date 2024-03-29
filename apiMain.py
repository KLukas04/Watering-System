from flask import Flask
from flask_restful import Api, Resource
import pymysql

app = Flask(__name__)
api = Api(app)

db = pymysql.connect(host="localhost", user="adminLukas", password="IbdtLmmB.11", database="sensor_data") 
cursor = db.cursor()
        
class SensorData(Resource):
    def get(self, sensor_id):
        db.commit()
        sql = f"SELECT {sensor_id} FROM SensorData ORDER BY SensorData.DatumUhrzeit DESC LIMIT 576"
        try: 
            cursor.execute(sql)
            results = cursor.fetchall()
            temp = [] # DatumUhrzeit geht momentan nict, da es nicht als JSON dirket geht
            for result in results:
                temp.append(result[0])
            print(len(temp))
            return {"data": temp}
        except:
            print("Error")
            return "Error"

api.add_resource(SensorData, "/alldata/<string:sensor_id>")

def start():
    app.run(host='0.0.0.0')
    
if __name__ == "__main__":
    app.run(host='0.0.0.0')
