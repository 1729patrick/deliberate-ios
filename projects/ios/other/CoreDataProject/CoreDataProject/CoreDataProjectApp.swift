//
//  CoreDataProjectApp.swift
//  CoreDataProject
//
//  Created by Patrick Battisti Forsthofer on 02/02/22.
//

import SwiftUI

@main
struct CoreDataProjectApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
