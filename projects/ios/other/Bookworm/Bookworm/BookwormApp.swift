//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Patrick Battisti Forsthofer on 01/02/22.
//

import SwiftUI

@main
struct BookwormApp: App {
    @StateObject private var dataController = DataController()
    
//managed object contexts. These are effectively the “live” version of your data – when you load objects and change them, those changes only exist in memory until you specifically save them back to the persistent store.
//So, the job of the view context is to let us work with all our data in memory, which is much faster than constantly reading and writing data to disk. When we’re ready we still do need to write changes out to persistent store if we want them to be there when our app runs next, but you can also choose to discard changes if you don’t want them.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
