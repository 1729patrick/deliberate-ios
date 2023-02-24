//
//  ComplexNetworkingApp.swift
//  ComplexNetworking
//
//  Created by Patrick Battisti Forsthofer on 24/02/23.
//

import SwiftUI

@main
struct ComplexNetworkingApp: App {
    #if DEBUG
    @State private var networkManager = NetworkManager(environment: .testing)
    #else
    @State private var networkManager = NetworkManager(environment: .production)
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.networkManager, networkManager)
        }
    }
}
