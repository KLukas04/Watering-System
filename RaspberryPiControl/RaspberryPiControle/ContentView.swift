//
//  ContentView.swift
//  RaspberryPiControle
//
//  Created by Lukas on 04.07.20.
//  Copyright © 2020 LukasKrinke. All rights reserved.
//

import SwiftUI
import CocoaMQTT
import Reachability

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: SensorData.entity(), sortDescriptors: []) var sensorData: FetchedResults<SensorData>
    
    @State private var isOn = false
    @State private var stopCrash = 0
    
    @State private var stunde = ""
    @State private var minute = ""
    @State private var switchHourMinute = true
    @State private var duration = ""
    @State private var temperatur = ""
    @State private var bodenfeuchte = ""
    @State private var isConnected = false
    
    @State private var showAlert = false
    @State private var alertTitel = ""
    @State private var alertMessage = ""
    
    var mqttClient = CocoaMQTT(clientID: "ios Device", host: "91.49.183.229", port: 2883)
    let reachability = try! Reachability()
    var serverAddress: String{
        if reachability.connection == .wifi{
            return "192.168.2.156"
        }else{
            return "84.191.197.229"
        }
    }
    var port: Int{
        if reachability.connection == .wifi{
            return 1883
        }else{
            return 2883
        }
    }
    
    init() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        print("ID: \(clientID), Server: \(serverAddress), Port: \(port)")
        mqttClient.keepAlive = 60
        mqttClient.allowUntrustCACertificate = true
        self.mqttClient =  CocoaMQTT(clientID: clientID, host: serverAddress, port: UInt16(port))
        
    }
    
    
    var disabledTimeButton: Bool{
        stunde.isEmpty || minute.isEmpty || Int(stunde) ?? 14 > 23 || Int(minute) ?? 15 > 59
    }
    
    var disabledDurationButton: Bool{
        duration.isEmpty
    }
    var body: some View {
        NavigationView{
            VStack{
                ZStack {
                    Form{
                        Section(header: Text("Connection to \(serverAddress)")) {
                            Button(action:{
                                if self.isConnected == false{
                                    
                                    self.mqttClient.connect()
                                    //self.mqttClient.logLevel = .debug
                                    self.subscribe()
                                    self.mqttClient.willMessage = CocoaMQTTWill(topic: "connection/stop", message: "stop")
                                    
                                    
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
                                        else if message.topic == "ios/temperatur"{
                                            let msg = message.string
                                            if let msgSplit = msg?.split(whereSeparator: {$0 == ","}).map(String.init){
                                                for temperatur in msgSplit{
                                                    if let temperatur = Double(temperatur){
                                                        print(temperatur)
                                                        let sensorData = SensorData(context: self.viewContext)
                                                        sensorData.temperatur = temperatur
                                                        
                                                        try? self.viewContext.save()
                                                    }
                                                }
                                            }else{
                                                self.alertTitel = "Error"
                                                self.alertMessage = "Daten vom Server konnten nicht interpretiert werden"
                                                self.showAlert = true
                                            }
                                        }
                                    }
                                    
                                }else{
                                    self.alertTitel = "Already Connected"
                                    self.alertMessage = "You are already connected to the server"
                                    self.showAlert = true
                                }
                            }) {
                                Text("Connect to server")
                                    .foregroundColor(isConnected ? .red : .green)
                            }
                            
                            Button(action:{
                                if self.isConnected{
                                    let seconds = 0.1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                                        self.mqttClient.disconnect()
                                    }
                                    
                                    self.mqttClient.publish("connection/stop", withString: "stop")
                                    
                                    self.alertTitel = "Disconnected"
                                    self.alertMessage = "You have successfully disconnected from the server"
                                    self.showAlert = true
                                }else{
                                    self.alertTitel = "No Connection"
                                    self.alertMessage = "You aren't connected to the server"
                                    self.showAlert = true
                                }
                                self.isConnected = false
                                
                            }) {
                                Text("Disconnect from server")
                            }
                            .foregroundColor(isConnected ? .green : .red)
                        }
                        
                        
                        Section(header: Text("Um wie viel Uhr soll gesprengt werden?")){
                        
                            TextField("Stunde", text: $stunde)
                                .keyboardType(.numberPad)
                                .modifier(DismissingKeyboard())
                            TextField("Minute", text: $minute)
                                .keyboardType(.numberPad)
                                .modifier(DismissingKeyboard())
                            
                            Button(action: {
                                self.sendTimes(hour: self.stunde, minute: self.minute)
                                print("Speicher")
                            }) {
                            Text("Speichern")
                            }.disabled(disabledTimeButton)
                        
                        }
                        
                        Section(header: Text("Wie lange soll gesprent werden?")){
                            
                            TextField("Dauer", text: $duration)
                                .keyboardType(.numberPad)
                                .modifier(DismissingKeyboard())
                            
                            Button(action: {
                                self.sendDuration(duration: self.duration)
                                print("Speicher")
                            }) {
                            Text("Speichern")
                            }.disabled(disabledDurationButton)
                        
                        }
                        
                        Toggle(isOn: $isOn) {
                            Text(isOn ? "On" : "Off")
                        }.onReceive([isOn].publisher.first()) { (value) in
                            if value == true{
                                self.stopCrash = 1
                            }
                            if self.stopCrash != 0{
                                self.sendState(state: value)
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert){
                Alert(title: Text(self.alertTitel), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Raspberry Pi Control")
        }
    }
    func subscribe(){
        DispatchQueue.main.async {
            if self.isConnected == false{
                print("Error")
                self.alertTitel = "Error"
                self.alertMessage = "Can't connect to the server. Try again!"
                self.showAlert = true
                //self.mqttClient.disconnect()
            }
        }
        
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
    }
    
    func sendState(state: Bool){
        if state{
            mqttClient.publish("rpi/gpio", withString: "on")
            print("Published ON")
        }else{
            mqttClient.publish("rpi/gpio", withString: "off")
            print("Published OFF")
        }
    }
    
    func sendTimes(hour: String, minute: String){
        mqttClient.publish("time", withString: "\(hour):\(minute)")
    }
    
    func sendDuration(duration: String){
        mqttClient.publish("duration", withString: duration)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


