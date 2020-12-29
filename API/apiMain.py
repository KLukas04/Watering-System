from flask import Flask
from flask_restful import Api, Resource
import pymysql

app = Flask(__name__)
api = Api(app)

db = pymysql.connect(host="192.168.2.156", user="adminLukas", password="IbdtLmmB.11", database="sensor_data") 
cursor = db.cursor()

class SensorData(Resource):
    def get(self, sensor_id):
        sql = f"SELECT {sensor_id} FROM SensorData"
        try: 
            cursor.execute(sql)
            results = cursor.fetchall()
            print(results)
            return "Success"
        except:
            print("Error")
            return "Success"

api.add_resource(SensorData, "/alldata/<string:sensor_id>")

if __name__ == "__main__":
    app.run(debug=True)