import requests

BASE = "http://127.0.0.1:5000/"

# DatumUhrzeit Temperatur Feuchtigkeit Regen
response = requests.get(BASE) #+ "alldata/DatumUhrzeit"
print(response.json())
