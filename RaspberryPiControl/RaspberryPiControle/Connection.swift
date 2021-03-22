//
//  Connection.swift
//  RaspberryPiControle
//
//  Created by Lukas on 29.12.20.
//  Copyright © 2020 LukasKrinke. All rights reserved.
//

import Foundation
import CocoaMQTT
import Reachability

class Connection: ObservableObject{
    var mqttClient: CocoaMQTT = CocoaMQTT(clientID: "", host: "", port: UInt16(0))
    let reachability = try! Reachability()
    
    @Published var port: Int
    @Published var serverAddress: String
    @Published var isOn = false
    @Published var stopCrash = 0
    @Published var isConnected = false
    
    @Published var stunde = ""
    @Published var minute = ""
    @Published var duration = ""
    
    @Published var temperatur = ""
    @Published var bodenfeuchte = ""
    
    @Published var showAlert = false
    @Published var alertTitel = ""
    @Published var alertMessage = ""
    
    init() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        
        serverAddress = reachability.connection == .wifi ? "192.168.2.105" : "91.49.183.11"
        port = reachability.connection == .wifi ? 1883 : 2883
        
        mqttClient =  CocoaMQTT(clientID: clientID, host: serverAddress, port: UInt16(port))
        
        mqttClient.keepAlive = 60
        mqttClient.allowUntrustCACertificate = true
        
        print("ID: \(clientID), Server: \(serverAddress), Port: \(port)")
        
    }
    
    func connect(){
        if !isConnected{
            _ = self.mqttClient.connect()
            print(isConnected)
            
            self.subscribe()
            self.mqttClient.willMessage = CocoaMQTTWill(topic: "connection/stop", message: "stop")
            listen()
        }else{
            alertTitel = "Already Connected"
            alertMessage = "You are already connected to the server"
            showAlert = true
        }
    }
    
    func disconnect(){
        if isConnected{
            let seconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                self.mqttClient.disconnect()
            }
            
            mqttClient.publish("connection/stop", withString: "stop")
            
            alertTitel = "Disconnected"
            alertMessage = "You have successfully disconnected from the server"
            showAlert = true
        }else{
            alertTitel = "No Connection"
            alertMessage = "You aren't connected to the server"
            showAlert = true
        }
        
        isConnected = false
    }
    
    func subscribe(){
        self.mqttClient.didConnectAck = { mqtt, connected in
            if connected.description == "accept"{
                print("Connected")
                self.mqttClient.subscribe("ios/water_now")
                self.mqttClient.subscribe("ios/temperatur")
                
                self.mqttClient.publish("connection/new", withString: "new")
                self.mqttClient.willMessage = CocoaMQTTWill(topic: "connection/stop", message: "stop")
                
                self.isConnected = true
                
                self.alertTitel = "Connected"
                self.alertMessage = "You have successfully connected to the server"
                self.showAlert = true
                
                return
                
            }
        }
        
        print("Error")
        
        self.alertTitel = "Error"
        self.alertMessage = "Can't connect to the server. Try again!"
        self.showAlert = true
    }
    
    func listen(){
        self.mqttClient.didReceiveMessage = { topic, message, id in
            print("Topic \(topic), Message: \(message)")
            if message.topic == "ios/water_now"{
                let msg = message.string
                if let msgSplit = msg?.split(whereSeparator: {$0 == ","}).map(String.init){
                    if msgSplit[0] == "YES"{
                        print("It works")
                        self.temperatur = msgSplit[1]
                        self.bodenfeuchte = msgSplit[2]
                        
                        self.alertTitel = "Es wird nun gesprengt"
                        self.alertMessage = "Die Temperatur beträgt \(self.temperatur) und die Bodenfeuchte liegt bei \(self.bodenfeuchte)."
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    func sendState(state: Bool){
        if isConnected{
            if state{
                mqttClient.publish("rpi/gpio", withString: "on")
                print("Published ON")
            }else{
                mqttClient.publish("rpi/gpio", withString: "off")
                print("Published OFF")
            }
        }
    }
    
    func sendTimes(hour: String, minute: String){
        if isConnected{
            mqttClient.publish("time", withString: "\(hour):\(minute)")
        }
    }
    
    func sendDuration(duration: String){
        if isConnected{
            let d = duration.replacingOccurrences(of: ",", with: ".")
            mqttClient.publish("duration", withString: d)
        }
    }
}
