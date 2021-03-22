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
    @ObservedObject private var con = Connection()
    
    var body: some View {
        NavigationView{
            VStack{
                ZStack {
                    Form{
                        Section(header: Text("Connection to \(con.serverAddress)")) {
                            Button(action:{
                                con.connect()
                            }) {
                                Text("Connect to server")
                                    .foregroundColor(con.isConnected ? .red : .green)
                            }
                            
                            Button(action:{
                                con.disconnect()
                                
                            }) {
                                Text("Disconnect from server")
                            }
                            .foregroundColor(con.isConnected ? .green : .red)
                        }
                        
                        
                        Section(header: Text("Um wie viel Uhr soll gesprengt werden?")){
                        
                            TextField("Stunde", text: $con.stunde)
                                .keyboardType(.numberPad)
                                .modifier(DismissingKeyboard())
                            TextField("Minute", text: $con.minute)
                                .keyboardType(.numberPad)
                                .modifier(DismissingKeyboard())
                            
                            Button(action: {
                                con.sendTimes(hour: con.stunde, minute: con.minute)
                                print("Speicher")
                            }) {
                            Text("Speichern")
                            }.disabled(con.stunde.isEmpty || con.minute.isEmpty || (Int(con.stunde) ?? 14) > 23 || (Int(con.minute) ?? 15) > 59)
                        
                        }
                        
                        Section(header: Text("Wie lange soll gesprent werden?")){
                            
                            TextField("Dauer", text: $con.duration)
                                .keyboardType(.decimalPad)
                                .modifier(DismissingKeyboard())
                            
                            Button(action: {
                                con.sendDuration(duration: con.duration)
                                print("Speicher")
                            }) {
                            Text("Speichern")
                            }.disabled(con.duration.isEmpty)
                        
                        }
                        
                        Toggle(isOn: $con.isOn){
                            Text(con.isOn ? "On" : "Off")
                        }.onChange(of: con.isOn){ value in
                            con.sendState(state: value)
                        }
                    }
                }
            }
            .alert(isPresented: $con.showAlert){
                Alert(title: Text(con.alertTitel), message: Text(con.alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Raspberry Pi Control")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


