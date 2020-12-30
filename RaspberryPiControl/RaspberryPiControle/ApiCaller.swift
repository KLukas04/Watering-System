//
//  ApiCaller.swift
//  
//
//  Created by Lukas on 30.12.20.
//

import Foundation

class ApiCaller{
    static let shared = ApiCaller()
    
    public func getJSON<T: Get>(key: String, completion: @escaping ([T]) -> ()){
        let urlString = "http://192.168.2.156:5000/alldata/\(key)"

        if let url = URL(string: urlString){
            URLSession.shared.dataTask(with: url){ data, res, err in
                if let data = data{
                    print("hey")

                    let decoder = JSONDecoder()
                    if let json = try? decoder.decode(Response.self, from: data){
                        var object = [T]()
                        for temp in json.data{
                            let entry = T(data: temp)
                            object.append(entry)
                        }
                        completion(object)
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
    let data: [Double]
}
class Data: Identifiable, Get{
    let id = UUID()
    var data: Double
    
    required init(data: Double) {
        self.data = data
    }
}

protocol Get {
    var data: Double {get set}
    init(data: Double)
}