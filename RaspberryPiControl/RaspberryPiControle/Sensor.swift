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
    @State private var temperaturen = [Temperatur]()
    var body: some View{
        
        List(temperaturen){ temp in
            Text("\(temp.Temperatur)")
        }
        .onAppear{
            getJSONTemperatur{ (temp) in
                temperaturen = temp
            }
        }
    }
    
    func getJSONTemperatur(completion: @escaping ([Temperatur]) -> ()){
        let urlString = "http://192.168.2.156:5000/alldata/Temperatur"
        
        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url){ data, res, err in
                if let data = data{
                    print("hey")
                    
                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(Response.self, from: data){
                        var temperaturen = [Temperatur]()
                        for temp in json.Temperatur{
                            let temperature = Temperatur(Temperatur: temp)
                            temperaturen.append(temperature)
                        }
                        completion(temperaturen)
                    }else{
                        print("Cant decode")
                    }
                }
            }.resume()
        }else{
            print("Error")
        }
    }
    
}

struct Response: Codable {
    let Temperatur: [Double]
}
struct Temperatur: Codable, Identifiable{
    let id = UUID()
    let Temperatur: Double
}


struct Sensor_Previews: PreviewProvider {
    static var previews: some View {
        SensorData()
    }
}
