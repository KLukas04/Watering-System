import requests

BASE = "http://127.0.0.1:5000/" #when from another device use: 192.168.2.156

# DatumUhrzeit Temperatur Feuchtigkeit Regen
response = requests.get(BASE + "alldata/Temperatur") #+ "alldata/DatumUhrzeit"
print(response.json())
d = response.json()
x = len(d['data'])
print(x)