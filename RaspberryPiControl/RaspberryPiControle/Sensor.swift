//
//  Sensor.swift
//  RaspberryPiControle
//
//  Created by Lukas on 05.08.20.
//  Copyright © 2020 LukasKrinke. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct SensorData: View {
    let sensorData = [
        "temp" : "Temperatur",
        "hum" : "Feuchtigkeit",
        "rain" : "Regen"
    ]
    @State private var data = [Data]()
    @State private var selectedData = "temp"
    var body: some View{
        NavigationView{
            VStack{
                Picker(selection: $selectedData, label: Text("Select Data?")) {
                    Text("Temperatur").tag("temp")
                    Text("Feuchtigkeit").tag("hum")
                    Text("Regen").tag("rain")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 10)
                
                /*List(data){ temp in
                    Text("\(temp.data)")
                }*/
                
                LineView(data: getValues(data: data), title: sensorData[selectedData], legend: "Gesamter Zeitraum")
                    .padding()
                
            }
            .navigationTitle("Sensordaten")
            .onAppear{
                ApiCaller.shared.getJSON(key: sensorData[selectedData]!) { (temp) in
                    data = temp
                }
            }
            .onChange(of: selectedData) { (new) in
                ApiCaller.shared.getJSON(key: sensorData[new]!) { (temp) in
                    data = temp
                }
            }
        }
    }
    
    func getValues(data: [Data]) -> [Double]{
        var values = [Double]()
        
        for value in data{
            values.append(value.data)
        }
        return values
    }
}


struct Sensor_Previews: PreviewProvider {
    static var previews: some View {
        SensorData()
    }
}
