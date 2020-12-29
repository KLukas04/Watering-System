from flask import Flask
from flask_restful import Api, Resource
import pymysql

app = Flask(__name__)
api = Api(app)

db = pymysql.connect(host="localhost", user="adminLukas", password="IbdtLmmB.11", database="sensor_data") 
cursor = db.cursor()

class SensorData(Resource):
    def get(self, sensor_id):
        sql = f"SELECT {sensor_id} FROM SensorData"
        try: 
            cursor.execute(sql)
            results = cursor.fetchall()
            temp = [] # DatumUhrzeit geht momentan nict, da es nicht als JSON dirket geht
            for result in results:
                temp.append(result[0])
            return {f"{sensor_id}": temp}
        except:
            print("Error")
            return "Success"

api.add_resource(SensorData, "/alldata/<string:sensor_id>")

if __name__ == "__main__":
    app.run(debug=True)
