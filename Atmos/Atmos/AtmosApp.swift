//
//  AtmosApp.swift
//  Atmos
//
//  Created by Nate de Jager on 2022-06-08.
//

import SwiftUI

@main
struct AtmosApp: App {
    
    @StateObject var atmosphericSettings = AtmosphericSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(atmosphericSettings)
        }
    }
}
