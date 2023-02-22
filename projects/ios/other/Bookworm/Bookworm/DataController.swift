//
//  DataController.swift
//  Bookworm
//
//  Created by Patrick Battisti Forsthofer on 01/02/22.
//

import CoreData
import Foundation


class DataController: ObservableObject {
//responsible for loading a data model and giving us access to the data inside
//and NSPersistentStoreContainer, which handles loading the actual data we have saved to the user’s device.
//From a modern point of view this sounds strange, but the “NS” part is short for “NeXTSTEP”, which was a huge operating system that Apple acquired when they brought Steve Jobs back into the fold in 1997 – Core Data has some really old foundations!
    let container = NSPersistentContainer(name: "Bookworm")
    
//That tells Core Data we want to use the Bookworm data model. It doesn’t actually load it – we’ll do that in a moment – but it does prepare Core Data to load it. Data models don’t contain our actual data, just the definitions of properties and attributes like we defined a moment ago.
//To actually load the data model we need to call loadPersistentStores() on our container, which tells Core Data to access our saved data according to the data model in Bookworm.xcdatamodeld. This doesn’t load all the data into memory at the same time, because that would be wasteful, but at least Core Data can see all the information we have.
//Anyway, we’re going to write a small initializer for DataController that loads our stored data immediately. If things go wrong – unlikely, but not impossible – we’ll print a message to the Xcode debug log.
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
