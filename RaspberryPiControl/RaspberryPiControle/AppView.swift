//
//  AppView.swift
//  RaspberryPiControle
//
//  Created by Lukas on 05.08.20.
//  Copyright © 2020 LukasKrinke. All rights reserved.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        TabView{
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SensorData()
                .tabItem {
                    Image(systemName: "externaldrive.fill.badge.icloud")
                    Text("Data")
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
