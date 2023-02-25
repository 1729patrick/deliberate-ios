//
//  CloudDefaultsApp.swift
//  CloudDefaults
//
//  Created by Patrick Battisti Forsthofer on 25/02/23.
//

import SwiftUI

@main
struct CloudDefaultsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    CloudDefaults.shared.start()
                }
        }
    }
}
