//
//  Sensor.swift
//  RaspberryPiControle
//
//  Created by Lukas on 05.08.20.
//  Copyright © 2020 LukasKrinke. All rights reserved.
//

import SwiftUI
import SwiftUICharts

struct Sensor: View {
    
    @FetchRequest(entity: SensorData.entity(), sortDescriptors: []) var sensorData: FetchedResults<SensorData>
    /*var disabled: Bool{
        //sensorData.temperatur.isEmpty
    }*/
    @State private var temperatures: [Double] = []
    
    var body: some View {
        VStack(spacing: 20){
            /*List(sensorData, id: \.self){temp in
                Text("\(temp.temperatur)")
            }
            //Text("")*/
            LineView(data: temperatures, title: "Temperatur")
                .padding()
                .frame(height: 500, alignment: .center)
                //.disabled(disabled)
            //LineView(data: self.sensorData.soilmoisture, title: "Bodenfeuchte")
            //.padding()
        }.onAppear{
            for temp in self.sensorData{
                self.temperatures.append(temp.temperatur)
            }
        }
    }
    
}

struct Sensor_Previews: PreviewProvider {
    static var previews: some View {
        Sensor()
    }
}
